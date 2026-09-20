import 'package:commuttr/core/service_day.dart';
import 'package:commuttr/data/models/models.dart';
import 'package:commuttr/services/journey_service.dart';
import 'package:flutter_test/flutter_test.dart';

PlanDeparture dep(String raw, double board, double? arrive, {int trip = 0, bool approx = false}) => PlanDeparture(
  boardRaw: raw,
  boardApprox: approx,
  boardMinutes: board,
  arriveRaw: arrive == null ? 'via' : formatMinutes(arrive),
  arriveApprox: false,
  arriveMinutes: arrive,
  scheduleId: 1,
  tripIndex: trip,
  fromSeq: 0,
  toSeq: 5,
);

PlanOption option(String dayType, List<PlanDeparture> deps) => PlanOption(
  timetableNumber: '000101',
  routeLabel: 'BELLVILLE - CAPE TOWN',
  dayType: dayType,
  dayLabel: dayType,
  segmentStops: const [],
  roadPath: const [],
  departures: deps,
  boardApprox: false,
  alightApprox: false,
  boardLabel: 'BELLVILLE',
  alightLabel: 'CAPE TOWN',
);

const from = Endpoint.stop(id: 7, name: 'BELLVILLE', lat: -33.89, lon: 18.63);
const to = Endpoint.stop(id: 101, name: 'CAPE TOWN', lat: -33.92, lon: 18.42);
const legend = {
  '000101': {'a': 'Mondays,Tuesdays,Wednesdays,Thursdays', 'b': 'Fridays'},
};

JourneySearchOutcome outcome(
  PlanResponse r,
  ServiceDate date, {
  double? now,
  SearchFilters filters = const SearchFilters(),
}) => JourneyService.buildOutcome(
  from: from,
  to: to,
  response: r,
  notes: legend,
  filters: filters,
  date: date,
  minutesNow: now,
  fromCache: false,
  fetchedAt: DateTime(2026),
);

void main() {
  final weekday = option('WEEKDAY', [
    dep('05:45', 345, 405, trip: 0),
    dep('08:45a', 525, 590, trip: 1),
    dep('08:45b', 525, 595, trip: 2),
    dep('17:10', 1030, 1100, trip: 3),
  ]);
  final sunday = option('SUNDAY', [dep('07:00', 420, 480, trip: 9)]);
  final response = PlanResponse(from: null, to: null, options: [weekday, sunday]);

  test('Monday hides the Friday-only bus and keeps the Mon–Thu one', () {
    final o = outcome(response, const ServiceDate(2026, 9, 14));
    expect(o.dayType, DayType.weekday);
    expect(o.hiddenByFootnote, 1);
    expect(o.allDay.map((r) => r.departure.boardRaw), ['05:45', '08:45a', '17:10']);
    expect(o.allDay[1].noteText, 'Mondays to Thursdays only');
  });

  test('Friday shows the Friday bus instead', () {
    final o = outcome(response, const ServiceDate(2026, 9, 18));
    expect(o.allDay.map((r) => r.departure.boardRaw), ['05:45', '08:45b', '17:10']);
  });

  test('only upcoming departures, with first and last bus of the day', () {
    final o = outcome(response, const ServiceDate(2026, 9, 14), now: 600);
    expect(o.rides.map((r) => r.boardTime), ['17:10']);
    expect(o.firstBus!.boardTime, '05:45');
    expect(o.lastBus!.boardTime, '17:10');
  });

  test('public holiday without a holiday timetable falls back to Sunday, flagged', () {
    final o = outcome(response, const ServiceDate(2026, 9, 24)); // Heritage Day, a Thursday
    expect(o.holidayName, 'Heritage Day');
    expect(o.holidayFallback, isTrue);
    expect(o.dayType, DayType.sunday);
    expect(o.allDay.single.boardTime, '07:00');
  });

  test('a day with no service says which days do run', () {
    final o = outcome(PlanResponse(from: null, to: null, options: [weekday]), const ServiceDate(2026, 9, 20));
    expect(o.allDay, isEmpty);
    expect(o.otherDayTypes, [DayType.weekday]);
  });

  test('arrive-by and sort filters', () {
    final o = outcome(
      response,
      const ServiceDate(2026, 9, 14),
      filters: const SearchFilters(departAfter: 0, arriveBy: 600, sort: SortBy.duration),
    );
    expect(o.rides.map((r) => r.boardTime), ['05:45', '08:45']);
    expect(o.rides.first.durationMinutes, 60);
  });

  test('a ride that crosses midnight keeps a positive duration', () {
    final late = option('WEEKDAY', [dep('23:40', 1420, 15)]);
    final o = outcome(PlanResponse(from: null, to: null, options: [late]), const ServiceDate(2026, 9, 14));
    expect(o.allDay.single.durationMinutes, 35);
    expect(o.allDay.single.arriveTime, '00:15');
  });

  test('approximate times can be excluded', () {
    final a = option('WEEKDAY', [dep('06:00', 360, 400, approx: true)]);
    final o = outcome(
      PlanResponse(from: null, to: null, options: [a]),
      const ServiceDate(2026, 9, 14),
      filters: const SearchFilters(includeApprox: false),
    );
    expect(o.rides, isEmpty);
    expect(o.allDay, hasLength(1));
  });
}
