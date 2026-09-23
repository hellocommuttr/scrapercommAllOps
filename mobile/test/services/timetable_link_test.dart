import 'package:commuttr/core/config.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where "Official timetable" sends a rider.
///
/// The link stored with a timetable is the file that was on the operator's site the day
/// we loaded it. Golden Arrow deletes those when it reissues: 26 of 40 sampled were 404
/// by September, and following the link gave the operator's own error page, which reads
/// as Commuttr being wrong about the service rather than stale about a file.
void main() {
  test('each operator has a page that lists its timetables', () {
    expect(AppConfig.timetablesUrlFor('gabs'), 'https://www.gabs.co.za/Timetable.aspx');
    expect(AppConfig.timetablesUrlFor('myciti'), 'https://www.myciti.org.za/en/timetables/');
    expect(AppConfig.timetablesUrlFor('metrorail'), 'https://www.prasa.com/train-schedules/cape-town');
  });

  test('an operator we have not met yet gets the bus one, not an empty link', () {
    expect(AppConfig.timetablesUrlFor('whoever'), startsWith('https://'));
  });

  test('support mail goes to Commuttr, not to a personal address', () {
    expect(AppConfig.supportEmail, 'support@commuttr.co.za');
  });
}
