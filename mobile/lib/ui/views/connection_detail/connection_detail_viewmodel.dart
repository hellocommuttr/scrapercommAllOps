import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/journey_service.dart';
import '../../../services/planner_service.dart';

/// A trip that needs one change of bus. Each leg is an ordinary ride, so it can be
/// opened in full and put on the planner like any other bus.
class ConnectionDetailViewModel extends BaseViewModel {
  ConnectionDetailViewModel(this.connection, this.date);

  final Connection connection;
  final ServiceDate date;
  final _nav = locator<NavigationService>();
  final _planner = locator<PlannerService>();

  bool added = false;

  late final List<Ride?> rides = connection.legs.map(_rideFor).toList();

  /// Null only when the leg has no boarding time to open it at. A stop whose position we
  /// do not know is still a stop: every leg of a journey opens.
  Ride? _rideFor(ConnectionLeg leg) {
    if (leg.boardMinutes == null) return null;
    return Ride(
      from: leg.from,
      to: leg.to,
      date: date,
      option: PlanOption(
        // Whose ride this is. Left out, it defaulted to Golden Arrow, so opening the
        // train leg of a journey gave a screen headed "the whole bus trip", quoting
        // Golden Arrow's timetables and saying no cash fare is published for a ride
        // that costs R12.00.
        operator: leg.operator,
        fare: leg.fare,
        timetableNumber: leg.timetableNumber,
        routeLabel: leg.routeLabel,
        dayType: connection.dayType,
        dayLabel: '',
        segmentStops: const [],
        roadPath: const [],
        departures: const [],
        boardApprox: false,
        alightApprox: false,
        boardLabel: leg.fromName,
        alightLabel: leg.toName,
      ),
      departure: PlanDeparture(
        boardRaw: leg.boardRaw,
        boardApprox: false,
        boardMinutes: leg.boardMinutes,
        arriveRaw: leg.arriveRaw,
        arriveApprox: false,
        arriveMinutes: leg.arriveMinutes,
        scheduleId: leg.scheduleId,
        tripIndex: leg.tripIndex,
        fromSeq: leg.fromSeq,
        toSeq: leg.toSeq,
      ),
    );
  }

  /// Minutes waiting at the change stop between leg [i] and leg [i + 1].
  double? waitAfter(int i) {
    final a = connection.legs[i].arriveMinutes, b = connection.legs[i + 1].boardMinutes;
    return a == null || b == null ? null : b - a;
  }

  /// Long waits, or changing after dark, deserve a safety note.
  bool needsSafetyNote(int i) {
    final w = waitAfter(i);
    final at = connection.legs[i].arriveMinutes;
    return (w != null && w > 20) || (at != null && (at >= 19 * 60 || at < 5 * 60));
  }

  void openLeg(int i) {
    final r = rides[i];
    if (r != null) _nav.navigateToTripDetailView(ride: r);
  }

  Future<void> addAll() async {
    final group = 'conn-${DateTime.now().microsecondsSinceEpoch}';
    for (final r in rides.whereType<Ride>()) {
      await _planner.add(r, groupId: group);
    }
    added = true;
    rebuildUi();
  }
}
