/// Time in Cape Town, and the rules that decide which timetable runs on a given day.
///
/// The API speaks in wall-clock strings and minutes after midnight with no zone, and
/// Golden Arrow's timetables are Cape Town times. South Africa has no daylight saving,
/// so South African Standard Time is a fixed UTC+2 — reading the device's zone would be
/// wrong for a phone set to another zone and buys nothing.
library;

const _sastOffset = Duration(hours: 2);

/// Timetable day types, as the API names them.
enum DayType {
  weekday('WEEKDAY', 'Weekday'),
  saturday('SATURDAY', 'Saturday'),
  sunday('SUNDAY', 'Sunday'),
  publicHoliday('PUBLIC_HOLIDAY', 'Public holiday');

  const DayType(this.api, this.label);
  final String api;
  final String label;

  static DayType? fromApi(String? value) {
    for (final t in values) {
      if (t.api == value) return t;
    }
    return null;
  }
}

/// A calendar date in Cape Town, with no time part.
class ServiceDate implements Comparable<ServiceDate> {
  const ServiceDate(this.year, this.month, this.day);

  factory ServiceDate.fromDateTime(DateTime d) => ServiceDate(d.year, d.month, d.day);

  /// `yyyy-mm-dd`, the form the database stores.
  factory ServiceDate.parse(String iso) {
    final p = iso.split('-').map(int.parse).toList();
    return ServiceDate(p[0], p[1], p[2]);
  }

  final int year;
  final int month;
  final int day;

  DateTime get _utcMidnight => DateTime.utc(year, month, day);

  /// 1 = Monday … 7 = Sunday.
  int get weekday => _utcMidnight.weekday;

  ServiceDate addDays(int n) => ServiceDate.fromDateTime(_utcMidnight.add(Duration(days: n)));

  int daysUntil(ServiceDate other) => other._utcMidnight.difference(_utcMidnight).inDays;

  /// The instant [minutes] after midnight on this date in Cape Town.
  DateTime at(num minutes) => _utcMidnight.subtract(_sastOffset).add(Duration(seconds: (minutes * 60).round()));

  String get iso =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(ServiceDate other) => iso.compareTo(other.iso);

  @override
  bool operator ==(Object other) => other is ServiceDate && other.iso == iso;

  @override
  int get hashCode => iso.hashCode;

  @override
  String toString() => iso;
}

/// The current moment in Cape Town. Injectable so tests can pin the time.
class SastClock {
  const SastClock([this._now = DateTime.now]);

  final DateTime Function() _now;

  /// Wall-clock time in Cape Town, as a UTC-flagged DateTime whose fields read as SAST.
  DateTime get wallClock => _now().toUtc().add(_sastOffset);

  ServiceDate get today => ServiceDate.fromDateTime(wallClock);

  /// Minutes after midnight, Cape Town time, with the seconds as a fraction.
  double get minutesNow {
    final w = wallClock;
    return w.hour * 60 + w.minute + w.second / 60;
  }

  /// Minutes from now until [minutes] past midnight on [date]; negative once it has passed.
  double minutesUntil(ServiceDate date, num minutes) => today.daysUntil(date) * 1440 + minutes - minutesNow;
}

/// South African public holidays, per the Public Holidays Act 36 of 1994: fixed dates,
/// Easter-relative Good Friday and Family Day, and a holiday falling on a Sunday moves to
/// the Monday. Computed rather than listed so the app does not go stale after a year.
///
/// Once-off holidays the President declares (e.g. election days) cannot be predicted and
/// are not included — the UI tells people to confirm holiday services with the operator.
abstract final class SaHolidays {
  static const _fixed = <(int, int, String)>[
    (1, 1, "New Year's Day"),
    (3, 21, 'Human Rights Day'),
    (4, 27, 'Freedom Day'),
    (5, 1, "Workers' Day"),
    (6, 16, 'Youth Day'),
    (8, 9, "National Women's Day"),
    (9, 24, 'Heritage Day'),
    (12, 16, 'Day of Reconciliation'),
    (12, 25, 'Christmas Day'),
    (12, 26, 'Day of Goodwill'),
  ];

  static final Map<int, Map<ServiceDate, String>> _cache = {};

  static Map<ServiceDate, String> forYear(int year) => _cache.putIfAbsent(year, () {
    final out = <ServiceDate, String>{};
    for (final (m, d, name) in _fixed) {
      final date = ServiceDate(year, m, d);
      out[date] = name;
      if (date.weekday == DateTime.sunday) out.putIfAbsent(date.addDays(1), () => '$name (observed)');
    }
    final easter = easterSunday(year);
    out[easter.addDays(-2)] = 'Good Friday';
    out[easter.addDays(1)] = 'Family Day';
    return out;
  });

  /// The holiday's name, or null on an ordinary day.
  static String? nameOf(ServiceDate date) => forYear(date.year)[date];

  /// Western Easter Sunday — the anonymous Gregorian ("Meeus/Jones/Butcher") algorithm.
  static ServiceDate easterSunday(int y) {
    final a = y % 19, b = y ~/ 100, c = y % 100, d = b ~/ 4, e = b % 4;
    final f = (b + 8) ~/ 25, g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4, k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = (h + l - 7 * m + 114) % 31 + 1;
    return ServiceDate(y, month, day);
  }
}

/// Which timetable a commuter needs on [date].
DayType dayTypeFor(ServiceDate date) {
  if (SaHolidays.nameOf(date) != null) return DayType.publicHoliday;
  return switch (date.weekday) {
    DateTime.saturday => DayType.saturday,
    DateTime.sunday => DayType.sunday,
    _ => DayType.weekday,
  };
}

/// "05:45" from 345 minutes. Minutes past 24h wrap, for trips that run past midnight.
String formatMinutes(num minutes) {
  final total = minutes.round() % 1440;
  return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
}

/// "1h 24m", "16 min".
String formatDuration(num minutes) {
  final m = minutes.round();
  if (m < 60) return '$m min';
  final h = m ~/ 60, r = m % 60;
  return r == 0 ? '${h}h' : '${h}h ${r}m';
}

/// "in 4 min", "in 1h 10m", "now", "12 min ago".
String formatRelative(double minutesUntil) {
  final m = minutesUntil.round();
  if (m.abs() < 1) return 'now';
  if (m < 0) return '${formatDuration(-m)} ago';
  return 'in ${formatDuration(m)}';
}

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "Fri 18 Sep 2026".
String formatDate(ServiceDate d, {bool withYear = true}) =>
    '${_weekdayNames[d.weekday - 1]} ${d.day} ${_monthNames[d.month - 1]}${withYear ? ' ${d.year}' : ''}';

/// "Today", "Tomorrow", or the date.
String formatDayRelative(ServiceDate d, ServiceDate today) {
  final diff = today.daysUntil(d);
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  return formatDate(d, withYear: d.year != today.year);
}
