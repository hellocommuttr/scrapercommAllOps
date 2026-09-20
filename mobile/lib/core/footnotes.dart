import 'service_day.dart';

/// Golden Arrow timetable footnotes: a letter after a time ("08:45a") whose legend says on
/// which days that bus runs ("a = Mondays,Tuesdays,Wednesdays,Thursdays").
///
/// A bus that only runs on Fridays must never be offered on a Monday, so every departure
/// is checked against its footnote before it is shown. A footnote we cannot read is not
/// silently dropped: the departure is kept and flagged "check the official timetable".
abstract final class Footnotes {
  static final _codeRe = RegExp(r'^\s*\d{1,2}[:h.]\d{2}\s*([a-zA-Z]+)\s*$');

  /// The footnote letters on a raw timetable cell, e.g. "a" from "08:45a"; null if none.
  static String? codeOf(String? raw) {
    if (raw == null) return null;
    final m = _codeRe.firstMatch(raw);
    return m?.group(1)?.toLowerCase();
  }

  static const _days = {
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  /// The weekdays a footnote's text names, or null if the text is not a list of days.
  static Set<int>? weekdaysOf(String? description) {
    if (description == null || description.trim().isEmpty) return null;
    final parts = description
        .toLowerCase()
        .replaceAll(RegExp(r'\bonly\b'), '')
        .split(RegExp(r'[,/&]|\band\b'))
        .map((p) => p.trim().replaceAll(RegExp(r's$'), ''))
        .where((p) => p.isNotEmpty);
    final out = <int>{};
    for (final p in parts) {
      final range = p.split(RegExp(r'\s+to\s+'));
      if (range.length == 2) {
        final a = _days[range[0].replaceAll(RegExp(r's$'), '')], b = _days[range[1]];
        if (a == null || b == null || b < a) return null;
        for (var d = a; d <= b; d++) {
          out.add(d);
        }
        continue;
      }
      final day = _days[p];
      if (day == null) return null;
      out.add(day);
    }
    return out.isEmpty ? null : out;
  }

  /// Whether a departure carrying [code] runs on [date], given the legend [notes].
  static FootnoteVerdict verdict(String? code, Map<String, String> notes, ServiceDate date) {
    if (code == null) return FootnoteVerdict.runs;
    final days = weekdaysOf(notes[code]);
    if (days == null) return FootnoteVerdict.unknown;
    return days.contains(date.weekday) ? FootnoteVerdict.runs : FootnoteVerdict.doesNotRun;
  }

  /// "Mondays to Thursdays only" from "Mondays,Tuesdays,Wednesdays,Thursdays".
  static String humanise(String? description) {
    final days = weekdaysOf(description);
    if (days == null) return description ?? '';
    final sorted = days.toList()..sort();
    const names = ['', 'Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'];
    final contiguous = sorted.length > 2 && sorted.last - sorted.first == sorted.length - 1;
    if (contiguous) return '${names[sorted.first]} to ${names[sorted.last]} only';
    if (sorted.length == 1) return '${names[sorted.first]} only';
    return '${sorted.map((d) => names[d]).join(' and ')} only';
  }
}

enum FootnoteVerdict { runs, doesNotRun, unknown }
