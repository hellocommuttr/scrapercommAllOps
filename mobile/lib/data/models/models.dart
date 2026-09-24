/// Wire models for the Commuttr API (snake_case JSON) and the app's own value types.
///
/// Parsed by hand: the payloads are small and stable, and a few fields need care that a
/// generator would not give them — minutes arrive as int *or* double, and a plan's
/// `from`/`to` is either a named stop or a lat/lon pin.
library;

typedef Json = Map<String, dynamic>;

double? _d(Object? v) => (v as num?)?.toDouble();
int? _i(Object? v) => (v as num?)?.toInt();
String? _s(Object? v) => v as String?;
List<Json> _list(Object? v) => ((v as List?) ?? const []).cast<Json>();

/// Who runs a service. The API names operators by code ('gabs', 'metrorail'); a missing
/// code means Golden Arrow, the only operator before trains arrived.
class OperatorRef {
  const OperatorRef(this.code, this.name, this.kind);

  static const goldenArrow = OperatorRef('gabs', 'Golden Arrow', 'bus');
  static const metrorail = OperatorRef('metrorail', 'Metrorail', 'train');
  static const myciti = OperatorRef('myciti', 'MyCiTi', 'bus');

  /// From API fields; [name] may be the long form ("Golden Arrow Buses").
  factory OperatorRef.from(String? code, {String? name, String? kind}) {
    if (code == null || code == 'gabs') return goldenArrow;
    if (code == 'metrorail') return metrorail;
    if (code == 'myciti') return myciti;
    return OperatorRef(code, name ?? code, kind ?? 'bus');
  }

  final String code;

  /// Short name, as riders say it: "Golden Arrow", "Metrorail".
  final String name;

  /// 'bus' or 'train'.
  final String kind;

  bool get isTrain => kind == 'train';

  /// "bus" / "train", for sentences.
  String get vehicle => isTrain ? 'train' : 'bus';

  /// "buses" / "trains" — "bus" does not pluralise by adding an s.
  String get vehicles => isTrain ? 'trains' : 'buses';

  /// "stop" / "station".
  String get stopWord => isTrain ? 'station' : 'stop';

  @override
  bool operator ==(Object other) => other is OperatorRef && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// A published fare, in cents. Only the cash price is shown as "the" price: a card price
/// is not what a cash payer is charged, and a card holder has already paid (the same rule
/// as the web app).
class Fare {
  const Fare({
    this.cashCents,
    this.cashEffectiveFrom,
    this.returnCents,
    this.fiveRideCents,
    this.weeklyCents,
    this.weeklySatCents,
    this.monthlyCents,
    this.basis,
    this.basisFrom,
    this.basisTo,
    this.zoneApprox = false,
    this.kind,
    this.saverCents,
    this.dayPassCents,
    this.threeDayPassCents,
  });

  static Fare? fromJson(Object? v) {
    if (v is! Json) return null;
    return Fare(
      cashCents: _i(v['cash_cents']),
      cashEffectiveFrom: _s(v['cash_effective_from']),
      returnCents: _i(v['return_cents']),
      fiveRideCents: _i(v['five_ride_cents']),
      weeklyCents: _i(v['weekly_cents']),
      weeklySatCents: _i(v['weekly_sat_cents']),
      monthlyCents: _i(v['monthly_cents']),
      basis: _s(v['basis']),
      basisFrom: _s(v['basis_from']),
      basisTo: _s(v['basis_to']),
      zoneApprox: v['zone_approx'] == true,
      kind: _s(v['kind']),
      saverCents: _i(v['saver_cents']),
      dayPassCents: _i(v['day_pass_cents']),
      threeDayPassCents: _i(v['three_day_pass_cents']),
    );
  }

  final int? cashCents;
  final String? cashEffectiveFrom;
  final int? returnCents;

  /// Golden Arrow's GO EASY bundles, which are counts of rides and not periods of time:
  /// 5 rides, 10 rides and 48 rides. They are held in the columns Metrorail's weekly and
  /// monthly tickets use, because the operator's own fare table has always had three
  /// products in those three slots.
  final int? fiveRideCents;
  final int? weeklyCents;
  final int? weeklySatCents;
  final int? monthlyCents;

  /// How the price was matched to this ride: 'exact', 'section', 'go_easy', 'prasa_zone'.
  final String? basis;
  final String? basisFrom;
  final String? basisTo;

  /// The station's fare zone was estimated.
  final bool zoneApprox;

  /// Connections only: 'through' (one ticket) or 'per_leg' (pay for each leg).
  final String? kind;

