import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/cached_api_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/favourites_service.dart';
import '../../../services/reference_data_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/shell_service.dart';
import '../../../services/support_service.dart';
import '../profile/page_layout.dart';

/// What is saved on this device, and the commuter's data actions: refresh, export,
/// import, clear history, erase everything.
///
/// Actions return a message for the view to show as a snackbar (null = nothing to say).
class OfflineDataViewModel extends ReactiveViewModel {
  final _settings = locator<SettingsService>();
  final _connectivity = locator<ConnectivityService>();
  final _cache = locator<CachedApiService>();
  final _reference = locator<ReferenceDataService>();
  final _favourites = locator<FavouritesService>();
  final _support = locator<SupportService>();
  final _dialogs = locator<DialogService>();
  final _nav = locator<NavigationService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_settings, _connectivity];

  static const refreshKey = 'refresh';
  static const exportKey = 'export';
  static const importKey = 'import';
  static const eraseKey = 'erase';

  bool get isWeb => kIsWeb;
  bool get offline => _connectivity.isOffline;

  int? stopCount;
  int? cacheBytes;

  String get snapshotDate => formatDataVersion(_settings.dataVersion) ?? 'Not loaded yet';

  String get lastRefreshed {
    final t = _settings.lastRefresh;
    return t == null
        ? 'Using the timetables that came with the app'
        : 'Last refreshed ${formatSastDate(t, withTime: true)}';
  }

  String get stopsLabel => stopCount == null ? '…' : '$stopCount stops';
  String get cacheLabel => switch (cacheBytes) {
    null => '…',
    0 => 'None yet',
    final b => formatBytes(b),
  };

  Future<void> init() => _loadCounts();

  Future<void> _loadCounts() async {
    stopCount = await _reference.stopCount();
    cacheBytes = await _cache.sizeBytes();
    rebuildUi();
  }

  // ---------------------------------------------------------------- refresh

  Future<String?> refresh() async {
    if (offline) {
      return "You're offline. Connect to the internet to refresh — your saved timetables still work.";
    }
    final ok = await _confirm(
      'Refresh timetable data?',
      'Commuttr reloads its timetables and downloads the latest stops and routes. '
          'Your planner, favourites and settings are kept.\n\n'
          'If the download works, searches saved for offline are cleared so they are fetched fresh. '
          'Nothing is cleared if you are offline.',
      'Refresh',
    );
    if (!ok) return null;
    bool refreshed;
    try {
      refreshed = await runBusyFuture(_support.refreshTimetableData(), busyObject: refreshKey, throwException: true);
    } catch (_) {
      return "Couldn't refresh the timetables. Your saved timetables still work — try again later.";
    } finally {
      await _loadCounts();
    }
    return refreshed
        ? 'Timetable data refreshed.'
        : "Couldn't reach Commuttr. Nothing was changed — your saved timetables still work. "
              'Try again when you have signal.';
  }

  // ---------------------------------------------------------------- export

  Future<String?> shareBackup() async {
    try {
      await runBusyFuture(_support.shareBackupFile(), busyObject: exportKey, throwException: true);
      return null;
    } catch (_) {
      return "Couldn't create the backup. Try again, or use Copy instead.";
    }
  }

  Future<String?> copyBackup() async {
    try {
      final json = await runBusyFuture(_support.exportData(), busyObject: exportKey, throwException: true);
      await Clipboard.setData(ClipboardData(text: json));
      return 'Backup copied. Paste it somewhere safe, like a note or a message to yourself.';
    } catch (_) {
      return "Couldn't copy the backup. Try again.";
    }
  }

  // ---------------------------------------------------------------- import

  /// Pick a .json backup file and import it.
  Future<String?> importFromFile() async {
    final String text;
    try {
      final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']);
      if (file == null) return null;
      text = utf8.decode(await file.readAsBytes(), allowMalformed: true);
    } catch (_) {
      return "Couldn't open that file. Choose the .json backup you exported from Commuttr.";
    }
    return importText(text);
  }

  /// Import backup text (from a file or pasted in).
  Future<String?> importText(String text) async {
    if (text.trim().isEmpty) return null;
    final ok = await _confirm(
      'Import this backup?',
      'Planner journeys, favourites, search history and settings from the backup are added to this device. '
          'Anything already here with the same details is replaced by the backup copy.',
      'Import',
    );
    if (!ok) return null;
    try {
      await runBusyFuture(_support.importData(text.trim()), busyObject: importKey, throwException: true);
      await _loadCounts();
      return 'Backup imported.';
    } on FormatException {
      return "That isn't a Commuttr backup. Use the text or .json file you exported from Commuttr.";
    } catch (_) {
      return "Couldn't import that backup — it may be damaged or from a newer version of Commuttr.";
    }
  }

  // ---------------------------------------------------------------- history & erase

  Future<String?> clearHistory() async {
    final ok = await _confirm(
      'Clear search history?',
      'Your recent and frequent searches are removed. Saved trips, Home and Work are kept.',
      'Clear',
    );
    if (!ok) return null;
    await _favourites.clearHistory();
    return 'Search history cleared.';
  }

  /// Returns a message only when erasing fails; on success the app restarts at the splash.
  Future<String?> eraseEverything() async {
    final ok = await _confirm(
      'Erase everything?',
      'This deletes from this device:\n'
          '• Your planner and its reminders\n'
          '• Favourites: Home, Work and saved trips\n'
          '• Search history\n'
          '• Notifications\n'
          '• Your profile and settings\n\n'
          "The timetables that came with the app are reloaded. This can't be undone — "
          'export a backup first if you might want it back.',
      'Erase everything',
    );
    if (!ok) return null;
    try {
      await runBusyFuture(_support.eraseEverything(), busyObject: eraseKey, throwException: true);
    } catch (_) {
      return "Couldn't erase everything. Close Commuttr, open it again and retry.";
    }
    locator<ShellService>().go(AppTab.home);
    unawaited(_nav.clearStackAndShow(Routes.startupView));
    return null;
  }

  Future<bool> _confirm(String title, String description, String action) async {
    final r = await _dialogs.showConfirmationDialog(
      title: title,
      description: description,
      confirmationTitle: action,
      cancelTitle: 'Cancel',
      barrierDismissible: true,
    );
    return r?.confirmed ?? false;
  }
}
