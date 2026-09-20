import 'package:flutter/material.dart';

import '../../core/service_day.dart';
import '../../data/models/models.dart';
import '../../services/journey_service.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// A "Recommended routes" card: duration and vehicle on the left, operator and route
/// chips with the stops in the middle, price and "Departs in …" on the right.
class RideCard extends StatelessWidget {
  const RideCard({super.key, required this.ride, required this.minutesUntil, this.onTap, this.highlighted = false});

  final Ride ride;

  /// Minutes until the scheduled departure (negative once it has left).
  final double minutesUntil;
  final VoidCallback? onTap;
  final bool highlighted;

  /// "Direct", "1 stop", "9 stops": stops in between, as the designs count them.
  static String stopsLabel(Ride r) {
    final n = r.departure.stopCount ?? (r.option.segmentStops.length > 2 ? r.option.segmentStops.length - 2 : 0);
    if (n <= 0) return 'Direct';
    return n == 1 ? '1 stop' : '$n stops';
  }

  static String departsLabel(double minutesUntil, String boardTime) {
    if (minutesUntil < -1 || minutesUntil >= 120) return 'Departs $boardTime';
    if (minutesUntil < 1) return 'Departs now';
    return 'Departs in ${formatDuration(minutesUntil)}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = c.accentText;
    final op = ride.operator;
    final duration = ride.durationMinutes;
    final cash = ride.fare?.cashCents;
    final departs = departsLabel(minutesUntil, ride.boardTime);
    final from = titleCase(ride.option.boardLabel.isEmpty ? ride.from.name : ride.option.boardLabel);
    final to = titleCase(ride.option.alightLabel.isEmpty ? ride.to.name : ride.option.alightLabel);
    final semantics =
        '${op.name} ${op.isTrain ? '${ride.option.routeNumber} line' : 'route ${ride.option.routeNumber}'}, '
        '$from to $to, ${stopsLabel(ride)}, ${duration != null ? formatDuration(duration) : ''}, $departs'
        '${ride.departure.boardApprox ? ', estimated time' : ''}'
        '${ride.noteText != null ? ', ${ride.noteText}' : ''}'
        '${cash != null ? ', ${formatRands(cash)}' : ''}';
    return Semantics(
      button: onTap != null,
      label: semantics,
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        highlighted: highlighted,
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: duration == null ? '–' : '${duration.round()}',
                          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' min', style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(transitIcon(op), color: c.muted, size: 24),
                ],
              ),
            ),
            Container(width: 1, height: 62, color: c.cardBorder, margin: const EdgeInsets.only(right: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteBadge(routeNumber: ride.option.routeNumber, operator: op),
                  const SizedBox(height: 8),
                  Text(
                    '$from → $to',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(color: c.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      stopsLabel(ride),
                      if (ride.walkLabel != null) ride.walkLabel!,
                      if (ride.noteText != null) ride.noteText!,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(color: c.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Fixed, so a long "Departs in 1 h 5 min" cannot squeeze the route and stops
            // out of shape.
            SizedBox(
              width: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (cash != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: c.infoSurface, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        formatRands(cash),
                        style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    )
                  else
                    const SizedBox(height: 34),
                  const SizedBox(height: 10),
                  Text(
                    ride.departure.boardApprox ? '$departs (est.)' : departs,
                    textAlign: TextAlign.end,
                    style: context.text.bodySmall?.copyWith(color: accent, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.muted),
          ],
        ),
      ),
    );
  }
}
