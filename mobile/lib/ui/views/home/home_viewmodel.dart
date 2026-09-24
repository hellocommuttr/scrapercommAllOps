import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.bottomsheets.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/service_day.dart';
import '../../../data/api/commuttr_api.dart';
import '../../../data/models/models.dart';
import '../../../services/cached_api_service.dart';
import '../../../services/favourites_service.dart';
import '../../../services/journey_service.dart';
import '../../../services/planner_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/shell_service.dart';
import '../../../services/support_service.dart';
import '../../bottom_sheets/filters/filters_sheet.dart';
import '../../dialogs/onboarding/show_onboarding.dart';
import '../../../services/reference_data_service.dart';

enum SearchProblem { notSavedOffline, server, rejected, busy }

/// What the "Your planner" card shows: the next planned journey, or — when the planner is
/// empty — the top recommended route, so "Start journey" is always one tap away.
typedef PlannerCardData = ({
  OperatorRef operator,
  String routeNumber,
  Endpoint from,
  Endpoint to,
  String boardTime,
  String? arriveTime,
  bool planned,
});

/// The commuter's usual trip between Home and Work, and the next buses or trains on it.
class CommuteSnapshot {
  const CommuteSnapshot({
    required this.from,
    required this.to,
    required this.rides,
    this.fromCache = false,
    this.unavailable = false,
  });

  final Endpoint from;
  final Endpoint to;
  final List<Ride> rides;
  final bool fromCache;
  final bool unavailable;
}

class HomeViewModel extends BaseViewModel {
  final _nav = locator<NavigationService>();
  final _sheets = locator<BottomSheetService>();
  final _journeys = locator<JourneyService>();
  final _favourites = locator<FavouritesService>();
  final _planner = locator<PlannerService>();
  final _settings = locator<SettingsService>();
  final _shell = locator<ShellService>();
  final _clock = const SastClock();

  Endpoint? from;
  Endpoint? to;
  SearchFilters filters = const SearchFilters();

  bool searching = false;
  JourneySearchOutcome? outcome;
  SearchProblem? problem;
  String? problemDetail;
  bool showAll = false;

  /// Trips with a change past the first one, which is all that shows until asked.
  bool showAllConnections = false;
  bool tripSaved = false;

  SavedPlace? home;
  SavedPlace? work;
  CommuteSnapshot? commute;
  bool commuteReversed = false;
  PlannedJourney? nextPlanned;
  List<TripPair> savedTrips = [];
  List<TripPair> frequent = [];

  String get displayName => _settings.displayName;

  /// Profile photo bytes (base64), for the header avatar.
  String? get photoBase64 => _settings.photoBase64;
  bool get canSearch => from != null && to != null && from != to;

  String get greeting {
    final h = _clock.wallClock.hour;
    final part = h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
    return displayName.isEmpty ? part : '$part, ${displayName.split(' ').first}';
  }

  String get whenLabel {
    final date = filters.date;
    final day = date == null ? '' : '${formatDayRelative(date, _clock.today)}, ';
    if (filters.arriveBy != null) return '${day}arrive by ${formatMinutes(filters.arriveBy!)}';
    if (isAllDay) return date == null ? 'All day' : '${day}all day';
    if (filters.departAfter != null) return '${day}leave after ${formatMinutes(filters.departAfter!)}';
    return date == null ? 'Leave now' : '${formatDayRelative(date, _clock.today)}, any time';
  }

  List<Ride> get visibleRides {
    final all = outcome?.rides ?? const <Ride>[];
    return showAll ? all : all.take(5).toList();
  }

  double minutesUntil(Ride r) => _clock.minutesUntil(r.date, r.boardMinutes);

  Future<void> init() async {
    // The first thing a new commuter sees; never wait on data loading for it.
    if (!_settings.onboardingSeen) unawaited(showOnboarding());
    await _applyDefaults();
    _shell.addListener(_onShell);
    _favourites.addListener(_reloadSide);
    _planner.addListener(_reloadSide);
    _settings.addListener(rebuildUi);
    await _reloadSide();
    _onShell();
    await _prefill();
  }

  /// Open on a trip the commuter makes, like the designs do: Home to Work (or back,
  /// after noon), else the most recent search. Nothing is filled in on a first launch.
  Future<void> _prefill() async {
    if (from != null || to != null) return;
    final h = home?.endpoint, w = work?.endpoint;
    if (h != null && w != null && h != w) {
      final toWork = _clock.wallClock.hour < 12;
      from = toWork ? h : w;
      to = toWork ? w : h;
    } else {
      final recent = await _favourites.recentSearches(limit: 1);
      if (recent.isEmpty) return;
      from = recent.first.from;
      to = recent.first.to;
    }
    await search();
  }

  /// Searches start from the Profile preferences: preferred operators and depart time.
  Future<void> _applyDefaults() async {
    final preferred = _settings.preferredOperators;
    var excluded = <String>{};
    if (preferred.isNotEmpty) {
      final all = await locator<ReferenceDataService>().operators();
      excluded = all.map((o) => o.code).where((c) => !preferred.contains(c)).toSet();
    }
    filters = filters.copyWith(excludedOperators: excluded, departAfter: () => _settings.defaultDepartMinutes);
  }

