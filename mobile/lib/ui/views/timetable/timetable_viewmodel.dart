import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../core/footnotes.dart';
import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/cached_api_service.dart';
import '../../../services/journey_service.dart';
import '../../../services/reference_data_service.dart';
import '../../../services/support_service.dart';

enum TimetableLoadProblem { notSavedOffline, failed }

/// One timetable in full: every direction and day type, as a grid.
///
/// Network-first through [JourneyService.timetable]; a copy opened before is shown offline
/// with the time it was saved.
class TimetableViewModel extends BaseViewModel {
  TimetableViewModel(this.timetableId);

  final int timetableId;

  final _journeys = locator<JourneyService>();
  final _support = locator<SupportService>();
  final _reference = locator<ReferenceDataService>();
  final _clock = const SastClock();

  TimetableDetail? detail;
  bool fromCache = false;
  DateTime? fetchedAt;
  bool stale = false;
  TimetableLoadProblem? problem;
  int selected = 0;

  /// Whose timetable this is.
  OperatorRef operator = OperatorRef.goldenArrow;

  bool get hasPdf => (detail?.info.pdfUrl ?? '').isNotEmpty;

  /// "Timetable 000101"; train timetables are unnumbered.
  String get timetableLabel {
    final n = detail?.info.timetableNumber ?? '';
    return n.isEmpty ? '${operator.name} timetable' : 'Timetable $n';
  }

  /// From the route in the on-device catalogue; an unnumbered timetable is a train's.
  Future<OperatorRef> _operatorOf(TimetableInfo info) async {
    try {
      final route = await _reference.routeById(info.routeId);
      if (route != null) return OperatorRef.from(route.operatorCode);
    } catch (_) {
      // Fall through to the guess.
    }
    return info.timetableNumber.isEmpty ? OperatorRef.metrorail : OperatorRef.goldenArrow;
  }

  List<TimetableSchedule> get schedules => detail?.schedules ?? const [];

  TimetableSchedule? get schedule => schedules.isEmpty ? null : schedules[selected.clamp(0, schedules.length - 1)];

  Future<void> load() async {
    problem = null;
    setBusy(true);
    try {
      final res = await _journeys.timetable(timetableId);
      detail = res.data;
      fromCache = res.fromCache;
      fetchedAt = res.fetchedAt;
      stale = res.isStale;
      selected = _defaultSchedule(res.data.schedules);
      operator = await _operatorOf(res.data.info);
    } on NotAvailableOffline {
      problem = TimetableLoadProblem.notSavedOffline;
    } catch (_) {
      problem = TimetableLoadProblem.failed;
    }
    setBusy(false);
  }

  /// Today's day type if the timetable has it (Sunday on a holiday without one), else the first.
  int _defaultSchedule(List<TimetableSchedule> list) {
    if (list.isEmpty) return 0;
    final today = dayTypeFor(_clock.today);
    for (final want in [today, if (today == DayType.publicHoliday) DayType.sunday]) {
      final i = list.indexWhere((s) => DayType.fromApi(s.dayType) == want && !s.noService);
      if (i >= 0) return i;
    }
    return 0;
  }

  void select(int index) {
    selected = index;
    rebuildUi();
  }

  /// "b — Fridays only" rows, sorted by letter.
  List<(String, String)> get legend {
    final notes = [...?detail?.notes]..sort((a, b) => a.code.compareTo(b.code));
    return [
      for (final n in notes)
        if (n.code.isNotEmpty) (n.code.toLowerCase(), Footnotes.humanise(n.description)),
    ];
  }

  /// "Saved Today, 07:42" in Cape Town time.
  String get savedLabel {
    final at = fetchedAt;
    if (at == null) return 'Saved copy';
    final w = at.toUtc().add(const Duration(hours: 2));
    return 'Saved ${formatDayRelative(ServiceDate.fromDateTime(w), _clock.today)}, '
        '${formatMinutes(w.hour * 60 + w.minute)}';
  }

  Future<void> openPdf() async {
    final url = detail?.info.pdfUrl;
    if (url != null && url.isNotEmpty) await _support.openUrl(url);
  }
}
