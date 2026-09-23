import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../app/app.locator.dart';
import '../data/db/app_database.dart';

/// Typed settings over the `key_values` table, loaded once at startup and kept in memory.
///
/// Everything lives in SQLite (not shared_preferences) so "Erase everything" and
/// export/import each have exactly one store to deal with.
class SettingsService with ListenableServiceMixin {
  SettingsService({AppDatabase? db}) : _db = db ?? locator<AppDatabase>() {
    listenToReactiveValues([_themeMode]);
  }

  final AppDatabase _db;
  final Map<String, String> _values = {};
  final ReactiveValue<ThemeMode> _themeMode = ReactiveValue(ThemeMode.dark);

  /// Bump to show the onboarding again after a significant change to how the app works.
  static const onboardingVersion = 1;

  Future<void> load() async {
    final rows = await _db.select(_db.keyValues).get();
    _values
      ..clear()
      ..addEntries(rows.map((r) => MapEntry(r.key, r.value)));
    _themeMode.value = ThemeMode.values.asNameMap()[_values['theme_mode']] ?? ThemeMode.dark;
  }

  String? _get(String key) => _values[key];

  Future<void> _set(String key, String? value) async {
    if (value == null) {
      _values.remove(key);
      await (_db.delete(_db.keyValues)..where((t) => t.key.equals(key))).go();
    } else {
      _values[key] = value;
      await _db.into(_db.keyValues).insertOnConflictUpdate(KeyValuesCompanion.insert(key: key, value: value));
    }
    notifyListeners();
  }

  // -- onboarding
  bool get onboardingSeen => int.tryParse(_get('onboarding_seen') ?? '') == onboardingVersion;
  Future<void> markOnboardingSeen() => _set('onboarding_seen', '$onboardingVersion');

  // -- profile (on this device only)
  String get displayName => _get('display_name') ?? '';
  Future<void> setDisplayName(String v) => _set('display_name', v.trim().isEmpty ? null : v.trim());
  String get homeArea => _get('home_area') ?? '';

  /// Optional contact details and photo. Stored on this device only; never uploaded.
  String get phone => _get('phone') ?? '';
  Future<void> setPhone(String v) => _set('phone', v.trim().isEmpty ? null : v.trim());
  String get email => _get('email') ?? '';
  Future<void> setEmail(String v) => _set('email', v.trim().isEmpty ? null : v.trim());

  /// Profile photo as base64-encoded image bytes.
  String? get photoBase64 => _get('photo');
  Future<void> setPhotoBase64(String? v) => _set('photo', v);

  /// Operator codes the commuter prefers; searches start with only these switched on.
  /// Empty means all operators.
  Set<String> get preferredOperators =>
      (_get('preferred_operators') ?? '').split(',').where((s) => s.isNotEmpty).toSet();
  Future<void> setPreferredOperators(Set<String> v) => _set('preferred_operators', v.isEmpty ? null : v.join(','));

  /// Default "depart" time for new searches, minutes after midnight; null means now.
  int? get defaultDepartMinutes => int.tryParse(_get('default_depart') ?? '');
  Future<void> setDefaultDepartMinutes(int? v) => _set('default_depart', v?.toString());

  /// Accessibility: larger text (a text scale multiplier), bold text, and reduced motion.
  double get textScale => double.tryParse(_get('text_scale') ?? '') ?? 1.0;
  Future<void> setTextScale(double v) => _set('text_scale', v == 1.0 ? null : '$v');
  bool get boldText => _get('bold_text') == 'true';
  Future<void> setBoldText(bool v) => _set('bold_text', v ? 'true' : null);
  bool get reduceMotion => _get('reduce_motion') == 'true';
  Future<void> setReduceMotion(bool v) => _set('reduce_motion', v ? 'true' : null);

  /// Push-style notification switches for the in-app inbox and reminders.
  /// Whether this phone helps us count how the network is used. On by default, and the
  /// whole of what it sends is described in the privacy policy: no name, no account, and
  /// an id this app made that the rider can throw away by turning this off.
  bool get shareUsage => _get('share_usage') != 'false';
  Future<void> setShareUsage(bool v) async {
    await _set('share_usage', '$v');
    // Off means forgotten, not merely silent: the next time it goes on, this phone is a
    // new one as far as any count is concerned.
    if (!v) await _set('install_id', null);
  }

  /// A random value made on first launch, so two searches from this phone can be counted
  /// as one person without anybody knowing who. Null while sharing is off.
  String? get installId => shareUsage ? _get('install_id') : null;
  Future<String?> ensureInstallId() async {
    if (!shareUsage) return null;
    final existing = _get('install_id');
    if (existing != null && existing.isNotEmpty) return existing;
    final made = _randomId();
    await _set('install_id', made);
    return made;
  }

  static String _randomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random.secure();
    return List.generate(24, (_) => chars[r.nextInt(chars.length)]).join();
  }

  /// Searches the app answered from its saved copy while offline, waiting for a
  /// connection to be reported. Capped, and dropped entirely when sharing is off.
  String? get pendingUsage => shareUsage ? _get('pending_usage') : null;
  Future<void> setPendingUsage(String? v) => _set('pending_usage', v);

  bool get notifyJourneyUpdates => _get('notify_journey') != 'false';
  Future<void> setNotifyJourneyUpdates(bool v) => _set('notify_journey', '$v');
  bool get notifyTimetableUpdates => _get('notify_timetable') != 'false';
  Future<void> setNotifyTimetableUpdates(bool v) => _set('notify_timetable', '$v');
  Future<void> setHomeArea(String v) => _set('home_area', v.trim().isEmpty ? null : v.trim());

  // -- preferences
  ThemeMode get themeMode => _themeMode.value;
  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode.value = m;
    await _set('theme_mode', m.name);
  }

  /// Minutes before departure for the "time to leave" reminder.
  int get reminderLeadMinutes => int.tryParse(_get('reminder_lead') ?? '') ?? 10;
  Future<void> setReminderLeadMinutes(int v) => _set('reminder_lead', '$v');

  /// Remind me to get off one stop before mine.
  bool get getOffAlerts => _get('get_off_alerts') != 'false';
  Future<void> setGetOffAlerts(bool v) => _set('get_off_alerts', '$v');

  /// Data saver: maps download tiles, so they can be switched off.
  bool get showMaps => _get('show_maps') != 'false';
  Future<void> setShowMaps(bool v) => _set('show_maps', '$v');

  /// How many minutes early the commuter likes to be at the stop (shown on trip detail).
  int get arriveEarlyMinutes => int.tryParse(_get('arrive_early') ?? '') ?? 5;
  Future<void> setArriveEarlyMinutes(int v) => _set('arrive_early', '$v');

  // -- data
  String? get dataVersion => _get('data_version');
  Future<void> setDataVersion(String v) => _set('data_version', v);

  DateTime? get lastRefresh => DateTime.tryParse(_get('last_refresh') ?? '');
  Future<void> setLastRefresh(DateTime v) => _set('last_refresh', v.toUtc().toIso8601String());

  String? get activeJourneyId => _get('active_journey');
  Future<void> setActiveJourneyId(String? id) => _set('active_journey', id);

  /// Everything, for export.
  Map<String, String> get all => Map.unmodifiable(_values);

  Future<void> importAll(Map<String, String> values) async {
    for (final e in values.entries) {
      await _set(e.key, e.value);
    }
    await load();
  }

  void clearMemory() {
    _values.clear();
    _themeMode.value = ThemeMode.dark;
  }
}