  /// Depart now / depart at / arrive by, from the "Depart now ▾" control.
  /// Every departure that day, from the first to the last.
  bool get isAllDay => filters.departAfter == 0 && filters.arriveBy == null;

  Future<void> setAllDay() => setWhen(departAt: 0);

  Future<void> setWhen({int? departAt, int? arriveBy}) async {
    filters = filters.copyWith(departAfter: () => departAt, arriveBy: () => arriveBy);
    rebuildUi();
    if (canSearch) await search();
  }

  void _onShell() {
    final start = _shell.pendingFrom;
    if (start != null) {
      _shell.pendingFrom = null;
      from = start;
      unawaited(_afterEndpointChange());
    }
    final pending = _shell.pendingSearch;
    if (pending != null) {
      _shell.pendingSearch = null;
      from = pending.$1;
      to = pending.$2;
      unawaited(search());
    }
  }

  Future<void> _reloadSide() async {
    home = await _favourites.place(PlaceKind.home);
    work = await _favourites.place(PlaceKind.work);
    savedTrips = await _favourites.savedTrips();
    frequent = await _favourites.frequentTrips(limit: 4);
    final upcoming = await _planner.upcoming(_clock.today, limit: 10);
    nextPlanned = upcoming.where((j) => j.date != _clock.today || j.boardMinutes >= _clock.minutesNow - 5).firstOrNull;
    if (from != null && to != null) tripSaved = await _favourites.isSaved(from!, to!);
    rebuildUi();
    unawaited(_loadCommute());
  }

  Future<void> _loadCommute() async {
    final h = home?.endpoint, w = work?.endpoint;
    if (h == null || w == null || h == w) {
      commute = null;
      rebuildUi();
      return;
    }
    // Mornings go to work, afternoons come home — unless the commuter flipped it.
    final toWork = (_clock.wallClock.hour < 12) != commuteReversed;
    final a = toWork ? h : w, b = toWork ? w : h;
    try {
      final o = await _journeys.search(a, b, const SearchFilters(), pin: true);
      // Each operator's best first, as on the results, then the next soonest to fill three.
      final best = o.bestPerOperator;
      final rides = [...best, ...o.rides.where((r) => !best.contains(r))].take(3).toList()
        ..sort((x, y) => o.rides.indexOf(x).compareTo(o.rides.indexOf(y)));
      commute = CommuteSnapshot(from: a, to: b, rides: rides, fromCache: o.fromCache);
    } catch (_) {
      commute = CommuteSnapshot(from: a, to: b, rides: const [], unavailable: true);
    }
    rebuildUi();
  }

  void flipCommute() {
    commuteReversed = !commuteReversed;
    unawaited(_loadCommute());
  }

  void searchCommute() {
    final c = commute;
    if (c == null) return;
    from = c.from;
    to = c.to;
    unawaited(search());
  }

  Future<void> pickFrom() async {
    final e = await _nav.navigateToStopPickerView(title: 'From');
    if (e is Endpoint) {
      from = e;
      await _afterEndpointChange();
    }
  }

  Future<void> pickTo() async {
    final e = await _nav.navigateToStopPickerView(title: 'To', forDestination: true);
    if (e is Endpoint) {
      to = e;
      await _afterEndpointChange();
    }
  }

  void clearFrom() {
    from = null;
    outcome = null;
    problem = null;
    rebuildUi();
  }

  void clearTo() {
    to = null;
    outcome = null;
    problem = null;
    rebuildUi();
  }

  Future<void> swap() async {
    final f = from;
    from = to;
    to = f;
    await _afterEndpointChange();
  }

  Future<void> _afterEndpointChange() async {
    if (canSearch) {
      await search();
    } else {
      outcome = null;
      problem = null;
      rebuildUi();
    }
  }

  Future<void> search() async {
    if (!canSearch) return;
    searching = true;
    problem = null;
    showAll = false;
    showAllConnections = false;
    rebuildUi();
    try {
      outcome = await _journeys.search(from!, to!, filters);
      unawaited(_favourites.recordSearch(from!, to!));
      tripSaved = await _favourites.isSaved(from!, to!);
    } on NotAvailableOffline {
      outcome = null;
      problem = SearchProblem.notSavedOffline;
    } on ApiException catch (e) {
      outcome = null;
      problem = switch (e.failure) {
        // "Too busy" is neither the rider's fault nor a broken server, and unlike a
        // rejected request, trying again shortly does work.
        ApiFailure.tooBusy => SearchProblem.busy,
        ApiFailure.badRequest => SearchProblem.rejected,
        _ => SearchProblem.server,
      };
      problemDetail = '${e.message} (${e.code})';
    } catch (e) {
      outcome = null;
      problem = SearchProblem.server;
      problemDetail = '$e';
    } finally {
      searching = false;
      rebuildUi();
    }
  }

