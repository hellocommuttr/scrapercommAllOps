import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/service_day.dart';
import '../../../services/journey_service.dart';
import '../../../services/planner_service.dart';
import '../../../services/reminder_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/shell_service.dart';
import '../../../services/support_service.dart';
import 'trip_progress.dart';

/// The Live Journey tab: the active planner journey, followed through the timetable.
///
/// Nothing here comes from the bus or train. Progress is the scheduled stop times compared with
/// the Cape Town clock, refreshed every 30 seconds.
class OnTripViewModel extends ReactiveViewModel {
  OnTripViewModel({SastClock clock = const SastClock()}) : _clock = clock;

  final SastClock _clock;
  final _planner = locator<PlannerService>();
  final _journeys = locator<JourneyService>();
  final _reminders = locator<ReminderService>();
  final _shell = locator<ShellService>();
  final _support = locator<SupportService>();
  final _settings = locator<SettingsService>();
  final _nav = locator<NavigationService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_planner];

  Timer? _ticker;

  PlannedJourney? _journey;
  PlannedJourney? get journey => _journey;

  /// The next planned journey, offered when no trip is under way.
  PlannedJourney? _next;
  PlannedJourney? get next => _next;

  /// Stop times could not be loaded (offline and never saved); only the ends show.
  bool get stopsUnavailable => _journey != null && _journey!.trip == null;

  bool _loadedOnce = false;
  bool get loadedOnce => _loadedOnce;

  /// Whether a get-off reminder was set for [journey] in this session.
  bool getOffReminder = false;
  bool get remindersSupported => _reminders.isSupported;

  ServiceDate get today => _clock.today;

  /// Whether maps are on (the data-saver preference); the map's buttons only show over a map.
  bool get showMaps => _settings.showMaps;

  /// Bumped to rebuild the map, which fits the route again.
  int mapEpoch = 0;

  void recentreMap() {
    mapEpoch++;
    rebuildUi();
  }

  /// The compact "Your trip" timeline shows every stop.
  bool timelineExpanded = false;

  void toggleTimeline() {
    timelineExpanded = !timelineExpanded;
    rebuildUi();
  }

  /// Minutes from now to [j]'s scheduled departure; negative once it has passed.
  double minutesUntilDeparture(PlannedJourney j) => _clock.minutesUntil(j.date, j.boardMinutes);

  TripProgress? get progress => _journey == null ? null : TripProgress.of(_journey!, _clock);

  Future<void> init() async {
    // ReactiveViewModel only rebuilds on a service change; the journey must be re-read.
    _planner.addListener(_onPlannerChanged);
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_journey != null || _next != null) rebuildUi();
    });
    await load();
  }

  void _onPlannerChanged() => load();

  Future<void> load() async {
    setBusy(true);
    try {
      var j = await _planner.active();
      if (j != null && j.trip == null) j = await _withSnapshot(j);
      if (j?.id != _journey?.id) {
        getOffReminder = j == null ? false : await _reminders.hasGetOff(j.id);
        timelineExpanded = false;
      }
      _journey = j;
      _next = j == null ? await _nextPlanned() : null;
    } finally {
      _loadedOnce = true;
      setBusy(false);
    }
  }

  /// Fetch and keep the stop times, so the trip still shows offline next time.
  Future<PlannedJourney> _withSnapshot(PlannedJourney j) async {
    try {
      final r = j.row;
      final res = await _journeys.tripStops(r.scheduleId, r.tripIndex, r.fromSeq, r.toSeq, pin: true);
      await _planner.saveSnapshot(j.id, res.data);
      return await _planner.byId(j.id) ?? j;
    } catch (_) {
      return j;
    }
  }

  Future<PlannedJourney?> _nextPlanned() async {
    final list = await _planner.upcoming(_clock.today, limit: 10);
    for (final j in list) {
      // Allow a few minutes' grace: the bus or train may still be at the stop.
      if (_clock.minutesUntil(j.date, j.boardMinutes) > -5) return j;
    }
    return null;
  }

  // ---------------------------------------------------------------- actions

  void planTrip() => _shell.go(AppTab.home);

  void openNotifications() => _nav.navigateToNotificationsView();

  void viewFullTrip() {
    final j = _journey;
    if (j != null) _nav.navigateToTripDetailView(plannedJourneyId: j.id);
  }

  void getHelp() => _nav.navigateToHelpView();

  /// Open the next stop (else the destination) in OpenStreetMap, for walking directions.
  Future<void> openNextStopInMap() async {
    final j = _journey;
    if (j == null) return;
    final next = progress?.nextStop;
    final (lat, lon) = next != null && next.hasLocation ? (next.lat!, next.lon!) : (j.to.lat, j.to.lon);
    final la = lat.toStringAsFixed(5), lo = lon.toStringAsFixed(5);
    await _support.openUrl('https://www.openstreetmap.org/?mlat=$la&mlon=$lo#map=17/$la/$lo');
  }

  Future<void> startNext() async {
    final n = _next;
    if (n != null) await _planner.start(n.id);
  }

  Future<void> endTrip() async {
    final j = _journey;
    if (j == null) return;
    await _reminders.cancelFor(j.id);
    await _planner.complete(j.id);
  }

  /// Turn the get-off reminder on or off. Returns a message when it could not be set.
  Future<String?> setGetOffReminder(bool on) async {
    final j = _journey;
    if (j == null) return null;
    if (!on) {
      await _reminders.cancelGetOff(j.id);
      getOffReminder = false;
      rebuildUi();
      return null;
    }
    if (!_reminders.isSupported) return 'Reminders need the Commuttr Android or iOS app.';
    final allowed = await _reminders.requestPermission();
    if (!allowed) return 'Allow notifications for Commuttr in your phone settings to get this reminder.';
    final ok = await _reminders.scheduleGetOff(j);
    getOffReminder = ok;
    rebuildUi();
    if (ok) return null;
    final place = j.operator.stopWord;
    return j.trip == null
        ? "${place == 'station' ? 'Station' : 'Stop'} times for this trip aren't saved yet, "
              "so there's nothing to time the reminder from."
        : 'Too late for a reminder. The $place before yours is already past its scheduled time.';
  }

  Future<void> share() async {
    final j = _journey;
    if (j == null) return;
    await _support.shareText(shareSummary(j), subject: 'My ${j.operator.name} trip');
  }

  /// "Metrorail Monte Vista line" / "Golden Arrow route 101".
  static String serviceName(PlannedJourney j) =>
      j.operator.isTrain ? '${j.operator.name} ${j.routeNumber} line' : '${j.operator.name} route ${j.routeNumber}';

  /// A short, WhatsApp-friendly description of [j].
  String shareSummary(PlannedJourney j) {
    final approx = j.approx ? ' (approx.)' : '';
    return [
      'My ${j.operator.vehicle} trip: ${serviceName(j)}',
      'From: ${j.from.displayName}',
      'To: ${j.to.displayName}',
      'Date: ${formatDate(j.date, withYear: false)}',
      'Scheduled departure: ${j.boardTime}$approx',
      if (j.arriveTime != null) 'Scheduled arrival: ${j.arriveTime}$approx',
      '',
      'Scheduled times, shared from Commuttr',
    ].join('\n');
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _planner.removeListener(_onPlannerChanged);
    super.dispose();
  }
}
