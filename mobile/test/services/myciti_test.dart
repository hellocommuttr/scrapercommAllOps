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

/// A MyCiTi option as the API returns it: a route code for a number, no fare, no PDF.
const mycitiJson = {
  'timetable_number': 'T01',
  'route_label': 'T01 to Dunoon',
  'operator_code': 'myciti',
  'operator_name': 'MyCiTi',
  'operator_kind': 'bus',
  'day_type': 'WEEKDAY',
  'day_label': 'Weekday',
  'segment_stops': [],
  'road_path': [],
  'departures': [
    {
      'board_raw': '09:35',
      'board_approx': false,
      'board_minutes': 575,
      'arrive_raw': '10:05',
      'arrive_approx': false,
      'arrive_minutes': 605,
      'schedule_id': 90001,
      'trip_index': 0,
      'from_seq': 0,
      'to_seq': 8,
      'stop_count': 7,
    },
  ],
  'board_approx': false,
  'alight_approx': false,
  'board_label': 'Civic Centre',
  'alight_label': 'Table View',
  'fare': null,
};

/// The Golden Arrow option between the two stops the rider actually chose.
const gabsJson = {
  'timetable_number': '000101',
  'route_label': 'CAPE TOWN - SEA POINT',
  'operator_code': 'gabs',
  'operator_name': 'Golden Arrow Buses',
  'operator_kind': 'bus',
  'day_type': 'WEEKDAY',
  'day_label': 'MONDAYS TO FRIDAYS',
  'segment_stops': [],
  'road_path': [],
  'departures': [
    {
      'board_raw': '09:00',
      'board_approx': false,
      'board_minutes': 540,
      'arrive_raw': '09:25',
      'arrive_approx': false,
      'arrive_minutes': 565,
      'schedule_id': 10,
      'trip_index': 0,
      'from_seq': 0,
      'to_seq': 5,
    },
  ],
  'board_approx': false,
  'alight_approx': false,
  'board_label': 'CAPE TOWN',
  'alight_label': 'SEA POINT',
  'fare': {'cash_cents': 1150, 'basis': 'go_easy'},
};

/// A weekday, so the fixtures' weekday timetables run whatever day the tests are run.
const monday = ServiceDate(2026, 9, 21);

