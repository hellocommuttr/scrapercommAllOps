import 'package:commuttr/ui/views/on_trip/trip_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which stops the on-trip rail draws.
///
/// It drew five stops round the bus and nothing else, so Cape Town to Bellville ended at
/// Elsies River: the rail stopped where five stops ran out, not where the trip did.
void main() {
  test('Cape Town to Bellville, not yet left: the destination is drawn after a gap', () {
    // Cape Town, Salt River Circle, Voortrekker Rd, Goodwood, Elsies River, …, Bellville.
    expect(StopRail.slotsFor(7, 0), [0, 1, 2, null, 6]);
  });

  test('a short trip shows every stop, with no gap', () {
    expect(StopRail.slotsFor(5, 0), [0, 1, 2, 3, 4]);
    expect(StopRail.slotsFor(3, 1), [0, 1, 2]);
  });

  test('near the end the last five run straight into the destination', () {
    expect(StopRail.slotsFor(7, 3), [2, 3, 4, 5, 6]);
    expect(StopRail.slotsFor(7, 6), [2, 3, 4, 5, 6]);
  });

  test('at every point of a long trip the bus and the destination are both on the rail', () {
    for (var n = 1; n <= 40; n++) {
      for (var cur = 0; cur < n; cur++) {
        final slots = StopRail.slotsFor(n, cur);
        expect(slots, contains(cur), reason: 'n=$n cur=$cur: where the bus is');
        expect(slots.last, n - 1, reason: 'n=$n cur=$cur: where the trip ends');
        expect(slots.length, lessThanOrEqualTo(5), reason: 'n=$n cur=$cur: room on a phone');
        final stops = slots.whereType<int>().toList();
        expect(stops, orderedEquals([...stops]..sort()), reason: 'n=$n cur=$cur: in travel order');
      }
    }
  });
}
