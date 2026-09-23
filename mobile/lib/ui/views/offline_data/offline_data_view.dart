import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../services/shell_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/common.dart';
import '../profile/page_layout.dart';
import '../profile/profile_widgets.dart';
import 'offline_data_viewmodel.dart';

class OfflineDataView extends StackedView<OfflineDataViewModel> {
  const OfflineDataView({super.key});

  @override
  Widget builder(BuildContext context, OfflineDataViewModel viewModel, Widget? child) {
    final vm = viewModel;

    /// Runs an action and shows the message it returns, if any.
    Future<void> run(Future<String?> Function() action) async {
      final messenger = ScaffoldMessenger.of(context);
      final message = await action();
      if (message != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    }

    Widget spinner(String key) => vm.busy(key)
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
        : Icon(Icons.chevron_right, color: context.colors.muted);

    final anyBusy = vm.isBusy || vm.anyObjectsBusy;

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
      body: SafeArea(
        bottom: false,
        child: ConstrainedListView(
          top: 0,
          children: [
            const PageHeader(
              title: 'Privacy & data',
              subtitle: 'Everything stays on this phone. Back it up, move it or erase it.',
              showBack: true,
            ),
            const SizedBox(height: 8),
            const OfflineBanner(),
            if (vm.isWeb)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: InfoBanner(
                  tone: BannerTone.warning,
                  message: "Clearing your browser's site data erases your planner. Export a backup to keep it.",
                ),
              ),
            const SectionHeader("What's saved on this device", padding: EdgeInsets.fromLTRB(16, 12, 8, 8)),
            NavGroup(
              children: [
                NavRow(icon: Icons.event_available_outlined, title: 'Timetable snapshot', subtitle: vm.snapshotDate),
                NavRow(icon: Icons.update_rounded, title: 'Stops and routes', subtitle: vm.lastRefreshed),
                NavRow(icon: Icons.place_outlined, title: 'Stops saved', subtitle: vm.stopsLabel),
                NavRow(
                  icon: Icons.history_rounded,
                  title: 'Saved searches',
                  subtitle: '${vm.cacheLabel} · trips and timetables you opened',
                ),
              ],
            ),
            const SectionHeader('What works offline'),
            const Padding(padding: pagePadding, child: _OfflineExplainer()),
            const SectionHeader('Timetables'),
            NavGroup(
              children: [
                NavRow(
                  icon: Icons.sync_rounded,
                  title: 'Refresh timetable data',
                  subtitle: 'Get the latest stops and routes. Keeps your planner.',
                  trailing: spinner(OfflineDataViewModel.refreshKey),
                  onTap: anyBusy ? null : () => run(vm.refresh),
                ),
              ],
            ),
            const SectionHeader('Backup'),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: InfoBanner(
                icon: Icons.backup_outlined,
                message:
                    'A backup holds your planner, favourites, search history and settings. '
                    'Use it to move to a new phone, because Commuttr has no accounts.',
              ),
            ),
            NavGroup(
              children: [
                NavRow(
                  icon: Icons.upload_outlined,
                  title: 'Export backup',
                  subtitle: 'Share or copy it as text',
                  trailing: spinner(OfflineDataViewModel.exportKey),
                  onTap: anyBusy ? null : () => _exportSheet(context, vm, run),
                ),
                NavRow(
                  icon: Icons.download_outlined,
                  title: 'Import backup',
                  subtitle: 'From a .json file or pasted text',
                  trailing: spinner(OfflineDataViewModel.importKey),
                  onTap: anyBusy ? null : () => _importSheet(context, vm, run),
                ),
              ],
            ),
            const SectionHeader('Clear'),
            NavGroup(
              children: [
                NavRow(
                  icon: Icons.manage_search_rounded,
                  title: 'Clear search history',
                  subtitle: 'Recent and frequent searches',
                  onTap: anyBusy ? null : () => run(vm.clearHistory),
                ),
                NavRow(
                  icon: Icons.delete_forever_outlined,
                  title: 'Erase everything',
                  subtitle: 'Planner, favourites, history, notifications and settings',
                  destructive: true,
                  trailing: vm.busy(OfflineDataViewModel.eraseKey) ? spinner(OfflineDataViewModel.eraseKey) : null,
                  onTap: anyBusy ? null : () => run(vm.eraseEverything),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportSheet(
    BuildContext context,
    OfflineDataViewModel vm,
    Future<void> Function(Future<String?> Function()) run,
  ) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetTitle('Export backup'),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share backup'),
              subtitle: const Text('Send it to yourself, e.g. by WhatsApp or email'),
              onTap: () => Navigator.pop(context, 'share'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy to clipboard'),
              subtitle: const Text('Paste it into a note to keep it'),
              onTap: () => Navigator.pop(context, 'copy'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'share') await run(vm.shareBackup);
    if (choice == 'copy') await run(vm.copyBackup);
  }

  Future<void> _importSheet(
    BuildContext context,
    OfflineDataViewModel vm,
    Future<void> Function(Future<String?> Function()) run,
  ) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetTitle('Import backup'),
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: const Text('Choose a backup file'),
              subtitle: const Text('The .json file you saved from Commuttr'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
            ListTile(
              leading: const Icon(Icons.content_paste_rounded),
              title: const Text('Paste backup text'),
              subtitle: const Text('The text you shared or copied from Commuttr'),
              onTap: () => Navigator.pop(context, 'paste'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'file') await run(vm.importFromFile);
    if (choice == 'paste' && context.mounted) {
      final text = await showDialog<String>(context: context, builder: (_) => const _PasteDialog());
      if (text != null) await run(() => vm.importText(text));
    }
  }

  @override
  OfflineDataViewModel viewModelBuilder(BuildContext context) => OfflineDataViewModel();

  @override
  void onViewModelReady(OfflineDataViewModel viewModel) => viewModel.init();
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Semantics(header: true, child: Text(title, style: context.text.titleMedium)),
    ),
  );
}

/// SPEC §4 in plain words.
class _OfflineExplainer extends StatelessWidget {
  const _OfflineExplainer();

  static const _works = [
    'Stop search, nearby stops, routes and timetables',
    'Any search, trip or timetable you opened before (marked "Saved")',
    'Your planner, favourites, recent searches and profile',
    'Trip details and "On my trip" for planned journeys',
    'Reminders on Android and iOS, even with the app closed',
  ];

  static const _needs = [
    'A new search between stops you haven\'t searched before',
    'Searching for a place or address',
    'Maps',
  ];

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Works without signal', style: context.text.titleSmall),
        const SizedBox(height: 8),
        for (final line in _works)
          _Bullet(icon: Icons.check_circle_outline_rounded, color: context.colors.success, text: line),
        const SizedBox(height: 14),
        Text('Needs a connection', style: context.text.titleSmall),
        const SizedBox(height: 8),
        for (final line in _needs) _Bullet(icon: Icons.wifi_rounded, color: context.colors.muted, text: line),
      ],
    ),
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Icon(icon, size: 18, color: color)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: context.text.bodyMedium)),
      ],
    ),
  );
}

/// A text field to paste a backup into, for when a file isn't handy.
class _PasteDialog extends StatefulWidget {
  const _PasteDialog();

  @override
  State<_PasteDialog> createState() => _PasteDialogState();
}

class _PasteDialogState extends State<_PasteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Paste backup text'),
    content: SizedBox(
      width: 480,
      child: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 6,
        maxLines: 10,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        decoration: const InputDecoration(hintText: '{"format": "commuttr-backup", …}', border: OutlineInputBorder()),
        onChanged: (_) => setState(() {}),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(
        onPressed: _controller.text.trim().isEmpty ? null : () => Navigator.pop(context, _controller.text),
        child: const Text('Import'),
      ),
    ],
  );
}
