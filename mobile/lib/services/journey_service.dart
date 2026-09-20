import '../app/app.locator.dart';
import '../core/footnotes.dart';
import '../core/service_day.dart';
import '../data/models/models.dart';
import 'cached_api_service.dart';
import 'reference_data_service.dart';

enum SortBy {
  departure('Departure time'),
  arrival('Arrival time'),
  duration('Duration'),
  fewerChanges('Fewer changes');

  const SortBy(this.label);
  final String label;
}

/// "What matters most to you" in Filters.
enum JourneyPreference {
  fastest('Fastest', 'Show me the quickest routes'),
  fewerChanges('Fewer changes', 'Show me routes with the least transfers'),
  shortestWalk('Shortest walk', 'Minimise walking distance');

  const JourneyPreference(this.label, this.description);
  final String label;
  final String description;
}

/// What the commuter asked for, beyond from and to.
class SearchFilters {
  const SearchFilters({
    this.date,
    this.departAfter,
    this.arriveBy,
    this.sort = SortBy.departure,
    this.includeApprox = true,
    this.excludedOperators = const {},
    this.preference = JourneyPreference.fewerChanges,
    this.routes = const {},
  });

  /// Null means today.
  final ServiceDate? date;

  /// Minutes after midnight; null means "now" (or start of day for a future date).
  final int? departAfter;

  /// Minutes after midnight; when set, only rides arriving by then.
  final int? arriveBy;
  final SortBy sort;

  /// Include departures whose time at this stop is estimated between published stops.
  final bool includeApprox;

  /// Operator codes the commuter switched off ("no trains"). Empty means every operator.
  final Set<String> excludedOperators;

  bool allows(OperatorRef o) => !excludedOperators.contains(o.code);

  /// Fastest puts the shortest rides first, shortest walk the closest boarding and
  /// alighting points; fewer changes keeps the chosen sort (single rides always come
  /// before trips with a change).
  final JourneyPreference preference;

  /// Only these route numbers / train lines (as on the route chip). Empty means all.
  final Set<String> routes;

  bool get isDefault =>
      date == null &&
      departAfter == null &&
      arriveBy == null &&
      sort == SortBy.departure &&
      includeApprox &&
      excludedOperators.isEmpty &&
      preference == JourneyPreference.fewerChanges &&
      routes.isEmpty;

  /// How many filters differ from the defaults, for the "Filter (2)" badge.
  int get activeCount => [
    date != null,
    departAfter != null,
    arriveBy != null,
    sort != SortBy.departure,
    !includeApprox,
    excludedOperators.isNotEmpty,
    preference != JourneyPreference.fewerChanges,
    routes.isNotEmpty,
  ].where((b) => b).length;

  SearchFilters copyWith({
    ServiceDate? Function()? date,
    int? Function()? departAfter,
    int? Function()? arriveBy,
    SortBy? sort,
    bool? includeApprox,
    Set<String>? excludedOperators,
    JourneyPreference? preference,
    Set<String>? routes,
  }) => SearchFilters(
    date: date != null ? date() : this.date,
    departAfter: departAfter != null ? departAfter() : this.departAfter,
    arriveBy: arriveBy != null ? arriveBy() : this.arriveBy,
    sort: sort ?? this.sort,
    includeApprox: includeApprox ?? this.includeApprox,
    excludedOperators: excludedOperators ?? this.excludedOperators,
    preference: preference ?? this.preference,
    routes: routes ?? this.routes,
  );
}

/// One bus or train a commuter can catch: a departure on a route, on a date.
class Ride {
  Ride({
    required this.from,
    required this.to,
    required this.option,
    required this.departure,
    required this.date,
    this.noteCode,
    this.noteText,
    this.footnoteUnknown = false,
  });

  final Endpoint from;
  final Endpoint to;
  final PlanOption option;
  final PlanDeparture departure;
  final ServiceDate date;

  /// Footnote on this departure and its meaning, e.g. "b" / "Fridays only".
  final String? noteCode;
  final String? noteText;

  /// The footnote could not be interpreted: tell people to check the official timetable.
  final bool footnoteUnknown;

  double get boardMinutes => departure.boardMinutes!;

  /// Arrival in minutes after midnight of [date]; past midnight runs beyond 1440.
  double? get arriveMinutes {
    final a = departure.arriveMinutes;
    if (a == null) return null;
    return a < boardMinutes ? a + 1440 : a;
  }

  double? get durationMinutes => arriveMinutes == null ? null : arriveMinutes! - boardMinutes;

  bool get approx => departure.boardApprox || departure.arriveApprox;

