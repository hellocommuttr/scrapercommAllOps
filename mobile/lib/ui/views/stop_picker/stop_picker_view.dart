import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../data/models/models.dart';
import '../../../services/favourites_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'stop_picker_viewmodel.dart';

String formatDistance(double metres) =>
    metres < 1000 ? '${(metres / 10).round() * 10} m' : '${(metres / 1000).toStringAsFixed(1)} km';

class StopPickerView extends StackedView<StopPickerViewModel> {
  const StopPickerView({super.key, required this.title, this.forDestination = false});

  final String title;
  final bool forDestination;

  @override
  Widget builder(BuildContext context, StopPickerViewModel viewModel, Widget? child) {
    final c = context.colors;
    final searching = viewModel.query.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: viewModel.onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search stops or places',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: viewModel.searchingAddresses
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (!searching) ...[
                      ListTile(
                        leading: const Icon(Icons.my_location),
                        title: const Text('Use my location'),
                        subtitle: Text('Find the nearest stops and stations', style: TextStyle(color: c.muted)),
                        trailing: viewModel.locating
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : null,
                        onTap: viewModel.locating ? null : viewModel.useMyLocation,
                      ),
                      if (viewModel.locationMessage != null)
                        Padding(
                          padding: pagePadding,
                          child: InfoBanner(
                            tone: BannerTone.warning,
                            message: viewModel.locationMessage!,
                            actionLabel: 'Settings',
                            onAction: viewModel.openLocationSettings,
                          ),
                        ),
                      for (final (stop, metres) in viewModel.nearby)
                        ListTile(
                          leading: Icon(stop.isStation ? Icons.train_outlined : Icons.near_me_outlined),
                          title: Text(stop.displayName),
                          subtitle: Text(
                            '${OperatorRef.from(stop.operatorCode).name} ${stop.isStation ? 'station' : 'bus stop'}'
                            ' · ${formatDistance(metres)} away',
                            style: TextStyle(color: c.muted),
                          ),
                          onTap: () => viewModel.pickStop(stop),
                        ),
                      if (viewModel.myLocation != null)
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: const Text('My exact location'),
                          subtitle: Text(
                            'Compare Golden Arrow, MyCiTi and trains from the stops near you',
                            style: TextStyle(color: c.muted),
                          ),
                          onTap: viewModel.pickMyLocation,
                        ),
                      if (viewModel.places.isNotEmpty) ...[
                        const SectionHeader('Saved places', padding: EdgeInsets.fromLTRB(16, 16, 16, 4)),
                        for (final p in viewModel.places)
                          ListTile(
                            leading: Icon(switch (p.kind) {
                              PlaceKind.home => Icons.home_outlined,
                              PlaceKind.work => Icons.work_outline,
                              PlaceKind.other => Icons.star_outline,
                            }),
                            title: Text(p.label),
                            subtitle: Text(p.endpoint.displayName, style: TextStyle(color: c.muted)),
                            onTap: () => viewModel.pickEndpoint(p.endpoint),
                          ),
                      ],
                      if (viewModel.recents.isNotEmpty) ...[
                        const SectionHeader('Recent', padding: EdgeInsets.fromLTRB(16, 16, 16, 4)),
                        for (final e in viewModel.recents)
                          ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(e.displayName),
                            onTap: () => viewModel.pickEndpoint(e),
                          ),
                      ],
                    ],
                    // A place covers every operator near it, which a single stop cannot, so
                    // places come first: picking the Cape Town *stop* shows only Golden Arrow.
                    if (searching && (viewModel.addresses.isNotEmpty || viewModel.addressMessage != null)) ...[
                      const SectionHeader(
                        'Places · every bus and train nearby',
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                      ),
                      for (final h in viewModel.addresses)
                        ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(titleCase(h.name)),
                          subtitle: Text(
                            'Compare Golden Arrow, MyCiTi and trains · ${h.full}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: c.muted),
                          ),
                          onTap: () => viewModel.pickAddress(h),
                        ),
                      if (viewModel.addressMessage != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(viewModel.addressMessage!, style: TextStyle(color: c.muted)),
                        ),
                    ],
                    SectionHeader(
                      searching ? 'Stops and stations' : 'All bus stops and train stations',
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    ),
                    if (viewModel.stops.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          searching ? 'No stop matches "${viewModel.query.trim()}".' : 'Loading stops…',
                          style: TextStyle(color: c.muted),
                        ),
                      ),
                    for (final s in viewModel.stops)
                      ListTile(
                        leading: Icon(s.isStation ? Icons.train_outlined : Icons.directions_bus_outlined),
                        title: Text(s.displayName),
                        subtitle: Text(
                          '${OperatorRef.from(s.operatorCode).name} ${s.isStation ? 'station' : 'bus stop'}',
                          style: TextStyle(color: c.muted),
                        ),
                        onTap: () => viewModel.pickStop(s),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  StopPickerViewModel viewModelBuilder(BuildContext context) => StopPickerViewModel();

  @override
  void onViewModelReady(StopPickerViewModel viewModel) => viewModel.init();
}