void main() {
  group('MyCiTi options', () {
    final option = PlanOption.fromJson(mycitiJson);

    test('operator, route code and missing fare', () {
      expect(option.operator, OperatorRef.myciti);
      expect(option.operator.isTrain, isFalse);
      expect(option.operator.name, 'MyCiTi');
      expect(option.routeNumber, 'T01');
      expect(option.fare, isNull);
    });

    test('a numbered MyCiTi route keeps its number', () {
      expect(routeShortName('101', '101: Vredehoek - Gardens', OperatorRef.myciti), '101');
    });
  });

  group('operator from a timetable number', () {
    test('empty is Metrorail, six digits is Golden Arrow, anything else MyCiTi', () {
      expect(operatorForTimetableNumber(''), OperatorRef.metrorail);
      expect(operatorForTimetableNumber('000101'), OperatorRef.goldenArrow);
      expect(operatorForTimetableNumber('T01'), OperatorRef.myciti);
      expect(operatorForTimetableNumber('101'), OperatorRef.myciti);
    });

    test('a MyCiTi leg of a connection is not read as Golden Arrow', () {
      final leg = ConnectionLeg.fromJson({
        'from_stop_id': 45514,
        'from_name': 'Civic Centre',
        'from_lat': -33.92,
        'from_lon': 18.43,
        'to_stop_id': 47085,
        'to_name': 'Table View',
        'to_lat': -33.82,
        'to_lon': 18.49,
        'route_label': 'T01 to Dunoon',
        'timetable_number': 'T01',
        'board_raw': '09:35',
        'arrive_raw': '10:05',
        'board_minutes': 575,
        'arrive_minutes': 605,
        'schedule_id': 1,
        'trip_index': 0,
        'from_seq': 0,
        'to_seq': 8,
      });
      expect(leg.operator, OperatorRef.myciti);
      expect(leg.routeNumber, 'T01');
      expect(leg.from!.isStation, isFalse);
    });
  });

  group('filters across three operators', () {
    JourneySearchOutcome outcome(SearchFilters filters) => JourneyService.buildOutcome(
      from: const Endpoint.stop(id: 45514, name: 'Civic Centre', lat: -33.92, lon: 18.43, operatorCode: 'myciti'),
      to: const Endpoint.stop(id: 47085, name: 'Table View', lat: -33.82, lon: 18.49, operatorCode: 'myciti'),
      response: PlanResponse.fromJson({
        'options': [mycitiJson],
      }),
      notes: const {},
      filters: filters,
      date: const ServiceDate(2026, 9, 21),
      minutesNow: null,
      fromCache: false,
      fetchedAt: DateTime(2026),
    );

    test('MyCiTi rides show by default', () {
      final o = outcome(const SearchFilters(departAfter: 0));
      expect(o.rides.single.operator, OperatorRef.myciti);
      expect(o.vehicles, 'buses');
    });

    test('the best ride of each operator leads, so bus, MyCiTi and train can be compared', () {
      Map<String, Object?> at(Map<String, Object?> j, int schedule, int board) => {
        ...j,
        'departures': [
          {
            ...((j['departures'] as List).first as Map<String, Object?>),
            'schedule_id': schedule,
            'board_minutes': board,
            'arrive_minutes': board + 40,
          },
        ],
      };
      final train = <String, Object?>{...gabsJson, 'timetable_number': '', 'operator_code': 'metrorail', 'operator_kind': 'train'};
      final o = JourneyService.buildOutcome(
        from: const Endpoint.pin(name: 'Buh Rein', lat: -33.82, lon: 18.71),
        to: const Endpoint.pin(name: 'Cape Town', lat: -33.93, lon: 18.42),
        response: PlanResponse.fromJson({
          'options': [
            // Two trains first, then two buses, then MyCiTi: all three show before "more".
            at(train, 1, 480),
            at(train, 2, 500),
            at(gabsJson, 3, 510),
            at(gabsJson, 4, 520),
            at(mycitiJson, 5, 530),
          ],
        }),
        notes: const {},
        filters: const SearchFilters(departAfter: 0),
        date: monday,
        minutesNow: null,
        fromCache: false,
        fetchedAt: DateTime(2026),
      );
      expect(o.rides, hasLength(5));
      expect(o.bestPerOperator.map((r) => r.operator.code), ['metrorail', 'gabs', 'myciti']);
      expect(o.bestPerOperator.map((r) => r.boardMinutes), [480, 510, 530]);
    });

    test('switching MyCiTi off hides them', () {
      final o = outcome(const SearchFilters(departAfter: 0, excludedOperators: {'myciti'}));
      expect(o.rides, isEmpty);
      expect(o.hiddenByOperator, 1);
      expect(o.hasAnyDirectService, isFalse);
    });
  });

  group('other operators near the same places', () {
    late AppDatabase db;
    late _FakeApi api;
    late JourneyService journeys;

    // Two Golden Arrow stops. The same trip, planned between those two points instead,
    // is what turns up the MyCiTi stops round the corner.
    const gabsFrom = Endpoint.stop(id: 7, name: 'CAPE TOWN', lat: -33.9248, lon: 18.4241, operatorCode: 'gabs');
    const gabsTo = Endpoint.stop(id: 101, name: 'SEA POINT', lat: -33.9200, lon: 18.3860, operatorCode: 'gabs');
    // The same two points, named as the stops are: a stop called what the rider asked for
    // is where they mean, so the name goes with the point.
    const pinPlan =
        '/api/plan?from_lat=-33.9248&from_lon=18.4241&from_name=CAPE TOWN&to_lat=-33.9200&to_lon=18.3860&to_name=SEA POINT';

    Map<String, Object?> nearby(int boardAway, int alightAway) => {
      ...mycitiJson,
      'board_away_m': boardAway,
      'alight_away_m': alightAway,
    };

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
      // The stops the rider chose: one Golden Arrow option.
      api.bodies['/api/plan?from=7&to=101'] = jsonEncode({
        'options': [gabsJson],
      });
    });

    tearDown(() => db.close());

    test('MyCiTi services near the same two points are offered too, with the walk', () async {
      api.bodies[pinPlan] = jsonEncode({
        // The Golden Arrow option comes back here as well: it must not be listed twice.
        'options': [gabsJson, nearby(149, 210)],
      });

      final o = await journeys.search(gabsFrom, gabsTo, const SearchFilters(date: monday, departAfter: 0));
      expect(o.allDay.map((r) => r.operator.code), ['gabs', 'myciti']);
      final myciti = o.allDay.firstWhere((r) => r.operator == OperatorRef.myciti);
      expect(myciti.walkM, 359);
      expect(myciti.walkLabel, '359 m walk');
    });

    test('an operator whose stops are kilometres away is left out', () async {
      api.bodies[pinPlan] = jsonEncode({
        'options': [nearby(149, 9818)],
      });

      final o = await journeys.search(gabsFrom, gabsTo, const SearchFilters(date: monday, departAfter: 0));
      expect(o.allDay.every((r) => r.operator == OperatorRef.goldenArrow), isTrue);
    });

    test('an operator switched off in Filters is not shown', () async {
      api.bodies[pinPlan] = jsonEncode({
        'options': [nearby(149, 210)],
      });

      final o = await journeys.search(
        gabsFrom,
        gabsTo,
        const SearchFilters(date: monday, departAfter: 0, excludedOperators: {'myciti', 'metrorail'}),
      );
      expect(o.allDay.single.operator, OperatorRef.goldenArrow);
      expect(o.hiddenByOperator, 0);
    });

    test('two map pins are planned once, because that plan already covers every operator', () async {
      const from = Endpoint.pin(name: 'Long Street', lat: -33.9248, lon: 18.4241);
      const to = Endpoint.pin(name: 'Main Road', lat: -33.9200, lon: 18.3860);
      api.bodies['/api/plan?from_lat=-33.9248&from_lon=18.4241&from_name=Long Street&to_lat=-33.9200&to_lon=18.3860&to_name=Main Road'] = jsonEncode({
        'options': [gabsJson, nearby(149, 210)],
      });

      final o = await journeys.search(from, to, const SearchFilters(date: monday, departAfter: 0));
      expect(o.allDay.map((r) => r.operator.code), ['gabs', 'myciti']);
      expect(api.paths.where((p) => p.startsWith('/api/plan')).length, 1);
    });

    test('from your location, the train from the nearest station is offered beside the bus', () async {
      // Standing at Buh Rein, going to Cape Town. The plan from that point only reaches
      // the bus stop; Kraaifontein station is 3.5 km away.
      const here = Endpoint.pin(name: 'My location', lat: -33.8205, lon: 18.7141);
      const capeTown = Endpoint.pin(name: 'Cape Town', lat: -33.9288, lon: 18.4172);
      api.bodies['/api/plan?from_lat=-33.8205&from_lon=18.7141&from_name=My location&to_lat=-33.9288&to_lon=18.4172&to_name=Cape Town'] =
          jsonEncode({
        'options': [gabsJson],
      });
      api.bodies['/api/plan?from=44240&to=43907'] = jsonEncode({
        'options': [
          {
            ...gabsJson,
            'timetable_number': '',
            'route_label': 'Northern Line',
            'operator_code': 'metrorail',
            'operator_name': 'Metrorail',
            'operator_kind': 'train',
            'board_label': 'KRAAIFONTEIN',
            'alight_label': 'CAPE TOWN',
            'fare': null,
            'departures': [
              {
                'board_raw': '08:10',
                'board_approx': false,
                'board_minutes': 490,
                'arrive_raw': '09:05',
                'arrive_approx': false,
                'arrive_minutes': 545,
                'schedule_id': 70001,
                'trip_index': 0,
                'from_seq': 0,
                'to_seq': 20,
              },
            ],
          },
        ],
      });

      final o = await journeys.search(here, capeTown, const SearchFilters(date: monday, departAfter: 0));
      expect(o.allDay.map((r) => r.operator.code).toSet(), {'gabs', 'metrorail'});
      final train = o.allDay.firstWhere((r) => r.operator == OperatorRef.metrorail);
      expect(train.option.boardAwayM, inInclusiveRange(3400, 3550));
      // Too far to call a walk: the card says how far each stop is instead.
      // "Cape Town" is Cape Town station by name, so there is no walk at that end.
      expect(train.walkLabel, '3.5 km to the stop');
      expect(train.walkLabel, isNot(contains('walk')));
    });

    test('a place called what a station is called starts from that station', () async {
      // The map puts Khayelitsha 4.5 km from Khayelitsha station, beyond the nearest-stop
      // reach of Nonkqubela; the rider named Khayelitsha and means that station.
      const khayelitsha = Endpoint.pin(name: 'Khayelitsha', lat: -34.0406, lon: 18.6674);
      const capeTown = Endpoint.pin(name: 'Cape Town', lat: -33.9288, lon: 18.4172);
      api.bodies['/api/plan?from_lat=-34.0406&from_lon=18.6674&from_name=Khayelitsha&to_lat=-33.9288&to_lon=18.4172&to_name=Cape Town'] =
          jsonEncode({'options': []});
      await journeys.search(khayelitsha, capeTown, const SearchFilters(date: monday, departAfter: 0));
      final trainPlans = api.paths.where((p) => p.startsWith('/api/plan?from=') && p.endsWith('&to=43907'));
      expect(trainPlans, ['/api/plan?from=44412&to=43907']);
    });

    test('two stops the rider chose are not swapped for other operators far away', () async {
      final o = await journeys.search(gabsFrom, gabsTo, const SearchFilters(date: monday, departAfter: 0));
      expect(o.allDay.every((r) => r.operator == OperatorRef.goldenArrow), isTrue);
      expect(api.paths.where((p) => p.startsWith('/api/plan?from=') && p != '/api/plan?from=7&to=101'), isEmpty);
    });
  });

  group('bundled seed', () {
    late AppDatabase db;
    late ReferenceDataService reference;

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDatabase(NativeDatabase.memory());
      final settings = SettingsService(db: db);
      await settings.load();
      reference = ReferenceDataService(db: db, api: _NoApi(), settings: settings);
      await reference.seedIfNeeded(assetJson: File('assets/seed/seed.json').readAsStringSync());
    });

    tearDown(() => db.close());

    test('ships all three operators, with MyCiTi routes and stops', () async {
      final ops = await reference.operators();
      expect(ops.map((o) => o.code), containsAll(['gabs', 'metrorail', 'myciti']));
      final routes = await reference.searchRoutes('', operatorCode: 'myciti');
      expect(routes.length, greaterThan(40));
      final stops = (await reference.searchStops('civic')).where((s) => s.operatorCode == 'myciti');
      expect(stops, isNotEmpty);
    });

    test('a changed snapshot is loaded even when the newest timetable date is the same', () async {
      final seed = File('assets/seed/seed.json').readAsStringSync();
      // Same data, new version string: the app must reload rather than compare dates.
      final other = seed.replaceFirst(RegExp('"version":"[^"]*"'), '"version":"2026-09-05T17:15:15Z+different"');
      await db.delete(db.busRoutes).go();
      await reference.seedIfNeeded(assetJson: other);
      expect(await reference.searchRoutes(''), isNotEmpty);
    });
  });
}