  /// MyCiTi: the saver fare, with [cashCents] its peak fare. Both are myconnect card
  /// fares; MyCiTi takes no cash.
  final int? saverCents;

  /// MyCiTi's 1-day and 3-day passes. [weeklyCents] is its 7-day pass.
  final int? dayPassCents;
  final int? threeDayPassCents;

  /// A MyCiTi fare, priced by distance band with a peak and a saver price.
  bool get isMyciti => basis == 'myciti_distance';

  /// The same fare without a price for one trip, keeping the bundles of rides. Golden
  /// Arrow publishes no cash fare, so no single ride can be priced, but its GO EASY
  /// prices are published and worth showing.
  Fare get withoutSingleTrip => Fare(
    cashEffectiveFrom: cashEffectiveFrom,
    fiveRideCents: fiveRideCents,
    weeklyCents: weeklyCents,
    weeklySatCents: weeklySatCents,
    monthlyCents: monthlyCents,
    basis: basis,
    basisFrom: basisFrom,
    basisTo: basisTo,
    zoneApprox: zoneApprox,
    kind: kind,
  );

  /// Anything to show at all: a price for the trip, or a bundle of rides.
  bool get hasAnything =>
      cashCents != null || fiveRideCents != null || weeklyCents != null || monthlyCents != null;
}

/// MyCiTi's peak: a journey starting on a weekday from 06:45 to 08:00 or 16:15 to 17:30.
/// Every other time, weekends and public holidays, is saver.
bool isMycitiPeak({required bool weekday, required double boardMinutes}) {
  final m = boardMinutes % 1440;
  return weekday && ((m >= 405 && m <= 480) || (m >= 975 && m <= 1050));
}

/// The fare that applies to boarding at [boardMinutes]: MyCiTi's peak or saver fare, or
/// for everyone else the one published fare.
int? fareAt(Fare? f, {required bool weekday, double? boardMinutes}) {
  if (f == null) return null;
  if (f.saverCents == null || boardMinutes == null) return f.cashCents;
  return isMycitiPeak(weekday: weekday, boardMinutes: boardMinutes) ? f.cashCents : f.saverCents;
}

/// "R12.00".
String formatRands(int cents) => 'R${(cents / 100).toStringAsFixed(2)}';

/// A place a journey starts or ends: a named bus stop or train station, or any point on
/// the map.
class Endpoint {
  const Endpoint.stop({
    required int this.id,
    required this.name,
    this.lat,
    this.lon,
    this.operatorCode,
    this.operatorKind,
  }) : kind = EndpointKind.stop;

  const Endpoint.pin({required this.name, required double this.lat, required double this.lon})
    : kind = EndpointKind.pin,
      id = null,
      operatorCode = null,
      operatorKind = null;

  factory Endpoint.fromJson(Json j) => j['kind'] == 'pin'
      ? Endpoint.pin(name: _s(j['name']) ?? 'Dropped pin', lat: _d(j['lat'])!, lon: _d(j['lon'])!)
      : Endpoint.stop(
          id: _i(j['id'])!,
          name: _s(j['name']) ?? '',
          lat: _d(j['lat']),
          lon: _d(j['lon']),
          operatorCode: _s(j['operator_code']),
          operatorKind: _s(j['operator_kind']),
        );

  final EndpointKind kind;
  final int? id;
  final String name;

  /// Null for the 48 stops whose position the timetables never gave us and no geocoder
  /// could place: Town Centre is one, and it is on 1,097 schedules. A stop with no
  /// position is still a stop a rider boards at, so it is still an endpoint - it simply
  /// cannot be drawn on a map.
  final double? lat;
  final double? lon;

  bool get hasPosition => lat != null && lon != null;

  /// Whose stop this is. Null for pins, and for stops saved before trains were added
  /// (those were all Golden Arrow's).
  final String? operatorCode;
  final String? operatorKind;

  bool get isStop => kind == EndpointKind.stop;

  /// A train station rather than a bus stop.
  bool get isStation => operatorKind == 'train';

  /// Query parameters for /api/plan, e.g. `from=7` or `from_lat=..&from_lon=..&from_name=..`.
  /// Pins are rounded to ~11 m so near-identical taps share a cache entry. A pin's name
  /// goes too: a place called "Khayelitsha" means Khayelitsha station, which the map puts
  /// 4.5 km from the place itself.
  Map<String, String> query(String prefix) => isStop
      ? {prefix: '$id'}
      : {
          '${prefix}_lat': lat!.toStringAsFixed(4),
          '${prefix}_lon': lon!.toStringAsFixed(4),
          if (name.trim().isNotEmpty) '${prefix}_name': name.trim(),
        };

