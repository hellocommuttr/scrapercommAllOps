import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/inbox_service.dart';
import '../../../services/reference_data_service.dart';
import '../../../services/reminder_service.dart';
import '../../../services/settings_service.dart';

/// Splash: open the database, load the bundled timetables on first run, then go Home.
/// Nothing here waits on the network, so the app opens the same with or without signal.
class StartupViewModel extends BaseViewModel {
  final _nav = locator<NavigationService>();
  final _settings = locator<SettingsService>();
  final _reference = locator<ReferenceDataService>();
  final _inbox = locator<InboxService>();

  String status = 'Getting things ready…';
  String? failure;

  Future<void> runStartupLogic() async {
    failure = null;
    rebuildUi();
    try {
      await _settings.load();
      final firstRun = _settings.dataVersion == null;
      if (firstRun) {
        status = 'Loading bus and train timetables…';
        rebuildUi();
      }
      await _reference.seedIfNeeded();
      if (firstRun) {
        await _inbox.post(
          InboxKind.info,
          'Welcome to Commuttr',
          'Golden Arrow and MyCiTi bus and Metrorail train timetables are saved on your phone, so you can look up '
              'stops, stations and routes without data. Times are scheduled, not live. Your planner and '
              'favourites stay on this device only.',
        );
      }
      await _inbox.refreshCount();
      await locator<ConnectivityService>().start();
      unawaited(locator<ReminderService>().init());
      // Refresh stops and routes in the background at most once a day.
      final last = _settings.lastRefresh;
      if (last == null || DateTime.now().difference(last) > const Duration(hours: 24)) {
        unawaited(_reference.refresh());
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await _nav.replaceWithMainView();
    } catch (e, st) {
      debugPrint('Startup failed: $e\n$st');
      failure =
          "Commuttr couldn't open its saved data. Try again, or reinstall the app if this keeps happening.\n"
          '(${e.runtimeType})';
      rebuildUi();
    }
  }
}