  OperatorRef get operator => option.operator;
  Fare? get fare => option.fare;

  /// Metres to walk to the boarding stop and from the alighting stop, when this ride is
  /// another operator's service near the places asked for.
  int get walkM => (option.boardAwayM ?? 0) + (option.alightAwayM ?? 0);

  /// "5 min walk away" — roughly, at 80 m a minute; null when the stops are the ones asked for.
  String? get walkLabel {
    if (walkM < 50) return null;
    final minutes = (walkM / 80).ceil();
    return walkM < 1000 ? '$walkM m walk' : '$minutes min walk';
  }

  String get boardTime => formatMinutes(boardMinutes);
  String? get arriveTime => arriveMinutes == null ? null : formatMinutes(arriveMinutes!);
}

/// Everything the results list needs to explain itself.
class JourneySearchOutcome {
  const JourneySearchOutcome({
    required this.from,
    required this.to,
    required this.date,
    required this.dayType,
    required this.rides,
    required this.allDay,
    required this.fromCache,
    required this.fetchedAt,
    this.holidayName,
    this.holidayFallback = false,
    this.hiddenByFootnote = 0,
    this.otherDayTypes = const [],
    this.connections = const [],
    this.hasAnyDirectService = true,
    this.hiddenByOperator = 0,
  });

  final Endpoint from;
  final Endpoint to;
  final ServiceDate date;
  final DayType dayType;

  /// Upcoming rides matching the filters, sorted.
  final List<Ride> rides;

  /// Every ride that runs on [date], by departure time — for first and last bus.
  final List<Ride> allDay;
  final bool fromCache;
  final DateTime fetchedAt;

  /// Set on a public holiday.
  final String? holidayName;

  /// No holiday timetable exists for this trip, so the Sunday one is shown.
  final bool holidayFallback;

  /// Departures dropped because their footnote says they do not run on [date].
  final int hiddenByFootnote;

  /// Day types that do have service, when [date] has none.
  final List<DayType> otherDayTypes;

  /// Trips with one change, when no single bus or train connects the two places.
  final List<Connection> connections;

  /// Some allowed bus or train connects these points on some day.
  final bool hasAnyDirectService;

  /// Route options left out because their operator is switched off in Filters.
  final int hiddenByOperator;

  /// Which kinds of vehicle these results are about: every ride and connection leg, or
  /// failing that the kinds of stop searched between. Pins count as either.
  Set<String> get kinds {
    final k = <String>{
      for (final r in allDay) r.operator.kind,
      for (final c in connections)
        for (final l in c.legs) l.operator.kind,
    };
    if (k.isNotEmpty) return k;
    return {
      for (final e in [from, to])
        if (e.isStop) e.isStation ? 'train' : 'bus',
    };
  }

  bool get _onlyTrains => kinds.length == 1 && kinds.first == 'train';
  bool get _onlyBuses => kinds.length == 1 && kinds.first == 'bus';

  /// "bus", "train", or "bus or train".
  String get vehicle => _onlyTrains ? 'train' : (_onlyBuses ? 'bus' : 'bus or train');

  /// "buses", "trains", or "buses and trains".
  String get vehicles => _onlyTrains ? 'trains' : (_onlyBuses ? 'buses' : 'buses and trains');

  Ride? get firstBus => allDay.isEmpty ? null : allDay.first;
  Ride? get lastBus => allDay.isEmpty ? null : allDay.last;

  bool get isStale => DateTime.now().difference(fetchedAt) > const Duration(days: 7);
}

/// Journey planning over the API, with timetable rules applied on the device.
class JourneyService {
  JourneyService({CachedApiService? api, ReferenceDataService? reference, SastClock? clock})
    : _api = api ?? locator<CachedApiService>(),
      _ref = reference ?? locator<ReferenceDataService>(),
      clock = clock ?? const SastClock();

  final CachedApiService _api;
  final ReferenceDataService _ref;
  final SastClock clock;

  /// How far a rider may be asked to walk to another operator's nearest stop before that
  /// operator's services stop being worth offering (about 15 minutes).
  static const maxTransferWalkM = 1200;

  Future<Cached<PlanResponse>> plan(Endpoint from, Endpoint to, {bool pin = false}) =>
      _api.get('/api/plan', query: {...from.query('from'), ...to.query('to')}, parse: PlanResponse.fromJson, pin: pin);

