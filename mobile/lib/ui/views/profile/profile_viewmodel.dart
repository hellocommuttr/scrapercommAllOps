import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/favourites_service.dart';
import '../../../services/planner_service.dart';
import '../../../services/reference_data_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/shell_service.dart';
import '../../../services/support_service.dart';
import '../legal/legal_content.dart';
import 'erase_device.dart';

/// The Profile tab: a local profile (no account), the planner and favourites at a
/// glance, preferences, support, and "Log out" (which clears this device).
class ProfileViewModel extends ReactiveViewModel {
  final _settings = locator<SettingsService>();
  final _favourites = locator<FavouritesService>();
  final _planner = locator<PlannerService>();
  final _reference = locator<ReferenceDataService>();
  final _shell = locator<ShellService>();
  final _nav = locator<NavigationService>();
  final _support = locator<SupportService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_settings];

  /// "Nearby stops" counts stops within this distance of Home.
  static const nearbyRadiusMetres = 1000.0;

  SavedPlace? home;
  SavedPlace? work;
  int savedTripCount = 0;
  int upcomingCount = 0;
  int todayCount = 0;

  /// Stops within [nearbyRadiusMetres] of Home; null when Home isn't set.
  int? nearbyStopCount;

  // -- profile

  String get name => _settings.displayName.isEmpty ? 'Your name' : _settings.displayName;
  String get location => _settings.homeArea.isEmpty ? 'Cape Town, South Africa' : _settings.homeArea;
  String? get photoBase64 => _settings.photoBase64;

  // -- planner

  String get upcomingTitle => upcomingCount == 1 ? '1 upcoming journey' : '$upcomingCount upcoming journeys';
  String get todaySummary =>
      todayCount == 1 ? 'You have 1 saved journey for today.' : 'You have $todayCount saved journeys for today.';

  // -- favourites

  String get homeSubtitle => home?.endpoint.displayName ?? 'Set home';
  String get workSubtitle => work?.endpoint.displayName ?? 'Set work';
  String get savedRoutesSubtitle => savedTripCount == 1 ? '1 route' : '$savedTripCount routes';
  String get nearbySubtitle => switch (nearbyStopCount) {
    null => 'Find stops',
    1 => '1 stop',
    final n => '$n stops',
  };

  // -- loading; favourites and planner are read from SQLite, so reload when they change

  Future<void> init() async {
    _favourites.addListener(_onDataChanged);
    _planner.addListener(_onDataChanged);
    await _load();
  }

  void _onDataChanged() => unawaited(_load());

  Future<void> _load() async {
    final places = await _favourites.places();
    home = places.where((p) => p.kind == PlaceKind.home).firstOrNull;
    work = places.where((p) => p.kind == PlaceKind.work).firstOrNull;
    savedTripCount = (await _favourites.savedTrips()).length;
    final today = const SastClock().today;
    final upcoming = await _planner.upcoming(today, limit: 500);
    upcomingCount = upcoming.length;
    todayCount = upcoming.where((j) => j.date == today).length;
    nearbyStopCount = await _stopsNear(home?.endpoint);
    rebuildUi();
  }

  Future<int?> _stopsNear(Endpoint? e) async {
    if (e == null || !e.hasPosition) return null;
    final near = await _reference.nearestStops(e.lat!, e.lon!, limit: 200);
    return near.where((s) => s.$2 <= nearbyRadiusMetres).length;
  }

  @override
  void dispose() {
    _favourites.removeListener(_onDataChanged);
    _planner.removeListener(_onDataChanged);
    super.dispose();
  }

  // -- actions

  void openNotifications() => _nav.navigateToNotificationsView();
  void editProfile() => _nav.navigateToEditProfileView();
  void openPlanner() => _shell.go(AppTab.planner);
  void openFavourites() => _nav.navigateToFavouritesView();
  void openNearbyStops() => _nav.navigateToNearbyStopsView();
  void openHelp() => _nav.navigateToHelpView();
  Future<void> shareApp() => _support.shareApp();
  void openLegal(LegalKind kind) => _nav.navigateToLegalView(kind: kind);
  void openAbout() => _nav.navigateToAboutView();

  /// Home or Work: pick a stop when it isn't set yet, otherwise manage it in Favourites.
  Future<void> tapPlace(PlaceKind kind) async {
    final current = kind == PlaceKind.home ? home : work;
    if (current != null) {
      openFavourites();
      return;
    }
    final result = await _nav.navigateToStopPickerView(
      title: kind == PlaceKind.home ? 'Set Home' : 'Set Work',
      forDestination: kind == PlaceKind.work,
    );
    if (result is Endpoint) await _favourites.setPlace(kind, result);
  }

  /// There are no accounts, so logging out clears this device and starts again.
  Future<void> logOut() => runBusyFuture(confirmAndEraseDevice(title: 'Log out of Commuttr?', confirmLabel: 'Log out'));
}
