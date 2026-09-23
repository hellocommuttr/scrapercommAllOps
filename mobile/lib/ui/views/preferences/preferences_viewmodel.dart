import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../data/api/commuttr_api.dart';
import '../../../services/reminder_service.dart';
import '../../../services/settings_service.dart';

/// Notifications (journey reminders, get-off alerts, timetable updates), data saver and
/// theme. Every change is saved as soon as it is made.
class PreferencesViewModel extends ReactiveViewModel {
  final _settings = locator<SettingsService>();
  final _reminders = locator<ReminderService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_settings];

  static const leadChoices = [5, 10, 15, 20, 30];
  static const earlyChoices = [0, 5, 10];

  static const _permissionRefused =
      "Notifications are off for Commuttr. Turn them on in your phone's settings to get reminders.";

  ThemeMode get themeMode => _settings.themeMode;
  Future<void> setThemeMode(ThemeMode m) => _settings.setThemeMode(m);

  /// Reminders are OS notifications, which only the Android and iOS apps can schedule.
  bool get remindersSupported => _reminders.isSupported;

  // -- notifications

  bool get journeyReminders => remindersSupported && _settings.notifyJourneyUpdates;

  /// Asks for notification permission before switching on. Returns a message to show
  /// when permission was refused (the setting then stays off).
  Future<String?> setJourneyReminders(bool on) async {
    if (on && !await _reminders.requestPermission()) {
      await _settings.setNotifyJourneyUpdates(false);
      return _permissionRefused;
    }
    await _settings.setNotifyJourneyUpdates(on);
    return null;
  }

  bool get getOffAlerts => remindersSupported && _settings.getOffAlerts;

  Future<String?> setGetOffAlerts(bool on) async {
    if (on && !await _reminders.requestPermission()) {
      await _settings.setGetOffAlerts(false);
      return _permissionRefused;
    }
    await _settings.setGetOffAlerts(on);
    return null;
  }

  /// In-app notices when timetables change; these live in the Notifications inbox.
  bool get timetableUpdates => _settings.notifyTimetableUpdates;
  Future<void> setTimetableUpdates(bool on) => _settings.setNotifyTimetableUpdates(on);

  int get reminderLead => _settings.reminderLeadMinutes;
  Future<void> setReminderLead(int v) => _settings.setReminderLeadMinutes(v);

  // -- data saver & travel

  bool get showMaps => _settings.showMaps;
  Future<void> setShowMaps(bool v) => _settings.setShowMaps(v);

  bool get shareUsage => _settings.shareUsage;

  /// Turning it off stops anything being sent and forgets the id, so the API is told at
  /// once rather than on the next launch.
  Future<void> setShareUsage(bool v) async {
    await _settings.setShareUsage(v);
    locator<CommuttrApi>().identify(
      deviceId: v ? await _settings.ensureInstallId() : null,
      client: v ? 'app' : null,
    );
    rebuildUi();
  }

  int get arriveEarly => _settings.arriveEarlyMinutes;
  Future<void> setArriveEarly(int v) => _settings.setArriveEarlyMinutes(v);
}
