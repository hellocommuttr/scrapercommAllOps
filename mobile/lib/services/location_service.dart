import 'package:geolocator/geolocator.dart';

enum LocationProblem { serviceOff, denied, deniedForever, unavailable }

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
    null => '',
  };
}

/// One-off location lookups, only when the commuter asks ("Use my location",
/// "Nearby stops"). No background tracking: trip progress runs on the timetable clock.
class LocationService {
  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return const LocationResult.failed(LocationProblem.serviceOff);
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return const LocationResult.failed(LocationProblem.denied);
      if (perm == LocationPermission.deniedForever) return const LocationResult.failed(LocationProblem.deniedForever);
      final last = await Geolocator.getLastKnownPosition().catchError((_) => null);
      final pos =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 12),
            ),
          ).catchError((Object e) {
            if (last != null) return last;
            throw e;
          });
      return LocationResult.ok(pos.latitude, pos.longitude);
    } catch (_) {
      return const LocationResult.failed(LocationProblem.unavailable);
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}
