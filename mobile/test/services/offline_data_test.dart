import 'dart:convert';
import 'dart:io';

import 'package:commuttr/core/service_day.dart';
import 'package:commuttr/data/api/commuttr_api.dart';
import 'package:commuttr/data/db/app_database.dart';
import 'package:commuttr/data/models/models.dart';
import 'package:commuttr/services/cached_api_service.dart';
import 'package:commuttr/services/connectivity_service.dart';
import 'package:commuttr/services/journey_service.dart';
import 'package:commuttr/services/planner_service.dart';
import 'package:commuttr/services/reference_data_service.dart';
import 'package:commuttr/services/settings_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers from a map of path -> body, or fails as if the phone were offline.
class FakeApi implements CommuttrApi {
  final Map<String, String> bodies = {};
  bool offline = false;
  int calls = 0;

  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) async {
    calls++;
    if (offline) throw const ApiException(ApiFailure.offline, 'no network');
    final body = bodies[path];
    if (body == null) throw ApiException(ApiFailure.badRequest, 'not found: $path', statusCode: 404);
    return body;
  }
}

const planJson = {
  'from': {'id': 7, 'name': 'BELLVILLE', 'lat': -33.89, 'lon': 18.63},
  'to': {'id': 101, 'name': 'CAPE TOWN', 'lat': -33.92, 'lon': 18.42},
  'options': [
    {
      'timetable_number': '000101',
      'route_label': 'BELLVILLE - CAPE TOWN',
      'day_type': 'WEEKDAY',
      'day_label': 'MONDAYS TO FRIDAYS',
      'segment_stops': [],
      'road_path': [
        [-33.89, 18.63],
        [-33.92, 18.42],
      ],
      'departures': [
        {
          'board_raw': '05:45',
          'board_approx': false,
          'board_minutes': 345,
          'arrive_raw': '06:45',
          'arrive_approx': false,
          'arrive_minutes': 405.5,
          'schedule_id': 10213,
          'trip_index': 0,
          'from_seq': 0,
          'to_seq': 10,
        },
      ],
      'board_approx': false,
      'alight_approx': false,
      'board_label': 'BELLVILLE',
      'alight_label': 'CAPE TOWN',
    },
  ],
};

const from = Endpoint.stop(id: 7, name: 'BELLVILLE', lat: -33.89, lon: 18.63);
const to = Endpoint.stop(id: 101, name: 'CAPE TOWN', lat: -33.92, lon: 18.42);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late FakeApi api;
  late SettingsService settings;
  late ConnectivityService connectivity;
  late CachedApiService cached;
  late ReferenceDataService reference;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi();
    settings = SettingsService(db: db);
    await settings.load();
    connectivity = ConnectivityService();
    cached = CachedApiService(db: db, api: api, connectivity: connectivity, settings: settings);
    reference = ReferenceDataService(db: db, api: api, settings: settings);
  });

  tearDown(() => db.close());

  group('bundled seed', () {
    test('loads the real seed asset and searches stops offline', () async {
      final seed = File('assets/seed/seed.json').readAsStringSync();
      await reference.seedIfNeeded(assetJson: seed);
      expect(await reference.stopCount(), greaterThan(200));
      final hits = await reference.searchStops('bellv');
      expect(hits.first.name, startsWith('BELLVILLE'));
      expect(api.calls, 0, reason: 'first run must not need the network');
    });

    test('footnote legends come from the seed', () async {
      await reference.seedIfNeeded(assetJson: File('assets/seed/seed.json').readAsStringSync());
      final notes = await reference.notesFor('000101');
      expect(notes['b'], 'Fridays');
    });

    test('is not reloaded when the same version is already there', () async {
      final seed = File('assets/seed/seed.json').readAsStringSync();
      await reference.seedIfNeeded(assetJson: seed);
      await db.delete(db.timetables).go();
      await reference.seedIfNeeded(assetJson: seed);
      expect(await db.timetables.count().getSingle(), 0);
    });
  });

  group('cache', () {
    test('a search that worked online works offline, flagged as saved', () async {
      api.bodies['/api/plan'] = jsonEncode(planJson);
      final journeys = JourneyService(api: cached, reference: reference);

      final online = await journeys.plan(from, to);
      expect(online.fromCache, isFalse);
      expect(online.data.options.single.departures.single.arriveMinutes, 405.5);

      api.offline = true;
      final offline = await journeys.plan(from, to);
      expect(offline.fromCache, isTrue);
      expect(offline.data.options.single.routeNumber, '101');
      expect(connectivity.isOffline, isTrue);
    });

    test('a new search offline says it is not saved', () async {
      api.offline = true;
      final journeys = JourneyService(api: cached, reference: reference);
      expect(() => journeys.plan(from, to), throwsA(isA<NotAvailableOffline>()));
    });

    test('server errors are not hidden behind the cache', () async {
      api.bodies['/api/plan'] = jsonEncode(planJson);
      final journeys = JourneyService(api: cached, reference: reference);
      await journeys.plan(from, to);
      api.bodies.remove('/api/plan');
      expect(() => journeys.plan(from, to), throwsA(isA<ApiException>()));
    });

    test('pinned responses survive clearUnpinned', () async {
      api.bodies['/api/plan'] = jsonEncode(planJson);
      final journeys = JourneyService(api: cached, reference: reference);
      await journeys.plan(from, to, pin: true);
      await cached.clearUnpinned();
      api.offline = true;
      expect((await journeys.plan(from, to)).fromCache, isTrue);
    });
  });

  group('planner', () {
    test('keeps a ride with its stop-time snapshot, and tracks the active trip', () async {
      final planner = PlannerService(db: db, settings: settings);
      final plan = PlanResponse.fromJson(planJson);
      final option = plan.options.single;
      final ride = Ride(
        from: from,
        to: to,
        option: option,
        departure: option.departures.single,
        date: const ServiceDate(2026, 9, 14),
      );
      final trip = TripStopsResponse.fromJson({
        'stops': [
          {
            'name': 'BELLVILLE',
            'stop_sequence': 0,
            'raw_value': '05:45',
            'cell_type': 'TIME',
            'departure_time': '05:45',
          },
          {
            'name': 'CAPE TOWN',
            'stop_sequence': 10,
            'raw_value': '06:45',
            'cell_type': 'TIME',
            'departure_time': '06:45',
          },
        ],
        'notes': [],
      });

      final id = await planner.add(ride, trip: trip);
      expect(await planner.contains(ride.date, ride.departure.rideKey), isTrue);

      final saved = (await planner.forDate(ride.date)).single;
      expect(saved.boardTime, '05:45');
      expect(saved.trip!.stops.last.minutes, 405);
      expect(saved.to.displayName, 'Cape Town');

      await planner.start(id);
      expect((await planner.active())!.status, JourneyStatus.active);
      await planner.complete(id);
      expect(await planner.active(), isNull);
      expect((await planner.byId(id))!.status, JourneyStatus.completed);
    });
  });
}