  String get cacheKey => isStop ? 's$id' : 'p${lat!.toStringAsFixed(4)},${lon!.toStringAsFixed(4)}';

  Json toJson() => {
    'kind': kind.name,
    'id': id,
    'name': name,
    'lat': lat,
    'lon': lon,
    'operator_code': ?operatorCode,
    'operator_kind': ?operatorKind,
  };

  /// Stop names come in upper case from the PDFs; show them in title case.
  /// Stations get " station" so "Cape Town" the station and "Cape Town" the bus stop can
  /// be told apart.
  String get displayName => isStation ? '${titleCase(name)} station' : titleCase(name);

  @override
  bool operator ==(Object other) => other is Endpoint && other.cacheKey == cacheKey;

  @override
  int get hashCode => cacheKey.hashCode;
}

enum EndpointKind { stop, pin }

/// "BELLVILLE (SANLAM)" -> "Bellville (Sanlam)". Leaves mixed-case text alone.
String titleCase(String s) {
  if (s != s.toUpperCase()) return s;
  return s.toLowerCase().replaceAllMapped(RegExp(r"(^|[\s(\-/'])([a-z])"), (m) => '${m[1]}${m[2]!.toUpperCase()}');
}

/// A row of /api/nearest_stops: an operator's closest stop to a point.
class NearestStop {
  const NearestStop(this.stop, this.distanceM);

  factory NearestStop.fromJson(Json j) => NearestStop(StopDto.fromJson(j), _i(j['distance_m']) ?? 0);

  final StopDto stop;
  final int distanceM;
}

class StopDto {
  const StopDto({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    this.operatorCode = 'gabs',
    this.operatorKind = 'bus',
  });

  factory StopDto.fromJson(Json j) => StopDto(
    id: _i(j['id'])!,
    name: _s(j['name']) ?? '',
    lat: _d(j['lat']),
    lon: _d(j['lon']),
    operatorCode: _s(j['operator_code']) ?? 'gabs',
    operatorKind: _s(j['operator_kind']) ?? 'bus',
  );

  final int id;
  final String name;
  final double? lat;
  final double? lon;
  final String operatorCode;
  final String operatorKind;

  bool get isStation => operatorKind == 'train';

  /// "Cape Town" or "Cape Town station".
  String get displayName => isStation ? '${titleCase(name)} station' : titleCase(name);

  Endpoint? get endpoint => lat == null || lon == null
      ? null
      : Endpoint.stop(id: id, name: name, lat: lat!, lon: lon!, operatorCode: operatorCode, operatorKind: operatorKind);
}

// ---------------------------------------------------------------- /api/plan

class PlanSegmentStop {
  const PlanSegmentStop({this.stopId, required this.name, this.lat, this.lon, required this.stopSequence});

  factory PlanSegmentStop.fromJson(Json j) => PlanSegmentStop(
    stopId: _i(j['stop_id']),
    name: _s(j['name']) ?? '',
    lat: _d(j['lat']),
    lon: _d(j['lon']),
    stopSequence: _i(j['stop_sequence']) ?? 0,
  );

  final int? stopId;
  final String name;
  final double? lat;
  final double? lon;
  final int stopSequence;
}

class PlanDeparture {
  const PlanDeparture({
    required this.boardRaw,
    required this.boardApprox,
    required this.boardMinutes,
    required this.arriveRaw,
    required this.arriveApprox,
    required this.arriveMinutes,
    required this.scheduleId,
    required this.tripIndex,
    required this.fromSeq,
    required this.toSeq,
    this.stopCount,
  });

  factory PlanDeparture.fromJson(Json j) => PlanDeparture(
    boardRaw: _s(j['board_raw']) ?? '',
    boardApprox: j['board_approx'] == true,
    boardMinutes: _d(j['board_minutes']),
    arriveRaw: _s(j['arrive_raw']) ?? '',
    arriveApprox: j['arrive_approx'] == true,
    arriveMinutes: _d(j['arrive_minutes']),
    scheduleId: _i(j['schedule_id'])!,
    tripIndex: _i(j['trip_index'])!,
    fromSeq: _i(j['from_seq'])!,
    toSeq: _i(j['to_seq'])!,
    stopCount: _i(j['stop_count']),
  );

  final String boardRaw;
  final bool boardApprox;
  final double? boardMinutes;
  final String arriveRaw;
  final bool arriveApprox;

