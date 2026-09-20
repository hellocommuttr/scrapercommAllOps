import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/service_day.dart';
import '../../theme/app_theme.dart';
import 'trip_progress.dart';

/// The mockups' "red-outlined" button: orange border, orange label and icon.
class AccentOutlinedButton extends StatelessWidget {
  const AccentOutlinedButton({super.key, required this.label, required this.icon, required this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accentText;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

/// The index the rail marks as "here": the last stop left while riding, the boarding stop
/// before departure, the alighting stop once arrived.
int _currentIndex(TripProgress p) => switch (p.phase) {
  TripPhase.onBoard => p.passedIndex,
  TripPhase.arrived => p.stops.length - 1,
  _ => 0,
};

/// A horizontal stop rail: up to five stops around the scheduled position, the current one
/// an orange bubble with the bus or train, labels under each dot.
class StopRail extends StatelessWidget {
  const StopRail({super.key, required this.progress});

  final TripProgress progress;

  static const _window = 5;
  static const _bubble = 32.0;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    final n = p.stops.length;
    final cur = _currentIndex(p);
    final start = (cur - 2).clamp(0, math.max(0, n - _window)).toInt();
    final end = math.min(n, start + _window);
    final dark = Theme.of(context).brightness == Brightness.dark;

    Widget half(bool show, bool travelled) => Expanded(
      child: show ? Container(height: 3, color: travelled ? accent : c.cardBorder) : const SizedBox.shrink(),
    );

    return Semantics(
      label: switch (p.phase) {
        TripPhase.arrived => 'Scheduled position: at ${p.stops.last.name}',
        TripPhase.onBoard => 'Scheduled position: past ${p.stops[cur].name}, next ${p.stops[cur + 1].name}',
        _ => 'Scheduled position: not yet left ${p.stops.first.name}',
      },
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = start; i < end; i++)
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: _bubble,
                    child: Row(
                      children: [
                        half(i > 0, i <= cur),
                        if (i == cur)
                          Container(
                            width: _bubble,
                            height: _bubble,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Brand.orangeDeep,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              p.operator.isTrain ? Icons.train : Icons.directions_bus,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        else
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < cur ? accent : (i == n - 1 ? (dark ? Colors.white : c.card) : c.muted),
                              border: i == n - 1 && i > cur ? Border.all(color: c.muted, width: 2) : null,
                            ),
                          ),
                        half(i < n - 1, i < cur),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      p.stops[i].name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        fontSize: 11,
                        color: i == cur ? c.accentText : (i < cur ? c.muted : null),
                        fontWeight: i == cur ? FontWeight.w700 : FontWeight.w500,
                      ),
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

enum _Role { board, next, other, destination }

/// The compact "Your trip" timeline: board stop, next stop, "— N more stops" (tap to
/// expand), destination. Times not printed in the timetable show as "(est.)".
class CompactTimeline extends StatelessWidget {
  const CompactTimeline({
    super.key,
    required this.progress,
    required this.boardSubline,
    required this.destinationSubline,
    required this.expanded,
    required this.onToggle,
  });

  final TripProgress progress;
  final String boardSubline;
  final String destinationSubline;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final last = p.stops.length - 1;
    final next = p.phase == TripPhase.onBoard ? p.nextIndex : null;
    bool visible(int i) => expanded || i == 0 || i == last || i == next;
    final word = p.operator.stopWord;
    final rows = <Widget>[];
    var hidden = 0;
    for (var i = 0; i <= last; i++) {
      if (!visible(i)) {
        hidden++;
        continue;
      }
      if (hidden > 0) {
        rows.add(_MoreRow(count: hidden, word: word, onTap: onToggle));
        hidden = 0;
      }
      final role = i == 0
          ? _Role.board
          : i == last
          ? _Role.destination
          : i == next
          ? _Role.next
          : _Role.other;
      rows.add(
        _StopRow(
          stop: p.stops[i],
          role: role,
          passed: p.phase != TripPhase.futureDay && i <= p.passedIndex,
          isLast: i == last,
          subline: switch (role) {
            _Role.board => boardSubline,
            _Role.destination => destinationSubline,
            _Role.next => 'Next $word',
            _Role.other => null,
          },
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...rows,
        if (expanded && last > 1)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: onToggle, child: Text('Show fewer ${word}s')),
          ),
      ],
    );
  }
}

const _timeWidth = 56.0;
const _railWidth = 24.0;

class _StopRow extends StatelessWidget {
  const _StopRow({required this.stop, required this.role, required this.passed, required this.isLast, this.subline});

  final ProgressStop stop;
  final _Role role;
  final bool passed;
  final bool isLast;
  final String? subline;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final est = stop.minutes == null || stop.approx;
    final time = formatMinutes(stop.minutes ?? stop.estimate);
    final bold = role != _Role.other;
    final dot = switch (role) {
      _Role.board => BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent, width: 2.5),
      ),
      _Role.next => BoxDecoration(shape: BoxShape.circle, color: accent),
      _Role.destination => BoxDecoration(shape: BoxShape.circle, color: dark ? Colors.white : c.muted),
      _Role.other => BoxDecoration(shape: BoxShape.circle, color: passed ? accent : c.muted),
    };
    final size = role == _Role.other ? 8.0 : 12.0;
    return Semantics(
      label: [stop.name, 'at $time', if (est) 'estimated', ?subline].join(', '),
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _timeWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: bold ? FontWeight.w600 : null,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: passed && role == _Role.other ? c.muted : null,
                    ),
                  ),
                  if (est) Text('(est.)', style: context.text.labelSmall?.copyWith(color: c.muted)),
                ],
              ),
            ),
            SizedBox(
              width: _railWidth,
              child: Column(
                children: [
                  SizedBox(height: 5 + (12 - size) / 2),
                  Container(width: size, height: size, decoration: dot),
                  if (!isLast) Expanded(child: VerticalDivider(width: 2, thickness: 1.5, color: c.cardBorder)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.name,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: bold ? FontWeight.w600 : null,
                        color: passed && role == _Role.other ? c.muted : null,
                      ),
                    ),
                    if (subline != null)
                      Text(
                        subline!,
                        style: context.text.bodySmall?.copyWith(color: role == _Role.next ? c.accentText : c.muted),
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

/// "— 2 more stops", tap to show them.
class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.count, required this.word, required this.onTap});

  final int count;
  final String word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = '— $count more ${count == 1 ? word : '${word}s'}';
    return Semantics(
      button: true,
      label: '$label. Show them',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              const SizedBox(width: _timeWidth),
              SizedBox(
                width: _railWidth,
                height: 48,
                child: VerticalDivider(width: 2, thickness: 1.5, color: c.cardBorder),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: context.text.bodySmall?.copyWith(color: c.muted)),
              ),
              Icon(Icons.expand_more, size: 20, color: c.muted),
            ],
          ),
        ),
      ),
    );
  }
}
