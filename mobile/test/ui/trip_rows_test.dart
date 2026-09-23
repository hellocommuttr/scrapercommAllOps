import 'package:commuttr/data/models/models.dart';
import 'package:commuttr/ui/views/trip_detail/trip_detail_view.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden Arrow 1501 as the timetable prints it: Cape Town 14:50, Uitzicht 16:30, and
/// "via" at the stops between.
const _run = [
  TripStop(name: 'CAPE TOWN', stopSequence: 0, rawValue: '14:50', cellType: 'TIME', departureTime: '14:50'),
  TripStop(name: 'N1 FREEWAY', stopSequence: 1, rawValue: 'via', cellType: 'VIA'),
  TripStop(name: 'CAPE GATE', stopSequence: 5, rawValue: 'via', cellType: 'VIA'),
  TripStop(name: 'BUH REIN', stopSequence: 6, rawValue: 'via', cellType: 'VIA'),
  TripStop(name: 'UITZICHT', stopSequence: 7, rawValue: '16:30', cellType: 'TIME', departureTime: '16:30'),
];

void main() {
  test('the whole run shows, with the rider\'s own point and where they get off', () {
    // Woodstock: on the road between Cape Town and N1 Freeway, riding to Buh Rein.
    final rows = tripRows(
      stops: _run,
      fromSeq: 1,
      toSeq: 6,
      boardLabel: 'between CAPE TOWN and N1 FREEWAY',
      alightLabel: 'BUH REIN',
      boardRaw: 'from 14:50',
      arriveRaw: 'about 16:16',
      boardApprox: true,
      arriveApprox: true,
    );
    expect(rows.map((r) => r.name), [
      'CAPE TOWN',
      'between CAPE TOWN and N1 FREEWAY',
      'N1 FREEWAY',
      'CAPE GATE',
      'BUH REIN',
      'UITZICHT',
    ]);
    expect(rows.map((r) => r.role), [
      StopRole.before,
      StopRole.board,
      StopRole.ride,
      StopRole.ride,
      StopRole.alight,
      StopRole.after,
    ]);
    expect(rows[1].pin, isTrue);
    // Where the timetable prints "via", the rider's own ends carry the departure's estimate.
    expect(rows[4].time, 'about 16:16');
    expect(rows[3].time, isEmpty);
    expect(rows.first.time, '14:50');
    expect(rows.last.time, '16:30');
  });

  test('boarding and alighting at named stops marks those stops', () {
    final rows = tripRows(
      stops: _run,
      fromSeq: 0,
      toSeq: 5,
      boardLabel: 'CAPE TOWN',
      alightLabel: 'CAPE GATE',
      boardRaw: '14:50',
      arriveRaw: 'about 16:01',
      boardApprox: false,
      arriveApprox: true,
    );
    expect(rows, hasLength(_run.length));
    expect(rows.map((r) => r.role), [
      StopRole.board,
      StopRole.ride,
      StopRole.alight,
      StopRole.after,
      StopRole.after,
    ]);
    expect(rows.any((r) => r.pin), isFalse);
  });

  group('prices', () {
    Map<String, Object?> leg(String number, String line, int cents) => {
      'from_stop_id': 1,
      'from_name': 'A',
      'to_stop_id': 2,
      'to_name': 'B',
      'route_label': line,
      'timetable_number': number,
      'board_raw': '06:05',
      'arrive_raw': '07:00',
      'schedule_id': 1,
      'trip_index': 0,
      'from_seq': 0,
      'to_seq': 3,
      'fare': {'cash_cents': cents, 'basis': 'prasa_zone'},
    };

    test('a train journey with a change shows each train\'s price and one ticket for the trip', () {
      final c = Connection.fromJson({
        'day_type': 'WEEKDAY',
        'change_at': ['CAPE TOWN'],
        'legs': [leg('', 'Northern Line INBOUND', 1200), leg('', 'Southern Line OUTBOUND', 1200)],
        'fare': {'kind': 'through', 'cash_cents': 1500, 'basis': 'prasa_zone'},
      });
      expect(c.fare?.cashCents, 1500);
      expect(c.oneTicket, isTrue);
      expect(c.legFaresOn(weekday: true), contains('R12.00 + '));
    });

    test('Golden Arrow prices are not shown, nor a total that includes one', () {
      final bus = PlanOption.fromJson({
        'timetable_number': '001501',
        'route_label': 'CAPE TOWN - KRAAIFONTEIN',
        'operator_code': 'gabs',
        'fare': {'cash_cents': 4450},
      });
      expect(bus.fare, isNull);
      // The GO EASY bundles are published, so those are kept for the trip screen. They
      // are counts of rides - 5, 10 and 48 - not a week's or a month's travel.
      final goldCard = PlanOption.fromJson({
        'timetable_number': '001501',
        'route_label': 'CAPE TOWN - KRAAIFONTEIN',
        'operator_code': 'gabs',
        'fare': {
          'cash_cents': 4450,
          'five_ride_cents': 13400,
          'weekly_cents': 24850,
          'monthly_cents': 109300,
          'basis': 'go_easy',
        },
      });
      expect(goldCard.fare!.cashCents, isNull);
      expect(goldCard.fare!.fiveRideCents, 13400);
      expect(goldCard.fare!.weeklyCents, 24850);
      expect(goldCard.fare!.monthlyCents, 109300);
      // R134.00 / 5 = R26.80 a ride, R248.50 / 10 = R24.85, R1,093 / 48 = R22.77: the
      // per-ride figures the screen shows beside each bundle.
      expect(formatRands(goldCard.fare!.fiveRideCents! ~/ 5), 'R26.80');
      expect(formatRands(goldCard.fare!.weeklyCents! ~/ 10), 'R24.85');
      expect(formatRands(goldCard.fare!.monthlyCents! ~/ 48), 'R22.77');
      final train = PlanOption.fromJson({
        'timetable_number': '',
        'route_label': 'Northern Line',
        'operator_code': 'metrorail',
        'operator_kind': 'train',
        'fare': {'cash_cents': 1200},
      });
      expect(train.fare?.cashCents, 1200);
      final mixed = Connection.fromJson({
        'day_type': 'WEEKDAY',
        'change_at': ['BELLVILLE'],
        'legs': [leg('001501', 'CAPE TOWN - BELLVILLE', 1500), leg('', 'Northern Line', 1200)],
        'fare': {'kind': 'per_leg', 'cash_cents': 2700},
      });
      expect(mixed.legs.first.fare, isNull);
      expect(mixed.fare, isNull);
      expect(mixed.legFaresOn(weekday: true), isNull);
    });
  });

  group('unofficial stops', () {
    PlanOption option(String board, String alight) => PlanOption.fromJson({
      'timetable_number': '001501',
      'route_label': 'CAPE TOWN - KRAAIFONTEIN',
      'operator_code': 'gabs',
      'board_label': board,
      'alight_label': alight,
    });

    test('a point on the road names the official stops either side', () {
      final o = option('between CAPE TOWN and N1 FREEWAY', 'BUH REIN');
      expect(o.boardBetween, ('CAPE TOWN', 'N1 FREEWAY'));
      expect(o.alightBetween, isNull);
      expect(o.unofficialStop, isTrue);
      final advice = unofficialStopAdvice(o)!;
      expect(advice, contains('not sure to stop'));
      expect(advice, contains('get on at Cape Town or N1 Freeway'));
      expect(advice, isNot(contains('off at')));
    });

    test('getting off at a point on the road says where to get off instead', () {
      final advice = unofficialStopAdvice(option('CAPE TOWN', 'between OLD OAK RD and NORTHPINE'))!;
      expect(advice, contains('Get off at Old Oak Rd or Northpine'));
    });

    test('named stops at both ends carry no warning', () {
      final o = option('CAPE TOWN', 'BUH REIN');
      expect(o.unofficialStop, isFalse);
      expect(unofficialStopAdvice(o), isNull);
    });
  });

  group('MyCiTi fares', () {
    // Civic Centre to Table View, 14.4 km along the route: the City's calculator says 10-20km.
    const fare = Fare(
      cashCents: 3250,
      saverCents: 2550,
      basis: 'myciti_distance',
      dayPassCents: 13000,
      threeDayPassCents: 29000,
      weeklyCents: 42000,
      monthlyCents: 150000,
    );

    test('peak on weekdays 06:45-08:00 and 16:15-17:30, saver every other time', () {
      expect(fareAt(fare, weekday: true, boardMinutes: 7 * 60), 3250);
      expect(fareAt(fare, weekday: true, boardMinutes: 6 * 60 + 45), 3250);
      expect(fareAt(fare, weekday: true, boardMinutes: 8 * 60 + 1), 2550);
      expect(fareAt(fare, weekday: true, boardMinutes: 16 * 60 + 30), 3250);
      expect(fareAt(fare, weekday: true, boardMinutes: 12 * 60), 2550);
      // Weekends and public holidays are saver all day.
      expect(fareAt(fare, weekday: false, boardMinutes: 7 * 60), 2550);
    });

    test('other operators have one fare whatever the time', () {
      const train = Fare(cashCents: 1200, basis: 'prasa_zone');
      expect(fareAt(train, weekday: true, boardMinutes: 7 * 60), 1200);
      expect(fareAt(train, weekday: false, boardMinutes: 12 * 60), 1200);
    });

    test('a MyCiTi option keeps its price and passes', () {
      final o = PlanOption.fromJson({
        'timetable_number': 'D05',
        'route_label': 'D05 to Dunoon',
        'operator_code': 'myciti',
        'fare': {
          'cash_cents': 3250,
          'saver_cents': 2550,
          'basis': 'myciti_distance',
          'day_pass_cents': 13000,
          'three_day_pass_cents': 29000,
          'weekly_cents': 42000,
          'monthly_cents': 150000,
        },
      });
      expect(o.fare!.isMyciti, isTrue);
      expect(o.fare!.saverCents, 2550);
      expect(o.fare!.dayPassCents, 13000);
      expect(o.fare!.threeDayPassCents, 29000);
    });
  });
}
