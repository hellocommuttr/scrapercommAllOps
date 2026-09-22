import 'dart:io';

import 'package:commuttr/core/service_day.dart';
import 'package:commuttr/data/api/commuttr_api.dart';
import 'package:commuttr/data/db/app_database.dart';
import 'package:commuttr/data/models/models.dart';
import 'package:commuttr/services/journey_service.dart';
import 'package:commuttr/services/reference_data_service.dart';
import 'package:commuttr/services/settings_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// A train option exactly as the AllOps API returns it (no timetable number, times with
/// seconds, a PRASA zone fare).
const trainJson = {
  'timetable_number': null,
  'route_label': 'Monte Vista Line OUTBOUND',
  'operator_code': 'metrorail',
  'operator_name': 'Metrorail',
  'operator_kind': 'train',
  'day_type': 'WEEKDAY',
  'day_label': 'Weekday',
  'segment_stops': [],
  'road_path': [],
  'departures': [
    {
      'board_raw': '05:15:00',
      'board_approx': false,
      'board_minutes': 315,
      'arrive_raw': '06:10:00',
      'arrive_approx': false,
      'arrive_minutes': 370,
      'schedule_id': 24936,
      'trip_index': 0,
      'from_seq': 0,
      'to_seq': 10,
      'stop_count': 9,
    },
  ],
  'board_approx': false,
  'alight_approx': false,
  'board_label': 'CAPE TOWN',
  'alight_label': 'BELLVILLE',
  'fare': {
    'code': 'Z2',
    'per_ride_cents': null,
    'weekly_cents': 7000,
    'monthly_cents': 22000,
    'basis': 'prasa_zone',
    'basis_from': 'Z2',
    'basis_to': '18.7 km apart',
    'zone_approx': false,
    'cash_cents': 1200,
    'cash_effective_from': '2025-08-01',
    'return_cents': 2400,
    'weekly_sat_cents': 8000,
  },
};