/// Answers from a map of full request keys ("path?sorted=query"), recording what was asked.
class _FakeApi implements CommuttrApi {

  /// What the app reported about usage: the server cannot see cached or picker searches.
  final List<Map<String, Object?>> posts = [];
  String? deviceId;

  @override
  Future<void> post(String path, Map<String, Object?> body) async => posts.add({'path': path, ...body});

  @override
  void identify({String? deviceId, String? client}) => this.deviceId = deviceId;
  final Map<String, String> bodies = {};
  final List<String> paths = [];

  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) async {
    final q = (query?.entries.toList() ?? [])..sort((a, b) => a.key.compareTo(b.key));
    final key = q.isEmpty ? path : '$path?${q.map((e) => '${e.key}=${e.value}').join('&')}';
    paths.add(key);
    final body = bodies[key];
    if (body == null) throw ApiException(ApiFailure.badRequest, 'no stub for $key', statusCode: 404);
    return body;
  }
}

class _NoApi implements CommuttrApi {

  /// What the app reported about usage: the server cannot see cached or picker searches.
  final List<Map<String, Object?>> posts = [];
  String? deviceId;

  @override
  Future<void> post(String path, Map<String, Object?> body) async => posts.add({'path': path, ...body});

  @override
  void identify({String? deviceId, String? client}) => this.deviceId = deviceId;
  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) =>
      throw const ApiException(ApiFailure.offline, 'offline');
}
