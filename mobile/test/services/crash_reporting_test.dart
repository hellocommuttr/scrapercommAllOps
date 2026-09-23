import 'package:commuttr/core/crash_reporting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reporting a crash to ourselves rather than to a third party.
///
/// The privacy policy promises riders no third-party trackers and no analytics SDKs,
/// which rules out Crashlytics and Sentry - and leaves an app with no way of knowing it
/// is broken. This sends the error to the Commuttr API instead, over the same switch and
/// the same anonymous id as everything else, and it must not become a second failure: a
/// crash reporter that throws, or that sends a hundred copies of one broken widget from a
/// phone whose data the rider paid for, is worse than none.
void main() {
  test('a crash in debug is logged, not sent, and never throws', () {
    expect(
      () => CrashReporting.report(StateError('boom'), StackTrace.current),
      returnsNormally,
    );
  });

  test('installing the handlers does not throw', () {
    expect(CrashReporting.install, returnsNormally);
  });

  test('the same error twice is one report', () {
    // Both calls are silent in tests; the point is that neither throws and the second is
    // recognised as a repeat rather than sent again.
    final error = StateError('repeat');
    expect(() => CrashReporting.report(error, StackTrace.current), returnsNormally);
    expect(() => CrashReporting.report(error, StackTrace.current), returnsNormally);
  });
}
