import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/service_day.dart';
import '../../../services/planner_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'planned_journey_card.dart';
import 'planner_viewmodel.dart';

/// The Planner tab (docs/DESIGN.md "Planner"). Lives in MainView's IndexedStack, so it has
/// no back button.
///
/// Order, as in the mockup: title + subtitle + "Add journey", date bar, stats card,
/// Planned | Completed tabs, numbered journey cards, the "Journeys are estimated" card.
class PlannerView extends StackedView<PlannerViewModel> {
  const PlannerView({super.key});

  @override
  void onViewModelReady(PlannerViewModel viewModel) => viewModel.init();

  @override
  Widget builder(BuildContext context, PlannerViewModel viewModel, Widget? child) {
    final shown = viewModel.shown;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DefaultTabController(
              length: 2,
              initialIndex: viewModel.tab.index,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _Header(viewModel: viewModel),
                  const OfflineBanner(),
                  Padding(
                    padding: pagePadding,
                    child: _DateBar(viewModel: viewModel),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: pagePadding,
                    child: _StatsCard(viewModel: viewModel),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: pagePadding,
                    child: TabBar(
                      onTap: viewModel.setTab,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      tabs: const [
                        Tab(text: 'Planned'),
                        Tab(text: 'Completed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!viewModel.loadedOnce && viewModel.isBusy)
                    const LoadingBlock(label: 'Loading your planner…')
                  else if (shown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _Empty(viewModel: viewModel),
                    )
                  else
                    for (var i = 0; i < shown.length; i++)
                      PlannedJourneyCard(
                        journey: shown[i],
                        number: i + 1,
                        isLast: i == shown.length - 1,
                        onSelected: (action) => _onAction(context, viewModel, shown[i], action),
                      ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: InfoBanner(
                      message: 'Journeys are estimated. Please arrive at your stop 5–10 minutes early.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    PlannerViewModel viewModel,
    PlannedJourney j,
    JourneyAction action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    void show(String? message) {
      if (message == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    switch (action) {
      case JourneyAction.details:
        viewModel.viewDetails(j);
      case JourneyAction.start:
        await viewModel.startTrip(j);
      case JourneyAction.remind:
        show(await viewModel.remind(j));
      case JourneyAction.move:
        final picked = await _pickDate(context, j.date, viewModel.today, help: 'Move this journey to');
        if (picked != null) show(await viewModel.moveTo(j, picked));
      case JourneyAction.delete:
        show(await viewModel.delete(j));
    }
  }

  @override
  PlannerViewModel viewModelBuilder(BuildContext context) => PlannerViewModel();
}

/// A Material date picker over a year either side of today, in Cape Town dates.
Future<ServiceDate?> _pickDate(BuildContext context, ServiceDate initial, ServiceDate today, {String? help}) async {
  DateTime local(ServiceDate d) => DateTime(d.year, d.month, d.day);
  final picked = await showDatePicker(
    context: context,
    initialDate: local(initial),
    firstDate: local(today.addDays(-365)),
    lastDate: local(today.addDays(365)),
    currentDate: local(today),
    helpText: help,
  );
  return picked == null ? null : ServiceDate.fromDateTime(picked);
}

/// "Planner" + bell, then "Your saved journeys for the day." + "⊕ Add journey".
class _Header extends StatelessWidget {
  const _Header({required this.viewModel});

  final PlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.muted;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text('Planner', style: context.text.headlineMedium, maxLines: 1)),
              ),
              TextButton.icon(
                onPressed: viewModel.addJourney,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Add journey', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Text('Your saved journeys for the day.', style: TextStyle(color: muted, fontSize: 14)),
        ],
      ),
    );
  }
}

/// ‹  📅 Today, 19 Sep 2026 ▾  ›, the middle opening a date picker.
class _DateBar extends StatelessWidget {
  const _DateBar({required this.viewModel});

  final PlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final d = viewModel.date;
    final label = viewModel.dateLabel;
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          IconButton(tooltip: 'Previous day', onPressed: viewModel.previousDay, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Semantics(
              button: true,
              label: 'Showing $label. Choose another date',
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await _pickDate(context, d, viewModel.today, help: 'Show journeys for');
                  if (picked != null) viewModel.setDate(picked);
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18, color: c.accentText),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          label,
                          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: c.muted),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(tooltip: 'Next day', onPressed: viewModel.nextDay, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

/// Three columns: "3 / Journeys", "1h 24m / Total travel time", "Golden Arrow / Transport mode".
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.viewModel});

  final PlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final total = viewModel.totalTravelMinutes;
    final ops = {for (final j in viewModel.all) j.operator};
    final modeIcon = ops.length == 1 ? transitIcon(ops.first) : Icons.commute_outlined;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Stat(icon: Icons.route_outlined, label: 'Journeys', value: '${viewModel.journeyCount}'),
            const VerticalDivider(width: 1),
            _Stat(icon: Icons.schedule, label: 'Total travel time', value: total > 0 ? formatDuration(total) : '-'),
            const VerticalDivider(width: 1),
            _Stat(icon: modeIcon, label: 'Transport mode', value: viewModel.transportMode),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              Icon(icon, size: 22, color: c.muted),
              const SizedBox(height: 6),
              Text(
                value,
                style: context.text.titleMedium?.copyWith(color: c.accentText, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: context.text.bodySmall?.copyWith(color: c.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.viewModel});

  final PlannerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final completedTab = viewModel.tab == PlannerTab.completed;
    final day = formatDayRelative(viewModel.date, viewModel.today);
    final dayText = day == 'Today' || day == 'Tomorrow' || day == 'Yesterday' ? day.toLowerCase() : 'on $day';
    return AppCard(
      padding: EdgeInsets.zero,
      child: EmptyState(
        icon: completedTab ? Icons.check_circle_outline : Icons.event_note_outlined,
        title: completedTab ? 'No completed journeys' : 'No journeys planned $dayText',
        message: completedTab
            ? 'Journeys you end on the Live Journey tab show up here.'
            : 'Search for a bus or train on Home and add it to your planner. It stays on this phone and works offline.',
        actionLabel: completedTab ? null : 'Add journey',
        onAction: completedTab ? null : viewModel.addJourney,
      ),
    );
  }
}
