import 'package:commuttr/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Times from a timetable the operator has already replaced.
///
/// Golden Arrow reissues weekly and we load when the loader is run. On 23 September 2026
/// the data was 18 days old and 639 of 2,140 timetables had an end date in the past - and
/// nothing looked at that date. An expired version's departures were grouped under the
/// same route as the current one's, so times that stopped running weeks ago sat beside
/// times that still do, with nothing to tell them apart.
///
/// The server now drops the expired copy where a current one exists, and where every copy
/// has ended (35 of 221 numbers) it sends the date so the trip can say so.
void main() {
  Map<String, dynamic> optionJson({String? expiredOn}) => {
    'timetable_number': '014301',
    'route_label': 'MAKHAZA - MOWBRAY - CAPE TOWN',
    'operator_code': 'gabs',
    'day_type': 'WEEKDAY',
    'day_label': 'MONDAYS TO FRIDAYS',
    'segment_stops': [],
    'road_path': [],
    'departures': [],
    'board_label': 'MAKHAZA',
    'alight_label': 'CAPE TOWN',
    if (expiredOn != null) 'timetable_expired_on': expiredOn,
  };

  test('a lapsed timetable carries the day it ended', () {
    final option = PlanOption.fromJson(optionJson(expiredOn: '2026-08-23'));

    expect(option.timetableExpiredOn, '2026-08-23');
  });

  test('a current one says nothing, which is the normal case', () {
    expect(PlanOption.fromJson(optionJson()).timetableExpiredOn, isNull);
  });

  test('the date survives a walk being added to the option', () {
    final option = PlanOption.fromJson(optionJson(expiredOn: '2026-08-23')).withWalk(boardAwayM: 400);

    expect(option.boardAwayM, 400);
    expect(option.timetableExpiredOn, '2026-08-23', reason: 'the warning must not fall off on the way');
  });
}