  /// Null when the timetable publishes no time at the alighting stop ("via").
  final double? arriveMinutes;
  final int scheduleId;
  final int tripIndex;
  final int fromSeq;
  final int toSeq;

  /// Stops between boarding and alighting, when the API says.
  final int? stopCount;

  /// Identifies one ride, so the same bus cannot be added to the planner twice.
  String get rideKey => '$scheduleId:$tripIndex:$fromSeq:$toSeq';
}

class PlanOption {
  const PlanOption({
    required this.timetableNumber,
    required this.routeLabel,
    required this.dayType,
    required this.dayLabel,
    required this.segmentStops,
    required this.roadPath,
    required this.departures,
    required this.boardApprox,
    required this.alightApprox,
    required this.boardLabel,
    required this.alightLabel,
    this.operator = OperatorRef.goldenArrow,
    this.fare,
    this.timetableExpiredOn,
    this.boardAwayM,
    this.alightAwayM,
  });

  factory PlanOption.fromJson(Json j) {
    final operator = OperatorRef.from(
      _s(j['operator_code']),
      name: _s(j['operator_name']),
      kind: _s(j['operator_kind']),
    );
    return PlanOption(
      timetableNumber: _s(j['timetable_number']) ?? '',
      routeLabel: _s(j['route_label']) ?? '',
      dayType: _s(j['day_type']) ?? '',
      dayLabel: _s(j['day_label']) ?? '',
      segmentStops: _list(j['segment_stops']).map(PlanSegmentStop.fromJson).toList(),
      roadPath: ((j['road_path'] as List?) ?? const [])
          .map((p) => ((p as List).cast<num>()))
          .map((p) => (p[0].toDouble(), p[1].toDouble()))
          .toList(),
      departures: _list(j['departures']).map(PlanDeparture.fromJson).toList(),
      boardApprox: j['board_approx'] == true,
      alightApprox: j['alight_approx'] == true,
      boardLabel: _s(j['board_label']) ?? '',
      alightLabel: _s(j['alight_label']) ?? '',
      operator: operator,
      fare: fareShownFor(operator, Fare.fromJson(j['fare'])),
      timetableExpiredOn: _s(j['timetable_expired_on']),
      boardAwayM: _i(j['board_away_m']),
      alightAwayM: _i(j['alight_away_m']),
    );
  }

  /// Golden Arrow's timetable number ("000101"); empty for trains, which have none.
  final String timetableNumber;
  final String routeLabel;
  final String dayType;
  final String dayLabel;
  final List<PlanSegmentStop> segmentStops;

  /// The road the bus drives, as (lat, lon) pairs.
  final List<(double, double)> roadPath;
  final List<PlanDeparture> departures;
  final bool boardApprox;
  final bool alightApprox;
  final String boardLabel;
  final String alightLabel;

  final OperatorRef operator;
  final Fare? fare;

  /// How far the boarding / alighting point is from where the rider asked, in metres.
  /// The day this timetable stopped being valid, when we hold nothing newer for the
  /// service. Null in the normal case, where what we have is current.
  final String? timetableExpiredOn;

  final int? boardAwayM;
  final int? alightAwayM;

  /// What goes on the route chip: a bus number ("101" from "000101") or a train line.
  String get routeNumber => routeShortName(timetableNumber, routeLabel, operator);

  /// The official stops either side when the rider gets on / off at a point on the road.
  (String, String)? get boardBetween => officialStopsAround(boardLabel);
  (String, String)? get alightBetween => officialStopsAround(alightLabel);

  /// Getting on or off somewhere the timetable names no stop.
  bool get unofficialStop => boardBetween != null || alightBetween != null;

