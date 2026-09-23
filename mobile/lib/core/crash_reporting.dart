import 'dart:async';

import 'package:flutter/foundation.dart';

import '../app/app.locator.dart';
import '../services/cached_api_service.dart';
import '../services/support_service.dart';

/// Tell us when the app breaks, without telling anybody else.
///
/// Commuttr promises riders no third-party trackers and no analytics SDKs. That is the
/// right promise and it rules out Crashlytics, Sentry and the rest - which is how most
/// apps find out a build is broken. Without something, the first news of a crash is a
/// one-star review from somebody standing at a bus stop.
///
/// So the app reports its own uncaught errors to the Commuttr API, over the same switch
/// and the same anonymous id as everything else. What goes: the error, the top frames,
/// the app version and the platform. What does not: anything on the screen, anywhere the
/// rider searched, or anything identifying them.
class CrashReporting {
  /// Frames past this say nothing a fix needs, and carry the risk of saying too much.
  static const _framesKept = 12;

  /// One report per distinct error per run. A widget that throws on every rebuild would
  /// otherwise send hundreds, from a phone whose data the rider paid for.
  static final Set<String> _seen = <String>{};

  static void install() {
    final flutterHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      flutterHandler?.call(details);
      report(details.exception, details.stack, kind: 'flutter');
    };

    // Anything thrown outside the framework: a future nobody awaited, a stream with no
    // error handler. Returning true says we have dealt with it.
    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack, kind: 'zone');
      return true;
    };
  }

  static void report(Object error, StackTrace? stack, {String kind = 'flutter'}) {
    final message = error.toString();
    if (!_seen.add('$kind|$message')) return;

    // Debug builds go to the console, where whoever is looking at them already is.
    if (kDebugMode) {
      debugPrint('Commuttr $kind error: $message');
      return;
    }

    unawaited(() async {
      try {
        final support = locator<SupportService>();
        locator<CachedApiService>().reportUsage({
          'kind': 'app_error',
          'message': message,
          'where': _topFrames(stack),
          'app_version': await support.appVersion(),
          'platform': support.platformName,
        });
      } catch (_) {
        // A crash reporter that throws is worse than none.
      }
    }());
  }

  static String? _topFrames(StackTrace? stack) {
    if (stack == null) return null;
    final lines = stack.toString().split('\n');
    return lines.take(_framesKept).join('\n');
  }
}
