import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app.locator.dart';
import '../../data/models/models.dart';
import '../../services/settings_service.dart';
import '../theme/app_theme.dart';

/// A stop shown on a [RouteMap].
class MapStop {
  const MapStop(this.lat, this.lon, {this.label, this.kind = MapStopKind.intermediate});

  final double lat;
  final double lon;
  final String? label;
  final MapStopKind kind;
}

enum MapStopKind { board, alight, intermediate, current }

/// The route a bus or train follows, and its stops, on an OpenStreetMap base map.
///
/// Maps need data (tiles are fetched live — the OSM tile policy does not allow bulk
/// offline caching), so they honour the "Show maps" data-saver preference. Offline, the
/// route line and stops still draw; only the background is missing.
class RouteMap extends StackedView<RouteMapModel> {
  const RouteMap({super.key, required this.path, required this.stops, this.height = 220});

  /// (lat, lon) pairs; falls back to joining the stops when empty.
  final List<(double, double)> path;
  final List<MapStop> stops;
  final double height;

  @override
  Widget builder(BuildContext context, RouteMapModel viewModel, Widget? child) {
    final c = context.colors;
    final points = (path.isNotEmpty ? path : stops.map((s) => (s.lat, s.lon))).map((p) => LatLng(p.$1, p.$2)).toList();
    if (points.length < 2) return const SizedBox.shrink();
    if (!viewModel.showMaps) {
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.cardBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.map_outlined, color: c.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Map hidden to save data', style: TextStyle(color: c.muted)),
            ),
            TextButton(onPressed: viewModel.showOnce, child: const Text('Show map')),
          ],
        ),
      );
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    return Semantics(
      label: 'Map of the route',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: height,
          child: FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.coordinates(coordinates: points, padding: const EdgeInsets.all(28)),
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
              backgroundColor: c.card,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'za.co.commuttr',
                tileBuilder: dark ? darkModeTileBuilder : null,
              ),
              PolylineLayer(
                polylines: [Polyline(points: points, color: accent, strokeWidth: 4)],
              ),
              MarkerLayer(
                markers: [
                  for (final s in stops)
                    if ((s.kind == MapStopKind.board || s.kind == MapStopKind.alight) && s.label != null)
                      // Start and destination carry a name bubble above the dot, as designed.
                      Marker(
                        point: LatLng(s.lat, s.lon),
                        width: 160,
                        height: 64,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: c.cardBorder),
                              ),
                              child: Text(
                                titleCase(s.label!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(width: 18, height: 18, child: _dot(s.kind, accent, dark)),
                          ],
                        ),
                      )
                    else
                      Marker(
                        point: LatLng(s.lat, s.lon),
                        width: s.kind == MapStopKind.intermediate ? 12 : 22,
                        height: s.kind == MapStopKind.intermediate ? 12 : 22,
                        child: _dot(s.kind, accent, dark),
                      ),
                ],
              ),
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomRight,
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(MapStopKind kind, Color accent, bool dark) {
    final bg = dark ? Colors.black : Colors.white;
    return switch (kind) {
      MapStopKind.intermediate => DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: 2),
        ),
      ),
      MapStopKind.board => DecoratedBox(
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
          border: Border.all(color: bg, width: 3),
        ),
      ),
      MapStopKind.alight => DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: 5),
        ),
      ),
      MapStopKind.current => DecoratedBox(
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.directions_bus, size: 12, color: Colors.white),
      ),
    };
  }

  @override
  RouteMapModel viewModelBuilder(BuildContext context) => RouteMapModel();
}

class RouteMapModel extends BaseViewModel {
  final _settings = locator<SettingsService>();
  bool _forced = false;

  bool get showMaps => _forced || _settings.showMaps;

  void showOnce() {
    _forced = true;
    rebuildUi();
  }
}
