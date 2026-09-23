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
                        // An arrival that is only the same floor as boarding is not a time.
                        child: Text(
                          '${vm.boardTime} → ${vm.duration == null && vm.arriveApprox ? '-' : vm.arriveTime ?? '-'}',
                          style: context.text.headlineSmall,
                        ),
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
            if (unofficialStopAdviceFor(vm.boardLabel, vm.alightLabel, vm.operator) case final advice?) ...[
              const SizedBox(height: 12),
              InfoBanner(tone: BannerTone.warning, icon: Icons.warning_amber_rounded, message: advice),
            ],
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
            else ...[
              if (vm.wholeTrip != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'The whole ${vm.operator.vehicle} trip. You ride the highlighted part.',
                    style: context.text.bodySmall?.copyWith(color: c.muted),
                  ),
                ),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Builder(
                  builder: (context) {
                    final rows = tripRows(
                      stops: vm.wholeTrip?.stops ?? stops,
                      fromSeq: vm.fromSeq,
                      toSeq: vm.toSeq,
                      boardLabel: vm.boardLabel,
                      alightLabel: vm.alightLabel,
                      boardRaw: vm.boardRaw,
                      arriveRaw: vm.arriveRaw,
                      boardApprox: vm.boardApprox,
                      arriveApprox: vm.arriveApprox,
                    );
                    return Column(
                      children: [
                        for (final (i, r) in rows.indexed)
                          _StopRow(row: r, index: i, count: rows.length, vehicle: vm.operator.vehicle),
                      ],
                    );
                  },
                ),
              ),
            ],
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
            FareCard(
              fare: vm.fare,
              operator: vm.operator,
              peak: isMycitiPeak(weekday: dayTypeFor(vm.date) == DayType.weekday, boardMinutes: vm.boardMinutes),
            ),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    // The PDF where the operator still publishes it, and its list of
                    // timetables where it does not. A link to a file that has been taken
                    // down reads as our data being wrong about the service.
                    child: vm.timetable?.pdfUrl != null
                        ? TextButton.icon(
                            onPressed: vm.openPdf,
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: const Text('Official timetable (PDF)'),
                          )
                        : TextButton.icon(
                            onPressed: vm.openOperatorTimetables,
                            icon: const Icon(Icons.open_in_new),
                            label: Text('Official timetables on ${vm.operator.name}'),
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

enum StopRole { board, alight, ride, before, after }

/// One line of the stop list: a timetable stop, or the rider's own point on the road.
class TripRow {
  const TripRow({required this.name, required this.time, required this.approx, required this.role, this.pin = false});

  final String name;

  /// What to print for the time: a published time, the departure's own estimate at the
  /// rider's two ends, or empty where the timetable gives none.
  final String time;
  final bool approx;
  final StopRole role;

  /// The rider's own point, where the timetable names no stop.
  final bool pin;
}

/// The whole run with the rider's part marked, as the web app lays it out.
///
/// A place on the road between two stops is the rider's own point and goes in between
/// them; otherwise the stops at the ride's two sequence numbers are where they get on and
/// off. Everything before boarding and after alighting is the vehicle's own trip, shown so
/// a rider can see where it comes from and where it ends.
List<TripRow> tripRows({
  required List<TripStop> stops,
  required int fromSeq,
  required int toSeq,
  required String boardLabel,
  required String alightLabel,
  required String boardRaw,
  required String arriveRaw,
  required bool boardApprox,
  required bool arriveApprox,
}) {
  final boardPin = boardLabel.startsWith('between ');
  final alightPin = alightLabel.startsWith('between ');
  final rows = <TripRow>[];
  var boarded = false;
  var alighted = false;
  for (final (i, st) in stops.indexed) {
    if (boardPin && !boarded && st.stopSequence >= fromSeq) {
      rows.add(TripRow(name: boardLabel, time: boardRaw, approx: boardApprox, role: StopRole.board, pin: true));
      boarded = true;
    }
    final timed = st.cellType != 'VIA' && st.departureTime != null;
    final StopRole role;
    if (!boardPin && !boarded && st.stopSequence == fromSeq) {
      role = StopRole.board;
      boarded = true;
    } else if (!alightPin && boarded && !alighted && st.stopSequence == toSeq) {
      role = StopRole.alight;
      alighted = true;
    } else if (!boarded) {
      role = StopRole.before;
    } else if (alighted) {
      role = StopRole.after;
    } else {
      role = StopRole.ride;
    }
    // At the rider's own two stops a via shows the departure's estimate, not a blank: the
    // card above has just said when they get on and off.
    final chosen = role == StopRole.board ? boardRaw : (role == StopRole.alight ? arriveRaw : null);
    rows.add(TripRow(name: st.name, time: timed ? st.departureTime! : (chosen ?? ''), approx: !timed, role: role));
    final next = i + 1 < stops.length ? stops[i + 1] : null;
    if (alightPin && boarded && !alighted && st.stopSequence <= toSeq && (next == null || next.stopSequence > toSeq)) {
      rows.add(TripRow(name: alightLabel, time: arriveRaw, approx: arriveApprox, role: StopRole.alight, pin: true));
      alighted = true;
    }
  }
  return rows;
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.row, required this.index, required this.count, required this.vehicle});

  final TripRow row;
  final int index;
  final int count;
  final String vehicle;

  /// "16:30" from "16:30:00"; the rider's own ends keep their words ("from 14:50").
  static String _clock(String t) => t.replaceFirstMapped(RegExp(r'^(\d\d:\d\d):\d\d$'), (m) => m[1]!);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    final mine = row.role == StopRole.board || row.role == StopRole.alight;
    final aside = row.role == StopRole.before || row.role == StopRole.after;
    final notes = <String>[];
    final String time;
    if (row.time.isEmpty || row.time == 'via') {
      time = '-';
      notes.add('time not published');
    } else {
      time = _clock(row.time);
      final code = row.approx ? null : Footnotes.codeOf(row.time);
      if (code != null) notes.add('footnote $code');
    }
    if (row.pin) notes.add('your stop · not an official stop, the $vehicle may not stop here');
    final tag = switch (row.role) {
      StopRole.board => 'get on here',
      StopRole.alight => 'get off here',
      StopRole.before when index == 0 => '$vehicle starts',
      StopRole.after when index == count - 1 => 'terminus',
      _ => null,
    };
    // Solid along the ride, faint where the rider is not on board.
    Color line(bool riding) => riding ? accent : accent.withValues(alpha: 0.25);
    final ridingAbove = row.role == StopRole.ride || row.role == StopRole.alight;
    final ridingBelow = row.role == StopRole.ride || row.role == StopRole.board;
    final faded = aside ? c.muted : null;
    return Semantics(
      label: '${titleCase(row.name)}${tag == null ? '' : ', $tag'}, ${time == '-' ? 'time not published' : time}',
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 96,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 8),
                child: Text(
                  time,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: mine ? FontWeight.w700 : FontWeight.w400,
                    color: time == '-' ? c.muted : faded,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Expanded(
                    child: Container(width: 2, color: index == 0 ? Colors.transparent : line(ridingAbove)),
                  ),
                  Container(
                    width: mine ? 14 : 10,
                    height: mine ? 14 : 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: row.role == StopRole.board ? accent : Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: aside ? accent.withValues(alpha: 0.35) : accent, width: 2),
                    ),
                  ),
                  Expanded(
                    child: Container(width: 2, color: index == count - 1 ? Colors.transparent : line(ridingBelow)),
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
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          titleCase(row.name),
                          style: TextStyle(fontWeight: mine ? FontWeight.w600 : FontWeight.w400, color: faded),
                        ),
                        if (tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: mine ? accent.withValues(alpha: 0.15) : c.infoSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(fontSize: 11, color: mine ? accent : c.muted, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    if (notes.isNotEmpty)
                      Text(
                        notes.join(' · '),
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

/// Golden Arrow: no price for one trip, because none is published, and the GO EASY
/// bundles that are. Shown here on the trip rather than on the results card, where a
/// bundle price beside a single journey would read as what that journey costs.
///
/// These are counts of RIDES, not periods of time. This screen called them "Gold Card
/// weekly, any number of trips that week" and "monthly, any number of trips that month",
/// which is a different product from the one Golden Arrow sells: 10 rides for R248.50 and
/// 48 rides for R1,093, used whenever the rider likes. Somebody commuting twice a day
/// would have run out on the Friday of the second week believing they had paid for the
/// month. The five-ride bundle was not shown at all, though its price has always been in
/// the data.
Widget _goldCard(BuildContext context, Fare f) {
  final c = context.colors;
  final products = [
    (5, f.fiveRideCents),
    (10, f.weeklyCents),
    (48, f.monthlyCents),
  ].where((p) => p.$2 != null).toList();
  return AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No price for a single trip', style: context.text.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Golden Arrow does not publish what one trip costs in cash, so Commuttr shows no price for it. '
          'Ask the driver, or see gabs.co.za.',
          style: context.text.bodySmall?.copyWith(color: c.muted),
        ),
        const SizedBox(height: 12),
        Text('Gold Card: GO EASY rides', style: context.text.titleSmall),
        for (final (rides, cents) in products)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(child: Text('$rides rides · ${formatRands(cents! ~/ rides)} a ride')),
                Text(formatRands(cents), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Rides are loaded onto a Gold Card and used whenever you travel, at one price '
          'whatever the distance. Not valid to or from Atlantis, Darling, Dassenberg, '
          'Mamre, Pella, Malmesbury, Koeberg Power Station, Melkbosstrand, Fisantekraal, '
          'Wellington, Paarl or Stellenbosch. Last published prices; they may have changed.',
          style: context.text.bodySmall?.copyWith(color: c.muted),
        ),
      ],
    ),
  );
}

