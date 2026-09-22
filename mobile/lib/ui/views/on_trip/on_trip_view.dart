import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/service_day.dart';
import '../../../services/planner_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/route_map.dart';
import '../planner/planned_journey_card.dart' show endpointSubline;
import 'on_trip_viewmodel.dart';
import 'trip_progress.dart';
import 'trip_widgets.dart';

/// The Live Journey tab (docs/DESIGN.md "Live Journey"). Lives in MainView's IndexedStack,
/// so it has no back button.
///
/// Order, as in the mockup: title + subtitle + "End journey", trip header card, next-stop
/// card with the stop rail, map card, "Your trip" card, "Need help?" card. Progress is the
/// timetable against the clock — never a vehicle position.
class OnTripView extends StackedView<OnTripViewModel> {
  const OnTripView({super.key});

  @override
  void onViewModelReady(OnTripViewModel viewModel) => viewModel.init();

  @override
  Widget builder(BuildContext context, OnTripViewModel viewModel, Widget? child) {
    final j = viewModel.journey;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _Header(viewModel: viewModel),
                const OfflineBanner(),
                if (!viewModel.loadedOnce)
                  const LoadingBlock(label: 'Loading your journey…')
                else if (j == null)
                  _NoTrip(viewModel: viewModel)
                else
                  _ActiveTrip(viewModel: viewModel, journey: j, progress: viewModel.progress!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  OnTripViewModel viewModelBuilder(BuildContext context) => OnTripViewModel();
}

/// "12 min", "1h 5m" — never negative.
String _mins(double m) => formatDuration(math.max(0, m.ceil()));

/// "Live Journey" + bell, then "You're on your way" + "☐ End journey".
class _Header extends StatelessWidget {
  const _Header({required this.viewModel});

  final OnTripViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final active = viewModel.journey != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text('Live Journey', style: context.text.headlineMedium, maxLines: 1),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    active || !viewModel.loadedOnce ? "You're on your way" : 'No journey in progress',
                    style: TextStyle(color: context.colors.muted, fontSize: 14),
                  ),
                ),
                if (active)
                  AccentOutlinedButton(
                    label: 'End journey',
                    icon: Icons.check_box_outline_blank,
                    onPressed: viewModel.endTrip,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The circle with the bus or train in it.
class _VehicleCircle extends StatelessWidget {
  const _VehicleCircle({required this.journey});

  final PlannedJourney journey;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.infoSurface,
        border: Border.all(color: context.colors.cardBorder),
      ),
      child: Icon(transitIcon(journey.operator), color: context.colors.accentText),
    ),
  );
}

// ---------------------------------------------------------------- no trip under way

class _NoTrip extends StatelessWidget {
  const _NoTrip({required this.viewModel});

  final OnTripViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final n = viewModel.next;
    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: EmptyState(
              icon: Icons.commute_outlined,
              title: 'No journey in progress',
              message: 'Start a journey from your planner and it shows here stop by stop, from the timetable.',
              actionLabel: n == null ? 'Plan a trip' : null,
              onAction: n == null ? viewModel.planTrip : null,
            ),
          ),
          if (n != null) ...[
            const SectionHeader('Your next planned journey', padding: EdgeInsets.fromLTRB(0, 24, 0, 8)),
            _NextCard(viewModel: viewModel, journey: n),
            const SizedBox(height: 8),
            Center(
              child: TextButton(onPressed: viewModel.planTrip, child: const Text('Plan a different trip')),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.viewModel, required this.journey});

  final OnTripViewModel viewModel;
  final PlannedJourney journey;

  @override
  Widget build(BuildContext context) {
    final j = journey;
    final c = context.colors;
    final until = viewModel.minutesUntilDeparture(j);
    final when = j.date == viewModel.today
        ? 'Departs ${formatRelative(until)}'
        : formatDayRelative(j.date, viewModel.today);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VehicleCircle(journey: j),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RouteBadge(routeNumber: j.routeNumber, operator: j.operator),
                    const SizedBox(height: 8),
                    Text('${j.from.displayName} → ${j.to.displayName}', style: context.text.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${j.arriveTime == null ? j.boardTime : '${j.boardTime} → ${j.arriveTime}'}'
                      '${j.approx ? ' (est.)' : ''}',
                      style: context.text.bodyMedium,
                    ),
                    Text(when, style: context.text.bodySmall?.copyWith(color: c.accentText)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: viewModel.startNext,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start journey'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- the trip in progress

class _ActiveTrip extends StatelessWidget {
  const _ActiveTrip({required this.viewModel, required this.journey, required this.progress});

  final OnTripViewModel viewModel;
  final PlannedJourney journey;
  final TripProgress progress;

  @override
  Widget build(BuildContext context) {
    final j = journey;
    final p = progress;
    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TripHeaderCard(viewModel: viewModel, journey: j),
          // Where it matters most: standing at the roadside.
          if (j.unofficialStopAdvice case final advice?) ...[
            const SizedBox(height: 12),
            InfoBanner(tone: BannerTone.warning, icon: Icons.warning_amber_rounded, message: advice),
          ],
          const SizedBox(height: 12),
          _NextStopCard(viewModel: viewModel, journey: j, progress: p),
          if (viewModel.stopsUnavailable) ...[
            const SizedBox(height: 12),
            InfoBanner(
              tone: BannerTone.warning,
              message:
                  "The ${j.operator.stopWord}-by-${j.operator.stopWord} times for this trip aren't saved on this "
                  'phone yet. Connect to the internet once to load them.',
            ),
          ],
          _MapCard(viewModel: viewModel, progress: p),
          const SizedBox(height: 12),
          _YourTripCard(viewModel: viewModel, journey: j, progress: p),
          const SizedBox(height: 12),
          _HelpCard(onHelp: viewModel.getHelp),
        ],
      ),
    );
  }
}

