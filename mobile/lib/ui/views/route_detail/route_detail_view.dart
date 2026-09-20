import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'route_detail_viewmodel.dart';

/// "Mon 10 Aug 2026" from an ISO date, or the raw text if it does not parse.
String _date(String iso) {
  try {
    return formatDate(ServiceDate.parse(iso));
  } catch (_) {
    return iso;
  }
}

/// The operator's full name, for "not affiliated with …" lines.
String operatorLegalName(OperatorRef o) => switch (o.code) {
  'gabs' => 'Golden Arrow Bus Services',
  'metrorail' => 'Metrorail (PRASA)',
  _ => o.name,
};

class RouteDetailView extends StackedView<RouteDetailViewModel> {
  const RouteDetailView({super.key, required this.routeId});

  final int routeId;

  @override
  Widget builder(BuildContext context, RouteDetailViewModel viewModel, Widget? child) {
    final route = viewModel.route;
    final operator = viewModel.operator;
    final muted = context.colors.muted;
    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.title),
        bottom: viewModel.refreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2, semanticsLabel: 'Checking for newer timetables'),
              )
            : null,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: !viewModel.loaded
              ? const LoadingBlock(label: 'Loading timetables…')
              : ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    const OfflineBanner(),
                    if (route != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TagChip(
                              '${operator.name} · ${operator.isTrain ? 'Train' : 'Bus'}',
                              icon: transitIcon(operator),
                            ),
                            const SizedBox(height: 10),
                            Semantics(
                              label: 'From ${titleCase(route.origin)} to ${titleCase(route.destination)}',
                              excludeSemantics: true,
                              child: Text(
                                '${titleCase(route.origin)} → ${titleCase(route.destination)}',
                                style: context.text.titleLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SectionHeader(
                      viewModel.timetables.length == 1 ? '1 timetable' : '${viewModel.timetables.length} timetables',
                    ),
                    if (route == null && viewModel.timetables.isEmpty)
                      const EmptyState(
                        icon: Icons.route_outlined,
                        title: 'Route not found',
                        message:
                            'This route is not in the timetables saved on your phone. '
                            'It may have been withdrawn — check the route list again.',
                      )
                    else if (viewModel.timetables.isEmpty)
                      EmptyState(
                        icon: Icons.schedule_outlined,
                        title: viewModel.refreshing ? 'Checking for timetables…' : 'No timetables saved',
                        message:
                            'No timetable for this route is saved on your phone yet. '
                            'Connect to the internet and open this route again.',
                      )
                    else
                      for (final t in viewModel.timetables)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _TimetableCard(
                            info: t,
                            label: viewModel.timetableLabel(t),
                            operator: operator,
                            status: viewModel.statusOf(t),
                            onOpen: () => viewModel.openTimetable(t),
                            onPdf: viewModel.hasPdf(t) ? () => viewModel.openPdf(t) : null,
                          ),
                        ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: ScheduledDisclaimer(
                        operator: operator,
                        extra: operator.isTrain
                            ? '${operator.name} can change or cancel services at short notice — check before you travel.'
                            : 'Check the official PDF if a time matters — ${operator.name} can change timetables.',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Text(
                        'Commuttr is independent and not affiliated with ${operatorLegalName(operator)}.',
                        textAlign: TextAlign.center,
                        style: context.text.bodySmall?.copyWith(color: muted),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  RouteDetailViewModel viewModelBuilder(BuildContext context) => RouteDetailViewModel(routeId);

  @override
  void onViewModelReady(RouteDetailViewModel viewModel) => viewModel.init();
}

class _TimetableCard extends StatelessWidget {
  const _TimetableCard({
    required this.info,
    required this.label,
    required this.operator,
    required this.status,
    required this.onOpen,
    this.onPdf,
  });

  final TimetableInfo info;
  final String label;
  final OperatorRef operator;
  final TimetableStatus status;
  final VoidCallback onOpen;
  final VoidCallback? onPdf;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final from = info.effectiveFrom, to = info.effectiveTo;
    final validity = from == null && to == null
        ? "Timetable from ${operator.name}'s published schedule"
        : [if (from != null) 'Valid from ${_date(from)}', if (to != null) 'until ${_date(to)}'].join(' ');
    return AppCard(
      onTap: onOpen,
      highlighted: status == TimetableStatus.current && !info.isPublicHoliday,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: label,
                  button: true,
                  excludeSemantics: true,
                  child: Text(label, style: context.text.titleMedium),
                ),
              ),
              Icon(Icons.chevron_right, color: c.muted),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (info.isPublicHoliday) TagChip('Public holiday', icon: Icons.event_outlined, color: c.warning),
              switch (status) {
                TimetableStatus.current => TagChip('In force', color: c.success),
                TimetableStatus.upcoming => const TagChip('Upcoming'),
                TimetableStatus.expired => const TagChip('Expired'),
              },
            ],
          ),
          const SizedBox(height: 8),
          Text(validity, style: context.text.bodyMedium?.copyWith(color: c.muted)),
          if (onPdf != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onPdf,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Official PDF'),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 0)),
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}