  /// The same option, with how far its stops are from where the rider actually asked.
  PlanOption withWalk({int? boardAwayM, int? alightAwayM}) => PlanOption(
    timetableNumber: timetableNumber,
    routeLabel: routeLabel,
    dayType: dayType,
    dayLabel: dayLabel,
    segmentStops: segmentStops,
    roadPath: roadPath,
    departures: departures,
    boardApprox: boardApprox,
    alightApprox: alightApprox,
    boardLabel: boardLabel,
    alightLabel: alightLabel,
    operator: operator,
    fare: fare,
    timetableExpiredOn: timetableExpiredOn,
    boardAwayM: boardAwayM ?? this.boardAwayM,
    alightAwayM: alightAwayM ?? this.alightAwayM,
  );
}

final _between = RegExp(r'^between (.+?) and (.+)$');

/// The two timetable stops either side of a rider's own point on the road, from the
/// API's "between CAPE TOWN and N1 FREEWAY"; null for a stop the timetable names.
(String, String)? officialStopsAround(String label) {
  final m = _between.firstMatch(label);
  return m == null ? null : (m[1]!, m[2]!);
}

/// Why a point on the road is not a sure place to catch a bus, and where is.
///
/// The planner finds these from the road a route drives, so the bus does pass. Whether it
/// stops there is up to the driver: nothing in the timetable says it will, and a rider who
/// waits there can watch it go by. The timetable's own stops are the safe bet.
String? unofficialStopAdvice(PlanOption o) => unofficialStopAdviceFor(o.boardLabel, o.alightLabel, o.operator);

/// The same, from the two labels, for screens that keep those rather than the option.
String? unofficialStopAdviceFor(String boardLabel, String alightLabel, OperatorRef operator) {
  String both((String, String) s) => '${titleCase(s.$1)} or ${titleCase(s.$2)}';
  final on = officialStopsAround(boardLabel);
  final off = officialStopsAround(alightLabel);
  if (on == null && off == null) return null;
  return [
    'Not an official stop: the ${operator.vehicle} passes here but is not sure to stop.',
    if (on != null) 'To be sure of catching it, get on at ${both(on)}.',
    if (off != null) '${on != null ? 'And get' : 'Get'} off at ${both(off)} to be sure it stops.',
  ].join(' ');
}

/// Whether the app prices a single trip on this operator.
///
/// Not Golden Arrow. It does not publish cash fares across the network, and what the API
/// holds is a cash price for a handful of routes: a rider shown R44.50 may be charged
/// something else at the door, and a wrong price is worse than none. Its GO EASY ride
/// bundles are published, and those are shown with the trip.
bool pricesShownFor(OperatorRef operator) => operator.code != OperatorRef.goldenArrow.code;

/// The fare to keep for this operator: all of it, or for Golden Arrow only the bundles
/// of rides. Null when nothing is left worth showing.
Fare? fareShownFor(OperatorRef operator, Fare? fare) {
  if (fare == null) return null;
  final kept = pricesShownFor(operator) ? fare : fare.withoutSingleTrip;
  return kept.hasAnything ? kept : null;
}

/// Which operator a timetable number belongs to, for payloads without an operator field.
OperatorRef operatorForTimetableNumber(String timetableNumber) {
  if (timetableNumber.isEmpty) return OperatorRef.metrorail;
  if (RegExp(r'^\d{6}$').hasMatch(timetableNumber)) return OperatorRef.goldenArrow;
  return OperatorRef.myciti;
}

/// The short name riders use for a route: Golden Arrow's number ("101" from "000101"),
/// or a train's line ("Monte Vista" from "Monte Vista Line OUTBOUND" or
/// "MONTE VISTA LINE: CAPE TOWN - BELLVILLE").
String routeShortName(String timetableNumber, String routeLabel, OperatorRef operator) {
  if (operator.isTrain || timetableNumber.isEmpty) {
    final line = routeLabel
        .replaceAll(RegExp(r':.*$'), '')
        .replaceAll(RegExp(r'\s+(OUTBOUND|INBOUND)\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+line\s*$', caseSensitive: false), '')
        .trim();
    final name = line.isEmpty ? routeLabel : line;
    return name == name.toUpperCase() ? titleCase(name) : name;
  }
  final trimmed = timetableNumber.replaceFirst(RegExp(r'^0+'), '');
  return trimmed.isEmpty ? timetableNumber : trimmed;
}

class PlanResponse {
  const PlanResponse({required this.from, required this.to, required this.options});

  factory PlanResponse.fromJson(Json j) => PlanResponse(
    from: j['from'] as Json?,
    to: j['to'] as Json?,
    options: _list(j['options']).map(PlanOption.fromJson).toList(),
  );

  final Json? from;
  final Json? to;
  final List<PlanOption> options;
}

// ---------------------------------------------------------------- /api/trip_stops

class TripStop {
  const TripStop({
    required this.name,
    this.lat,
    this.lon,
    required this.stopSequence,
    required this.rawValue,
    required this.cellType,
    this.departureTime,
  });

  factory TripStop.fromJson(Json j) => TripStop(
    name: _s(j['name']) ?? '',
    lat: _d(j['lat']),
    lon: _d(j['lon']),
    stopSequence: _i(j['stop_sequence']) ?? 0,
    rawValue: _s(j['raw_value']) ?? '',
    cellType: _s(j['cell_type']) ?? 'NONE',
    departureTime: _s(j['departure_time']),
  );

