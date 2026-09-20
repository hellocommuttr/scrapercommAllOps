import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../data/models/models.dart';
import '../../../services/favourites_service.dart';
import '../../../services/reference_data_service.dart';
import '../../../services/shell_service.dart';
import '../../../services/support_service.dart';

/// One banner in "Partner offers", from `assets/content/partner_offers.json`.
class PartnerOffer {
  const PartnerOffer({required this.headline, required this.body, required this.cta, required this.url, this.icon});

  factory PartnerOffer.fromJson(Json j) => PartnerOffer(
    headline: (j['headline'] as String?) ?? '',
    body: (j['body'] as String?) ?? '',
    cta: (j['cta'] as String?) ?? 'Learn more',
    url: (j['url'] as String?) ?? '',
    icon: j['icon'] as String?,
  );

  final String headline;
  final String body;
  final String cta;

  /// A web page, or `app://help` for a screen inside Commuttr.
  final String url;

  /// 'bus', 'train' or 'tips': which artwork the banner draws.
  final String? icon;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    return q.isNotEmpty && '$headline $body'.toLowerCase().replaceAll('\n', ' ').contains(q);
  }
}

/// A row in "Popular routes": a trip the commuter searches often, or a starter pair.
class PopularRoute {
  const PopularRoute({required this.from, required this.to, required this.via, this.duration});

  final Endpoint from;
  final Endpoint to;

  /// "via Golden Arrow", built only from what the endpoints tell us.
  final String via;

  /// "28 min" when a duration is known; nothing is estimated here.
  final String? duration;

  String get title => '${from.displayName} → ${to.displayName}';

  bool get isTrain => from.isStation && to.isStation;
}

/// The Explore tab: route search over the on-device catalogue (buses and trains), shortcuts, partner offers,
/// operators and popular routes. Everything here works offline.
class ExploreViewModel extends BaseViewModel {
  ExploreViewModel() {
    // Home records searches while this tab sits in the IndexedStack; keep the list current.
    _favourites.addListener(_onFavouritesChanged);
  }

  static const offersAsset = 'assets/content/partner_offers.json';

  /// Popular routes shown on the tab; "See all" lists the rest.
  static const popularOnTab = 3;

  final _nav = locator<NavigationService>();
  final _reference = locator<ReferenceDataService>();
  final _favourites = locator<FavouritesService>();
  final _shell = locator<ShellService>();
  final _support = locator<SupportService>();

  String query = '';
  List<RouteSummary> results = const [];
  List<RouteSummary> allRoutes = const [];
  List<PartnerOffer> offers = const [];
  List<PopularRoute> popular = const [];

  /// Operators with timetables in Commuttr.
  List<OperatorRef> operators = const [OperatorRef.goldenArrow];

  /// Guards against a slow earlier query overwriting a newer one's results.
  int _searchSeq = 0;

  bool get isSearching => query.trim().isNotEmpty;

  List<PartnerOffer> get offerResults => offers.where((o) => o.matches(query)).toList();

  List<PopularRoute> get popularShown => popular.take(popularOnTab).toList();

  /// Golden Arrow or Metrorail as the catalogue names them, falling back to the built-in reference.
  OperatorRef operatorFor(OperatorRef fallback) =>
      operators.where((o) => o.code == fallback.code).firstOrNull ?? fallback;

  Future<void> init() async {
    setBusy(true);
    await Future.wait([reloadRoutes(), _loadOperators(), _loadPopular(), _loadOffers()]);
    setBusy(false);
  }

  Future<void> _loadOperators() async {
    try {
      final found = await _reference.operators();
      if (found.isNotEmpty) operators = found;
    } catch (_) {
      // Keep Golden Arrow, which is always there.
    }
    rebuildUi();
  }

  Future<void> _loadOffers() async {
    try {
      final raw = jsonDecode(await rootBundle.loadString(offersAsset)) as List;
      offers = raw.cast<Json>().map(PartnerOffer.fromJson).where((o) => o.headline.isNotEmpty).toList();
    } catch (_) {
      offers = const [];
    }
    rebuildUi();
  }

