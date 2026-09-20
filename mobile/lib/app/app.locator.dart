// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_services/src/snackbar/snackbar_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../data/api/commuttr_api.dart';
import '../data/db/app_database.dart';
import '../services/cached_api_service.dart';
import '../services/connectivity_service.dart';
import '../services/favourites_service.dart';
import '../services/inbox_service.dart';
import '../services/journey_service.dart';
import '../services/location_service.dart';
import '../services/planner_service.dart';
import '../services/reference_data_service.dart';
import '../services/reminder_service.dart';
import '../services/settings_service.dart';
import '../services/shell_service.dart';
import '../services/support_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
  // Register environments
  locator.registerEnvironment(
    environment: environment,
    environmentFilter: environmentFilter,
  );

  // Register dependencies
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => AppDatabase());
  locator.registerLazySingleton<CommuttrApi>(() => HttpCommuttrApi());
  locator.registerLazySingleton(() => SettingsService());
  locator.registerLazySingleton(() => ConnectivityService());
  locator.registerLazySingleton(() => CachedApiService());
  locator.registerLazySingleton(() => ReferenceDataService());
  locator.registerLazySingleton(() => JourneyService());
  locator.registerLazySingleton(() => PlannerService());
  locator.registerLazySingleton(() => FavouritesService());
  locator.registerLazySingleton(() => InboxService());
  locator.registerLazySingleton(() => ReminderService());
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => ShellService());
  locator.registerLazySingleton(() => SupportService());
}