  final String name;
  final double? lat;
  final double? lon;
  final int stopSequence;
  final String rawValue;

  /// TIME, VIA (bus passes, no published time) or NONE.
  final String cellType;

  /// "HH:MM" or null.
  final String? departureTime;

  /// Minutes after midnight, or null when no time is published here.
  double? get minutes {
    final t = departureTime;
    if (t == null) return null;
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]).toDouble();
  }

  Json toJson() => {
    'name': name,
    'lat': lat,
    'lon': lon,
    'stop_sequence': stopSequence,
    'raw_value': rawValue,
    'cell_type': cellType,
    'departure_time': departureTime,
  };
}

class NoteDto {
  const NoteDto(this.code, this.description);

  factory NoteDto.fromJson(Json j) => NoteDto(_s(j['code']) ?? '', _s(j['description']) ?? '');

  final String code;
  final String description;

  Json toJson() => {'code': code, 'description': description};
}

class TripStopsResponse {
  const TripStopsResponse({required this.stops, required this.notes});

  factory TripStopsResponse.fromJson(Json j) => TripStopsResponse(
    stops: _list(j['stops']).map(TripStop.fromJson).toList(),
    notes: _list(j['notes']).map(NoteDto.fromJson).toList(),
  );

  final List<TripStop> stops;
  final List<NoteDto> notes;

  Json toJson() => {'stops': stops.map((s) => s.toJson()).toList(), 'notes': notes.map((n) => n.toJson()).toList()};
}

// ---------------------------------------------------------------- /api/connections

class ConnectionLeg {
  const ConnectionLeg({
    required this.fromStopId,
    required this.fromName,
    this.fromLat,
    this.fromLon,
    required this.toStopId,
    required this.toName,
    this.toLat,
    this.toLon,
    required this.routeLabel,
    required this.timetableNumber,
    required this.boardRaw,
    required this.arriveRaw,
    this.boardMinutes,
    this.arriveMinutes,
    required this.scheduleId,
    required this.tripIndex,
    required this.fromSeq,
    required this.toSeq,
    this.fare,
  });

  factory ConnectionLeg.fromJson(Json j) => ConnectionLeg(
    fromStopId: _i(j['from_stop_id'])!,
    fromName: _s(j['from_name']) ?? '',
    fromLat: _d(j['from_lat']),
    fromLon: _d(j['from_lon']),
    toStopId: _i(j['to_stop_id'])!,
    toName: _s(j['to_name']) ?? '',
    toLat: _d(j['to_lat']),
    toLon: _d(j['to_lon']),
    routeLabel: _s(j['route_label']) ?? '',
    timetableNumber: _s(j['timetable_number']) ?? '',
    boardRaw: _s(j['board_raw']) ?? '',
    arriveRaw: _s(j['arrive_raw']) ?? '',
    boardMinutes: _d(j['board_minutes']),
    arriveMinutes: _d(j['arrive_minutes']),
    scheduleId: _i(j['schedule_id'])!,
    tripIndex: _i(j['trip_index'])!,
    fromSeq: _i(j['from_seq'])!,
    toSeq: _i(j['to_seq'])!,
    fare: fareShownFor(operatorForTimetableNumber(_s(j['timetable_number']) ?? ''), Fare.fromJson(j['fare'])),
  );

  final int fromStopId;
  final String fromName;
  final double? fromLat;
  final double? fromLon;
  final int toStopId;
  final String toName;
  final double? toLat;
  final double? toLon;
  final String routeLabel;
  final String timetableNumber;
  final String boardRaw;
  final String arriveRaw;
  final double? boardMinutes;
  final double? arriveMinutes;
  final int scheduleId;
  final int tripIndex;
  final int fromSeq;
  final int toSeq;
  final Fare? fare;

  /// Legs carry no operator field, so tell from the timetable number: Metrorail's are
  /// empty, Golden Arrow's are six zero-padded digits ("000101"), and MyCiTi's are its
  /// route codes ("T01", "D05", "101").
  OperatorRef get operator => operatorForTimetableNumber(timetableNumber);

  String get routeNumber => routeShortName(timetableNumber, routeLabel, operator);

  /// "05:15" — train times arrive with seconds ("05:15:00"), so format from minutes.
  String get boardTime => boardMinutes == null ? boardRaw : _hhmm(boardMinutes!);