  Future<void> openFilters() async {
    final res = await _sheets.showCustomSheet(
      variant: BottomSheetType.filters,
      data: FiltersRequest(filters, routes: _routesInResults()),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
    if (res?.confirmed == true && res?.data is SearchFilters) {
      filters = res!.data as SearchFilters;
      rebuildUi();
      await search();
    }
  }

  List<(String, OperatorRef)> _routesInResults() {
    final seen = <String>{};
    return [
      for (final r in outcome?.allDay ?? const <Ride>[])
        if (seen.add(r.option.routeNumber)) (r.option.routeNumber, r.operator),
    ];
  }

  Future<void> seeTomorrow() async {
    filters = filters.copyWith(date: () => _clock.today.addDays(1), departAfter: () => null, arriveBy: () => null);
    await search();
  }

  Future<void> seeFullDay() async {
    filters = filters.copyWith(departAfter: () => 0);
    await search();
  }

  void toggleShowAll() {
    showAll = !showAll;
    rebuildUi();
  }

  void toggleShowAllConnections() {
    showAllConnections = !showAllConnections;
    rebuildUi();
  }

  Future<void> toggleSaveTrip() async {
    if (!canSearch) return;
    await _favourites.toggleSavedTrip(from!, to!);
    tripSaved = !tripSaved;
    rebuildUi();
  }

  void openRide(Ride r) => _nav.navigateToTripDetailView(ride: r);

  void openConnection(Connection c) =>
      _nav.navigateToConnectionDetailView(connection: c, date: outcome?.date ?? _clock.today);

  void runTrip(TripPair t) {
    from = t.from;
    to = t.to;
    unawaited(search());
  }

  Future<void> setPlace(PlaceKind kind) async {
    final e = await _nav.navigateToStopPickerView(title: kind == PlaceKind.home ? 'Set Home' : 'Set Work');
    if (e is Endpoint) await _favourites.setPlace(kind, e);
  }

  /// The top recommended route that hasn't departed, when nothing is planned yet.
  Ride? get suggestedRide => nextPlanned == null ? outcome?.rides.firstOrNull : null;

  PlannerCardData? get plannerCard {
    final j = nextPlanned;
    if (j != null) {
      return (
        operator: j.operator,
        routeNumber: j.routeNumber,
        from: j.from,
        to: j.to,
        boardTime: j.boardTime,
        arriveTime: j.arriveTime,
        planned: true,
      );
    }
    final r = suggestedRide;
    if (r == null) return null;
    return (
      operator: r.operator,
      routeNumber: r.option.routeNumber,
      from: r.from,
      to: r.to,
      boardTime: r.boardTime,
      arriveTime: r.arriveTime,
      planned: false,
    );
  }

  void openPlanned() {
    final j = nextPlanned;
    if (j != null) {
      _nav.navigateToTripDetailView(plannedJourneyId: j.id);
    } else if (suggestedRide != null) {
      openRide(suggestedRide!);
    }
  }

  bool startingJourney = false;

  /// Start the next planned journey; with nothing planned, put the top recommended route
  /// on the planner (with its stop times, so it works offline) and start that.
  Future<void> startPlanned() async {
    if (startingJourney) return;
    startingJourney = true;
    rebuildUi();
    try {
      var id = nextPlanned?.id;
      final r = suggestedRide;
      if (id == null && r != null) {
        TripStopsResponse? trip;
        try {
          final d = r.departure;
          trip = (await _journeys.tripStops(d.scheduleId, d.tripIndex, d.fromSeq, d.toSeq, pin: true)).data;
        } catch (_) {
          // Offline and not saved: start anyway; Live Journey shows board and alight only.
        }
        id = await _planner.add(r, trip: trip);
      }
      if (id == null) return;
      await _planner.start(id);
      _shell.go(AppTab.trip);
    } finally {
      startingJourney = false;
      rebuildUi();
    }
  }

  void openNotifications() => _nav.navigateToNotificationsView();
  void openExplore() => _shell.go(AppTab.explore);
  void openPlanner() => _shell.go(AppTab.planner);
  void openNearby() => _nav.navigateToNearbyStopsView();
  void openHelp() => _nav.navigateToHelpView();
  void openProfile() => _shell.go(AppTab.profile);
  void goTab(AppTab tab) => _shell.go(tab);
  void openLiveJourney() => _shell.go(AppTab.trip);

  /// "View more routes": show every remaining departure.
  void viewMore() {
    showAll = true;
    rebuildUi();
  }

  void reportProblem() => _nav.navigateToReportIssueView(
    report: ReportContext(
      fromName: from?.name,
      fromId: from?.id,
      toName: to?.name,
      toId: to?.id,
      serviceDate: (filters.date ?? _clock.today).iso,
      dayType: dayTypeFor(filters.date ?? _clock.today).api,
      fromCache: outcome?.fromCache,
      fetchedAt: outcome?.fetchedAt,
      errorCode: problemDetail,
    ),
  );

  @override
  void dispose() {
    _shell.removeListener(_onShell);
    _favourites.removeListener(_reloadSide);
    _planner.removeListener(_reloadSide);
    _settings.removeListener(rebuildUi);
    super.dispose();
  }
}
