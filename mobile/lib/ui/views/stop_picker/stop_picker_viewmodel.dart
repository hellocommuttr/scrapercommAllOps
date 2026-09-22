import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../data/models/models.dart';
import '../../../services/cached_api_service.dart';
import '../../../services/favourites_service.dart';
import '../../../services/journey_service.dart';
import '../../../services/location_service.dart';
import '../../../services/reference_data_service.dart';

/// Choose a start or end point: a bus stop or train station (searchable offline), a saved place,
/// a recent one, your location, or — online — any address.
class StopPickerViewModel extends BaseViewModel {
  final _nav = locator<NavigationService>();
  final _ref = locator<ReferenceDataService>();
  final _favourites = locator<FavouritesService>();
  final _journeys = locator<JourneyService>();
  final _location = locator<LocationService>();

  String query = '';
  List<StopDto> stops = [];
  List<SavedPlace> places = [];
  List<Endpoint> recents = [];
  List<GeoHit> addresses = [];
  bool searchingAddresses = false;
  String? addressMessage;

  bool locating = false;
  String? locationMessage;
  List<(StopDto, double)> nearby = [];
  (double, double)? myLocation;

  Timer? _debounce;
  int _geoRequest = 0;

  Future<void> init() async {
    places = await _favourites.places();
    final seen = <String>{};
    for (final t in await _favourites.recentSearches(limit: 10)) {
      for (final e in [t.from, t.to]) {
        if (seen.add(e.cacheKey)) recents.add(e);
      }
    }
    recents = recents.take(6).toList();
    stops = await _ref.searchStops('', limit: 400);
    rebuildUi();
  }

  void onQueryChanged(String value) {
    query = value;
    _debounce?.cancel();
    unawaited(_searchStops());
    addresses = [];
    addressMessage = null;
    if (value.trim().length >= 3) {
      // The address search goes through our API to OpenStreetMap, which allows about one
      // request a second — so wait until typing pauses.
      _debounce = Timer(const Duration(milliseconds: 700), _searchAddresses);
    }
    rebuildUi();
  }

  Future<void> _searchStops() async {
    stops = await _ref.searchStops(query, limit: query.trim().isEmpty ? 400 : 40);
    rebuildUi();
  }

  Future<void> _searchAddresses() async {
    final request = ++_geoRequest;
    searchingAddresses = true;
    rebuildUi();
    try {
      // The API already keeps to Cape Town. Adding ", Cape Town" here stopped its own list
      // of places matching at all, so "Cape Town" and "Buh Rein" never came back as places.
      final hits = await _journeys.geocode(query.trim());
      if (request != _geoRequest) return;
      addresses = hits.take(5).toList();
      addressMessage = hits.isEmpty && stops.isEmpty ? 'No places found.' : null;
    } on NotAvailableOffline {
      if (request != _geoRequest) return;
      addressMessage = 'Searching for addresses needs a connection. Stops and stations still work offline.';
    } catch (_) {
      if (request != _geoRequest) return;
      addressMessage = "Address search isn't available right now.";
    } finally {
      if (request == _geoRequest) {
        searchingAddresses = false;
        rebuildUi();
      }
    }
  }

  Future<void> useMyLocation() async {
    locating = true;
    locationMessage = null;
    rebuildUi();
    final r = await _location.current();
    locating = false;
    if (!r.ok) {
      locationMessage = r.message;
      rebuildUi();
      return;
    }
    myLocation = (r.lat!, r.lon!);
    // The closest few, then each other operator's closest: the three nearest stops are
    // usually all Golden Arrow, which hid the station a rider could also walk to.
    final closest = await _ref.nearestStops(r.lat!, r.lon!, limit: 3);
    final perOperator = await _ref.nearestStopPerOperator(
      r.lat!,
      r.lon!,
      maxMetres: JourneyService.maxNearestStopM.toDouble(),
    );
    final ids = {for (final (s, _) in closest) s.id};
    nearby = [...closest, ...perOperator.where((p) => !ids.contains(p.$1.id))];
    rebuildUi();
  }

  Future<void> openLocationSettings() => _location.openSettings();

  void pickStop(StopDto s) {
    final e = s.endpoint;
    if (e != null) _nav.back(result: e);
  }

  void pickEndpoint(Endpoint e) => _nav.back(result: e);

  void pickAddress(GeoHit h) => _nav.back(
    result: Endpoint.pin(name: h.name, lat: h.lat, lon: h.lon),
  );

  void pickMyLocation() {
    final l = myLocation;
    if (l == null) return;
    _nav.back(
      result: Endpoint.pin(name: 'My location', lat: l.$1, lon: l.$2),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