/// Bus icon circle, operator + route chips, "From → To", "View full trip >".
class _TripHeaderCard extends StatelessWidget {
  const _TripHeaderCard({required this.viewModel, required this.journey});

  final OnTripViewModel viewModel;
  final PlannedJourney journey;

  @override
  Widget build(BuildContext context) {
    final j = journey;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VehicleCircle(journey: j),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RouteBadge(routeNumber: j.routeNumber, operator: j.operator),
                const SizedBox(height: 8),
                Text('${j.from.displayName} → ${j.to.displayName}', style: context.text.titleMedium),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: viewModel.viewFullTrip,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.only(left: 14, right: 8)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('View full trip'), SizedBox(width: 4), Icon(Icons.chevron_right, size: 18)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Next stop in / 4 stops (12 min) / Adderley St / Stop ID: 0487" with "🔔 Get off" at the
/// right, then the stop rail and "Based on the timetable".
class _NextStopCard extends StatelessWidget {
  const _NextStopCard({required this.viewModel, required this.journey, required this.progress});

  final OnTripViewModel viewModel;
  final PlannedJourney journey;
  final TripProgress progress;

  @override
  Widget build(BuildContext context) {
    final j = journey;
    final p = progress;
    final c = context.colors;
    final last = p.stops.length - 1;
    final word = j.operator.stopWord;

    // The stop the card is about: the next one, or the destination once arrived.
    final idx = p.nextIndex ?? last;
    final stop = p.stops[idx];
    final String? stopId = idx == 0
        ? (j.from.isStop ? endpointSubline(j.from) : null)
        : idx == last
        ? (j.to.isStop ? endpointSubline(j.to) : null)
        : null;
    final est = stop.minutes == null || stop.approx;
    final subline = stopId ?? 'Scheduled ${formatMinutes(stop.minutes ?? stop.estimate)}${est ? ' (est.)' : ''}';

    final count = p.stopsRemaining;
    final countText = '$count ${count == 1 ? word : '${word}s'}';
    final Widget value;
    final String spoken;
    switch (p.phase) {
      case TripPhase.futureDay:
        final day = 'Scheduled for ${formatDate(j.date, withYear: false)}';
        value = Text(day, style: context.text.titleMedium);
        spoken = day;
      case TripPhase.arrived:
        value = Text('Arrived (est.)', style: context.text.titleMedium?.copyWith(color: c.accentText));
        spoken = 'Scheduled to have arrived at ${stop.name}';
      case TripPhase.notDeparted || TripPhase.onBoard:
        final m = _mins(stop.estimate - p.now);
        value = Text.rich(
          TextSpan(
            text: '$countText ',
            children: [
              TextSpan(
                text: '($m${est ? ' est.' : ''})',
                style: TextStyle(color: c.accentText),
              ),
            ],
          ),
          style: context.text.titleMedium,
        );
        spoken = 'Next $word ${stop.name} in $m. $countText to go';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Semantics(
                  label: '$spoken. $subline',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.phase == TripPhase.arrived ? 'Your $word' : 'Next $word in',
                        style: context.text.bodySmall?.copyWith(color: c.muted),
                      ),
                      const SizedBox(height: 2),
                      value,
                      const SizedBox(height: 8),
                      Text(stop.name, style: context.text.titleLarge),
                      const SizedBox(height: 2),
                      Text(subline, style: context.text.bodySmall?.copyWith(color: c.muted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _GetOffToggle(viewModel: viewModel),
            ],
          ),
          const SizedBox(height: 18),
          StopRail(progress: p),
          const SizedBox(height: 10),
          Text('Based on the timetable', style: context.text.bodySmall?.copyWith(color: c.muted)),
        ],
      ),
    );
  }
}

