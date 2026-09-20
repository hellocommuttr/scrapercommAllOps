import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'preference_rows_model.dart';

/// The mockups' "Preferences" group, shared by Profile and Edit Profile: Transport
/// preferences, Default depart time, Notifications and Accessibility.
class PreferenceRows extends StackedView<PreferenceRowsModel> {
  const PreferenceRows({super.key, this.transportTitle = 'Transport preferences'});

  /// Profile says "Transport preferences"; Edit Profile says "Preferred transport modes".
  final String transportTitle;

  @override
  Widget builder(BuildContext context, PreferenceRowsModel viewModel, Widget? child) => NavGroup(
    children: [
      NavRow(
        icon: Icons.directions_bus_outlined,
        title: transportTitle,
        subtitle: viewModel.transportSummary,
        onTap: () => showTransportPreferencesSheet(context),
      ),
      NavRow(
        icon: Icons.schedule_rounded,
        title: 'Default depart time',
        subtitle: viewModel.departSummary,
        onTap: () => showDefaultDepartSheet(context),
      ),
      NavRow(
        icon: Icons.notifications_none_rounded,
        title: 'Notifications',
        subtitle: 'Journey updates, disruptions and more',
        onTap: viewModel.openNotifications,
      ),
      NavRow(
        icon: Icons.accessibility_new_rounded,
        title: 'Accessibility',
        subtitle: 'Set your accessibility preferences',
        onTap: () => showAccessibilitySheet(context),
      ),
    ],
  );

  @override
  PreferenceRowsModel viewModelBuilder(BuildContext context) => PreferenceRowsModel();

  @override
  void onViewModelReady(PreferenceRowsModel viewModel) => viewModel.init();
}

// ---------------------------------------------------------------- sheets

Future<void> _sheet(BuildContext context, Widget Function(BuildContext, PreferenceRowsModel) body) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ViewModelBuilder<PreferenceRowsModel>.reactive(
        viewModelBuilder: PreferenceRowsModel.new,
        onViewModelReady: (vm) => vm.init(),
        builder: (context, vm, _) => SafeArea(
          child: SingleChildScrollView(padding: const EdgeInsets.only(bottom: 16), child: body(context, vm)),
        ),
      ),
    );

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 14, color: context.colors.muted)),
      ],
    ),
  );
}

/// Operator checkboxes; at least one stays on.
Future<void> showTransportPreferencesSheet(BuildContext context) => _sheet(
  context,
  (context, vm) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SheetHeader(
        title: 'Transport preferences',
        subtitle: 'Searches start with these operators switched on. Keep at least one.',
      ),
      for (final o in vm.operators)
        CheckboxListTile(
          value: vm.isSelected(o),
          onChanged: vm.canToggle(o) ? (on) => vm.toggleOperator(o, on ?? false) : null,
          secondary: Icon(transitIcon(o)),
          title: Text(o.name),
          subtitle: Text(
            vm.canToggle(o) ? (o.isTrain ? 'Trains' : 'Buses') : 'At least one operator stays on',
            style: TextStyle(color: context.colors.muted),
          ),
        ),
    ],
  ),
);

/// "Depart now" or a fixed time for new searches.
Future<void> showDefaultDepartSheet(BuildContext context) => _sheet(context, (context, vm) {
  final minutes = vm.defaultDepartMinutes;
  final accent = context.colors.accentText;
  Future<void> pick() async {
    final initial = minutes == null ? TimeOfDay.now() : TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    final t = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Default depart time',
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (t != null) await vm.setDefaultDepartMinutes(t.hour * 60 + t.minute);
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SheetHeader(title: 'Default depart time', subtitle: 'New searches start from this time.'),
      ListTile(
        leading: const Icon(Icons.bolt_rounded),
        title: const Text('Depart now'),
        selected: minutes == null,
        selectedColor: accent,
        trailing: minutes == null ? Icon(Icons.check_rounded, color: accent) : null,
        onTap: () => vm.setDefaultDepartMinutes(null),
      ),
      ListTile(
        leading: const Icon(Icons.schedule_rounded),
        title: Text(minutes == null ? 'Pick a time' : 'Depart at ${PreferenceRowsModel.formatDepart(minutes)}'),
        subtitle: Text(
          minutes == null ? 'Always search from the same time' : 'Tap to change the time',
          style: TextStyle(color: context.colors.muted),
        ),
        selected: minutes != null,
        selectedColor: accent,
        trailing: minutes != null ? Icon(Icons.check_rounded, color: accent) : null,
        onTap: pick,
      ),
    ],
  );
});

/// Larger text, bold text and reduced motion. These apply across the whole app.
Future<void> showAccessibilitySheet(BuildContext context) => _sheet(context, (context, vm) {
  final scale = vm.textScale;
  final label = '${scale.toStringAsFixed(1)}×';
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SheetHeader(title: 'Accessibility', subtitle: 'These settings apply across Commuttr.'),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Row(
          children: [
            const ExcludeSemantics(child: Icon(Icons.text_increase_rounded)),
            const SizedBox(width: 16),
            const Expanded(child: Text('Larger text', style: TextStyle(fontSize: 16))),
            Text(label, style: TextStyle(color: context.colors.muted)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Slider(
          value: scale,
          min: PreferenceRowsModel.minTextScale,
          max: PreferenceRowsModel.maxTextScale,
          divisions: 6,
          label: label,
          semanticFormatterCallback: (v) => 'Text size ${v.toStringAsFixed(1)} times',
          onChanged: vm.setTextScale,
        ),
      ),
      SwitchListTile(
        secondary: const Icon(Icons.format_bold_rounded),
        title: const Text('Bold text'),
        subtitle: Text('Heavier text that is easier to read', style: TextStyle(color: context.colors.muted)),
        value: vm.boldText,
        onChanged: vm.setBoldText,
      ),
      SwitchListTile(
        secondary: const Icon(Icons.motion_photos_off_outlined),
        title: const Text('Reduce motion'),
        subtitle: Text('Fewer animations', style: TextStyle(color: context.colors.muted)),
        value: vm.reduceMotion,
        onChanged: vm.setReduceMotion,
      ),
    ],
  );
});