  /// Re-reads the route catalogue; a background refresh may have replaced it since launch.
  Future<List<RouteSummary>> reloadRoutes() async {
    try {
      allRoutes = await _reference.searchRoutes('');
    } catch (_) {
      // Keep what we had.
    }
    rebuildUi();
    return allRoutes;
  }

  /// One operator's routes, fresh from the catalogue.
  Future<List<RouteSummary>> routesFor(OperatorRef operator) async {
    final all = await reloadRoutes();
    return all.where((r) => r.operatorCode == operator.code).toList();
  }

  // ---------------------------------------------------------------- popular routes

  Future<void> _loadPopular() async {
    List<TripPair> trips;
    try {
      trips = await _favourites.frequentTrips(limit: 20);
    } catch (_) {
      trips = const [];
    }
    popular = trips.isNotEmpty
        ? [for (final t in trips) PopularRoute(from: t.from, to: t.to, via: _via(t.from, t.to))]
        : await _starters();
    rebuildUi();
  }

  void _onFavouritesChanged() => _loadPopular();

  /// "via Golden Arrow", "via Metrorail", or both for a trip that changes mode. Dropped pins say nothing.
  static String _via(Endpoint from, Endpoint to) {
    final names = <String>{
      for (final e in [from, to])
        if (e.isStop) OperatorRef.from(e.operatorCode, kind: e.operatorKind).name,
    };
    return names.isEmpty ? '' : 'via ${names.join(' + ')}';
  }

  /// Real pairs from the catalogue for a commuter who has not searched yet.
  Future<List<PopularRoute>> _starters() async {
    const pairs = [
      ('BELLVILLE', 'CAPE TOWN', 'gabs'),
      ('CAPE TOWN', 'BELLVILLE', 'metrorail'),
      ('CAPE TOWN', 'BELLVILLE', 'gabs'),
    ];
    final out = <PopularRoute>[];
    for (final (a, b, op) in pairs) {
      final from = await _stop(a, op);
      final to = await _stop(b, op);
      if (from == null || to == null) continue;
      out.add(PopularRoute(from: from, to: to, via: 'via ${OperatorRef.from(op).name}'));
    }
    return out;
  }

  /// The stop or station called exactly [name], run by [operatorCode].
  Future<Endpoint?> _stop(String name, String operatorCode) async {
    try {
      final found = await _reference.searchStops(name, limit: 200);
      final s = found
          .where(
            (s) => s.operatorCode == operatorCode && s.name.toUpperCase() == name && s.lat != null && s.lon != null,
          )
          .firstOrNull;
      if (s == null) return null;
      return Endpoint.stop(
        id: s.id,
        name: s.name,
        lat: s.lat!,
        lon: s.lon!,
        operatorCode: s.operatorCode,
        operatorKind: s.operatorKind,
      );
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------- search

  Future<void> search(String value) async {
    query = value;
    final seq = ++_searchSeq;
    if (!isSearching) {
      results = const [];
      rebuildUi();
      return;
    }
    rebuildUi();
    final found = await _reference.searchRoutes(value);
    if (seq != _searchSeq) return;
    results = found;
    rebuildUi();
  }

  void clearSearch() => search('');

  // ---------------------------------------------------------------- navigation

  void openRoute(RouteSummary route) => _nav.navigateToRouteDetailView(routeId: route.id);

  void openNearbyStops() => _nav.navigateToNearbyStopsView();

  void openFavourites() => _nav.navigateToFavouritesView();

  void openNotifications() => _nav.navigateToNotificationsView();

  void openPopular(PopularRoute route) => _shell.searchOnHome(route.from, route.to);

  /// A web page in the browser, or a screen inside the app.
  Future<void> openOffer(PartnerOffer offer) async {
    if (offer.url == 'app://help') {
      await _nav.navigateToHelpView();
    } else if (offer.url.startsWith('http')) {
      await _support.openUrl(offer.url);
    }
  }

  @override
  void dispose() {
    _favourites.removeListener(_onFavouritesChanged);
    super.dispose();
  }
}
