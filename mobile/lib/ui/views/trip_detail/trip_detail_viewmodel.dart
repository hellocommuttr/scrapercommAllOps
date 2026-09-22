import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/footnotes.dart';
import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/cached_api_service.dart';
import '../../../services/journey_service.dart';
import '../../../services/planner_service.dart';
import '../../../services/reference_data_service.dart';
import '../../../services/reminder_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/shell_service.dart';
import '../../../services/support_service.dart';

/// One ride in full: every stop and time, footnotes, the map, where the data came from,
/// and what the commuter can do with it. Opened either from search results (a [Ride])
/// or from the planner (a saved journey, which works offline from its snapshot).
class TripDetailViewModel extends BaseViewModel {
  TripDetailViewModel({this.ride, this.plannedJourneyId});

  final Ride? ride;
  final String? plannedJourneyId;

  final _nav = locator<NavigationService>();
  final _journeys = locator<JourneyService>();
  final _planner = locator<PlannerService>();
  final _ref = locator<ReferenceDataService>();
  final _reminders = locator<ReminderService>();
  final _settings = locator<SettingsService>();
  final _support = locator<SupportService>();
  final _clock = const SastClock();

  PlannedJourney? planned;
  TripStopsResponse? trip;

  /// The vehicle's whole run, first stop to terminus, for the stop list: where it starts
  /// and ends matters as much as where the rider gets on and off. [trip] stays the
  /// rider's own stretch, which the planner saves and the trip in progress follows.
  TripStopsResponse? wholeTrip;
  bool tripFromCache = false;
  DateTime? tripFetchedAt;
  bool tripUnavailable = false;
  TimetableInfo? timetable;
  Map<String, String> legend = const {};
  String? message;

  /// Header fields below are set; the rest (stops, timetable) may still be loading.
  bool headerReady = false;
  bool missing = false;

  // A unified view over a search result or a planner item.
  late String routeNumber;
  late String routeLabel;
  late String timetableNumber;
  late String dayLabel;
  late Endpoint from;
  late Endpoint to;
  late ServiceDate date;
  late double boardMinutes;
  double? arriveMinutes;
  late bool boardApprox;
  late bool arriveApprox;
  late String boardRaw;
  String arriveRaw = '';
  late int scheduleId, tripIndex, fromSeq, toSeq;
  List<(double, double)> roadPath = const [];
  OperatorRef operator = OperatorRef.goldenArrow;

  /// The published fare: in full for a search result, cash price only for a planner item.
  Fare? fare;

  /// How far the boarding and alighting stops are from the places the rider asked for,
  /// with the stops' own names — set when this ride is another operator's service nearby.
  int? boardAwayM;
  int? alightAwayM;
  String boardLabel = '';
  String alightLabel = '';

  bool get isPlanned => planned != null;
  bool get remindersSupported => _reminders.isSupported;
  int get arriveEarly => _settings.arriveEarlyMinutes;
  String get boardTime => formatMinutes(boardMinutes);
  String? get arriveTime => arriveMinutes == null ? null : formatMinutes(arriveMinutes!);
  double? get duration => rideMinutes(boardMinutes, arriveMinutes, approx: boardApprox || arriveApprox);
  double get minutesUntil => _clock.minutesUntil(date, boardMinutes);
  String? get noteCode => Footnotes.codeOf(boardRaw);
  String get rideKey => '$scheduleId:$tripIndex:$fromSeq:$toSeq';

  /// Footnotes that apply to this ride, humanised ("b — Fridays only").
  List<(String, String)> get footnotes {
    final codes = <String>{
      ?noteCode,
      for (final s in trip?.stops ?? const <TripStop>[])
        if (Footnotes.codeOf(s.rawValue) != null) Footnotes.codeOf(s.rawValue)!,
    };
    final all = {...legend, for (final n in trip?.notes ?? const <NoteDto>[]) n.code.toLowerCase(): n.description};
    return [for (final c in codes) (c, all[c] == null ? 'See the official timetable' : Footnotes.humanise(all[c]))];
  }

