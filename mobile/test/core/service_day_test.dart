import 'package:commuttr/core/service_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SastClock', () {
    test('reads Cape Town time regardless of the device zone', () {
      // 22:30 UTC is 00:30 the next day in Cape Town.
      final clock = SastClock(() => DateTime.utc(2026, 9, 17, 22, 30));
      expect(clock.today, const ServiceDate(2026, 9, 18));
      expect(clock.minutesNow, 30);
    });

    test('minutesUntil spans days', () {
      final clock = SastClock(() => DateTime.utc(2026, 9, 18, 5)); // 07:00 SAST
      expect(clock.minutesUntil(const ServiceDate(2026, 9, 18), 7 * 60 + 15), 15);
      expect(clock.minutesUntil(const ServiceDate(2026, 9, 19), 7 * 60), 1440);
    });

    test('ServiceDate.at gives the instant in Cape Town', () {
      expect(const ServiceDate(2026, 9, 18).at(8 * 60), DateTime.utc(2026, 9, 18, 6));
      // Trips that run past midnight.
      expect(const ServiceDate(2026, 9, 18).at(1440 + 30), DateTime.utc(2026, 9, 18, 22, 30));
    });
  });

  group('SaHolidays', () {
    test('Easter-relative holidays', () {
      expect(SaHolidays.easterSunday(2026), const ServiceDate(2026, 4, 5));
      expect(SaHolidays.easterSunday(2027), const ServiceDate(2027, 3, 28));
      expect(SaHolidays.nameOf(const ServiceDate(2026, 4, 3)), 'Good Friday');
      expect(SaHolidays.nameOf(const ServiceDate(2026, 4, 6)), 'Family Day');
    });

    test('a holiday on a Sunday moves to the Monday', () {
      // 9 August 2026 is a Sunday.
      expect(SaHolidays.nameOf(const ServiceDate(2026, 8, 9)), "National Women's Day");
      expect(SaHolidays.nameOf(const ServiceDate(2026, 8, 10)), "National Women's Day (observed)");
    });

    test('ordinary days are not holidays', () {
      expect(SaHolidays.nameOf(const ServiceDate(2026, 9, 18)), isNull);
    });
  });

  group('dayTypeFor', () {
    test('weekdays, weekends and holidays', () {
      expect(dayTypeFor(const ServiceDate(2026, 9, 18)), DayType.weekday); // Friday
      expect(dayTypeFor(const ServiceDate(2026, 9, 19)), DayType.saturday);
      expect(dayTypeFor(const ServiceDate(2026, 9, 20)), DayType.sunday);
      expect(dayTypeFor(const ServiceDate(2026, 9, 24)), DayType.publicHoliday); // Heritage Day
      expect(dayTypeFor(const ServiceDate(2026, 6, 16)), DayType.publicHoliday); // Youth Day
    });
  });

  group('formatting', () {
    test('minutes and durations', () {
      expect(formatMinutes(345), '05:45');
      expect(formatMinutes(1440 + 15), '00:15');
      expect(formatDuration(16), '16 min');
      expect(formatDuration(84), '1h 24m');
      expect(formatDuration(120), '2h');
      expect(formatRelative(4.2), 'in 4 min');
      expect(formatRelative(0.3), 'now');
    });

    test('dates', () {
      const today = ServiceDate(2026, 9, 18);
      expect(formatDate(today), 'Fri 18 Sep 2026');
      expect(formatDayRelative(today, today), 'Today');
      expect(formatDayRelative(today.addDays(1), today), 'Tomorrow');
    });
  });
}
