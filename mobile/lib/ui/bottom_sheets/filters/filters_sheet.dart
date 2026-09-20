import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/journey_service.dart';
import '../../../services/reference_data_service.dart';
import '../../theme/app_theme.dart';

/// What the Filters sheet is opened with: the current filters, and the routes in the
/// current results so "Routes" can offer them.
class FiltersRequest {
  const FiltersRequest(this.filters, {this.routes = const []});

  final SearchFilters filters;

  /// Route chip labels (bus numbers, train lines) with their operator.
  final List<(String, OperatorRef)> routes;
}

/// Filters, as designed: transport modes, travel time, journey preference, routes,
/// accessibility and sort. Completes with the new [SearchFilters], or unconfirmed.
class FiltersSheet extends StatefulWidget {
  const FiltersSheet({super.key, required this.request, required this.completer});

  final SheetRequest<dynamic> request;
  final void Function(SheetResponse<dynamic>) completer;

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late final FiltersRequest _req = widget.request.data is FiltersRequest
      ? widget.request.data as FiltersRequest
      : FiltersRequest((widget.request.data as SearchFilters?) ?? const SearchFilters());
  late SearchFilters _f = _req.filters;
  final _today = const SastClock().today;
  List<OperatorRef> _operators = const [OperatorRef.goldenArrow, OperatorRef.myciti, OperatorRef.metrorail];

  @override
  void initState() {
    super.initState();
    locator<ReferenceDataService>().operators().then((ops) {
      if (mounted && ops.isNotEmpty) setState(() => _operators = ops);
    });
  }

  bool get _allModes => _f.excludedOperators.isEmpty;

  void _toggleOperator(OperatorRef o) {
    final excluded = {..._f.excludedOperators};
    if (_allModes) {
      // From "all modes", tapping one operator means "only this one".
      excluded.addAll(_operators.map((x) => x.code).where((c) => c != o.code));
    } else if (excluded.contains(o.code)) {
      excluded.remove(o.code);
    } else {
      excluded.add(o.code);
      if (_operators.every((x) => excluded.contains(x.code))) return;
    }
    setState(() => _f = _f.copyWith(excludedOperators: excluded));
  }

  void _selectAll() => setState(() => _f = _f.copyWith(excludedOperators: const {}));

