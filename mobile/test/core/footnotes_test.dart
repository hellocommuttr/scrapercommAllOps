import 'package:commuttr/core/footnotes.dart';
import 'package:commuttr/core/service_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const legend = {'a': 'Mondays,Tuesdays,Wednesdays,Thursdays', 'b': 'Fridays', 'x': 'Via Kuils River'};
  const monday = ServiceDate(2026, 9, 14);
  const friday = ServiceDate(2026, 9, 18);

  test('reads the footnote letter off a timetable cell', () {
    expect(Footnotes.codeOf('08:45a'), 'a');
    expect(Footnotes.codeOf('08:45 b'), 'b');
    expect(Footnotes.codeOf('08:45'), isNull);
    expect(Footnotes.codeOf('via'), isNull);
    expect(Footnotes.codeOf(null), isNull);
  });

  test('parses day lists and ranges', () {
    expect(Footnotes.weekdaysOf('Mondays,Tuesdays,Wednesdays,Thursdays'), {1, 2, 3, 4});
    expect(Footnotes.weekdaysOf('Fridays only'), {5});
    expect(Footnotes.weekdaysOf('Mondays to Fridays'), {1, 2, 3, 4, 5});
    expect(Footnotes.weekdaysOf('Mondays and Fridays'), {1, 5});
    expect(Footnotes.weekdaysOf('Via Kuils River'), isNull);
  });

  test('a Friday-only bus never shows on a Monday', () {
    expect(Footnotes.verdict('b', legend, monday), FootnoteVerdict.doesNotRun);
    expect(Footnotes.verdict('b', legend, friday), FootnoteVerdict.runs);
    expect(Footnotes.verdict('a', legend, friday), FootnoteVerdict.doesNotRun);
  });

  test('an unreadable footnote is flagged, not hidden', () {
    expect(Footnotes.verdict('x', legend, monday), FootnoteVerdict.unknown);
    expect(Footnotes.verdict('z', legend, monday), FootnoteVerdict.unknown);
    expect(Footnotes.verdict(null, legend, monday), FootnoteVerdict.runs);
  });

  test('humanises legends', () {
    expect(Footnotes.humanise('Mondays,Tuesdays,Wednesdays,Thursdays'), 'Mondays to Thursdays only');
    expect(Footnotes.humanise('Fridays'), 'Fridays only');
    expect(Footnotes.humanise('Mondays,Fridays'), 'Mondays and Fridays only');
    expect(Footnotes.humanise('Via Kuils River'), 'Via Kuils River');
  });
}
