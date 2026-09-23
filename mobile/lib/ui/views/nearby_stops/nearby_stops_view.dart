import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../services/favourites_service.dart';
import '../../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'nearby_stops_viewmodel.dart';

class NearbyStopsView extends StackedView<NearbyStopsViewModel> {
  const NearbyStopsView({super.key});

  @override
  Widget builder(BuildContext context, NearbyStopsViewModel viewModel, Widget? child) {
    final muted = context.colors.muted;
    final stops = viewModel.stops;
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby stops and stations')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.near_me_outlined, color: context.colors.accentText),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Find bus stops and train stations near you. Your location is used once, on this device, '
                              'and not stored.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: viewModel.isBusy ? null : viewModel.locate,
                          icon: viewModel.isBusy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(
                            viewModel.isBusy
                                ? 'Finding your location…'
                                : viewModel.hasResult
                                ? 'Update my location'
                                : 'Use my location',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (viewModel.failure != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: InfoBanner(
                    tone: BannerTone.warning,
                    icon: Icons.location_off_outlined,
                    message: viewModel.failure!.message,
                    actionLabel: viewModel.canOpenSettings
                        ? 'Open settings'
                        : viewModel.failure!.problem == LocationProblem.denied
                        ? 'Try again'
                        : null,
                    onAction: viewModel.canOpenSettings ? viewModel.openSettings : viewModel.locate,
                  ),
                ),
              if (stops != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: pagePadding,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (f, label) in const [
                        (StopFilter.all, 'All'),
                        (StopFilter.bus, 'Bus stops'),
                        (StopFilter.train, 'Train stations'),
                      ])
                        ChoiceChip(
                          label: Text(label),
                          selected: viewModel.filter == f,
                          onSelected: (_) => viewModel.setFilter(f),
                          showCheckmark: false,
                          labelStyle: TextStyle(color: viewModel.filter == f ? Colors.white : null),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                    ],
                  ),
                ),
                SectionHeader(
                  stops.isEmpty ? 'Nothing found' : _closestTitle(viewModel.filter),
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                ),
                if (stops.isEmpty)
                  EmptyState(
                    icon: Icons.wrong_location_outlined,
                    title: switch (viewModel.filter) {
                      StopFilter.all => 'No stops or stations saved',
                      StopFilter.bus => 'No bus stops saved',
                      StopFilter.train => 'No train stations saved',
                    },
                    message: viewModel.filter == StopFilter.all
                        ? 'The stop list on your phone is empty. Open Offline & data in Profile to reload it.'
                        : 'None are saved on your phone. Choose All, or open Offline & data in Profile to reload.',
                  )
                else ...[
                  Padding(
                    padding: pagePadding,
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < stops.length; i++) ...[
                            if (i > 0) const Divider(indent: 56),
                            _StopRow(stop: stops[i], onTap: () => _showActions(context, viewModel, stops[i])),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Text(
                      'Distances are in a straight line; the walk may be longer. Stops and stations come from the timetables '
                      'saved on your phone, so this works offline.',
                      style: context.text.bodySmall?.copyWith(color: muted),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, NearbyStopsViewModel vm, NearbyStop stop) async {
    final messenger = ScaffoldMessenger.of(context);
    Future<void> save(BuildContext sheet, PlaceKind kind, String label) async {
      Navigator.of(sheet).pop();
      final ok = await vm.saveAs(stop, kind);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            ok ? '${stop.name} saved as $label' : "This ${stop.kindWord} can't be saved. It has no location.",
          ),
        ),
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Semantics(header: true, child: Text(stop.name, style: sheet.text.titleMedium)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                '${stop.distanceLabel} away · ${stop.walkLabel}',
                style: TextStyle(color: sheet.colors.muted),
              ),
            ),
            NavRow(
              icon: transitIcon(stop.operator),
              title: 'Plan a trip from here',
              onTap: () {
                Navigator.of(sheet).pop();
                vm.planFrom(stop);
              },
            ),
            NavRow(
              icon: Icons.home_outlined,
              title: 'Save as Home',
              trailing: const SizedBox.shrink(),
              onTap: () => save(sheet, PlaceKind.home, 'Home'),
            ),
            NavRow(
              icon: Icons.work_outline,
              title: 'Save as Work',
              trailing: const SizedBox.shrink(),
              onTap: () => save(sheet, PlaceKind.work, 'Work'),
            ),
            NavRow(
              icon: Icons.map_outlined,
              title: 'Open in maps',
              subtitle: 'OpenStreetMap, needs a connection',
              trailing: const Icon(Icons.open_in_new, size: 20),
              onTap: () {
                Navigator.of(sheet).pop();
                vm.openInMaps(stop);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static String _closestTitle(StopFilter f) => switch (f) {
    StopFilter.all => 'Closest stops and stations',
    StopFilter.bus => 'Closest bus stops',
    StopFilter.train => 'Closest train stations',
  };

  @override
  NearbyStopsViewModel viewModelBuilder(BuildContext context) => NearbyStopsViewModel();
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.stop, required this.onTap});

  final NearbyStop stop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        '${stop.stop.isStation ? '' : 'Bus stop '}${stop.name}, ${stop.distanceLabel} away, '
        'about ${stop.walkMinutes} minutes walk',
    hint: 'Shows options for this ${stop.kindWord}',
    excludeSemantics: true,
    child: ListTile(
      onTap: onTap,
      minTileHeight: 56,
      leading: Icon(transitIcon(stop.operator)),
      title: Text(stop.name),
      subtitle: Text(stop.walkLabel, style: TextStyle(color: context.colors.muted)),
      trailing: Text(stop.distanceLabel, style: context.text.titleSmall),
    ),
  );
}