  Future<void> _pickTime({required bool arrival}) async {
    final current = arrival ? _f.arriveBy : _f.departAfter;
    final m = current ?? (arrival ? 19 * 60 : const SastClock().minutesNow.round());
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m ~/ 60 % 24, minute: m % 60),
      helpText: arrival ? 'Latest arrival' : 'Earliest departure',
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (t == null) return;
    final v = t.hour * 60 + t.minute;
    setState(() => _f = arrival ? _f.copyWith(arriveBy: () => v) : _f.copyWith(departAfter: () => v));
  }

  Future<void> _pickDate() async {
    final base = _f.date ?? _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(base.year, base.month, base.day),
      firstDate: DateTime(_today.year, _today.month, _today.day),
      lastDate: DateTime(_today.year, _today.month, _today.day).add(const Duration(days: 60)),
      helpText: 'Travel date',
    );
    if (picked == null) return;
    final d = ServiceDate.fromDateTime(picked);
    setState(() => _f = _f.copyWith(date: () => d == _today ? null : d));
  }

  Future<void> _pickRoutes() async {
    final chosen = {..._f.routes};
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Routes', style: context.text.titleMedium),
                  trailing: TextButton(onPressed: () => Navigator.pop(context, chosen), child: const Text('Done')),
                ),
                CheckboxListTile(
                  title: const Text('All routes'),
                  value: chosen.isEmpty,
                  onChanged: (_) => setLocal(chosen.clear),
                ),
                if (_req.routes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Search for a trip first to choose from its routes.'),
                  ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final (label, op) in _req.routes)
                        CheckboxListTile(
                          secondary: Icon(op.isTrain ? Icons.train_outlined : Icons.directions_bus_outlined),
                          title: Text(op.isTrain ? '${op.name} $label line' : '${op.name} $label'),
                          value: chosen.contains(label),
                          onChanged: (v) => setLocal(() => v == true ? chosen.add(label) : chosen.remove(label)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null) setState(() => _f = _f.copyWith(routes: result));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final day = _f.date == null ? 'Today' : formatDayRelative(_f.date!, _today);
    // Stacked shows custom sheets on a transparent surface, so the sheet paints its own.
    return Material(
      color: Theme.of(context).bottomSheetTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Flexible(child: _content(context, c, day)),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, AppColors c, String day) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.94),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => widget.completer(SheetResponse(confirmed: false)),
                  ),
                  const SizedBox(width: 4),
                  Text('Filters', style: context.text.titleLarge),
                  const Spacer(),
                  TextButton(onPressed: () => setState(() => _f = const SearchFilters()), child: const Text('Reset')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Refine your search to find the best options for your journey.',
                  style: TextStyle(color: c.muted),
                ),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                children: [
                  _heading('Transport modes', 'Select one or more', action: ('Select all', _selectAll)),
                  Row(
                    children: [
                      for (final o in _operators) ...[
                        Expanded(
                          child: _ModeTile(
                            label: o.name,
                            icon: o.isTrain ? Icons.train_outlined : Icons.directions_bus_outlined,
                            selected: !_allModes && _f.allows(o),
                            onTap: () => _toggleOperator(o),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (!_operators.any((o) => o.code == 'myciti')) ...[
                        const Expanded(
                          child: _ModeTile(label: 'MyCiTi', icon: Icons.directions_bus_filled_outlined, soon: true),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: _ModeTile(
                          label: 'All modes',
                          icon: Icons.commute_outlined,
                          selected: _allModes,
                          onTap: _selectAll,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _heading('Travel time', 'When do you want to travel?', action: (day, _pickDate)),
                  Row(
                    children: [
                      Expanded(
                        child: _DropBox(
                          label: 'Earliest departure',
                          value: '$day, ${_f.departAfter == null ? 'now' : formatMinutes(_f.departAfter!)}',
                          onTap: () => _pickTime(arrival: false),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('–', style: TextStyle(color: c.muted)),
                      ),
                      Expanded(
                        child: _DropBox(
                          label: 'Latest arrival',
                          value: '$day, ${_f.arriveBy == null ? 'any time' : formatMinutes(_f.arriveBy!)}',
                          onTap: () => _pickTime(arrival: true),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _heading('Journey preferences', 'Choose what matters most to you'),
                  for (final p in JourneyPreference.values) ...[
                    _PreferenceCard(
                      preference: p,
                      selected: _f.preference == p,
                      onTap: () => setState(() => _f = _f.copyWith(preference: p)),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Divider(height: 24),
                  _heading('Routes', 'Filter by specific routes (optional)'),
                  _DropBox(value: _f.routes.isEmpty ? 'All routes' : _f.routes.join(', '), onTap: _pickRoutes),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Accessibility', style: context.text.titleMedium),
                            Text('Show wheelchair accessible services only', style: TextStyle(color: c.muted)),
                            Text(
                              'Not published by the operators yet',
                              style: context.text.bodySmall?.copyWith(color: c.muted, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      const Switch(value: false, onChanged: null),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Sort by', style: context.text.titleMedium),
                  const SizedBox(height: 10),
                  _SortBar(
                    value: _f.sort,
                    onChanged: (s) => setState(() => _f = _f.copyWith(sort: s)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => widget.completer(SheetResponse(confirmed: false)),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 56)),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => widget.completer(SheetResponse(confirmed: true, data: _f)),
                      style: FilledButton.styleFrom(minimumSize: const Size(48, 56)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Apply filters'),
                          if (_f.activeCount > 0) ...[
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: Colors.black,
                              child: Text(
                                '${_f.activeCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String title, String subtitle, {(String, VoidCallback)? action}) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.titleMedium),
              Text(subtitle, style: TextStyle(color: context.colors.muted)),
            ],
          ),
        ),
        if (action != null) TextButton(onPressed: action.$2, child: Text(action.$1)),
      ],
    ),
  );
}

/// A square transport-mode tile with a radio circle in its corner.
class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.label, required this.icon, this.selected = false, this.onTap, this.soon = false});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  final bool soon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: soon ? '$label, coming soon' : label,
      excludeSemantics: true,
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? accent : c.cardBorder, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: soon
              ? () => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('MyCiTi timetables are coming soon.')))
              : onTap,
          child: SizedBox(
            height: 92,
            child: Stack(
              children: [
                Positioned(
                  top: 6,
                  right: 6,
                  child: selected
                      ? Icon(Icons.check_circle, size: 20, color: accent)
                      : Icon(Icons.radio_button_unchecked, size: 20, color: c.muted),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 30, color: soon ? c.muted : null),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(fontSize: 12, color: soon ? c.muted : null),
                        ),
                        if (soon) Text('Soon', style: TextStyle(fontSize: 10, color: c.muted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled box with a chevron, like a dropdown.
class _DropBox extends StatelessWidget {
  const _DropBox({this.label, required this.value, required this.onTap});

  final String? label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null) Text(label!, style: context.text.bodySmall?.copyWith(color: c.muted)),
                    Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: c.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({required this.preference, required this.selected, required this.onTap});

  final JourneyPreference preference;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    final icon = switch (preference) {
      JourneyPreference.fastest => Icons.schedule,
      JourneyPreference.fewerChanges => Icons.swap_horiz,
      JourneyPreference.shortestWalk => Icons.directions_walk,
    };
    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? accent : c.cardBorder, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: selected ? accent : null),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(preference.label, style: context.text.titleSmall),
                    Text(preference.description, style: TextStyle(color: c.muted, fontSize: 13)),
                  ],
                ),
              ),
              selected ? Icon(Icons.check_circle, color: accent) : Icon(Icons.radio_button_unchecked, color: c.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Four joined segments: Departure time, Arrival time, Duration, Fewer changes.
class _SortBar extends StatelessWidget {
  const _SortBar({required this.value, required this.onChanged});

  final SortBy value;
  final ValueChanged<SortBy> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.cardBorder),
      ),
      child: Row(
        children: [
          for (final s in SortBy.values)
            Expanded(
              child: Semantics(
                selected: s == value,
                button: true,
                child: InkWell(
                  onTap: () => onChanged(s),
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: s == value
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: accent, width: 1.5),
                          )
                        : null,
                    child: Text(
                      s.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(fontSize: 12, color: s == value ? accent : null),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