  /// What the other operators run between the same two places.
  ///
  /// A plan between two stop ids only covers that stop's operator, so someone standing at
  /// a Golden Arrow stop would never see the MyCiTi stop across the road or the station
  /// round the corner. Planning between the same two *points* asks the API for everything
  /// nearby instead, and it returns how far each option's stops are from those points —
  /// so anything more than a short walk away can be dropped. Skipped when both ends are
  /// already map points, because that plan covers every operator.
  Future<List<PlanOption>> _nearbyOperatorOptions(
    Endpoint from,
    Endpoint to,
    SearchFilters filters,
    Set<String> alreadyShown,
  ) async {
    if (!from.isStop && !to.isStop) return const [];
    try {
      final res = await plan(
        Endpoint.pin(name: from.name, lat: from.lat, lon: from.lon),
        Endpoint.pin(name: to.name, lat: to.lat, lon: to.lon),
      );
      return res.data.options
          .where(
            (o) =>
                !alreadyShown.contains(o.operator.code) &&
                filters.allows(o.operator) &&
                (o.boardAwayM ?? 0) <= maxTransferWalkM &&
                (o.alightAwayM ?? 0) <= maxTransferWalkM,
          )
          .toList();
    } catch (_) {
      // Offline, or the API could not plan from those points: the chosen stops' own
      // operators are still shown.
      return const [];
    }
  }

  /// Trips with one change. Either end may be a stop or a map pin.
  Future<Cached<ConnectionsResponse>> connections(Endpoint from, Endpoint to) => _api.get(
    '/api/connections',
    query: {...from.query('from'), ...to.query('to')},
    parse: ConnectionsResponse.fromJson,
  );

  Future<Cached<TripStopsResponse>> tripStops(
    int scheduleId,
    int tripIndex,
    int fromSeq,
    int toSeq, {
    bool pin = false,
  }) => _api.get(
    '/api/trip_stops',
    query: {'schedule_id': '$scheduleId', 'trip_index': '$tripIndex', 'from_seq': '$fromSeq', 'to_seq': '$toSeq'},
    parse: TripStopsResponse.fromJson,
    pin: pin,
    // A ride's stop times never change for a given schedule, so a saved copy is as
    // good as a fresh one and saves data.
    cacheFirst: true,
  );

  Future<Cached<TimetableDetail>> timetable(int id) => _api.get('/api/timetables/$id', parse: TimetableDetail.fromJson);

  Future<List<GeoHit>> geocode(String q) async {
    final res = await _api.get(
      '/api/geocode',
      query: {'q': q.trim()},
      parse: (j) => ((j['results'] as List?) ?? const []).cast<Json>().map(GeoHit.fromJson).toList(),
    );
    return res.data;
  }

  /// Plan a trip and apply day type, footnotes, time and sort.
  Future<JourneySearchOutcome> search(Endpoint from, Endpoint to, SearchFilters filters, {bool pin = false}) async {
    final res = await plan(from, to, pin: pin);
    final date = filters.date ?? clock.today;
    // What the chosen stops' own operators run, plus the other operators' services from
    // their nearest stops to the same two places.
    final nearby = await _nearbyOperatorOptions(
      from,
      to,
      filters,
      res.data.options.map((o) => o.operator.code).toSet(),
    );
    final options = [...res.data.options, ...nearby];
    final notes = <String, Map<String, String>>{};
    for (final o in options) {
      notes[o.timetableNumber] ??= await _ref.notesFor(o.timetableNumber);
    }
    var outcome = buildOutcome(
      from: from,
      to: to,
      response: PlanResponse(from: res.data.from, to: res.data.to, options: options),
      notes: notes,
      filters: filters,
      date: date,
      minutesNow: date == clock.today ? clock.minutesNow : null,
      fromCache: res.fromCache,
      fetchedAt: res.fetchedAt,
    );
    if (!outcome.hasAnyDirectService) {
      try {
        final c = await connections(from, to);
        final dt = outcome.dayType == DayType.publicHoliday ? DayType.sunday : outcome.dayType;
        // A connection is offered only when every leg's operator is switched on.
        final allowed = c.data.connections.where((x) => x.legs.every((l) => filters.allows(l.operator))).toList();
        final forDay = allowed.where((x) => DayType.fromApi(x.dayType) == dt).toList();
        outcome = JourneySearchOutcome(
          from: from,
          to: to,
          date: date,
          dayType: outcome.dayType,
          rides: const [],
          allDay: const [],
          fromCache: outcome.fromCache,
          fetchedAt: outcome.fetchedAt,
          holidayName: outcome.holidayName,
          connections: forDay,
          hasAnyDirectService: false,
          otherDayTypes: forDay.isEmpty
              ? allowed.map((x) => DayType.fromApi(x.dayType)).whereType<DayType>().toSet().toList()
              : const [],
        );
      } on NotAvailableOffline {
        // Keep the plain "no direct bus" outcome.
      }
    }
    return outcome;
  }