  /// Null when no arrival time is published.
  String? get arriveTime => arriveMinutes == null ? null : _hhmm(arriveMinutes!);

  /// The stop itself, whether or not we know where it is. It used to be null without a
  /// position, which closed the leg: a trip through Town Centre could be read on the
  /// results screen and not opened, because that one stop is unplaced on the map.
  Endpoint get from => Endpoint.stop(
    id: fromStopId,
    name: fromName,
    lat: fromLat,
    lon: fromLon,
    operatorCode: operator.code,
    operatorKind: operator.kind,
  );

  Endpoint get to => Endpoint.stop(
    id: toStopId,
    name: toName,
    lat: toLat,
    lon: toLon,
    operatorCode: operator.code,
    operatorKind: operator.kind,
  );
}

class Connection {
  const Connection({
    required this.dayType,
    required this.changeAt,
    required this.legs,
    this.waitMinutes,
    this.totalMinutes,
    this.fare,
  });

  factory Connection.fromJson(Json j) {
    final legs = _list(j['legs']).map(ConnectionLeg.fromJson).toList();
    return Connection(
      dayType: _s(j['day_type']) ?? '',
      changeAt: ((j['change_at'] as List?) ?? const []).cast<String>(),
      legs: legs,
      waitMinutes: _i(j['wait_minutes']),
      totalMinutes: _i(j['total_minutes']),
      // A total that includes a leg whose price is not shown would be a price not shown.
      fare: legs.every((l) => pricesShownFor(l.operator)) ? Fare.fromJson(j['fare']) : null,
    );
  }

  final String dayType;
  final List<String> changeAt;
  final List<ConnectionLeg> legs;

  /// Whose journey this is: "gabs", "metrorail", or both where a trip ever mixes them.
  String get operatorKey => (legs.map((l) => l.operator.code).toSet().toList()..sort()).join('+');
  final int? waitMinutes;
  final int? totalMinutes;
  final Fare? fare;

  /// One ticket covers the whole trip (Metrorail's is for the distance between the two
  /// end stations, change or no change; MyCiTi charges one fare for the whole distance),
  /// rather than a ticket per ride.
  bool get oneTicket => fare?.kind == 'through';

  /// What the whole trip costs when it starts as it does, on a weekday or not: MyCiTi's
  /// peak or saver fare, otherwise the one fare.
  int? priceOn({required bool weekday}) => fareAt(fare, weekday: weekday, boardMinutes: legs.first.boardMinutes);

  /// Each ride's own price, "Northern R12.00 + Southern R12.00", when every ride has one.
  /// Where one ticket covers the trip these are what each would cost on its own.
  String? legFaresOn({required bool weekday}) {
    final parts = [
      for (final l in legs)
        if (fareAt(l.fare, weekday: weekday, boardMinutes: l.boardMinutes) case final c?)
          '${l.routeNumber} ${formatRands(c)}',
    ];
    return parts.length == legs.length && parts.isNotEmpty ? parts.join(' + ') : null;
  }
}

class ConnectionsResponse {
  const ConnectionsResponse({
    this.legsRequired,
    required this.connections,
    this.searchIncomplete = false,
  });

  factory ConnectionsResponse.fromJson(Json j) => ConnectionsResponse(
    legsRequired: _i(j['legs_required']),
    connections: _list(j['connections']).map(Connection.fromJson).toList(),
    searchIncomplete: j['search_incomplete'] == true,
  );

  final int? legsRequired;
  final List<Connection> connections;

  /// The search was cut short rather than finished, so an empty list here is not the same
  /// as "there is no way to make this journey".
  ///
  /// The dense parts of the network can take longer to search than the API will wait. When
  /// that happens the rider used to be told no journey exists, which is a claim nobody had
  /// established - CAPE TOWN to BELLVILLE was shown as impossible for a while on exactly
  /// this path. The app must never say a journey does not exist on the strength of a
  /// search that did not finish.
  final bool searchIncomplete;
}

// ---------------------------------------------------------------- catalogue

class RouteSummary {
  const RouteSummary({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.letterGroup,
    required this.timetableCount,
    this.operatorCode = 'gabs',
  });

  factory RouteSummary.fromJson(Json j) => RouteSummary(
    id: _i(j['id'])!,
    name: _s(j['name']) ?? '',
    origin: _s(j['origin']) ?? '',
    destination: _s(j['destination']) ?? '',
    letterGroup: _s(j['letter_group']) ?? '',
    timetableCount: _i(j['timetable_count']) ?? 0,
    operatorCode: _s(j['operator_code']) ?? 'gabs',
  );

