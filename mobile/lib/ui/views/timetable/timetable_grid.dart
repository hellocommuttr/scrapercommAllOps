import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models/models.dart';
import '../../theme/app_theme.dart';

/// A timetable schedule as a grid: stop names pinned on the left, one column per bus or train,
/// scrolling sideways. Rows have a fixed height (scaled with the system text size) so the
/// pinned column and the scrolling columns stay aligned.
class TimetableGrid extends StatefulWidget {
  const TimetableGrid({
    super.key,
    required this.schedule,
    required this.legend,
    this.operator = OperatorRef.goldenArrow,
  });

  final TimetableSchedule schedule;

  /// For wording: "Bus 3" / "Train 3", "Stop" / "Station".
  final OperatorRef operator;

  /// Footnote letter → readable text, for screen-reader labels.
  final Map<String, String> legend;

  @override
  State<TimetableGrid> createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  final _horizontal = ScrollController();

  String get _vehicle => widget.operator.isTrain ? 'Train' : 'Bus';

  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final rowH = 44.0 * scale;
    final headerH = 40.0 * scale;
    final colW = 64.0 * scale;
    final s = widget.schedule;
    final stops = [...s.stops]..sort((a, b) => a.stopSequence.compareTo(b.stopSequence));
    final cellsByTrip = [
      for (final t in s.trips) {for (final cell in t.cells) cell.stopSequence: cell},
    ];
    final stripe = scheme.surfaceContainerHigh.withValues(alpha: 0.5);
    final border = BorderSide(color: c.cardBorder);

    return LayoutBuilder(
      builder: (context, box) {
        final stopW = math.min(180.0 * scale, math.max(110.0, box.maxWidth * 0.4));

        Widget stopColumn() => Container(
          width: stopW,
          decoration: BoxDecoration(border: Border(right: border)),
          child: Column(
            children: [
              Container(
                height: headerH,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.operator.isTrain ? 'Station' : 'Stop',
                  style: context.text.labelMedium?.copyWith(color: c.muted),
                ),
              ),
              for (var r = 0; r < stops.length; r++)
                Container(
                  height: rowH,
                  color: r.isEven ? stripe : null,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    titleCase(stops[r].name),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.15),
                  ),
                ),
            ],
          ),
        );

        Widget tripColumn(int i) {
          final trip = s.trips[i];
          final cells = cellsByTrip[i];
          return SizedBox(
            width: colW,
            child: Column(
              children: [
                Semantics(
                  header: true,
                  label: '$_vehicle ${i + 1}${trip.noteCodes.isEmpty ? '' : ', footnote ${trip.noteCodes.join(', ')}'}',
                  excludeSemantics: true,
                  child: Container(
                    height: headerH,
                    alignment: Alignment.center,
                    child: _WithNote(
                      text: '${i + 1}',
                      note: trip.noteCodes.isEmpty ? null : trip.noteCodes.join(),
                      style: context.text.labelMedium?.copyWith(color: c.muted),
                    ),
                  ),
                ),
                for (var r = 0; r < stops.length; r++)
                  Container(
                    height: rowH,
                    color: r.isEven ? stripe : null,
                    alignment: Alignment.center,
                    child: _cell(context, cells[stops[r].stopSequence], stops[r], i),
                  ),
              ],
            ),
          );
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            color: c.card,
            border: Border.fromBorderSide(border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stopColumn(),
                Expanded(
                  child: Scrollbar(
                    controller: _horizontal,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontal,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [for (var i = 0; i < s.trips.length; i++) tripColumn(i)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cell(BuildContext context, TimetableCell? cell, PlanSegmentStop stop, int tripIndex) {
    final c = context.colors;
    final where = '${titleCase(stop.name)}, ${widget.operator.vehicle} ${tripIndex + 1}';
    if (cell == null || cell.cellType == 'NONE' || (cell.cellType == 'TIME' && cell.departureTime == null)) {
      return Semantics(
        label: '$where: does not stop',
        excludeSemantics: true,
        child: Text('–', style: TextStyle(color: c.muted.withValues(alpha: 0.6))),
      );
    }
    if (cell.cellType == 'VIA') {
      return Semantics(
        label: '$where: passes, time not published',
        excludeSemantics: true,
        child: Text(
          'via',
          style: TextStyle(color: c.muted, fontStyle: FontStyle.italic, fontSize: 13),
        ),
      );
    }
    // Train times can carry seconds ("05:15:00"); the grid shows hours and minutes.
    final raw = cell.departureTime!;
    final time = raw.length > 5 && raw[2] == ':' && raw[5] == ':' ? raw.substring(0, 5) : raw;
    final code = cell.noteCode?.toLowerCase();
    final meaning = code == null ? null : widget.legend[code];
    return Semantics(
      label:
          'Scheduled $time at $where'
          '${code == null ? '' : ', footnote $code${meaning == null ? '' : ': $meaning'}'}',
      excludeSemantics: true,
      child: _WithNote(
        text: time,
        note: code,
        style: const TextStyle(fontSize: 14, fontFeatures: [FontFeature.tabularFigures()]),
      ),
    );
  }
}

/// A time with its footnote letter raised after it: "08:45ᵇ".
class _WithNote extends StatelessWidget {
  const _WithNote({required this.text, required this.note, this.style});

  final String text;
  final String? note;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: text,
      style: style,
      children: [
        if (note != null && note!.isNotEmpty)
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Padding(
              padding: const EdgeInsets.only(left: 1),
              child: Text(
                note!,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.accentText),
              ),
            ),
          ),
      ],
    ),
    maxLines: 1,
    softWrap: false,
  );
}