  /// The timetable rules, separated from I/O so they can be tested exhaustively.
  static JourneySearchOutcome buildOutcome({
    required Endpoint from,
    required Endpoint to,
    required PlanResponse response,
    required Map<String, Map<String, String>> notes,
    required SearchFilters filters,
    required ServiceDate date,
    required double? minutesNow,
    required bool fromCache,
    required DateTime fetchedAt,
  }) {
    final wanted = dayTypeFor(date);
    final holidayName = SaHolidays.nameOf(date);
    var dayType = wanted;
    final allowed = response.options.where((o) => filters.allows(o.operator)).toList();
    var options = allowed.where((o) => DayType.fromApi(o.dayType) == wanted).toList();
    var holidayFallback = false;
    if (wanted == DayType.publicHoliday && options.isEmpty) {
      // Golden Arrow normally runs its Sunday service on public holidays when a route has
      // no holiday timetable. Shown with a banner telling people to confirm.
      dayType = DayType.sunday;
      holidayFallback = true;
      options = allowed.where((o) => DayType.fromApi(o.dayType) == DayType.sunday).toList();
    }

    var hidden = 0;
    final allDay = <Ride>[];
    final seen = <String>{};
    for (final o in options) {
      final legend = notes[o.timetableNumber] ?? const {};
      for (final d in o.departures) {
        if (d.boardMinutes == null) continue;
        if (!seen.add(d.rideKey)) continue;
        final code = Footnotes.codeOf(d.boardRaw);
        final verdict = Footnotes.verdict(code, legend, date);
        if (verdict == FootnoteVerdict.doesNotRun) {
          hidden++;
          continue;
        }
        allDay.add(
          Ride(
            from: from,
            to: to,
            option: o,
            departure: d,
            date: date,
            noteCode: code,
            noteText: code == null ? null : (legend[code] == null ? null : Footnotes.humanise(legend[code])),
            footnoteUnknown: verdict == FootnoteVerdict.unknown,
          ),
        );
      }
    }
    allDay.sort((a, b) => a.boardMinutes.compareTo(b.boardMinutes));

    final after = filters.departAfter?.toDouble() ?? (minutesNow != null ? minutesNow - 1 : 0);
    var rides = allDay.where((r) => r.boardMinutes >= after).toList();
    if (filters.arriveBy != null) {
      rides = rides.where((r) => r.arriveMinutes != null && r.arriveMinutes! <= filters.arriveBy!).toList();
    }
    if (!filters.includeApprox) rides = rides.where((r) => !r.approx).toList();
    if (filters.routes.isNotEmpty) rides = rides.where((r) => filters.routes.contains(r.option.routeNumber)).toList();
    switch (filters.sort) {
      case SortBy.departure:
      // Every option here is a single ride, so "fewer changes" orders by departure.
      case SortBy.fewerChanges:
        break;
      case SortBy.arrival:
        rides.sort((a, b) => (a.arriveMinutes ?? 1e9).compareTo(b.arriveMinutes ?? 1e9));
      case SortBy.duration:
        rides.sort((a, b) => (a.durationMinutes ?? 1e9).compareTo(b.durationMinutes ?? 1e9));
    }
    switch (filters.preference) {
      case JourneyPreference.fastest:
        rides.sort((a, b) => (a.durationMinutes ?? 1e9).compareTo(b.durationMinutes ?? 1e9));
      case JourneyPreference.shortestWalk:
        double walk(Ride r) => ((r.option.boardAwayM ?? 0) + (r.option.alightAwayM ?? 0)).toDouble();
        rides.sort((a, b) => walk(a).compareTo(walk(b)));
      case JourneyPreference.fewerChanges:
        break;
    }

    final otherDayTypes = options.isEmpty
        ? allowed.map((o) => DayType.fromApi(o.dayType)).whereType<DayType>().toSet().toList()
        : const <DayType>[];

    return JourneySearchOutcome(
      from: from,
      to: to,
      date: date,
      dayType: dayType,
      rides: rides,
      allDay: allDay,
      fromCache: fromCache,
      fetchedAt: fetchedAt,
      holidayName: holidayName,
      holidayFallback: holidayFallback,
      hiddenByFootnote: hidden,
      otherDayTypes: otherDayTypes,
      hasAnyDirectService: allowed.isNotEmpty,
      hiddenByOperator: response.options.length - allowed.length,
    );
  }
}