const busJson = {
  'timetable_number': '000101',
  'route_label': 'BELLVILLE - ELSIES RIVER - CAPE TOWN',
  'operator_code': 'gabs',
  'operator_name': 'Golden Arrow Buses',
  'operator_kind': 'bus',
  'day_type': 'WEEKDAY',
  'day_label': 'MONDAYS TO FRIDAYS',
  'segment_stops': [],
  'road_path': [],
  'departures': [
    {
      'board_raw': '05:45',
      'board_approx': false,
      'board_minutes': 345,
      'arrive_raw': '06:45',
      'arrive_approx': false,
      'arrive_minutes': 405,
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
  'fare': {'per_ride_cents': 2680, 'cash_cents': null, 'basis': 'go_easy'},
};

const monday = ServiceDate(2026, 9, 14);
const from = Endpoint.stop(id: 43907, name: 'CAPE TOWN', lat: -33.92, lon: 18.43, operatorKind: 'train');
const to = Endpoint.stop(id: 43942, name: 'BELLVILLE', lat: -33.90, lon: 18.63, operatorKind: 'train');

JourneySearchOutcome outcome(SearchFilters filters) => JourneyService.buildOutcome(
  from: from,
  to: to,
  response: PlanResponse.fromJson({
    'options': [trainJson, busJson],
  }),
  notes: const {},
  filters: filters,
  date: monday,
  minutesNow: null,
  fromCache: false,
  fetchedAt: DateTime(2026),
);

void main() {
  group('train options', () {
    final train = PlanOption.fromJson(trainJson);

    test('parse operator, line name and fare', () {
      expect(train.operator, OperatorRef.metrorail);
      expect(train.operator.isTrain, isTrue);
      expect(train.timetableNumber, '');
      expect(train.routeNumber, 'Monte Vista');
      expect(train.fare!.cashCents, 1200);
      expect(train.fare!.returnCents, 2400);
      expect(train.departures.single.stopCount, 9);
    });

    test('route names from the catalogue read as lines', () {
      expect(routeShortName('', 'CENTRAL LINE: CAPE TOWN - BELLVILLE', OperatorRef.metrorail), 'Central');
      expect(routeShortName('000101', 'BELLVILLE - CAPE TOWN', OperatorRef.goldenArrow), '101');
    });

    test('a bus card price is never the cash fare', () {
      final bus = PlanOption.fromJson(busJson);
      expect(bus.operator, OperatorRef.goldenArrow);
      // Golden Arrow prices are not shown at all for now (see pricesShownFor).
      expect(bus.fare?.cashCents, isNull);
    });

    test('formatRands', () {
      expect(formatRands(1200), 'R12.00');
      expect(formatRands(4150), 'R41.50');
    });
  });

  group('connection legs', () {
    test('an unnumbered leg is a train, and times drop their seconds', () {
      final leg = ConnectionLeg.fromJson({
        'from_stop_id': 1,
        'from_name': 'CAPE TOWN',
        'from_lat': -33.9,
        'from_lon': 18.4,
        'to_stop_id': 2,
        'to_name': 'BELLVILLE',
        'to_lat': -33.9,
        'to_lon': 18.6,
        'route_label': 'Central Line OUTBOUND',
        'timetable_number': null,
        'board_raw': '05:15:00',
        'arrive_raw': '06:10:00',
        'board_minutes': 315,
        'arrive_minutes': 370,
        'schedule_id': 1,
        'trip_index': 0,
        'from_seq': 0,
        'to_seq': 5,
      });
      expect(leg.operator.isTrain, isTrue);
      expect(leg.boardTime, '05:15');
      expect(leg.arriveTime, '06:10');
      expect(leg.from!.displayName, 'Cape Town station');
    });
  });

  group('operator filter', () {
    test('both operators by default, first and last across both', () {
      final o = outcome(const SearchFilters(departAfter: 0));
      expect(o.rides.map((r) => r.operator.code), ['metrorail', 'gabs']);
      expect(o.vehicles, 'buses and trains');
    });

    test('switching buses off leaves only trains', () {
      final o = outcome(const SearchFilters(departAfter: 0, excludedOperators: {'gabs'}));
      expect(o.rides.single.operator, OperatorRef.metrorail);
      expect(o.hiddenByOperator, 1);
      expect(o.vehicles, 'trains');
      expect(o.vehicle, 'train');
    });

    test('the filter counts towards the badge', () {
      expect(const SearchFilters(excludedOperators: {'metrorail'}).activeCount, 1);
    });
  });

  group('stops and stations', () {
    test('a station and a bus stop with the same name read differently', () {
      const station = StopDto(
        id: 1,
        name: 'CAPE TOWN',
        lat: 0,
        lon: 0,
        operatorCode: 'metrorail',
        operatorKind: 'train',
      );
      const busStop = StopDto(id: 2, name: 'CAPE TOWN', lat: 0, lon: 0);
      expect(station.displayName, 'Cape Town station');
      expect(busStop.displayName, 'Cape Town');
      expect(station.endpoint!.isStation, isTrue);
    });

    test('an endpoint saved before trains existed still loads as a bus stop', () {
      final e = Endpoint.fromJson({'kind': 'stop', 'id': 7, 'name': 'BELLVILLE', 'lat': -33.9, 'lon': 18.6});
      expect(e.isStation, isFalse);
      expect(e.displayName, 'Bellville');
      expect(Endpoint.fromJson(from.toJson()).isStation, isTrue);
    });
  });

  group('seed', () {
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

    test('loads both operators, their stations and their lines', () async {
      final ops = await reference.operators();
      expect(ops.map((o) => o.code), containsAll(['gabs', 'metrorail']));
      final stations = (await reference.searchStops('cape town')).where((s) => s.isStation);
      expect(stations, isNotEmpty);
      final lines = await reference.searchRoutes('', operatorCode: 'metrorail');
      expect(lines, isNotEmpty);
      expect(lines.every((r) => r.operatorCode == 'metrorail'), isTrue);
    });

    test('an unnumbered train timetable never matches a lookup', () async {
      expect(await reference.currentTimetable('', monday), isNull);
      expect(await reference.notesFor(''), isEmpty);
    });
  });
}

class _NoApi implements CommuttrApi {
  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) =>
      throw const ApiException(ApiFailure.offline, 'offline');
}
