import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../services/shell_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/common.dart';
import '../profile/page_layout.dart';
import '../profile/profile_widgets.dart';
import 'preferences_viewmodel.dart';

class PreferencesView extends StackedView<PreferencesViewModel> {
  const PreferencesView({super.key});

  @override
  Widget builder(BuildContext context, PreferencesViewModel viewModel, Widget? child) {
    final vm = viewModel;
    final muted = context.colors.muted;

    /// Switches that need notification permission show a message when it is refused.
    ValueChanged<bool>? permissioned(Future<String?> Function(bool) set) => vm.remindersSupported
        ? (on) async {
            final messenger = ScaffoldMessenger.of(context);
            final message = await set(on);
            if (message != null) messenger.showSnackBar(SnackBar(content: Text(message)));
          }
        : null;

    const appOnly = 'Available in the Android and iOS apps.';

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
      body: SafeArea(
        bottom: false,
        child: ConstrainedListView(
          top: 0,
          children: [
            const PageHeader(
              title: 'Notifications',
              subtitle: 'Journey updates, disruptions and more.',
              showBack: true,
            ),
            const SectionHeader('Notifications', padding: EdgeInsets.fromLTRB(16, 16, 8, 8)),
            if (!vm.remindersSupported)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: InfoBanner(
                  message:
                      "Reminders need the Android or iOS app — a browser can't notify you when "
                      'Commuttr is closed.',
                ),
              ),
            _Group(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Journey reminders'),
                  subtitle: Text(
                    vm.remindersSupported ? 'A reminder before your planned journeys leave.' : appOnly,
                    style: TextStyle(color: muted),
                  ),
                  value: vm.journeyReminders,
                  onChanged: permissioned(vm.setJourneyReminders),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.pin_drop_outlined),
                  title: const Text('Get-off alerts'),
                  subtitle: Text(
                    vm.remindersSupported ? 'A notification one stop before yours, from the scheduled times.' : appOnly,
                    style: TextStyle(color: muted),
                  ),
                  value: vm.getOffAlerts,
                  onChanged: permissioned(vm.setGetOffAlerts),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.update_rounded),
                  title: const Text('Timetable updates'),
                  subtitle: Text('When new timetables are loaded or change.', style: TextStyle(color: muted)),
                  value: vm.timetableUpdates,
                  onChanged: vm.setTimetableUpdates,
                ),
                _Labelled(
                  title: 'Remind me before departure',
                  subtitle: 'Minutes before your bus is scheduled to leave.',
                  child: _Choice<int>(
                    label: 'Minutes before departure',
                    selected: vm.reminderLead,
                    onChanged: vm.setReminderLead,
                    options: [for (final m in PreferencesViewModel.leadChoices) (m, '$m', null)],
                    suffix: 'min',
                  ),
                ),
              ],
            ),
            const SectionHeader('Data saver'),
            _Group(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.map_outlined),
                  title: const Text('Show maps'),
                  subtitle: Text(
                    'Maps download images and use data. Timetables never need maps.',
                    style: TextStyle(color: context.colors.muted),
                  ),
                  value: vm.showMaps,
                  onChanged: vm.setShowMaps,
                ),
              ],
            ),
            const SectionHeader('Travel'),
            _Group(
              children: [
                _Labelled(
                  title: 'Arrive at my stop early',
                  subtitle: 'Shown on trip details. Buses can leave early — 5 to 10 min is safest.',
                  child: _Choice<int>(
                    label: 'Minutes early',
                    selected: vm.arriveEarly,
                    onChanged: vm.setArriveEarly,
                    options: [for (final m in PreferencesViewModel.earlyChoices) (m, m == 0 ? 'Off' : '$m min', null)],
                  ),
                ),
              ],
            ),
            const SectionHeader('Appearance'),
            Padding(
              padding: pagePadding,
              child: _Choice<ThemeMode>(
                label: 'Theme',
                selected: vm.themeMode,
                onChanged: vm.setThemeMode,
                options: const [
                  (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
                  (ThemeMode.light, 'Light', Icons.light_mode_outlined),
                  (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Changes are saved straight away, on this device only.',
                style: context.text.bodySmall?.copyWith(color: context.colors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  PreferencesViewModel viewModelBuilder(BuildContext context) => PreferencesViewModel();
}

/// A bordered card holding a few settings, separated by dividers.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: pagePadding,
    child: AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const Divider(height: 1), children[i]],
        ],
      ),
    ),
  );
}

/// A setting title and explanation above its control.
class _Labelled extends StatelessWidget {
  const _Labelled({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.titleSmall),
        const SizedBox(height: 2),
        Text(subtitle, style: context.text.bodySmall?.copyWith(color: context.colors.muted)),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

/// A full-width single-choice [SegmentedButton].
class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onChanged,
    required this.options,
    this.suffix,
  });

  final String label;
  final T selected;
  final ValueChanged<T> onChanged;
  final List<(T, String, IconData?)> options;

  /// Spoken after each option, e.g. "10 min", while the button only shows "10".
  final String? suffix;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    container: true,
    child: SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(minimumSize: const Size(0, 48)),
        segments: [
          for (final (value, text, icon) in options)
            ButtonSegment<T>(
              value: value,
              icon: icon == null ? null : Icon(icon),
              label: Text(text, semanticsLabel: suffix == null ? null : '$text $suffix'),
              tooltip: suffix == null ? null : '$text $suffix',
            ),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    ),
  );
}
