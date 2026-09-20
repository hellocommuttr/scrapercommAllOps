import 'package:flutter/foundation.dart';

/// Build-time configuration, supplied with `--dart-define-from-file=env/<flavor>.json`.
///
/// Nothing here is a secret: the API is public and read-only.
abstract final class AppConfig {
  static const _apiBaseUrlDefine = String.fromEnvironment('API_BASE_URL');

  /// Where Commuttr's support mail goes. Shown to users, so it must be real before release.
  static const supportEmail = String.fromEnvironment('SUPPORT_EMAIL', defaultValue: 'support@commuttr.co.za');

  /// Golden Arrow's own site: fares, disruptions, lost property and complaints belong
  /// there, not with Commuttr. We link to it rather than copying contact details that
  /// could go stale.
  static const goldenArrowUrl = 'https://www.gabs.co.za';

  /// Commuttr's support phone line and live-chat link. Set these in `env/<flavor>.json`
  /// before release; while empty the Help screen says the channel is not open yet
  /// rather than dialling a number nobody answers.
  static const supportPhone = String.fromEnvironment('SUPPORT_PHONE');
  static const supportChatUrl = String.fromEnvironment('SUPPORT_CHAT_URL');

  /// Support hours shown next to the chat and phone rows.
  static const supportHours = String.fromEnvironment('SUPPORT_HOURS', defaultValue: '08:00 – 20:00');

  /// Metrorail's (PRASA's) own site: tickets, service notices and complaints about trains.
  static const metrorailUrl = 'https://www.metrorail.co.za';

  /// SAPS emergency number — a national number, safe to hard-code.
  static const sapsEmergency = '10111';

  static const appName = 'Commuttr';

  /// The API origin. An explicit define always wins; otherwise pick the address a local
  /// `mvn spring-boot:run` is reachable on from each platform.
  static String get apiBaseUrl {
    if (_apiBaseUrlDefine.isNotEmpty) return _stripSlash(_apiBaseUrlDefine);
    if (kIsWeb) {
      // Served by the Spring app itself: same origin. From `flutter run -d chrome` the
      // page lives on a random port, so fall back to the API's default port.
      final origin = Uri.base.origin;
      return Uri.base.port == 8000 ? origin : 'http://localhost:8000';
    }
    // The Android emulator reaches the host machine through 10.0.2.2.
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  static String _stripSlash(String s) => s.endsWith('/') ? s.substring(0, s.length - 1) : s;
}
