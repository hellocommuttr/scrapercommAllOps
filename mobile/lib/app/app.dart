import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

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
import '../ui/bottom_sheets/filters/filters_sheet.dart';
import '../ui/dialogs/onboarding/onboarding_dialog.dart';
import '../ui/views/about/about_view.dart';
import '../ui/views/connection_detail/connection_detail_view.dart';
import '../ui/views/edit_profile/edit_profile_view.dart';
import '../ui/views/favourites/favourites_view.dart';
import '../ui/views/help/help_view.dart';
import '../ui/views/legal/legal_view.dart';
import '../ui/views/main/main_view.dart';
import '../ui/views/nearby_stops/nearby_stops_view.dart';
import '../ui/views/notifications/notifications_view.dart';
import '../ui/views/offline_data/offline_data_view.dart';
import '../ui/views/preferences/preferences_view.dart';
import '../ui/views/report_issue/report_issue_view.dart';
import '../ui/views/route_detail/route_detail_view.dart';
import '../ui/views/startup/startup_view.dart';
import '../ui/views/stop_picker/stop_picker_view.dart';
import '../ui/views/timetable/timetable_view.dart';
import '../ui/views/trip_detail/trip_detail_view.dart';

/// The app's routes, services, dialogs and bottom sheets. `dart run build_runner build`
/// generates app.locator.dart, app.router.dart, app.dialogs.dart and app.bottomsheets.dart.
///
/// Home, Planner, On my trip, Explore and Profile are tabs inside [MainView], not routes.
@StackedApp(
  routes: [
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: MainView),
    MaterialRoute(page: StopPickerView),
    MaterialRoute(page: TripDetailView),
    MaterialRoute(page: ConnectionDetailView),
    MaterialRoute(page: RouteDetailView),
    MaterialRoute(page: TimetableView),
    MaterialRoute(page: NearbyStopsView),
    MaterialRoute(page: FavouritesView),
    MaterialRoute(page: EditProfileView),
    MaterialRoute(page: PreferencesView),
    MaterialRoute(page: OfflineDataView),
    MaterialRoute(page: HelpView),
    MaterialRoute(page: ReportIssueView),
    MaterialRoute(page: NotificationsView),
    MaterialRoute(page: LegalView),
    MaterialRoute(page: AboutView),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: AppDatabase),
    LazySingleton(classType: HttpCommuttrApi, asType: CommuttrApi),
    LazySingleton(classType: SettingsService),
    LazySingleton(classType: ConnectivityService),
    LazySingleton(classType: CachedApiService),
    LazySingleton(classType: ReferenceDataService),
    LazySingleton(classType: JourneyService),
    LazySingleton(classType: PlannerService),
    LazySingleton(classType: FavouritesService),
    LazySingleton(classType: InboxService),
    LazySingleton(classType: ReminderService),
    LazySingleton(classType: LocationService),
    LazySingleton(classType: ShellService),
    LazySingleton(classType: SupportService),
  ],
  dialogs: [StackedDialog(classType: OnboardingDialog)],
  bottomsheets: [StackedBottomsheet(classType: FiltersSheet)],
)
class App {}
