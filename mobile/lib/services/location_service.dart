import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

enum LocationProblem { serviceOff, denied, deniedForever, unavailable, insecureOrigin }

class LocationResult {
  const LocationResult.ok(double this.lat, double this.lon) : problem = null;
  const LocationResult.failed(LocationProblem this.problem) : lat = null, lon = null;

  final double? lat;
  final double? lon;
  final LocationProblem? problem;

  bool get ok => problem == null;

  String get message => switch (problem) {
    LocationProblem.serviceOff => 'Location is switched off. Turn it on, or pick your stop from the list.',
    LocationProblem.denied => 'Commuttr needs location permission to find stops near you.',
    LocationProblem.deniedForever =>
      'Location permission is blocked. You can allow it in your phone settings, or pick your stop from the list.',
    LocationProblem.unavailable => "We couldn't get your location. Pick your stop from the list instead.",
    LocationProblem.insecureOrigin =>
      'Browsers only share your location over a secure (https) connection. Open Commuttr over https, or pick '
          'your stop from the list.',
    null => '',
  };
}

/// One-off location lookups, only when the commuter asks ("Use my location",
/// "Nearby stops"). No background tracking: trip progress runs on the timetable clock.
class LocationService {
  Future<LocationResult> current() async {
    try {
      // On the web a browser refuses location outright unless the page came over https
      // (localhost excepted), and it refuses it as PERMISSION_DENIED - indistinguishable
      // from the rider having said no. That sent them to "pick your stop from the list",
      // which is useless advice when the fix is the address bar. Said plainly instead.
      //
      // navigator.geolocation still EXISTS on an insecure origin, so nothing before the
      // call reveals this; only the error does, and by then it looks like a refusal.
      if (kIsWeb && Uri.base.scheme == 'http' && !_localhost(Uri.base.host)) {
        return const LocationResult.failed(LocationProblem.insecureOrigin);
      }
      if (!await Geolocator.isLocationServiceEnabled()) return const LocationResult.failed(LocationProblem.serviceOff);
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return const LocationResult.failed(LocationProblem.denied);
      if (perm == LocationPermission.deniedForever) return const LocationResult.failed(LocationProblem.deniedForever);
      // getLastKnownPosition is NOT supported on the web, and geolocator_web does not
      // reject a future for it - it throws SYNCHRONOUSLY:
      //
      //   Future<Position> getLastKnownPosition({...}) => throw _unsupported(...)
      //
      // so there is no future for .catchError to attach to and the throw went straight
      // past it to the catch below. Every web request for a location failed there, before
      // getCurrentPosition was ever called, and the rider was told we could not get their
      // location no matter what they allowed.
      //
      // A real try/catch rather than .catchError, because only that catches both.
      Position? last;
      if (!kIsWeb) {
        try {
          last = await Geolocator.getLastKnownPosition();
        } catch (_) {
          last = null;
        }
      }
      Position pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 12),
          ),
        );
      } catch (e) {
        // A last known fix is better than nothing when the live one times out; on the web
        // there is never one, so the failure is reported honestly instead.
        if (last == null) rethrow;
        pos = last;
      }
      return LocationResult.ok(pos.latitude, pos.longitude);
    } catch (_) {
      return const LocationResult.failed(LocationProblem.unavailable);
    }
  }

  /// Browsers treat localhost as secure however it is served, so testing at
  /// http://localhost works and only a LAN address or a real http host is refused.
  static bool _localhost(String host) => host == 'localhost' || host == '127.0.0.1' || host == '::1';

  Future<void> openSettings() => Geolocator.openAppSettings();
}
