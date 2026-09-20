import 'package:flutter/material.dart';

import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/planner_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// What the overflow menu on a planner card can do.
enum JourneyAction { details, start, remind, move, delete }

/// The grey line under a stop name: "Stop ID: 0487" for a stop, "Map point" for a pin.
String endpointSubline(Endpoint e) =>
    e.isStop && e.id != null ? 'Stop ID: ${e.id.toString().padLeft(4, '0')}' : 'Map point';

/// One numbered journey on the Planner, joined to the next by a dashed line.
///
/// Mockup: orange numbered circle | card: "09:15 → 09:31", duration pill, ⋮; operator and
/// route chips; stop 1 (orange hollow dot) and stop 2 (white dot) with sublines; footer
/// "🕑 Departs 09:15 • Arrives 09:31".
class PlannedJourneyCard extends StatelessWidget {
  const PlannedJourneyCard({
    super.key,
    required this.journey,
    required this.number,
    required this.isLast,
    required this.onSelected,
  });

  final PlannedJourney journey;
  final int number;
  final bool isLast;
  final ValueChanged<JourneyAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final j = journey;
    final c = context.colors;
    final arrive = j.arriveTime;
    final boardEst = j.row.boardApprox ? ' (est.)' : '';
    final arriveEst = j.row.arriveApprox ? ' (est.)' : '';
    final reminder = j.row.reminderLeadMinutes;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 30,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  ExcludeSemantics(
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Brand.orangeDeep),
                      child: Text(
                        '$number',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                  Expanded(
                    child: isLast
                        ? const SizedBox.shrink()
                        : CustomPaint(painter: _DashedLine(c.muted.withValues(alpha: 0.6)), size: Size.infinite),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  highlighted: j.status == JourneyStatus.active,
                  onTap: () => onSelected(JourneyAction.details),
                  padding: const EdgeInsets.fromLTRB(14, 4, 0, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              arrive == null ? j.boardTime : '${j.boardTime} → $arrive',
                              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              semanticsLabel: arrive == null
                                  ? 'Journey $number, ${j.boardTime}'
                                  : 'Journey $number, ${j.boardTime} to $arrive',
                            ),
                          ),
                          if (j.durationMinutes != null) _Pill(formatDuration(j.durationMinutes!)),
                          _Menu(journey: j, onSelected: onSelected),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            RouteBadge(routeNumber: j.routeNumber, operator: j.operator),
                            if (j.status == JourneyStatus.active)
                              TagChip('Live Journey', icon: transitIcon(j.operator), color: c.accentText),
                            if (j.status != JourneyStatus.completed && reminder != null)
                              TagChip('Reminder $reminder min before', icon: Icons.alarm),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StopLine(name: j.from.displayName, subline: endpointSubline(j.from), first: true),
                      _StopLine(name: j.to.displayName, subline: endpointSubline(j.to), first: false),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 16, color: c.muted),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                arrive == null
                                    ? 'Departs ${j.boardTime}$boardEst'
                                    : 'Departs ${j.boardTime}$boardEst • Arrives $arrive$arriveEst',
                                style: context.text.bodySmall?.copyWith(color: c.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: context.colors.infoSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.colors.cardBorder),
    ),
    child: Text(label, style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
  );
}

/// A stop with its dot: the boarding stop an orange hollow dot, the destination a white
/// dot, joined by a short line.
class _StopLine extends StatelessWidget {
  const _StopLine({required this.name, required this.subline, required this.first});

  final String name;
  final String subline;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 14,
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: first ? null : (dark ? Colors.white : c.muted),
                      border: first ? Border.all(color: accent, width: 2.5) : null,
                    ),
                  ),
                  if (first) Expanded(child: VerticalDivider(width: 14, thickness: 1.5, color: c.cardBorder)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: first ? 12 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(subline, style: context.text.bodySmall?.copyWith(color: c.muted)),
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

class _Menu extends StatelessWidget {
  const _Menu({required this.journey, required this.onSelected});

  final PlannedJourney journey;
  final ValueChanged<JourneyAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final status = journey.status;
    PopupMenuItem<JourneyAction> item(JourneyAction a, IconData icon, String label, {bool destructive = false}) {
      final col = destructive ? Theme.of(context).colorScheme.error : null;
      return PopupMenuItem(
        value: a,
        child: Row(
          children: [
            Icon(icon, size: 20, color: col),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: col)),
          ],
        ),
      );
    }

    return PopupMenuButton<JourneyAction>(
      tooltip: 'More options for the ${journey.boardTime} journey',
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (_) => [
        item(JourneyAction.details, Icons.info_outline, 'View details'),
        if (status == JourneyStatus.planned) item(JourneyAction.start, Icons.play_arrow_rounded, 'Start journey'),
        if (status != JourneyStatus.completed) item(JourneyAction.remind, Icons.alarm_add_outlined, 'Remind me'),
        item(JourneyAction.move, Icons.event_outlined, 'Move to another day'),
        item(JourneyAction.delete, Icons.delete_outline, 'Delete', destructive: true),
      ],
    );
  }
}

/// A vertical dashed line down the middle of its box.
class _DashedLine extends CustomPainter {
  const _DashedLine(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final x = size.width / 2;
    const dash = 4.0, gap = 4.0;
    for (var y = 4.0; y < size.height; y += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(x, (y + dash).clamp(0, size.height)), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLine old) => old.color != color;
}
