import 'package:commuttr/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// A leg through a stop whose position nobody knows.
///
/// 48 of the 1,151 stops have no coordinates: the timetables never gave any and no
/// geocoder could place them. Town Centre is one, and it is on 1,097 schedules, so Buh
/// Rein to Kalk Bay changes there. The leg used to have no endpoints without a position,
/// which is what closed it on screen: the first leg of that trip opened and the two after
/// it could not, with no way to tell why.
void main() {
  Map<String, dynamic> legJson({bool placed = true}) => {
    'from_stop_id': 101,
    'from_name': 'CAPE TOWN',
    'from_lat': -33.922,
    'from_lon': 18.423,
    'to_stop_id': 159,
    'to_name': 'TOWN CENTRE',
    if (placed) 'to_lat': -34.045,
    if (placed) 'to_lon': 18.619,
    'route_label': 'CAPE TOWN - MITCHELLS PLAIN',
    'timetable_number': '021401',
    'board_raw': '07:00',
    'arrive_raw': '07:50',
    'board_minutes': 420,
    'arrive_minutes': 470,
    'schedule_id': 7,
    'trip_index': 2,
    'from_seq': 1,
    'to_seq': 9,
  };

  test('an unplaced stop is still an endpoint, and says it has no position', () {
    final leg = ConnectionLeg.fromJson(legJson(placed: false));

    expect(leg.to.id, 159);
    expect(leg.to.displayName, 'Town Centre');
    expect(leg.to.hasPosition, isFalse);
    // The planner is asked for a stop by id, so the leg can still be opened and saved.
    expect(leg.to.query('to'), {'to': '159'});
  });

  test('a placed stop carries its position', () {
    final leg = ConnectionLeg.fromJson(legJson());

    expect(leg.to.hasPosition, isTrue);
    expect(leg.to.lat, -34.045);
  });
}
