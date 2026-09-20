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

    // A Golden Arrow stop and a MyCiTi stop 150 m away, at both ends of the trip.
    const gabsFrom = Endpoint.stop(id: 7, name: 'CAPE TOWN', lat: -33.9248, lon: 18.4241, operatorCode: 'gabs');
    const gabsTo = Endpoint.stop(id: 101, name: 'SEA POINT', lat: -33.9200, lon: 18.3860, operatorCode: 'gabs');

    String nearest(int id, String name, int distance) =>
        '{"stops":[{"id":$id,"name":"$name","lat":-33.92,"lon":18.42,'
        '"operator_code":"myciti","operator_kind":"bus","distance_m":$distance}]}';

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

    test("MyCiTi's nearby stops are offered too, with the walk", () async {
      api.bodies['/api/nearest_stops?lat=-33.9248&limit=1&lon=18.4241&operator=myciti'] = nearest(45516, 'Lower Plein', 149);
      api.bodies['/api/nearest_stops?lat=-33.9200&limit=1&lon=18.3860&operator=myciti'] = nearest(45600, 'Sea Point', 210);
      api.bodies['/api/plan?from=45516&to=45600'] = jsonEncode({
        'options': [mycitiJson],
      });

      final o = await journeys.search(gabsFrom, gabsTo, const SearchFilters(departAfter: 0));
      expect(o.allDay.map((r) => r.operator.code), containsAll(['gabs', 'myciti']));
      final myciti = o.allDay.firstWhere((r) => r.operator == OperatorRef.myciti);
      expect(myciti.walkM, 359);
      expect(myciti.walkLabel, '359 m walk');
    });

    test('an operator whose stops are kilometres away is left out', () async {
      api.bodies['/api/nearest_stops?lat=-33.9248&limit=1&lon=18.4241&operator=myciti'] = nearest(45516, 'Lower Plein', 149);
      api.bodies['/api/nearest_stops?lat=-33.9200&limit=1&lon=18.3860&operator=myciti'] = nearest(48741, 'Soldier', 9818);

      final o = await journeys.search(gabsFrom, gabsTo, const SearchFilters(departAfter: 0));
      expect(o.allDay.every((r) => r.operator == OperatorRef.goldenArrow), isTrue);
    });

    test('an operator switched off in Filters is not fetched at all', () async {
      final o = await journeys.search(
        gabsFrom,
        gabsTo,
        const SearchFilters(departAfter: 0, excludedOperators: {'myciti', 'metrorail'}),
      );
      expect(o.allDay.single.operator, OperatorRef.goldenArrow);
      expect(api.paths.where((p) => p.contains('nearest_stops')), isEmpty);
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
  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) =>
      throw const ApiException(ApiFailure.offline, 'offline');
}