  Future<void> init() async {
    setBusy(true);
    if (ride != null) {
      final r = ride!;
      routeNumber = r.option.routeNumber;
      routeLabel = r.option.routeLabel;
      timetableNumber = r.option.timetableNumber;
      dayLabel = r.option.dayLabel;
      from = r.from;
      to = r.to;
      date = r.date;
      boardMinutes = r.boardMinutes;
      arriveMinutes = r.arriveMinutes;
      boardApprox = r.departure.boardApprox;
      arriveApprox = r.departure.arriveApprox;
      boardRaw = r.departure.boardRaw;
      arriveRaw = r.departure.arriveRaw;
      scheduleId = r.departure.scheduleId;
      tripIndex = r.departure.tripIndex;
      fromSeq = r.departure.fromSeq;
      toSeq = r.departure.toSeq;
      roadPath = r.option.roadPath;
      operator = r.operator;
      fare = r.fare;
      boardAwayM = r.option.boardAwayM;
      alightAwayM = r.option.alightAwayM;
      boardLabel = r.option.boardLabel;
      alightLabel = r.option.alightLabel;
      headerReady = true;
      await _findPlanned();
    } else {
      final j = await _planner.byId(plannedJourneyId!);
      if (j == null) {
        missing = true;
        setBusy(false);
        return;
      }
      _fromPlanned(j);
    }
    timetable = await _ref.currentTimetable(timetableNumber, date);
    legend = await _ref.notesFor(timetableNumber);
    await _loadTrip();
    await _loadWholeTrip();
    setBusy(false);
  }

  Future<void> _loadWholeTrip() async {
    try {
      wholeTrip = (await _journeys.tripStops(scheduleId, tripIndex, 0, 9999)).data;
    } catch (_) {
      // Offline without it saved: the rider's own stretch is shown instead.
    }
  }

  void _fromPlanned(PlannedJourney j) {
    planned = j;
    final row = j.row;
    routeNumber = j.routeNumber;
    routeLabel = row.routeLabel;
    timetableNumber = row.timetableNumber;
    operator = j.operator;
    fare = j.cashFareCents == null ? null : Fare(cashCents: j.cashFareCents);
    dayLabel = row.dayLabel;
    from = j.from;
    to = j.to;
    date = j.date;
    boardMinutes = j.boardMinutes;
    arriveMinutes = j.arriveMinutes;
    boardApprox = row.boardApprox;
    arriveApprox = row.arriveApprox;
    boardRaw = row.boardRaw;
    arriveRaw = row.arriveRaw;
    scheduleId = row.scheduleId;
    tripIndex = row.tripIndex;
    fromSeq = row.fromSeq;
    toSeq = row.toSeq;
    boardLabel = j.boardLabel;
    alightLabel = j.alightLabel;
    trip = j.trip;
    headerReady = true;
  }

  Future<void> _findPlanned() async {
    final list = await _planner.forDate(date);
    planned = list
        .where((j) => '${j.row.scheduleId}:${j.row.tripIndex}:${j.row.fromSeq}:${j.row.toSeq}' == rideKey)
        .firstOrNull;
  }

  Future<void> _loadTrip() async {
    if (trip != null) return;
    try {
      final res = await _journeys.tripStops(scheduleId, tripIndex, fromSeq, toSeq, pin: isPlanned);
      trip = res.data;
      tripFromCache = res.fromCache;
      tripFetchedAt = res.fetchedAt;
      if (planned != null) await _planner.saveSnapshot(planned!.id, res.data);
    } on NotAvailableOffline {
      tripUnavailable = true;
    } catch (_) {
      tripUnavailable = true;
    }
  }

  Future<void> retryTrip() async {
    tripUnavailable = false;
    setBusy(true);
    await _loadTrip();
    setBusy(false);
  }

