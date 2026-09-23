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

/// How long a ride takes, or null when that is not known.
///
/// Where the timetable prints no time after the rider's stretch, both ends can only be
/// given the same lower bound and the ride comes out at 0 min. That is not a duration;
/// the card shows "–" instead.
double? rideMinutes(double board, double? arrive, {required bool approx}) {
  if (arrive == null) return null;
  final m = arrive - board;
  return m < 1 && approx ? null : m;
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

  double? get durationMinutes => rideMinutes(boardMinutes, arriveMinutes, approx: approx);

  bool get approx => departure.boardApprox || departure.arriveApprox;

  OperatorRef get operator => option.operator;
  Fare? get fare => option.fare;

  /// What this ride costs, when it leaves: MyCiTi's peak or saver fare, else the fare.
  int? get priceCents => fareAt(fare, weekday: dayTypeFor(date) == DayType.weekday, boardMinutes: boardMinutes);

  /// Metres to walk to the boarding stop and from the alighting stop, when this ride is
  /// another operator's service near the places asked for.
  int get walkM => (option.boardAwayM ?? 0) + (option.alightAwayM ?? 0);

  /// "5 min walk away" — roughly, at 80 m a minute; null when the stops are the ones asked for.
  String? get walkLabel {
    if (walkM < 50) return null;
    if (walkM > JourneyService.maxTransferWalkM) {
      // An operator's nearest stop, further than a walk: say how far each end is rather
      // than suggest an hour on foot.
      String km(int m) => m < 1000 ? '$m m' : '${(m / 1000).toStringAsFixed(1)} km';
      final board = option.boardAwayM ?? 0;
      final alight = option.alightAwayM ?? 0;
      return [if (board >= 50) '${km(board)} to the stop', if (alight >= 50) '${km(alight)} from the stop'].join(', ');
    }
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
    this.allDayConnections = const [],
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

  /// Trips with one change that fit the chosen time, soonest first. Offered alongside the
  /// direct rides, not only instead of them.
  final List<Connection> connections;

  /// Every trip with one change that runs on [date], whatever the time — so "no more
  /// today" can be told apart from "none at all".
  final List<Connection> allDayConnections;

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

  /// The best ride of each operator, in the order the rides are sorted: what the home
  /// screen shows before "View more". Showing only the single best ride hid the Golden
  /// Arrow bus behind the train, and a rider cannot compare times and prices of operators
  /// they cannot see.
  List<Ride> get bestPerOperator {
    final seen = <String>{};
    return [
      for (final r in rides)
        if (seen.add(r.operator.code)) r,
    ];
  }

  /// The same for journeys with a change: the soonest on each operator.
  ///
  /// One card, and "view 16 more ways", hid every train behind a bus. Buh Rein to Kalk
  /// Bay showed three Golden Arrow buses taking 3h30m, with two trains doing it in 2h09m
  /// for R14 inside the button. What is worth hiding is another way to make the same trip
  /// on the same network, never the only way to make it on a different one.
  List<Connection> get bestConnectionPerOperator {
    final seen = <String>{};
    return [
      for (final c in connections)
        if (seen.add(c.operatorKey)) c,
    ];
  }

  Ride? get firstBus => allDay.isEmpty ? null : allDay.first;
  Ride? get lastBus => allDay.isEmpty ? null : allDay.last;

  bool get isStale => DateTime.now().difference(fetchedAt) > const Duration(days: 7);

  /// The same outcome with the trips that need a change added, leaving the direct rides
  /// alone. [otherDayTypes] is replaced only when given.
  JourneySearchOutcome withConnections(
    List<Connection> connections, {
    List<Connection> allDayConnections = const [],
    List<DayType>? otherDayTypes,
  }) => JourneySearchOutcome(
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
    hiddenByFootnote: hiddenByFootnote,
    otherDayTypes: otherDayTypes ?? this.otherDayTypes,
    connections: connections,
    allDayConnections: allDayConnections,
    hasAnyDirectService: hasAnyDirectService,
    hiddenByOperator: hiddenByOperator,
  );
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
    // A stop we cannot place cannot stand for the place it is at.
    if (!from.hasPosition || !to.hasPosition) return const [];
    try {
      final res = await plan(
        Endpoint.pin(name: from.name, lat: from.lat!, lon: from.lon!),
        Endpoint.pin(name: to.name, lat: to.lat!, lon: to.lon!),
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

  /// How far away an operator's nearest stop may be and still be offered from a place or
  /// your location. Further than a walk, but a rider near a bus stop who is 3 km from a
  /// station still wants to know the train is there.
  static const maxNearestStopM = 5000;

  /// Each remaining operator's service from its nearest stop to the place asked for.
  ///
  /// A plan from a point only looks at stops close to it, so someone at Buh Rein was
  /// offered the bus there and never the train from Kraaifontein, 3 km away. When either
  /// end is a point (your location, a place, an address), every operator not already
  /// shown is planned between its own nearest stops to the two ends, so the rider can
  /// compare them all. The distances ride along on the option, for the card to show.
  Future<List<PlanOption>> _nearestStopOptions(
    Endpoint from,
    Endpoint to,
    SearchFilters filters,
    Set<String> alreadyShown,
  ) async {
    if (from.isStop && to.isStop) return const [];
    // A stop stands for itself on its own operator; on any other it stands for the
    // place it is at.
    //
    // A place is where the rider named: a station called "Khayelitsha" is Khayelitsha,
    // though the map puts the suburb nearer Nonkqubela. Same-named stops win over nearest.
    Future<Map<String, (Endpoint, double)>> ends(Endpoint e) async => {
      // Nothing near a stop with no position: what is near it is not knowable. It still
      // stands for itself on its own operator, below.
      if (e.hasPosition)
        for (final (s, m) in await _ref.nearestStopPerOperator(e.lat!, e.lon!, maxMetres: maxNearestStopM.toDouble()))
          if (s.endpoint != null) s.operatorCode: (s.endpoint!, m),
      if (!e.isStop)
        // No walk: the rider named it, and the suburb's point on the map is not where they are.
        for (final (s, _) in await _ref.stopsNamed(e.name, e.lat!, e.lon!))
          if (s.endpoint != null) s.operatorCode: (s.endpoint!, 0.0),
      if (e.isStop && e.operatorCode != null) e.operatorCode!: (e, 0.0),
    };
    final starts = await ends(from);
    final finishes = await ends(to);
    final out = <PlanOption>[];
    for (final code in starts.keys) {
      if (alreadyShown.contains(code) || !finishes.containsKey(code)) continue;
      if (!filters.allows(OperatorRef.from(code))) continue;
      final (a, aM) = starts[code]!;
      final (b, bM) = finishes[code]!;
      if (a == b) continue;
      try {
        final res = await plan(a, b);
        out.addAll(
          res.data.options
              .where((o) => o.operator.code == code)
              .map((o) => o.withWalk(boardAwayM: aM.round(), alightAwayM: bM.round())),
        );
      } catch (_) {
        // Offline, or nothing runs between those two stops: the other operators still show.
      }
    }
    return out;
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
    // Then, from a place or your location, any operator still missing, from its nearest stop.
    final further = await _nearestStopOptions(from, to, filters, {
      for (final o in [...res.data.options, ...nearby]) o.operator.code,
    });
    final options = [...res.data.options, ...nearby, ...further];
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
    // A trip with a change is worth showing even when something runs straight through.
    // Asking only when nothing did meant one direct bus hid every other way to make the
    // journey: Kraaifontein to Rosebank has a single direct bus and sixteen ways to do it
    // by train, and a rider looking for the train was told there was none.
    try {
      final c = await connections(from, to);
      final dt = outcome.dayType == DayType.publicHoliday ? DayType.sunday : outcome.dayType;
      // A connection is offered only when every leg's operator is switched on.
      final allowed = c.data.connections.where((x) => x.legs.every((l) => filters.allows(l.operator))).toList();
      final forDay = allowed.where((x) => DayType.fromApi(x.dayType) == dt).toList()..sort(_bySoonest);
      outcome = outcome.withConnections(
        sortConnections(
          forDay
              .where((x) => fitsTime(x, filters, date: date, minutesNow: clock.minutesNow, today: clock.today))
              .toList(),
          filters,
        ),
        allDayConnections: forDay,
        // Only when nothing runs straight through either is the rider stuck for the day.
        // With a direct service the day types already come from its own timetable.
        otherDayTypes: !outcome.hasAnyDirectService && forDay.isEmpty
            ? allowed.map((x) => DayType.fromApi(x.dayType)).whereType<DayType>().toSet().toList()
            : null,
      );
    } catch (_) {
      // Offline, or the API could not plan a change between these two. The direct rides
      // are still worth showing, so this never fails the search.
    }
    return outcome;
  }

  static int _bySoonest(Connection a, Connection b) =>
      (a.legs.first.boardMinutes ?? 1e9).compareTo(b.legs.first.boardMinutes ?? 1e9);

  /// Whether a trip with a change leaves at the chosen time — the same rule the direct
  /// rides follow, so "Leave now" never offers a connection whose first bus has gone and
  /// a direct one that hasn't. Departure is the first leg; arrival is the last.
  static bool fitsTime(
    Connection c,
    SearchFilters filters, {
    required ServiceDate date,
    required double minutesNow,
    required ServiceDate today,
  }) {
    final after = filters.departAfter?.toDouble() ?? (date == today ? minutesNow - 1 : 0);
    final board = c.legs.first.boardMinutes;
    if (board != null && board < after) return false;
    if (filters.arriveBy != null) {
      final arrive = c.legs.last.arriveMinutes;
      if (arrive == null || arrive > filters.arriveBy!) return false;
    }
    return true;
  }

  /// Trips with a change in the order the rider asked for: soonest first by default, which
  /// is what "Leave now" means and what the one card shown before "View more" should be.
  static List<Connection> sortConnections(List<Connection> cs, SearchFilters filters) {
    final out = [...cs]..sort(_bySoonest);
    int? total(Connection c) => c.totalMinutes;
    if (filters.preference == JourneyPreference.fastest || filters.sort == SortBy.duration) {
      out.sort((a, b) => (total(a) ?? 1 << 30).compareTo(total(b) ?? 1 << 30));
    } else if (filters.sort == SortBy.arrival) {
      out.sort((a, b) => (a.legs.last.arriveMinutes ?? 1e9).compareTo(b.legs.last.arriveMinutes ?? 1e9));
    }
    return out;
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