/// MyCiTi: the fare that applies when this bus leaves, both fares, and the passes.
Widget _mycitiFare(BuildContext context, Fare f, bool peak, String? since, String? note) {
  final c = context.colors;
  final passes = [
    ('1-day pass', f.dayPassCents),
    ('3-day pass', f.threeDayPassCents),
    ('7-day pass', f.weeklyCents),
    ('Monthly pass', f.monthlyCents),
  ].where((p) => p.$2 != null).toList();
  return AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatRands(peak ? f.cashCents! : f.saverCents!), style: context.text.headlineSmall),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(peak ? 'peak, myconnect card' : 'saver, myconnect card', style: TextStyle(color: c.muted)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Expanded(child: Text('Peak · weekdays 06:45–08:00 and 16:15–17:30')),
            Text(formatRands(f.cashCents!), style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              const Expanded(child: Text('Saver · all other times, weekends and public holidays')),
              Text(formatRands(f.saverCents!), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (passes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Unlimited travel passes', style: context.text.titleSmall),
          for (final (label, cents) in passes)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(child: Text('$label · any route, any time')),
                  Text(formatRands(cents!), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
        const SizedBox(height: 8),
        Text(
          'MyCiTi takes no cash: tap a myconnect card on the way in and out. Cards are sold at MyCiTi '
          'stations and selected retailers.',
          style: context.text.bodySmall?.copyWith(color: c.muted),
        ),
        if (since != null)
          Text('Fares from $since. Prices may change.', style: context.text.bodySmall?.copyWith(color: c.muted)),
        if (note != null) Text(note, style: context.text.bodySmall?.copyWith(color: c.muted)),
      ],
    ),
  );
}

/// The published cash fare, the rules behind it, and — for trains — the tickets sold at
/// the station. Says plainly when nothing is published rather than showing a card price.
/// The fare block on a trip: cash where the operator publishes one, MyCiTi's two fares
/// and passes, or Golden Arrow's GO EASY bundles. Public so a test can read what a rider
/// reads.
class FareCard extends StatelessWidget {
  const FareCard({super.key, required this.fare, required this.operator, this.peak = false});

  final Fare? fare;
  final OperatorRef operator;

  /// This ride starts in MyCiTi's peak period, so the peak fare is the one it costs.
  final bool peak;

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

  Widget _myciti(BuildContext context, Fare f, String? since, String? note) =>
      _mycitiFare(context, f, peak, since, note);

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
      'myciti_distance' =>
        f.basisFrom == null ? null : 'MyCiTi fare band ${f.basisFrom}${f.basisTo != null ? ' (${f.basisTo})' : ''}.',
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
    if (f != null && cash == null && !operator.isTrain && !f.isMyciti &&
        (f.fiveRideCents != null || f.weeklyCents != null || f.monthlyCents != null)) {
      return _goldCard(context, f);
    }
    if (f == null || cash == null) {
      return InfoBanner(
        message: switch (operator.code) {
          'metrorail' => 'Metrorail publishes no fare for this journey. Buy your ticket at the station.',
          'myciti' =>
            'MyCiTi fares are by distance and paid with a myconnect card. Commuttr does not have them yet, '
                'see myciti.org.za.',
          _ =>
            'Golden Arrow does not publish its cash fares, so Commuttr does not show a price. Ask the driver, '
                'or see gabs.co.za.',
        },
      );
    }
    final since = _since(f.cashEffectiveFrom);
    final note = _basis(f);
    if (f.isMyciti && f.saverCents != null) return _myciti(context, f, since, note);
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
              'The fare zone for one of these stations is estimated, so check at the ticket office.',
              style: context.text.bodySmall?.copyWith(color: c.warning),
            ),
        ],
      ),
    );
  }
}
