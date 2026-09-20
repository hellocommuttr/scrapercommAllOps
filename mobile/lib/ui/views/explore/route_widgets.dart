import 'package:flutter/material.dart';

import '../../../data/models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Whose route this is.
OperatorRef routeOperator(RouteSummary r) => OperatorRef.from(r.operatorCode);

/// "Airport Ind → Bellville", falling back to the route's own name. Train routes are
/// named "CENTRAL LINE: CAPE TOWN - BELLVILLE"; without ends they show the part after
/// the line.
String routeTitle(RouteSummary r) {
  if (r.origin.isNotEmpty && r.destination.isNotEmpty) {
    return '${titleCase(r.origin)} → ${titleCase(r.destination)}';
  }
  final colon = r.name.indexOf(':');
  if (routeOperator(r).isTrain && colon >= 0) return titleCase(r.name.substring(colon + 1).trim());
  return titleCase(r.name);
}

/// "T01", "101" — the code MyCiTi names a route by, taken from "101: Vredehoek - …".
String mycitiCode(RouteSummary r) {
  final colon = r.name.indexOf(':');
  return (colon > 0 ? r.name.substring(0, colon) : r.name).trim();
}

/// The family a MyCiTi route belongs to: its letter ("T", "D") or its hundred ("100s").
String mycitiGroup(RouteSummary r) {
  final code = mycitiCode(r).toUpperCase();
  if (code.isEmpty) return '#';
  final letter = RegExp(r'^[A-Z]+').firstMatch(code)?.group(0);
  if (letter != null) return letter;
  final digits = RegExp(r'^\d+').firstMatch(code)?.group(0);
  return digits == null ? '#' : '${digits[0]}00s';
}

/// "Central line", from "CENTRAL LINE: CAPE TOWN - BELLVILLE". For train routes only.
String trainLineName(RouteSummary r) => '${routeShortName('', r.name, OperatorRef.metrorail)} line';

String timetableCountLabel(int n) => n == 1 ? '1 timetable' : '$n timetables';

/// One route in a list, bus or train.
class RouteTile extends StatelessWidget {
  const RouteTile({super.key, required this.route, required this.onTap, this.showLine = true});

  final RouteSummary route;
  final VoidCallback onTap;

  /// Name the operator (and train line) in the subtitle; off in a single operator's list.
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final operator = routeOperator(route);
    final count = timetableCountLabel(route.timetableCount);
    final subtitle = !showLine ? count : '${operator.name} · ${operator.isTrain ? trainLineName(route) : count}';
    return ListTile(
      onTap: onTap,
      minTileHeight: 56,
      leading: Icon(transitIcon(operator), semanticLabel: operator.vehicle),
      title: Text(routeTitle(route)),
      subtitle: Text(subtitle, style: TextStyle(color: context.colors.muted)),
      trailing: Icon(Icons.chevron_right, color: context.colors.muted),
    );
  }
}

/// The full list of one operator's routes: bus routes A–Z by the operator's letter
/// groups, train routes grouped by line.
///
/// Pushed with a plain [MaterialPageRoute] from Explore; it filters in memory, so it works
/// offline and needs no view model of its own.
class RouteListPage extends StatefulWidget {
  const RouteListPage({super.key, required this.routes, required this.onOpen, this.operator, this.initialQuery = ''});

  final List<RouteSummary> routes;
  final ValueChanged<RouteSummary> onOpen;

  /// Whose routes these are; null for a search across every operator.
  final OperatorRef? operator;
  final String initialQuery;

  @override
  State<RouteListPage> createState() => _RouteListPageState();
}

class _RouteListPageState extends State<RouteListPage> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;

  bool get _train => widget.operator?.isTrain ?? false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Train routes group by line ("Central line"), Golden Arrow by letter, and MyCiTi —
  /// which has no letter groups — by route family ("T", "D", "100s").
  String _groupOf(RouteSummary r) {
    final operator = routeOperator(r);
    if (operator.isTrain) return trainLineName(r);
    if (operator == OperatorRef.myciti) return mycitiGroup(r);
    return r.letterGroup.isEmpty ? '#' : r.letterGroup.toUpperCase();
  }

  /// Group headers and routes, flattened so the list can be built lazily.
  List<Object> get _items {
    final q = _query.trim().toUpperCase();
    final filtered = q.isEmpty ? widget.routes : widget.routes.where((r) => r.name.toUpperCase().contains(q)).toList();
    final byGroup = <String, List<RouteSummary>>{};
    final lines = <String>{};
    for (final r in filtered) {
      final g = _groupOf(r);
      if (routeOperator(r).isTrain) lines.add(g);
      (byGroup[g] ??= []).add(r);
    }
    // Bus letters first, then train lines.
    final groups = byGroup.keys.toList()
      ..sort((a, b) {
        final la = lines.contains(a) ? 1 : 0, lb = lines.contains(b) ? 1 : 0;
        return la != lb ? la - lb : a.compareTo(b);
      });
    return [
      for (final g in groups) ...[(g, lines.contains(g)), ...byGroup[g]!],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final count = items.whereType<RouteSummary>().length;
    final example = _train ? '"Bellville" or "Simon\'s Town"' : '"Bellville" or "Khayelitsha"';
    final o = widget.operator;
    final title = o == null ? 'All routes' : '${o.name} ${_train ? 'lines' : 'routes'}';
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
                  controller: _controller,
                  onChanged: (v) => setState(() => _query = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: _train ? 'Filter lines or stations' : 'Filter routes or areas',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear filter',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _controller.clear();
                              _query = '';
                            }),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      count == 1 ? '1 route' : '$count routes',
                      style: context.text.bodySmall?.copyWith(color: context.colors.muted),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        title: 'No routes match',
                        message: 'Try part of a place name, such as $example.',
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          if (item is (String, bool)) {
                            final (label, isLine) = item;
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                              child: Semantics(
                                header: true,
                                label: isLine ? label : 'Routes starting with $label',
                                excludeSemantics: true,
                                child: Text(
                                  label,
                                  style: context.text.titleMedium?.copyWith(color: context.colors.accentText),
                                ),
                              ),
                            );
                          }
                          final r = item as RouteSummary;
                          return RouteTile(route: r, showLine: o == null, onTap: () => widget.onOpen(r));
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