  /// Add this ride to the planner (with its stop times, so it works offline).
  Future<PlannedJourney?> addToPlanner({bool quiet = false}) async {
    if (planned != null) return planned;
    final r = ride;
    if (r == null) return null;
    final id = await _planner.add(r, trip: trip);
    if (trip == null) {
      // Pin the saved response so eviction never removes a planner trip's detail.
      try {
        final res = await _journeys.tripStops(scheduleId, tripIndex, fromSeq, toSeq, pin: true);
        await _planner.saveSnapshot(id, res.data);
      } catch (_) {}
    }
    planned = await _planner.byId(id);
    if (!quiet) message = 'Added to your planner for ${formatDayRelative(date, _clock.today).toLowerCase()}.';
    rebuildUi();
    return planned;
  }

  Future<void> removeFromPlanner() async {
    final j = planned;
    if (j == null) return;
    await _reminders.cancelFor(j.id);
    await _planner.remove(j.id);
    planned = null;
    message = 'Removed from your planner.';
    rebuildUi();
    if (ride == null) _nav.back();
  }

  Future<void> startTrip() async {
    final j = await addToPlanner(quiet: true);
    if (j == null) return;
    await _planner.start(j.id);
    if (_settings.getOffAlerts && _reminders.isSupported) {
      final fresh = await _planner.byId(j.id);
      if (fresh != null) await _reminders.scheduleGetOff(fresh);
    }
    _nav.popUntil((route) => route.isFirst);
    locator<ShellService>().go(AppTab.trip);
  }

  Future<void> remindMe() async {
    if (!_reminders.isSupported) {
      message = kIsWeb
          ? 'Reminders need the Commuttr app on Android or iPhone — browsers can\'t alert you reliably.'
          : 'Reminders aren\'t available on this device.';
      rebuildUi();
      return;
    }
    final lead = _settings.reminderLeadMinutes;
    if (minutesUntil <= lead) {
      message = 'This ${operator.vehicle} is scheduled in under $lead minutes — too soon for a reminder.';
      rebuildUi();
      return;
    }
    if (!await _reminders.requestPermission()) {
      message = 'Allow notifications for Commuttr in your phone settings to get reminders.';
      rebuildUi();
      return;
    }
    final j = await addToPlanner(quiet: true);
    if (j == null) return;
    final ok = await _reminders.scheduleLeave(j, lead);
    if (ok) await _planner.setReminder(j.id, lead);
    planned = await _planner.byId(j.id);
    message = ok
        ? 'We\'ll remind you $lead min before $boardTime.'
        : 'Couldn\'t set the reminder — the time has passed.';
    rebuildUi();
  }

  Future<void> share() => _support.shareText(
    '${operator.isTrain ? '${operator.name} $routeNumber line' : '${operator.name} route $routeNumber'}\n'
    '${from.displayName} → ${to.displayName}\n'
    '${formatDate(date)}: scheduled $boardTime${boardApprox ? ' (approx.)' : ''}'
    '${arriveTime != null ? ', arrives $arriveTime' : ''}\n'
    'Scheduled times, not live — shared from Commuttr.',
    subject: 'My ${operator.vehicle}',
  );

  Future<void> openPdf() async {
    final url = timetable?.pdfUrl;
    if (url != null) await _support.openUrl(url);
  }

  void report() => _nav.navigateToReportIssueView(
    report: ReportContext(
      fromName: from.name,
      fromId: from.id,
      toName: to.name,
      toId: to.id,
      serviceDate: date.iso,
      dayType: dayTypeFor(date).api,
      routeLabel: routeLabel,
      timetableNumber: timetableNumber,
      rideKey: rideKey,
      boardTime: boardTime,
      pdfUrl: timetable?.pdfUrl,
      fromCache: tripFromCache,
      fetchedAt: tripFetchedAt,
    ),
  );

  void clearMessage() => message = null;
}
