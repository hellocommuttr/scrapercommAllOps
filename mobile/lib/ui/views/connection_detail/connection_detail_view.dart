import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'connection_detail_viewmodel.dart';

class ConnectionDetailView extends StackedView<ConnectionDetailViewModel> {
  const ConnectionDetailView({super.key, required this.connection, required this.date});

  final Connection connection;
  final ServiceDate date;

  @override
  Widget builder(BuildContext context, ConnectionDetailViewModel viewModel, Widget? child) {
    final c = context.colors;
    final legs = connection.legs;
    final weekday = dayTypeFor(date) == DayType.weekday;
    final legFares = connection.legFaresOn(weekday: weekday);
    // Each ride's own price as it leaves: MyCiTi's peak or saver, else the cash fare.
    String legPrice(ConnectionLeg leg) {
      final p = fareAt(leg.fare, weekday: weekday, boardMinutes: leg.boardMinutes);
      if (p == null) return '';
      return ' · ${formatRands(p)}${leg.fare!.isMyciti ? '' : ' cash'}${connection.oneTicket ? ' on its own' : ''}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trip with one change')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Text(
                '${titleCase(legs.first.fromName)} → ${titleCase(legs.last.toName)}',
                style: context.text.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${formatDate(date)}'
                '${connection.totalMinutes != null ? ' · ${formatDuration(connection.totalMinutes!)} in total' : ''}',
                style: TextStyle(color: c.muted),
              ),
              const SizedBox(height: 12),
              const ScheduledDisclaimer(
                extra: 'A late first ride can mean missing the second — leave extra time at the change.',
              ),
              if (connection.fare?.isMyciti == true &&
                  connection.priceOn(weekday: weekday) != null) ...[
                const SizedBox(height: 8),
                InfoBanner(
                  icon: Icons.payments_outlined,
                  message:
                      '${formatRands(connection.priceOn(weekday: weekday)!)} for the whole trip '
                      'on a myconnect card: MyCiTi charges one fare for the total distance, change included '
                      '(${connection.fare!.basisFrom}, ${connection.fare!.basisTo}). Peak '
                      '${formatRands(connection.fare!.cashCents!)} on weekdays 06:45–08:00 and 16:15–17:30, saver '
                      '${formatRands(connection.fare!.saverCents!)} at all other times. MyCiTi takes no cash.',
                ),
              ] else if (connection.fare?.cashCents != null) ...[
                const SizedBox(height: 8),
                InfoBanner(
                  icon: Icons.payments_outlined,
                  message: connection.fare!.kind == 'per_leg'
                      ? 'About ${formatRands(connection.fare!.cashCents!)} in cash in total — you pay for each ride '
                            'separately ($legFares). '
                            'Last published fares; they may have changed.'
                      : '${formatRands(connection.fare!.cashCents!)} cash for the whole trip: one ticket from '
                            '${titleCase(legs.first.fromName)} to ${titleCase(legs.last.toName)} covers the change'
                            '${legFares != null ? ' ($legFares if bought separately)' : ''}. '
                            'Last published fare; it may have changed.',
                ),
              ],
              const SizedBox(height: 12),
              for (final (i, leg) in legs.indexed) ...[
                AppCard(
                  onTap: viewModel.rides[i] == null ? null : () => viewModel.openLeg(i),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${leg.operator.isTrain ? 'Train' : 'Bus'} ${i + 1}'
                              '${legPrice(leg)}',
                              style: context.text.bodySmall?.copyWith(color: c.muted),
                            ),
                            const SizedBox(height: 4),
                            RouteBadge(routeNumber: leg.routeNumber, operator: leg.operator),
                            const SizedBox(height: 8),
                            Text(
                              '${leg.boardTime}  ${leg.from?.displayName ?? titleCase(leg.fromName)}',
                              style: context.text.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${leg.arriveTime ?? 'time not published'}'
                              '  ${leg.to?.displayName ?? titleCase(leg.toName)}',
                              style: context.text.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      if (viewModel.rides[i] != null) Icon(Icons.chevron_right, color: c.muted),
                    ],
                  ),
                ),
                if (i < legs.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.transfer_within_a_station, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Change at ${titleCase(leg.toName)}'
                                '${viewModel.waitAfter(i) != null ? ' — ${formatDuration(viewModel.waitAfter(i)!)} wait' : ''}',
                              ),
                            ),
                          ],
                        ),
                        if (viewModel.needsSafetyNote(i)) ...[
                          const SizedBox(height: 8),
                          const InfoBanner(
                            tone: BannerTone.warning,
                            icon: Icons.shield_outlined,
                            message:
                                'Long wait or after dark at this change. Wait where it\'s well lit and busy, and '
                                'share your trip with someone. In an emergency call 10111.',
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: viewModel.added ? null : viewModel.addAll,
                icon: Icon(viewModel.added ? Icons.check : Icons.bookmark_add_outlined),
                // "Both" is only true of two legs; the API may return a journey with more.
                label: Text(
                  legs.length == 2
                      ? (viewModel.added ? 'Both rides are on your planner' : 'Add both rides to planner')
                      : (viewModel.added
                            ? 'All ${legs.length} rides are on your planner'
                            : 'Add all ${legs.length} rides to planner'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  ConnectionDetailViewModel viewModelBuilder(BuildContext context) => ConnectionDetailViewModel(connection, date);
}
