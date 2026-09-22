import 'package:commuttr/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('offline', () {
    test('a request with no network marks the app offline', () {
      final c = ConnectivityService()..reportSuccess();
      c.reportOffline();
      expect(c.isOffline, isTrue);
    });

    test('one slow request straight after others came back is not offline', () {
      // Searching from a place: the plans came back, the search for journeys with a
      // change took longer than the timeout, and the rider was told they were offline.
      final c = ConnectivityService()..reportSuccess();
      c.reportOffline(timedOut: true);
      expect(c.isOffline, isFalse);
    });

    test('timeouts with nothing ever coming back are offline', () {
      final c = ConnectivityService();
      c.reportOffline(timedOut: true);
      expect(c.isOffline, isTrue);
    });
  });
}
