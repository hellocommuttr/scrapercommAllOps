import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/reference_data_service.dart';
import '../../../services/support_service.dart';

/// Where a timetable stands relative to today.
enum TimetableStatus { current, upcoming, expired }

/// A route's timetables. Shows what is on the device at once, then asks the API for the
/// route's latest timetable headers (new PDFs, new dates) and reloads if it answers.
class RouteDetailViewModel extends BaseViewModel {
  RouteDetailViewModel(this.routeId);

  final int routeId;

  final _nav = locator<NavigationService>();
  final _reference = locator<ReferenceDataService>();
  final _support = locator<SupportService>();
  final _clock = const SastClock();

  RouteSummary? route;
  List<TimetableInfo> timetables = const [];

  /// True while the background refresh is running.
  bool refreshing = false;

  bool loaded = false;

  String get title => route == null ? 'Route' : titleCase(route!.name);

  /// Whose route this is. Before the route loads, an unnumbered timetable means a train.
  OperatorRef get operator {
    final r = route;
    if (r != null) return OperatorRef.from(r.operatorCode);
    if (timetables.isNotEmpty && timetables.every((t) => t.timetableNumber.isEmpty)) return OperatorRef.metrorail;
    return OperatorRef.goldenArrow;
  }

  /// "Timetable 000101"; train timetables have no number, so they are counted instead.
  String timetableLabel(TimetableInfo t) {
    if (t.timetableNumber.isNotEmpty) return 'Timetable ${t.timetableNumber}';
    if (timetables.length == 1) return '${operator.name} timetable';
    return '${operator.name} timetable ${timetables.indexOf(t) + 1}';
  }

  /// Only real links: train timetables carry none.
  bool hasPdf(TimetableInfo t) => (t.pdfUrl ?? '').isNotEmpty;

  Future<void> init() async {
    setBusy(true);
    await _loadLocal();
    loaded = true;
    setBusy(false);
    refreshing = true;
    rebuildUi();
    // Never throws; keeps the local rows when offline.
    await _reference.refreshRoute(routeId);
    await _loadLocal();
    refreshing = false;
    rebuildUi();
  }

  Future<void> _loadLocal() async {
    try {
      route = await _reference.routeById(routeId);
      final rows = await _reference.timetablesForRoute(routeId);
      // Regular timetables first, then holiday ones; newest first within each.
      rows.sort((a, b) {
        if (a.isPublicHoliday != b.isPublicHoliday) return a.isPublicHoliday ? 1 : -1;
        return (b.effectiveFrom ?? '').compareTo(a.effectiveFrom ?? '');
      });
      timetables = rows;
    } catch (_) {
      // Leave whatever was loaded before.
    }
  }

  TimetableStatus statusOf(TimetableInfo t) {
    final today = _clock.today.iso;
    if (t.effectiveTo != null && t.effectiveTo!.compareTo(today) < 0) return TimetableStatus.expired;
    if (t.effectiveFrom != null && t.effectiveFrom!.compareTo(today) > 0) return TimetableStatus.upcoming;
    return TimetableStatus.current;
  }

  void openTimetable(TimetableInfo t) => _nav.navigateToTimetableView(timetableId: t.id, title: title);

  Future<void> openPdf(TimetableInfo t) async {
    final url = t.pdfUrl;
    if (url != null && url.isNotEmpty) await _support.openUrl(url);
  }
}
