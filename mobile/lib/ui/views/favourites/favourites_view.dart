import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../services/favourites_service.dart';
import '../../../services/shell_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/common.dart';
import '../profile/page_layout.dart';
import '../profile/profile_widgets.dart';
import 'favourites_viewmodel.dart';

class FavouritesView extends StackedView<FavouritesViewModel> {
  const FavouritesView({super.key});

  @override
  Widget builder(BuildContext context, FavouritesViewModel viewModel, Widget? child) {
    final vm = viewModel;
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
      body: SafeArea(
        bottom: false,
        child: !vm.loaded
            ? const LoadingBlock()
            : ConstrainedListView(
                top: 0,
                children: [
                  const PageHeader(
                    title: 'Favourites',
                    subtitle: 'Your places, saved routes and recent searches.',
                    showBack: true,
                  ),
                  SectionHeader(
                    'Places',
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                    actionLabel: 'Add a place',
                    onAction: () => vm.pickPlace(PlaceKind.other),
                  ),
                  NavGroup(
                    children: [
                      _PlaceRow(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        place: vm.home,
                        onTap: () => vm.pickPlace(PlaceKind.home),
                        onRemove: vm.home == null ? null : () => vm.removePlace(vm.home!),
                      ),
                      _PlaceRow(
                        icon: Icons.work_outline_rounded,
                        label: 'Work',
                        place: vm.work,
                        onTap: () => vm.pickPlace(PlaceKind.work),
                        onRemove: vm.work == null ? null : () => vm.removePlace(vm.work!),
                      ),
                      for (final p in vm.others)
                        _PlaceRow(
                          icon: Icons.place_outlined,
                          label: p.label,
                          place: p,
                          onTap: () => vm.pickPlace(PlaceKind.other, replacing: p),
                          onRemove: () => vm.removePlace(p),
                        ),
                    ],
                  ),
                  const SectionHeader('Saved routes'),
                  if (vm.savedTrips.isEmpty)
                    const EmptyState(
                      icon: Icons.star_outline_rounded,
                      title: 'No saved routes yet',
                      message: 'Tap "Save trip" on a search result to keep that trip here for one-tap searching.',
                    )
                  else
                    NavGroup(
                      children: [
                        for (final t in vm.savedTrips)
                          _TripRow(trip: t, saved: true, onTap: () => vm.search(t), onToggle: () => vm.toggleSaved(t)),
                      ],
                    ),
                  SectionHeader(
                    'Recent searches',
                    actionLabel: vm.recent.isEmpty ? null : 'Clear',
                    onAction: vm.clearHistory,
                  ),
                  if (vm.recent.isEmpty)
                    const EmptyState(
                      icon: Icons.history_rounded,
                      title: 'No recent searches',
                      message: 'Trips you search for on Home appear here.',
                    )
                  else
                    NavGroup(
                      children: [
                        for (final t in vm.recent)
                          _TripRow(
                            trip: t,
                            saved: vm.isSaved(t),
                            icon: Icons.history_rounded,
                            onTap: () => vm.search(t),
                            onToggle: () => vm.toggleSaved(t),
                          ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      'Favourites are kept on this device only.',
                      style: context.text.bodySmall?.copyWith(color: context.colors.muted),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  FavouritesViewModel viewModelBuilder(BuildContext context) => FavouritesViewModel();

  @override
  void onViewModelReady(FavouritesViewModel viewModel) => viewModel.init();
}

/// Home, Work or another place. Tap to set or change it; the bin removes it.
class _PlaceRow extends StatelessWidget {
  const _PlaceRow({required this.icon, required this.label, required this.place, required this.onTap, this.onRemove});

  final IconData icon;
  final String label;
  final SavedPlace? place;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final set = place != null;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        set ? place!.endpoint.displayName : 'Not set. Tap to choose a stop',
        style: TextStyle(color: context.colors.muted),
      ),
      trailing: onRemove == null
          ? Icon(Icons.add_rounded, color: context.colors.muted)
          : IconButton(tooltip: 'Remove $label', icon: const Icon(Icons.delete_outline_rounded), onPressed: onRemove),
    );
  }
}

/// A from → to pair: tap to search it, star to save or unsave it.
class _TripRow extends StatelessWidget {
  const _TripRow({
    required this.trip,
    required this.saved,
    required this.onTap,
    required this.onToggle,
    this.icon = Icons.alt_route_rounded,
  });

  final TripPair trip;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(icon),
    title: Text(trip.title),
    subtitle: Text('Tap to see scheduled buses', style: TextStyle(color: context.colors.muted)),
    trailing: IconButton(
      tooltip: saved ? 'Remove from saved trips' : 'Save trip',
      isSelected: saved,
      icon: const Icon(Icons.star_outline_rounded),
      selectedIcon: Icon(Icons.star_rounded, color: Theme.of(context).colorScheme.primary),
      onPressed: onToggle,
    ),
  );
}
