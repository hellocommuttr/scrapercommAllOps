import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/footnotes.dart';
import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/journey_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/route_map.dart';
import 'trip_detail_viewmodel.dart';

class TripDetailView extends StackedView<TripDetailViewModel> {
  const TripDetailView({super.key, this.ride, this.plannedJourneyId});

  final Ride? ride;
  final String? plannedJourneyId;

  @override
  Widget builder(BuildContext context, TripDetailViewModel viewModel, Widget? child) {
    final msg = viewModel.message;
    if (msg != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.clearMessage();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(msg)));
      });
    }
    final ready = viewModel.headerReady;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip details'),
        actions: [
          IconButton(
            tooltip: 'Share this trip',
            onPressed: ready ? viewModel.share : null,
            icon: const Icon(Icons.share_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) => switch (v) {
              'report' => viewModel.report(),
              'pdf' => viewModel.openPdf(),
              'remove' => viewModel.removeFromPlanner(),
              _ => null,
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'report', child: Text('Report a problem with this ${viewModel.operator.vehicle}')),
              if (viewModel.timetable?.pdfUrl != null)
                const PopupMenuItem(value: 'pdf', child: Text('Official timetable (PDF)')),
              if (viewModel.isPlanned) const PopupMenuItem(value: 'remove', child: Text('Remove from planner')),
            ],
          ),
        ],
      ),
      body: _body(context, viewModel),
      bottomNavigationBar: viewModel.headerReady ? _actions(context, viewModel) : null,
    );
  }

  Widget _body(BuildContext context, TripDetailViewModel vm) {
    if (vm.missing) {
      return const EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Journey not found',
        message: 'This journey is no longer on your planner.',
      );
    }
    if (!vm.headerReady) return const LoadingBlock(label: 'Loading trip…');
    final c = context.colors;
    final today = const SastClock().today;
    final stops = vm.trip?.stops ?? const <TripStop>[];
    final located = stops.where((s) => s.lat != null && s.lon != null).toList();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            const OfflineBanner(),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RouteBadge(routeNumber: vm.routeNumber, operator: vm.operator),
                      const Spacer(),
                      if (vm.isPlanned) const TagChip('On your planner', icon: Icons.bookmark_added_outlined),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(titleCase(vm.routeLabel), style: context.text.bodySmall?.copyWith(color: c.muted)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text('${vm.boardTime} → ${vm.arriveTime ?? '—'}', style: context.text.headlineSmall),
                      ),
                      if (vm.duration != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: c.infoSurface, borderRadius: BorderRadius.circular(8)),
                          child: Text(formatDuration(vm.duration!)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDayRelative(vm.date, today)} · ${vm.dayLabel.isEmpty ? dayTypeFor(vm.date).label : titleCase(vm.dayLabel)}'
                    '${vm.date == today && vm.minutesUntil > -1 ? ' · scheduled ${formatRelative(vm.minutesUntil)}' : ''}',
                    style: TextStyle(color: c.accentText, fontWeight: FontWeight.w500),
                  ),
                  if (vm.boardApprox || vm.arriveApprox) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${vm.boardApprox ? 'The departure' : 'The arrival'} time is estimated: the timetable prints no time at '
                      '${vm.boardApprox ? vm.from.displayName : vm.to.displayName}, so Commuttr works it out from the stops on either side.',
                      style: context.text.bodySmall?.copyWith(color: c.muted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            ScheduledDisclaimer(
              operator: vm.operator,
              extra:
                  'Be at your ${vm.operator.stopWord} '
                  '${vm.arriveEarly > 0 ? '${vm.arriveEarly}–${vm.arriveEarly + 5}' : '5–10'} min early.',
            ),
            if (vm.footnotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final (code, text) in vm.footnotes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InfoBanner(icon: Icons.event_outlined, message: 'Footnote “$code”: $text.'),
                ),
            ],
            if (vm.tripFromCache && vm.tripFetchedAt != null) ...[
              const SizedBox(height: 8),
              const InfoBanner(tone: BannerTone.offline, message: 'Stop times from saved data.'),
            ],
            const SectionHeader('Stops', padding: EdgeInsets.fromLTRB(0, 20, 0, 8)),
            if (vm.tripUnavailable)
              EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Stop-by-stop times aren\'t saved',
                message:
                    'Connect once to load them. Add this ${vm.operator.vehicle} to your planner and they\'ll be kept '
                    'for offline use.',
                actionLabel: 'Try again',
                onAction: vm.retryTrip,
              )
            else if (stops.isEmpty)
              const LoadingBlock()
            else
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [for (final (i, s) in stops.indexed) _StopRow(stop: s, index: i, count: stops.length)],
                ),
              ),
            if (located.length >= 2 || vm.roadPath.length >= 2) ...[
              const SectionHeader('Map', padding: EdgeInsets.fromLTRB(0, 20, 0, 8)),
              RouteMap(
                path: vm.roadPath,
                stops: [
                  for (final (i, s) in located.indexed)
                    MapStop(
                      s.lat!,
                      s.lon!,
                      label: s.name,
                      kind: i == 0
                          ? MapStopKind.board
                          : (i == located.length - 1 ? MapStopKind.alight : MapStopKind.intermediate),
                    ),
                ],
              ),
            ],
            if ((vm.boardAwayM ?? 0) >= 50 || (vm.alightAwayM ?? 0) >= 50) ...[
              const SizedBox(height: 8),
              InfoBanner(
                icon: Icons.directions_walk,
                message:
                    'These are ${vm.operator.name} stops near your places: '
                    '${vm.boardAwayM ?? 0} m to ${titleCase(vm.boardLabel)}'
                    ' and ${vm.alightAwayM ?? 0} m from ${titleCase(vm.alightLabel)}.',
              ),
            ],
            const SectionHeader('Fare', padding: EdgeInsets.fromLTRB(0, 20, 0, 8)),
            _FareCard(fare: vm.fare, operator: vm.operator),
            const SectionHeader('About this timetable', padding: EdgeInsets.fromLTRB(0, 20, 0, 8)),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.operator.isTrain
                        ? '${vm.operator.name} ${vm.routeNumber} line'
                        : '${vm.operator.name} timetable ${vm.timetableNumber}',
                    style: context.text.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  if (vm.timetable?.effectiveFrom != null)
                    Text(
                      'Valid from ${formatDate(ServiceDate.parse(vm.timetable!.effectiveFrom!))}'
                      '${vm.timetable!.effectiveTo != null ? ' to ${formatDate(ServiceDate.parse(vm.timetable!.effectiveTo!))}' : ''}',
                      style: TextStyle(color: c.muted),
                    ),
                  Text(
                    'Commuttr is independent and not affiliated with '
                    '${switch (vm.operator.code) {
                      'metrorail' => 'Metrorail or PRASA',
                      'myciti' => 'MyCiTi or the City of Cape Town',
                      _ => 'Golden Arrow Bus Services',
                    }}. '
                    'If times here differ from the official timetable, the official one is right.',
                    style: context.text.bodySmall?.copyWith(color: c.muted),
                  ),
                  if (vm.timetable?.pdfUrl != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: vm.openPdf,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Official timetable (PDF)'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: vm.report,
                icon: const Icon(Icons.flag_outlined),
                label: Text('${vm.operator.isTrain ? 'Train' : 'Bus'} didn\'t come or times wrong? Tell us'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, TripDetailViewModel vm) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.cardBorder)),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Row(
              children: [
                Expanded(
                  child: vm.isPlanned
                      ? OutlinedButton.icon(
                          onPressed: vm.remindMe,
                          icon: Icon(
                            vm.planned!.row.reminderLeadMinutes != null
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                          ),
                          label: Text(vm.planned!.row.reminderLeadMinutes != null ? 'Reminder set' : 'Remind me'),
                        )
                      : OutlinedButton.icon(
                          onPressed: vm.addToPlanner,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: const Text('Add to planner'),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: vm.startTrip,
                    icon: Icon(vm.operator.isTrain ? Icons.train : Icons.directions_bus),
                    label: const Text('Start journey'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  TripDetailViewModel viewModelBuilder(BuildContext context) =>
      TripDetailViewModel(ride: ride, plannedJourneyId: plannedJourneyId);

  @override
  void onViewModelReady(TripDetailViewModel viewModel) => viewModel.init();
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.stop, required this.index, required this.count});

  final TripStop stop;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    final isEnd = index == 0 || index == count - 1;
    final code = Footnotes.codeOf(stop.rawValue);
    final String time;
    final String? note;
    if (stop.cellType == 'VIA' || stop.departureTime == null) {
      time = '—';
      note = 'time not published';
    } else {
      time = stop.departureTime!;
      note = code == null ? null : 'footnote $code';
    }
    return Semantics(
      label: '${titleCase(stop.name)}, ${note ?? 'scheduled $time'}',
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 64,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 8),
                child: Text(
                  time,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: isEnd ? FontWeight.w700 : FontWeight.w400,
                    color: time == '—' ? c.muted : null,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Expanded(
                    child: Container(width: 2, color: index == 0 ? Colors.transparent : accent.withValues(alpha: 0.6)),
                  ),
                  Container(
                    width: isEnd ? 14 : 10,
                    height: isEnd ? 14 : 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 0 ? accent : Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: accent, width: 2),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: index == count - 1 ? Colors.transparent : accent.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(titleCase(stop.name), style: TextStyle(fontWeight: isEnd ? FontWeight.w600 : FontWeight.w400)),
                    if (note != null)
                      Text(
                        note,
                        style: context.text.bodySmall?.copyWith(color: c.muted, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The published cash fare, the rules behind it, and — for trains — the tickets sold at
/// the station. Says plainly when nothing is published rather than showing a card price.
class _FareCard extends StatelessWidget {
  const _FareCard({required this.fare, required this.operator});

  final Fare? fare;
  final OperatorRef operator;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String? _since(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso);
    return d == null ? iso : '${_months[d.month - 1]} ${d.year}';
  }

  String? _basis(Fare f) {
    final between = f.basisFrom != null && f.basisTo != null ? '${f.basisFrom} to ${f.basisTo}' : null;
    return switch (f.basis) {
      'go_easy' => 'GO Easy is one price for any journey, however far it goes.',
      'exact' => between == null ? null : 'Fare published for $between.',
      'section' =>
        between == null
            ? null
            : 'No fare is published for your two stops, so this is the $between fare, the nearest published one '
                  'that covers your whole ride.',
      'prasa_zone' =>
        f.basisFrom == null ? null : 'Metrorail fare zone ${f.basisFrom}${f.basisTo != null ? ' (${f.basisTo})' : ''}.',
      _ => between == null ? null : 'No fare is published for your two stops, so this is the fare for $between.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final f = fare;
    final cash = f?.cashCents;
    if (f == null || cash == null) {
      return InfoBanner(
        message: switch (operator.code) {
          'metrorail' => 'Metrorail publishes no fare for this journey. Buy your ticket at the station.',
          'myciti' =>
            'MyCiTi fares are by distance and paid with a myconnect card. Commuttr does not have them yet — '
                'see myciti.org.za.',
          _ => 'Golden Arrow publishes no cash fare for this journey. Ask the driver, or see gabs.co.za.',
        },
      );
    }
    final since = _since(f.cashEffectiveFrom);
    final note = _basis(f);
    final tickets = operator.isTrain
        ? [
            ('Return', 'there and back', f.returnCents),
            ('Weekly', 'Monday to Friday', f.weeklyCents),
            ('Weekly', 'Monday to Saturday', f.weeklySatCents),
            ('Monthly', 'calendar month', f.monthlyCents),
          ].where((t) => t.$3 != null).toList()
        : const <(String, String, int?)>[];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatRands(cash), style: context.text.headlineSmall),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(operator.isTrain ? 'single, cash' : 'cash', style: TextStyle(color: c.muted)),
              ),
            ],
          ),
          if (since != null)
            Text(
              'Last published fare, from $since. Prices may have changed since.',
              style: context.text.bodySmall?.copyWith(color: c.muted),
            ),
          for (final (label, what, cents) in tickets)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(child: Text('$label · $what')),
                  Text(formatRands(cents!), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          if (operator.isTrain) ...[
            const SizedBox(height: 6),
            Text(
              'Buy tickets at the station before you board.',
              style: context.text.bodySmall?.copyWith(color: c.muted),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(note, style: context.text.bodySmall?.copyWith(color: c.muted)),
          ],
          if (f.zoneApprox)
            Text(
              'The fare zone for one of these stations is estimated — check at the ticket office.',
              style: context.text.bodySmall?.copyWith(color: c.warning),
            ),
        ],
      ),
    );
  }
}
