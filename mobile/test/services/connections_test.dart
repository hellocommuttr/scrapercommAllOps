import 'dart:convert';
import 'dart:io';

import 'package:commuttr/core/service_day.dart';
import 'package:commuttr/data/api/commuttr_api.dart';
import 'package:commuttr/data/db/app_database.dart';
import 'package:commuttr/data/models/models.dart';
import 'package:commuttr/services/cached_api_service.dart';
import 'package:commuttr/services/connectivity_service.dart';
import 'package:commuttr/services/journey_service.dart';
import 'package:commuttr/services/reference_data_service.dart';
import 'package:commuttr/services/settings_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Journeys that need a change, alongside the ones that don't.
///
/// The app asked the API for these only when nothing ran straight through, so a single
/// direct bus hid every other way to make the trip: Buh Rein to Bellville showed one
/// Golden Arrow bus and none of the journeys that change at Cape Town, and a rider
/// looking for the train was shown nothing at all. The web app had always asked for both.
void main() {
  const monday = ServiceDate(2026, 1, 5);

  /// One direct Golden Arrow bus between the two stops the rider chose.
  const directJson = {
    'timetable_number': '000101',
    'route_label': 'BUH REIN - BELLVILLE',
    'operator_code': 'gabs',
    'operator_name': 'Golden Arrow Buses',
    'operator_kind': 'bus',
    'day_type': 'WEEKDAY',
    'day_label': 'MONDAYS TO FRIDAYS',
    'segment_stops': [],
    'road_path': [],
    'departures': [
      {
        'board_raw': '05:50',
        'board_approx': false,
        'board_minutes': 350,
        'arrive_raw': '06:40',
        'arrive_approx': false,
        'arrive_minutes': 400,
        'schedule_id': 5001,
        'trip_index': 0,
        'from_seq': 0,
        'to_seq': 6,
        'stop_count': 5,
      },
    ],
    'board_approx': false,
    'alight_approx': false,
    'board_label': 'BUH REIN',
    'alight_label': 'BELLVILLE',
    'fare': null,
  };

  /// One leg of a journey with a change, for whichever operator [operatorCode] names.
  Map<String, Object?> leg({
    required int scheduleId,
    required String routeLabel,
    required String timetableNumber,
    required String board,
    required String arrive,
    required String fromName,
    required String toName,
  }) => {
    'from_stop_id': scheduleId,
    'from_name': fromName,
    'to_stop_id': scheduleId + 1,
    'to_name': toName,
    'route_label': routeLabel,
    'timetable_number': timetableNumber,
    'board_raw': board,
    'arrive_raw': arrive,
    'board_minutes': _minutes(board),
    'arrive_minutes': _minutes(arrive),
    'schedule_id': scheduleId,
    'trip_index': 0,
    'from_seq': 0,
    'to_seq': 4,
    'fare': null,
  };

  /// Two trains, changing at Cape Town. A Metrorail timetable number is empty.
  final trainConnection = {
    'day_type': 'WEEKDAY',
    'change_at': ['CAPE TOWN'],
    'wait_minutes': 15,
    'total_minutes': 95,
    'fare': null,
    'legs': [
      leg(
        scheduleId: 7001,
        routeLabel: 'NORTHERN LINE',
        timetableNumber: '',
        board: '05:50',
        arrive: '06:45',
        fromName: 'BUH REIN',
        toName: 'CAPE TOWN',
      ),
      leg(
        scheduleId: 7003,
        routeLabel: 'SOUTHERN LINE',
        timetableNumber: '',
        board: '07:00',
        arrive: '07:25',
        fromName: 'CAPE TOWN',
        toName: 'BELLVILLE',
      ),
    ],
  };

  const from = Endpoint.stop(id: 3370, name: 'BUH REIN', lat: -33.8300, lon: 18.7100, operatorCode: 'gabs');
  const to = Endpoint.stop(id: 412, name: 'BELLVILLE', lat: -33.9020, lon: 18.6290, operatorCode: 'gabs');

  late AppDatabase db;
  late _FakeApi api;
  late JourneyService journeys;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsService(db: db);
    await settings.load();
    api = _FakeApi();
    final cached = CachedApiService(db: db, api: api, connectivity: ConnectivityService(), settings: settings);
    final reference = ReferenceDataService(db: db, api: api, settings: settings);
    await reference.seedIfNeeded(assetJson: File('assets/seed/seed.json').readAsStringSync());
    journeys = JourneyService(api: cached, reference: reference);
    api.bodies['/api/plan?from=3370&to=412'] = jsonEncode({
      'options': [directJson],
    });
    api.bodies['/api/connections?from=3370&to=412'] = jsonEncode({
      'legs_required': 2,
      'connections': [trainConnection],
    });
  });

  tearDown(() => db.close());

  test('a journey with a change is offered even when a direct bus runs', () async {
    final o = await journeys.search(from, to, const SearchFilters(date: monday, departAfter: 0));

    expect(o.hasAnyDirectService, isTrue, reason: 'the direct bus is still there');
    expect(o.rides, isNotEmpty, reason: 'the direct bus must not be thrown away');
    expect(o.connections, hasLength(1), reason: 'and the trip with a change is offered alongside it');
    expect(o.connections.single.changeAt, ['CAPE TOWN']);
    expect(api.paths, contains('/api/connections'));
  });

  test('the change is still offered when nothing runs straight through', () async {
    api.bodies['/api/plan?from=3370&to=412'] = jsonEncode({'options': []});

    final o = await journeys.search(from, to, const SearchFilters(date: monday, departAfter: 0));

    expect(o.hasAnyDirectService, isFalse);
    expect(o.connections, hasLength(1));
  });

  test('a connection whose operator is switched off is not offered', () async {
    final o = await journeys.search(
      from,
      to,
      const SearchFilters(date: monday, departAfter: 0, excludedOperators: {'metrorail'}),
    );

    expect(o.connections, isEmpty, reason: 'both legs are trains');
    expect(o.rides, isNotEmpty, reason: 'the direct bus is unaffected');
  });

  test('a connection for another day type is not shown as if it ran today', () async {
    api.bodies['/api/connections?from=3370&to=412'] = jsonEncode({
      'legs_required': 2,
      'connections': [
        {...trainConnection, 'day_type': 'SATURDAY'},
      ],
    });

    final o = await journeys.search(from, to, const SearchFilters(date: monday, departAfter: 0));

    expect(o.connections, isEmpty);
  });

  /// A two-bus trip leaving at [board], changing at Cape Town after [wait] minutes.
  Map<String, Object?> busTrip(String board, {required int wait, required int total}) {
    String at(int m) => '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
    final b = _minutes(board);
    final change = b + 60;
    return {
      'day_type': 'WEEKDAY',
      'change_at': ['CAPE TOWN'],
      'wait_minutes': wait,
      'total_minutes': total,
      'fare': null,
      'legs': [
        leg(
          scheduleId: 8000 + b,
          routeLabel: '101',
          timetableNumber: '000101',
          board: board,
          arrive: at(change),
          fromName: 'BUH REIN',
          toName: 'CAPE TOWN',
        ),
        leg(
          scheduleId: 9000 + b,
          routeLabel: '1501',
          timetableNumber: '001501',
          board: at(change + wait),
          arrive: at(b + total),
          fromName: 'CAPE TOWN',
          toName: 'BELLVILLE',
        ),
      ],
    };
  }

  /// The three the live API gives for Buh Rein to Bellville, in the order it gives them.
  void threeTrips() => api.bodies['/api/connections?from=3370&to=412'] = jsonEncode({
    'legs_required': 2,
    'connections': [
      busTrip('07:10', wait: 10, total: 100),
      busTrip('05:30', wait: 25, total: 170),
      busTrip('05:50', wait: 15, total: 190),
    ],
  });

  List<String> boards(JourneySearchOutcome o) => [for (final c in o.connections) c.legs.first.boardRaw];

  test('the next to leave leads, whatever order the API sent them in', () async {
    threeTrips();

    final o = await journeys.search(from, to, const SearchFilters(date: monday, departAfter: 0));

    expect(boards(o), ['05:30', '05:50', '07:10']);
  });

  test('a trip whose first ride has already left is not offered', () async {
    threeTrips();

    final o = await journeys.search(from, to, const SearchFilters(date: monday, departAfter: 5 * 60 + 45));

    expect(boards(o), ['05:50', '07:10']);
    expect(o.allDayConnections, hasLength(3), reason: 'the whole day is kept, for "see the whole day"');
  });

  test('arrive by keeps only trips whose last ride gets in by then', () async {
    threeTrips();

    // 05:30 + 170 min = 08:20, 05:50 + 190 = 09:00, 07:10 + 100 = 08:50.
    final o = await journeys.search(from, to, const SearchFilters(date: monday, departAfter: 0, arriveBy: 8 * 60 + 50));

    expect(boards(o), ['05:30', '07:10']);
  });

  test('fastest puts the shortest trip first', () async {
    threeTrips();

    final o = await journeys.search(
      from,
      to,
      const SearchFilters(date: monday, departAfter: 0, preference: JourneyPreference.fastest),
    );

    expect(boards(o), ['07:10', '05:30', '05:50']);
  });

  test('a failure fetching connections still returns the direct rides', () async {
    api.bodies.remove('/api/connections?from=3370&to=412');

    final o = await journeys.search(from, to, const SearchFilters(date: monday, departAfter: 0));

    expect(o.rides, isNotEmpty);
    expect(o.connections, isEmpty);
  });
}

int _minutes(String hhmm) {
  final p = hhmm.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

/// Answers from a map of full request keys ("path?sorted=query"), recording what was asked.
class _FakeApi implements CommuttrApi {
  final Map<String, String> bodies = {};
  final List<String> paths = [];

  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) async {
    final q = (query?.entries.toList() ?? [])..sort((a, b) => a.key.compareTo(b.key));
    final key = q.isEmpty ? path : '$path?${q.map((e) => '${e.key}=${e.value}').join('&')}';
    paths.add(path);
    final body = bodies[key];
    if (body == null) throw Exception('no canned answer for $key');
    return body;
  }
}