/// "🔔 Get off": the get-off reminder, orange outline when off, filled orange when on.
class _GetOffToggle extends StatelessWidget {
  const _GetOffToggle({required this.viewModel});

  final OnTripViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final on = viewModel.getOffReminder;
    final accent = context.colors.accentText;
    Future<void> toggle() async {
      final messenger = ScaffoldMessenger.of(context);
      final message = await viewModel.setGetOffReminder(!on);
      if (message == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    return Semantics(
      toggled: on,
      button: true,
      label: 'Get off reminder',
      hint: on ? 'On. Double tap to turn off' : 'Off. Double tap to turn on',
      excludeSemantics: true,
      child: on
          ? FilledButton.icon(
              onPressed: toggle,
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              icon: const Icon(Icons.notifications_active, size: 18),
              label: const Text('Get off'),
            )
          : OutlinedButton.icon(
              onPressed: toggle,
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              icon: const Icon(Icons.notifications_none, size: 18),
              label: const Text('Get off'),
            ),
    );
  }
}

/// The route map with recentre (◎) and navigate (➤) buttons on its right edge.
class _MapCard extends StatelessWidget {
  const _MapCard({required this.viewModel, required this.progress});

  final OnTripViewModel viewModel;
  final TripProgress progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final mapStops = <MapStop>[
      for (var i = 0; i < p.stops.length; i++)
        if (p.stops[i].hasLocation)
          MapStop(
            p.stops[i].lat!,
            p.stops[i].lon!,
            label: p.stops[i].name,
            kind: i == 0
                ? MapStopKind.board
                : i == p.stops.length - 1
                ? MapStopKind.alight
                : MapStopKind.intermediate,
          ),
      if (p.scheduledPosition case final pos?) MapStop(pos.$1, pos.$2, kind: MapStopKind.current),
    ];
    final path = [
      for (final s in p.stops)
        if (s.hasLocation) (s.lat!, s.lon!),
    ];
    if (path.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Stack(
        children: [
          RouteMap(key: ValueKey(viewModel.mapEpoch), path: path, stops: mapStops),
          if (viewModel.showMaps)
            Positioned(
              right: 8,
              top: 8,
              child: Column(
                children: [
                  _MapButton(icon: Icons.my_location, label: 'Recentre the map', onTap: viewModel.recentreMap),
                  const SizedBox(height: 8),
                  _MapButton(
                    icon: Icons.near_me_outlined,
                    label: 'Open the next stop in OpenStreetMap',
                    onTap: viewModel.openNextStopInMap,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Material(
          color: c.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: c.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(width: 48, height: 48, child: Icon(icon, size: 22)),
          ),
        ),
      ),
    );
  }
}

/// "Your trip" + "Total travel time: 16 min", the compact timeline, "View full trip".
class _YourTripCard extends StatelessWidget {
  const _YourTripCard({required this.viewModel, required this.journey, required this.progress});

  final OnTripViewModel viewModel;
  final PlannedJourney journey;
  final TripProgress progress;

  @override
  Widget build(BuildContext context) {
    final j = journey;
    final c = context.colors;
    final total = j.durationMinutes;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text('Your trip', style: context.text.titleMedium)),
              ),
              if (total != null)
                Text.rich(
                  TextSpan(
                    text: 'Total travel time: ',
                    style: TextStyle(color: c.muted),
                    children: [
                      TextSpan(
                        text: '${formatDuration(total)}${j.approx ? ' (est.)' : ''}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  style: context.text.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 14),
          CompactTimeline(
            progress: progress,
            boardSubline: endpointSubline(j.from),
            destinationSubline: endpointSubline(j.to),
            expanded: viewModel.timelineExpanded,
            onToggle: viewModel.toggleTimeline,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: viewModel.viewFullTrip, child: const Text('View full trip')),
        ],
      ),
    );
  }
}

/// "ⓘ Need help? / Get support or report an issue on this trip." + "Get help".
class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.onHelp});

  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.info_outline, color: c.accentText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need help?', style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'Get support or report an issue on this trip.',
                  style: context.text.bodySmall?.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AccentOutlinedButton(label: 'Get help', icon: Icons.support_agent, onPressed: onHelp),
        ],
      ),
    );
  }
}
