import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/planner_service.dart';

/// Where the commuter is in the timetable, relative to the scheduled trip.
enum TripPhase {
  /// The journey is on a later day.
  futureDay,

  /// Today, before the scheduled departure.
  notDeparted,

  /// Between scheduled departure and arrival.
  onBoard,

  /// The scheduled arrival has passed.
  arrived,
}

/// A stop on the ride with its scheduled time, on the journey's own clock.
class ProgressStop {
  const ProgressStop({
    required this.name,
    this.lat,
    this.lon,
    this.minutes,
    required this.estimate,
    this.approx = false,
  });

  final String name;
  final double? lat;
  final double? lon;

  /// Published time as minutes after midnight of the journey's date (can exceed 1440),
  /// or null when the timetable shows no time here (a VIA cell).
  final double? minutes;

  /// [minutes], or a straight-line guess between neighbouring timed stops. Only used to
  /// place the marker; never shown as a time.
  final double estimate;

  /// The printed time is itself worked out (a dropped pin between stops).
  final bool approx;

  bool get hasLocation => lat != null && lon != null;
}

/// Scheduled progress, worked out from stop times and the Cape Town clock. This is
/// arithmetic on the timetable, not a position report from the bus or train.
class TripProgress {
  TripProgress._({
    required this.phase,
    required this.stops,
    required this.passedIndex,
    required this.segmentFraction,
    required this.now,
    this.operator = OperatorRef.goldenArrow,
  });

  /// [j]'s stops against [clock]. Uses the stop-time snapshot when there is one, else
  /// just the board and alight points.
  factory TripProgress.of(PlannedJourney j, SastClock clock) {
    final stops = _stopsFor(j);
    // Minutes since midnight at the start of the journey's date, so a trip that runs
    // past midnight (or yesterday's late bus) still lines up with its stop times.
    final now = -clock.minutesUntil(j.date, 0);
    final last = stops.length - 1;
    final TripPhase phase;
    var passed = -1;
    var fraction = 0.0;
    if (clock.today.daysUntil(j.date) > 0) {
      phase = TripPhase.futureDay;
    } else if (now < stops.first.estimate) {
      phase = TripPhase.notDeparted;
    } else if (now >= stops[last].estimate) {
      phase = TripPhase.arrived;
      passed = last;
    } else {
      phase = TripPhase.onBoard;
      for (var i = 0; i < stops.length; i++) {
        if (stops[i].estimate <= now) passed = i;
      }
      if (passed >= last) passed = last - 1;
      final a = stops[passed].estimate, b = stops[passed + 1].estimate;
      fraction = b > a ? ((now - a) / (b - a)).clamp(0.0, 1.0) : 0;
    }
    return TripProgress._(
      phase: phase,
      stops: stops,
      passedIndex: passed,
      segmentFraction: fraction,
      now: now,
      operator: j.operator,
    );
  }

  final TripPhase phase;
  final List<ProgressStop> stops;

  /// Whose bus or train; for "stop" / "station" and the marker icon.
  final OperatorRef operator;

  /// The last stop the bus is scheduled to have left; -1 before departure.
  final int passedIndex;

  /// How far between [passedIndex] and the next stop, 0–1.
  final double segmentFraction;

  /// The current time as minutes after midnight of the journey's date.
  final double now;

  /// The next stop the bus is scheduled to reach, or null once arrived.
  int? get nextIndex => switch (phase) {
    TripPhase.arrived => null,
    TripPhase.onBoard => passedIndex + 1,
    _ => 0,
  };

  ProgressStop? get nextStop => nextIndex == null ? null : stops[nextIndex!];

  /// Stops still to come, counting the one to get off at.
  int get stopsRemaining => switch (phase) {
    TripPhase.onBoard => stops.length - 1 - passedIndex,
    TripPhase.arrived => 0,
    _ => stops.length - 1,
  };

  /// 0 at the boarding stop, 1 at the alighting stop, measured in stops.
  double get railFraction {
    if (stops.length < 2) return 0;
    return switch (phase) {
      TripPhase.arrived => 1,
      TripPhase.onBoard => (passedIndex + segmentFraction) / (stops.length - 1),
      _ => 0,
    };
  }

  /// Minutes until [s]'s published time, or null when it has none.
  double? minutesUntil(ProgressStop s) => s.minutes == null ? null : s.minutes! - now;

  /// Where the bus is scheduled to be, between the last and next stop.
  (double, double)? get scheduledPosition {
    if (phase != TripPhase.onBoard) return null;
    final a = stops[passedIndex], b = stops[passedIndex + 1];
    if (!a.hasLocation || !b.hasLocation) return null;
    final f = segmentFraction;
    return (a.lat! + (b.lat! - a.lat!) * f, a.lon! + (b.lon! - a.lon!) * f);
  }

  static List<ProgressStop> _stopsFor(PlannedJourney j) {
    final board = j.boardMinutes;
    final arrive = j.arriveMinutes;
    final raw = j.trip?.stops ?? const [];
    if (raw.length < 2) {
      final end = arrive ?? board;
      return [
        ProgressStop(
          name: j.from.displayName,
          lat: j.from.lat,
          lon: j.from.lon,
          minutes: board,
          estimate: board,
          approx: j.row.boardApprox,
        ),
        ProgressStop(
          name: j.to.displayName,
          lat: j.to.lat,
          lon: j.to.lon,
          minutes: arrive,
          estimate: end,
          approx: j.row.arriveApprox,
        ),
      ];
    }

    // A time well before boarding belongs to the next day. The half-day margin keeps a
    // first stop printed a minute or two before an interpolated boarding time on the
    // same day.
    double? norm(double? m) => m == null ? null : (m + 720 < board ? m + 1440 : m);
    final times = [for (final s in raw) norm(s.minutes)];
    final last = raw.length - 1;
    // The ends always have a time: the ride's own board and arrive times when the
    // timetable cell is empty.
    final ends = <int, double?>{0: times[0] ?? board, last: times[last] ?? arrive};
    final known = [for (var i = 0; i < raw.length; i++) ends.containsKey(i) ? ends[i] : times[i]];

    double estimateAt(int i) {
      if (known[i] != null) return known[i]!;
      var p = i - 1, n = i + 1;
      while (p > 0 && known[p] == null) {
        p--;
      }
      while (n < last && known[n] == null) {
        n++;
      }
      final pm = known[p] ?? board;
      final nm = n <= last ? known[n] : null;
      if (nm == null) return pm;
      return pm + (nm - pm) * (i - p) / (n - p);
    }

    return [
      for (var i = 0; i < raw.length; i++)
        ProgressStop(
          name: raw[i].name.isEmpty ? (i == 0 ? j.from.displayName : j.to.displayName) : titleCase(raw[i].name),
          lat: raw[i].lat,
          lon: raw[i].lon,
          minutes: known[i],
          estimate: estimateAt(i),
          approx: (i == 0 && j.row.boardApprox) || (i == last && j.row.arriveApprox),
        ),
    ];
  }
}
