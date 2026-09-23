import 'package:commuttr/core/service_day.dart';
import 'package:commuttr/data/models/models.dart';
import 'package:commuttr/app/app.locator.dart';
import 'package:commuttr/data/db/app_database.dart';
import 'package:commuttr/services/journey_service.dart';
import 'package:commuttr/services/planner_service.dart';
import 'package:commuttr/services/settings_service.dart';
import 'package:commuttr/ui/views/connection_detail/connection_detail_viewmodel.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the home screen shows before "view more ways with a change".
///
/// Buh Rein to Kalk Bay offered one card: three Golden Arrow buses, 3h30m. Two trains do
/// the same trip in 2h09m for R14.00, and they were inside "view 16 more ways". Hiding
/// another bus behind a bus is a shorter screen; hiding the only train behind a bus is a
/// rider who never learns the train runs.
void main() {
  Map<String, dynamic> leg(String timetableNumber, String from, String to) => {
    'from_stop_id': 1,
    'from_name': from,
    'from_lat': -33.9,
    'from_lon': 18.4,
    'to_stop_id': 2,
    'to_name': to,
    'to_lat': -34.0,
    'to_lon': 18.5,
    'route_label': '$from - $to',
    'timetable_number': timetableNumber,
    'board_raw': '05:30',
    'arrive_raw': '06:45',
    'board_minutes': 330,
    'arrive_minutes': 405,
    'schedule_id': 1,
    'trip_index': 1,
    'from_seq': 1,
    'to_seq': 5,
  };

  Connection journey(List<Map<String, dynamic>> legs) =>
      Connection.fromJson({'day_type': 'WEEKDAY', 'change_at': const ['CAPE TOWN'], 'legs': legs});

  // Golden Arrow's timetable numbers are six digits; Metrorail's are empty.
  final bus = journey([leg('001501', 'BUH REIN', 'CAPE TOWN'), leg('008601', 'CAPE TOWN', "PICK 'N PAY")]);
  final anotherBus = journey([leg('007801', 'BUH REIN', 'CAPE TOWN'), leg('005401', 'CAPE TOWN', "PICK 'N PAY")]);
  final train = journey([leg('', 'KRAAIFONTEIN', 'WOODSTOCK'), leg('', 'WOODSTOCK', 'KALK BAY')]);

  JourneySearchOutcome outcomeWith(List<Connection> connections) => JourneySearchOutcome(
    from: const Endpoint.pin(name: 'Buh Rein', lat: -33.82, lon: 18.71),
    to: const Endpoint.pin(name: 'Kalk Bay', lat: -34.13, lon: 18.45),
    date: const ServiceDate(2026, 9, 23),
    dayType: DayType.weekday,
    rides: const [],
    allDay: const [],
    fromCache: false,
    fetchedAt: DateTime(2026, 9, 23),
    connections: connections,
  );

  test('the soonest on each operator is shown, the rest wait behind the button', () {
    final o = outcomeWith([bus, anotherBus, train]);

    final headline = o.bestConnectionPerOperator;

    expect(headline, hasLength(2));
    expect(headline.first, same(bus));
    expect(headline.last, same(train));
    // One bus journey hidden, no train hidden.
    expect(o.connections.length - headline.length, 1);
  });

  test('one operator only means one card, as before', () {
    expect(outcomeWith([bus, anotherBus]).bestConnectionPerOperator, hasLength(1));
  });

  test('a journey knows whose it is', () {
    expect(bus.operatorKey, 'gabs');
    expect(train.operatorKey, 'metrorail');
  });

  // The ride handed to the trip screen carried no operator, so it fell back to Golden
  // Arrow: the train leg opened as "the whole bus trip", quoting Golden Arrow's
  // timetables and saying no cash fare is published, for a ride that costs R12.00.
  test('opening a leg keeps the operator that runs it', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsService(db: db);
    await settings.load();
    locator.registerSingleton<NavigationService>(NavigationService());
    locator.registerSingleton<PlannerService>(PlannerService(db: db, settings: settings));
    addTearDown(() async {
      await locator.reset();
      await db.close();
    });

    final vm = ConnectionDetailViewModel(train, const ServiceDate(2026, 9, 23));

    final ride = vm.rides.first!;

    expect(ride.option.operator.code, 'metrorail');
    expect(ride.option.operator.kind, 'train');
  });
}
