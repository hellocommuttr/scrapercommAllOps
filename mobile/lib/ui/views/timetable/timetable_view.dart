import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../route_detail/route_detail_view.dart' show operatorLegalName;
import 'timetable_grid.dart';
import 'timetable_viewmodel.dart';

String _date(String iso) {
  try {
    return formatDate(ServiceDate.parse(iso));
  } catch (_) {
    return iso;
  }
}

class TimetableView extends StackedView<TimetableViewModel> {
  const TimetableView({super.key, required this.timetableId, required this.title});

  final int timetableId;
  final String title;

  /// Text blocks stay readable on wide web; the grid may use more room.
  static const _textWidth = 720.0;
  static const _gridWidth = 1200.0;

  @override
  Widget builder(BuildContext context, TimetableViewModel viewModel, Widget? child) => Scaffold(
    appBar: AppBar(title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
    body: _body(context, viewModel),
  );

  Widget _constrained(Widget child, {double maxWidth = _textWidth}) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );

  Widget _body(BuildContext context, TimetableViewModel vm) {
    if (vm.isBusy && vm.detail == null) return const LoadingBlock(label: 'Loading timetable…');
    if (vm.problem != null) {
      return _constrained(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const OfflineBanner(),
            switch (vm.problem!) {
              TimetableLoadProblem.notSavedOffline => EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Not saved for offline',
                message:
                    'Not saved for offline. Connect once to view this timetable. '
                    'After that it stays on your phone.',
                actionLabel: 'Retry',
                onAction: vm.load,
              ),
              TimetableLoadProblem.failed => EmptyState(
                icon: Icons.error_outline,
                title: "Couldn't load this timetable",
                message: 'Something went wrong on our side. Try again in a moment.',
                actionLabel: 'Retry',
                onAction: vm.load,
              ),
            },
          ],
        ),
      );
    }
    final d = vm.detail!;
    final schedule = vm.schedule;
    final legend = vm.legend;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _constrained(const OfflineBanner()),
        if (vm.fromCache)
          _constrained(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: InfoBanner(
                tone: vm.stale ? BannerTone.warning : BannerTone.offline,
                icon: Icons.download_done_rounded,
                message: vm.stale
                    ? '${vm.savedLabel}. This copy is over a week old, '
                          '${vm.hasPdf ? 'check the official PDF' : 'connect to check for changes'}.'
                    : vm.savedLabel,
              ),
            ),
          ),
        _constrained(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _Header(
              detail: d,
              label: vm.timetableLabel,
              operator: vm.operator,
              onPdf: vm.hasPdf ? vm.openPdf : null,
            ),
          ),
        ),
        if (vm.schedules.isEmpty)
          _constrained(
            EmptyState(
              icon: Icons.table_rows_outlined,
              title: 'No times in this timetable',
              message: vm.hasPdf
                  ? 'We could not read times from this timetable. Open the official PDF instead.'
                  : 'We could not read times from this timetable. Check with ${vm.operator.name} before you travel.',
            ),
          )
        else ...[
          _constrained(const SectionHeader('Direction and day')),
          _constrained(
            Padding(
              padding: pagePadding,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < vm.schedules.length; i++)
                    ChoiceChip(
                      label: Text(_scheduleLabel(vm.schedules[i])),
                      selected: i == vm.selected,
                      onSelected: (_) => vm.select(i),
                      showCheckmark: false,
                      labelStyle: TextStyle(color: i == vm.selected ? Colors.white : null),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (schedule != null)
            _constrained(
              Padding(
                padding: pagePadding,
                child: schedule.noService
                    ? AppCard(
                        child: Row(
                          children: [
                            Icon(Icons.block, color: context.colors.muted),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No service. No ${vm.operator.vehicles} are scheduled in this direction on '
                                '${schedule.dayLabel.isEmpty ? 'this day' : schedule.dayLabel}.',
                              ),
                            ),
                          ],
                        ),
                      )
                    : schedule.trips.isEmpty || schedule.stops.isEmpty
                    ? const AppCard(child: Text('No times were published for this direction and day.'))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${schedule.trips.length} scheduled '
                            '${schedule.trips.length == 1 ? vm.operator.vehicle : vm.operator.vehicles}'
                            ' · scroll sideways for more',
                            style: context.text.bodySmall?.copyWith(color: context.colors.muted),
                          ),
                          const SizedBox(height: 8),
                          TimetableGrid(
                            key: ValueKey(schedule.id),
                            schedule: schedule,
                            operator: vm.operator,
                            legend: {for (final (code, text) in legend) code: text},
                          ),
                        ],
                      ),
              ),
              maxWidth: _gridWidth,
            ),
        ],
        if (legend.isNotEmpty) ...[
          _constrained(const SectionHeader('Footnotes')),
          _constrained(
            Padding(
              padding: pagePadding,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (code, text) in legend)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Semantics(
                          label: 'Footnote $code: $text',
                          excludeSemantics: true,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: code,
                                  style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.accentText),
                                ),
                                TextSpan(text: ' · $text'),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
        _constrained(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _Key(operator: vm.operator),
          ),
        ),
        _constrained(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ScheduledDisclaimer(operator: vm.operator),
          ),
        ),
        _constrained(
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text(
              'Commuttr is independent and not affiliated with ${operatorLegalName(vm.operator)}.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(color: context.colors.muted),
            ),
          ),
        ),
      ],
    );
  }

  static String _scheduleLabel(TimetableSchedule s) {
    final dir = titleCase(s.directionLabel);
    final day = s.dayLabel.isNotEmpty ? s.dayLabel : (DayType.fromApi(s.dayType)?.label ?? s.dayType);
    return dir.isEmpty ? day : '$dir · $day';
  }

  @override
  TimetableViewModel viewModelBuilder(BuildContext context) => TimetableViewModel(timetableId);

  @override
  void onViewModelReady(TimetableViewModel viewModel) => viewModel.load();
}

class _Header extends StatelessWidget {
  const _Header({required this.detail, required this.label, required this.operator, required this.onPdf});

  final TimetableDetail detail;
  final String label;
  final OperatorRef operator;

  /// Null when there is no PDF (train timetables).
  final VoidCallback? onPdf;

  @override
  Widget build(BuildContext context) {
    final info = detail.info;
    final muted = context.colors.muted;
    final from = info.effectiveFrom, to = info.effectiveTo;
    final validity = from == null && to == null
        ? "Timetable from ${operator.name}'s published schedule"
        : [if (from != null) 'Timetable valid from ${_date(from)}', if (to != null) 'until ${_date(to)}'].join(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.routeName.isNotEmpty)
          Semantics(header: true, child: Text(titleCase(detail.routeName), style: context.text.titleLarge)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TagChip(operator.name, icon: transitIcon(operator)),
            Text(label, style: context.text.bodyMedium),
            if (info.isPublicHoliday)
              TagChip('Public holiday', icon: Icons.event_outlined, color: context.colors.warning),
          ],
        ),
        const SizedBox(height: 4),
        Text(validity, style: context.text.bodyMedium?.copyWith(color: muted)),
        if (onPdf != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Official PDF'),
          ),
        ],
      ],
    );
  }
}

/// How to read the grid.
class _Key extends StatelessWidget {
  const _Key({required this.operator});

  final OperatorRef operator;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.muted;
    final style = context.text.bodySmall?.copyWith(color: muted);
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        Text.rich(
          TextSpan(
            style: style,
            children: [
              const TextSpan(
                text: 'via',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              TextSpan(text: ' = passes this ${operator.stopWord}, time not published'),
            ],
          ),
        ),
        Text('– = does not stop here', style: style),
      ],
    );
  }
}
