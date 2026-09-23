import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/service_day.dart';
import '../../../services/planner_service.dart';
import '../../../services/reminder_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/shell_service.dart';

/// Which list the Planner shows.
enum PlannerTab { planned, completed }

/// The Planner tab: the commuter's saved journeys for one day.
///
/// Actions that need to tell the commuter something return the message, and the view
/// shows it as a snackbar in the app's own theme.
class PlannerViewModel extends ReactiveViewModel {
  PlannerViewModel({SastClock clock = const SastClock()}) : _clock = clock;

  final SastClock _clock;
  final _planner = locator<PlannerService>();
  final _reminders = locator<ReminderService>();
  final _settings = locator<SettingsService>();
  final _shell = locator<ShellService>();
  final _nav = locator<NavigationService>();
  final _dialogs = locator<DialogService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_planner];

  late ServiceDate _date = _clock.today;
  ServiceDate get date => _date;
  ServiceDate get today => _clock.today;

  /// The date bar's label: "Today, 19 Sep 2026", "Tomorrow, 20 Sep 2026", "Sat, 26 Sep 2026".
  String get dateLabel {
    final parts = formatDate(_date).split(' ');
    final rel = formatDayRelative(_date, today);
    final lead = const {'Today', 'Tomorrow', 'Yesterday'}.contains(rel) ? rel : parts.first;
    return '$lead, ${parts.skip(1).join(' ')}';
  }

  PlannerTab tab = PlannerTab.planned;

  List<PlannedJourney> _all = const [];

  /// Every journey on the selected day, whatever its status.
  List<PlannedJourney> get all => _all;

  List<PlannedJourney> get planned => _all.where((j) => j.status != JourneyStatus.completed).toList();
  List<PlannedJourney> get completed => _all.where((j) => j.status == JourneyStatus.completed).toList();
  List<PlannedJourney> get shown => tab == PlannerTab.planned ? planned : completed;

  int get journeyCount => _all.length;

  double get totalTravelMinutes => _all.fold(0, (sum, j) => sum + (j.durationMinutes ?? 0));

  /// "stop", "station", or "stop or station" for a day with both.
  String get placeWord {
    final kinds = {for (final j in _all) j.operator.stopWord};
    return kinds.length == 1 ? kinds.first : (kinds.isEmpty ? 'stop' : 'stop or station');
  }

  /// Who runs the day's journeys: "Golden Arrow", "Metrorail", "Bus & train", or "—".
  String get transportMode {
    final ops = {for (final j in _all) j.operator};
    if (ops.isEmpty) return '-';
    if (ops.length == 1) return ops.first.name;
    final kinds = {for (final o in ops) o.kind};
    return kinds.length > 1 ? 'Bus & train' : (kinds.first == 'train' ? 'Trains' : 'Buses');
  }

  bool _loadedOnce = false;
  bool get loadedOnce => _loadedOnce;

  Future<void> init() async {
    // ReactiveViewModel only rebuilds on a service change; the journeys must be re-read.
    _planner.addListener(_onPlannerChanged);
    await load();
  }

  void _onPlannerChanged() => load();

  Future<void> load() async {
    final requested = _date;
    final rows = await runBusyFuture(_planner.forDate(requested));
    // Ignore a slow answer for a day the commuter has already moved away from.
    if (requested != _date) return;
    _all = rows;
    _loadedOnce = true;
    rebuildUi();
  }

  void setTab(int index) {
    tab = PlannerTab.values[index];
    rebuildUi();
  }

  void setDate(ServiceDate d) {
    if (d == _date) return;
    _date = d;
    rebuildUi();
    load();
  }

  void previousDay() => setDate(_date.addDays(-1));
  void nextDay() => setDate(_date.addDays(1));

  void addJourney() => _shell.go(AppTab.home);

  void openNotifications() => _nav.navigateToNotificationsView();

  void viewDetails(PlannedJourney j) => _nav.navigateToTripDetailView(plannedJourneyId: j.id);

  Future<void> startTrip(PlannedJourney j) async {
    await _planner.start(j.id);
    _shell.go(AppTab.trip);
  }

  /// Schedule a "time to leave" notification. Returns the message to show.
  Future<String> remind(PlannedJourney j) async {
    if (!_reminders.isSupported) {
      return 'Reminders need the Commuttr Android or iOS app. The web version cannot notify you.';
    }
    final allowed = await _reminders.requestPermission();
    if (!allowed) return 'Allow notifications for Commuttr in your phone settings to get reminders.';
    final lead = _settings.reminderLeadMinutes;
    final ok = await _reminders.scheduleLeave(j, lead);
    if (!ok) {
      return 'Too late for a reminder. The ${j.boardTime} ${j.operator.vehicle} is scheduled '
          'less than $lead min from now.';
    }
    await _planner.setReminder(j.id, lead);
    return "We'll remind you $lead min before the scheduled ${j.boardTime} departure.";
  }

  /// Move [j] to [to]. Any reminder was for the old day, so it is cancelled.
  Future<String?> moveTo(PlannedJourney j, ServiceDate to) async {
    if (to == j.date) return null;
    await _reminders.cancelFor(j.id);
    if (j.row.reminderLeadMinutes != null) await _planner.setReminder(j.id, null);
    await _planner.moveTo(j.id, to);
    return 'Moved to ${formatDayRelative(to, today)}.';
  }

  /// Ask first, then delete [j] and its reminders. Returns a message once deleted.
  Future<String?> delete(PlannedJourney j) async {
    final res = await _dialogs.showConfirmationDialog(
      title: 'Delete this journey?',
      description:
          'The ${j.boardTime} ${j.operator.isTrain ? '${j.routeNumber} line train' : 'route ${j.routeNumber}'} '
          'from ${j.from.displayName} will be removed '
          'from your planner, with any reminders for it.',
      confirmationTitle: 'Delete',
      cancelTitle: 'Keep',
      barrierDismissible: true,
    );
    if (res?.confirmed != true) return null;
    await _reminders.cancelFor(j.id);
    await _planner.remove(j.id);
    return 'Journey deleted.';
  }

  @override
  void dispose() {
    _planner.removeListener(_onPlannerChanged);
    super.dispose();
  }
}
