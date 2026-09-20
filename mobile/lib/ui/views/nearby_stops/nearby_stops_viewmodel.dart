import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../data/models/models.dart';
import '../../../services/favourites_service.dart';
import '../../../services/location_service.dart';
import '../../../services/reference_data_service.dart';
import '../../../services/shell_service.dart';
import '../../../services/support_service.dart';

/// A bus stop or train station and how far it is, in a straight line.
class NearbyStop {
  const NearbyStop(this.stop, this.metres);

  final StopDto stop;
  final double metres;

  /// Average walking pace used for the estimate.
  static const metresPerMinute = 80.0;

  /// "Wynberg" or "Wynberg station".
  String get name => stop.displayName;

  OperatorRef get operator => OperatorRef.from(stop.operatorCode, kind: stop.operatorKind);

  /// "stop" / "station".
  String get kindWord => stop.isStation ? 'station' : 'stop';

  String get distanceLabel {
    if (metres < 1000) return '${(metres / 10).round() * 10} m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  int get walkMinutes => (metres / metresPerMinute).ceil().clamp(1, 9999);

  String get walkLabel => '~$walkMinutes min walk';
}

/// Which places the list shows.
enum StopFilter { all, bus, train }

/// Nearby stops and stations: one location fix, only when asked, matched against the
/// stops saved on the device — so it works without data.
class NearbyStopsViewModel extends BaseViewModel {
  /// Rows shown per filter.
  static const shown = 15;

  final _location = locator<LocationService>();
  final _reference = locator<ReferenceDataService>();
  final _favourites = locator<FavouritesService>();
  final _support = locator<SupportService>();

  LocationResult? failure;

  /// Every saved stop and station, nearest first; null until located.
  List<NearbyStop>? _all;
  StopFilter filter = StopFilter.all;

  bool get hasResult => _all != null;

  /// The closest [shown] places matching [filter]; null until located.
  List<NearbyStop>? get stops {
    final all = _all;
    if (all == null) return null;
    return all
        .where(
          (s) => switch (filter) {
            StopFilter.all => true,
            StopFilter.bus => !s.stop.isStation,
            StopFilter.train => s.stop.isStation,
          },
        )
        .take(shown)
        .toList();
  }

  void setFilter(StopFilter f) {
    filter = f;
    rebuildUi();
  }

  Future<void> locate() async {
    failure = null;
    setBusy(true);
    final result = await _location.current();
    if (!result.ok) {
      failure = result;
      setBusy(false);
      return;
    }
    try {
      // Every stop is scored anyway; keep them all so each filter has its own nearest few
      // (stations are far fewer than bus stops and would rarely make an overall top 15).
      final rows = await _reference.nearestStops(result.lat!, result.lon!, limit: 1 << 30);
      _all = [for (final (s, d) in rows) NearbyStop(s, d)];
    } catch (_) {
      failure = const LocationResult.failed(LocationProblem.unavailable);
    }
    setBusy(false);
  }

  bool get canOpenSettings => failure?.problem == LocationProblem.deniedForever;

  Future<void> openSettings() => _location.openSettings();

  /// Saves the stop as Home or Work. Returns false when the stop has no coordinates.
  Future<bool> saveAs(NearbyStop s, PlaceKind kind) async {
    final e = s.stop.endpoint;
    if (e == null) return false;
    await _favourites.setPlace(kind, e);
    return true;
  }

  /// Go to Home with this stop as the starting point.
  void planFrom(NearbyStop s) {
    final e = s.stop.endpoint;
    if (e == null) return;
    locator<NavigationService>().popUntil((route) => route.isFirst);
    locator<ShellService>().planFrom(e);
  }

  Future<void> openInMaps(NearbyStop s) async {
    final lat = s.stop.lat, lon = s.stop.lon;
    if (lat == null || lon == null) return;
    await _support.openUrl('https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=18/$lat/$lon');
  }
}
