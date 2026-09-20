import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../data/models/models.dart';
import '../../../services/favourites_service.dart';
import '../../../services/shell_service.dart';

/// Home, Work and other places; saved trips; recent searches. All on this device.
class FavouritesViewModel extends BaseViewModel {
  final _favourites = locator<FavouritesService>();
  final _shell = locator<ShellService>();
  final _nav = locator<NavigationService>();
  final _dialogs = locator<DialogService>();

  SavedPlace? home;
  SavedPlace? work;
  List<SavedPlace> others = const [];
  List<TripPair> savedTrips = const [];
  List<TripPair> recent = const [];
  Set<String> _savedIds = const {};

  bool loaded = false;

  bool isSaved(TripPair t) => _savedIds.contains(t.id);

  Future<void> init() async {
    _favourites.addListener(_onChanged);
    await _load();
  }

  void _onChanged() => unawaited(_load());

  Future<void> _load() async {
    final places = await _favourites.places();
    home = places.where((p) => p.kind == PlaceKind.home).firstOrNull;
    work = places.where((p) => p.kind == PlaceKind.work).firstOrNull;
    others = places.where((p) => p.kind == PlaceKind.other).toList();
    savedTrips = await _favourites.savedTrips();
    _savedIds = savedTrips.map((t) => t.id).toSet();
    recent = await _favourites.recentSearches(limit: 10);
    loaded = true;
    rebuildUi();
  }

  @override
  void dispose() {
    _favourites.removeListener(_onChanged);
    super.dispose();
  }

  // -- places

  /// Set or change Home / Work, or add another place, via the stop picker.
  Future<void> pickPlace(PlaceKind kind, {SavedPlace? replacing}) async {
    final title = switch (kind) {
      PlaceKind.home => 'Set Home',
      PlaceKind.work => 'Set Work',
      PlaceKind.other => replacing == null ? 'Add a place' : 'Change place',
    };
    final result = await _nav.navigateToStopPickerView(title: title, forDestination: kind != PlaceKind.home);
    if (result is! Endpoint) return;
    // Other places aren't keyed by kind, so replacing one means removing the old row.
    if (replacing != null && kind == PlaceKind.other) await _favourites.removePlace(replacing.id);
    await _favourites.setPlace(kind, result);
  }

  Future<void> removePlace(SavedPlace place) async {
    final r = await _dialogs.showConfirmationDialog(
      title: 'Remove ${place.label}?',
      description: '${place.endpoint.displayName} is removed from your favourites.',
      confirmationTitle: 'Remove',
      cancelTitle: 'Cancel',
      barrierDismissible: true,
    );
    if (r?.confirmed ?? false) await _favourites.removePlace(place.id);
  }

  // -- trips

  /// Back to the Home tab with this trip searched.
  void search(TripPair trip) {
    _nav.popUntil((r) => r.isFirst);
    _shell.searchOnHome(trip.from, trip.to);
  }

  Future<void> toggleSaved(TripPair trip) => _favourites.toggleSavedTrip(trip.from, trip.to);

  Future<void> clearHistory() async {
    final r = await _dialogs.showConfirmationDialog(
      title: 'Clear search history?',
      description: 'Your recent searches are removed. Saved trips, Home and Work are kept.',
      confirmationTitle: 'Clear',
      cancelTitle: 'Cancel',
      barrierDismissible: true,
    );
    if (r?.confirmed ?? false) await _favourites.clearHistory();
  }
}