  final int id;
  final String name;
  final String origin;
  final String destination;
  final String letterGroup;
  final int timetableCount;
  final String operatorCode;
}

class TimetableInfo {
  const TimetableInfo({
    required this.id,
    required this.routeId,
    required this.timetableNumber,
    required this.isPublicHoliday,
    this.effectiveFrom,
    this.effectiveTo,
    this.pdfUrl,
  });

  factory TimetableInfo.fromJson(Json j) => TimetableInfo(
    id: _i(j['id'])!,
    routeId: _i(j['route_id']) ?? 0,
    timetableNumber: _s(j['timetable_number']) ?? '',
    isPublicHoliday: j['is_public_holiday'] == true,
    effectiveFrom: _s(j['effective_from']),
    effectiveTo: _s(j['effective_to']),
    pdfUrl: _s(j['pdf_url']),
  );

  final int id;
  final int routeId;
  final String timetableNumber;
  final bool isPublicHoliday;

  /// ISO dates; null `effectiveTo` means open-ended.
  final String? effectiveFrom;
  final String? effectiveTo;
  final String? pdfUrl;
}

class TimetableCell {
  const TimetableCell({
    required this.stopSequence,
    required this.cellType,
    this.departureTime,
    this.noteCode,
    required this.rawValue,
  });

  factory TimetableCell.fromJson(Json j) => TimetableCell(
    stopSequence: _i(j['stop_sequence']) ?? 0,
    cellType: _s(j['cell_type']) ?? 'NONE',
    departureTime: _s(j['departure_time']),
    noteCode: _s(j['note_code']),
    rawValue: _s(j['raw_value']) ?? '',
  );

  final int stopSequence;
  final String cellType;
  final String? departureTime;
  final String? noteCode;
  final String rawValue;
}

class TimetableTrip {
  const TimetableTrip({required this.tripIndex, required this.noteCodes, required this.cells});

  factory TimetableTrip.fromJson(Json j) => TimetableTrip(
    tripIndex: _i(j['trip_index']) ?? 0,
    noteCodes: ((j['note_codes'] as List?) ?? const []).cast<String>(),
    cells: _list(j['cells']).map(TimetableCell.fromJson).toList(),
  );

  final int tripIndex;
  final List<String> noteCodes;
  final List<TimetableCell> cells;
}

class TimetableSchedule {
  const TimetableSchedule({
    required this.id,
    required this.directionLabel,
    required this.dayType,
    required this.dayLabel,
    required this.noService,
    required this.stops,
    required this.trips,
  });

  factory TimetableSchedule.fromJson(Json j) => TimetableSchedule(
    id: _i(j['id'])!,
    directionLabel: _s(j['direction_label']) ?? '',
    dayType: _s(j['day_type']) ?? '',
    dayLabel: _s(j['day_label']) ?? '',
    noService: j['no_service'] == true,
    stops: _list(j['stops']).map(PlanSegmentStop.fromJson).toList(),
    trips: _list(j['trips']).map(TimetableTrip.fromJson).toList(),
  );

  final int id;
  final String directionLabel;
  final String dayType;
  final String dayLabel;
  final bool noService;
  final List<PlanSegmentStop> stops;
  final List<TimetableTrip> trips;
}

class TimetableDetail {
  const TimetableDetail({required this.info, required this.routeName, required this.notes, required this.schedules});

  factory TimetableDetail.fromJson(Json j) {
    final t = j['timetable'] as Json;
    return TimetableDetail(
      info: TimetableInfo.fromJson(t),
      routeName: _s(t['route_name']) ?? '',
      notes: _list(j['notes']).map(NoteDto.fromJson).toList(),
      schedules: _list(j['schedules']).map(TimetableSchedule.fromJson).toList(),
    );
  }

  final TimetableInfo info;
  final String routeName;
  final List<NoteDto> notes;
  final List<TimetableSchedule> schedules;
}

class GeoHit {
  const GeoHit({required this.name, required this.full, required this.lat, required this.lon});

  factory GeoHit.fromJson(Json j) =>
      GeoHit(name: _s(j['name']) ?? '', full: _s(j['full']) ?? '', lat: _d(j['lat'])!, lon: _d(j['lon'])!);

  final String name;
  final String full;
  final double lat;
  final double lon;
}

String _hhmm(double minutes) {
  final t = minutes.round() % 1440;
  return '${(t ~/ 60).toString().padLeft(2, '0')}:${(t % 60).toString().padLeft(2, '0')}';
}
