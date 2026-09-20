import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../data/db/app_database.dart';
import '../../../services/inbox_service.dart';
import '../../../services/shell_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/common.dart';
import 'notifications_viewmodel.dart';

class NotificationsView extends StackedView<NotificationsViewModel> {
  const NotificationsView({super.key});

  @override
  Widget builder(BuildContext context, NotificationsViewModel viewModel, Widget? child) => DefaultTabController(
    length: InboxFilter.values.length,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: viewModel.hasUnread ? viewModel.markAllRead : null,
            child: const Text('Mark all as read'),
          ),
          const SizedBox(width: 4),
        ],
        bottom: _CountTabBar(viewModel: viewModel),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
      body: viewModel.isBusy
          ? const LoadingBlock()
          : TabBarView(
              children: [for (final f in InboxFilter.values) _InboxList(viewModel: viewModel, filter: f)],
            ),
    ),
  );

  @override
  NotificationsViewModel viewModelBuilder(BuildContext context) => NotificationsViewModel();

  @override
  void onViewModelReady(NotificationsViewModel viewModel) => viewModel.load();
}

/// "All (3) | Updates (2) | Alerts (1)": each tab carries a count badge, orange on the selected tab.
class _CountTabBar extends StatelessWidget implements PreferredSizeWidget {
  const _CountTabBar({required this.viewModel});

  final NotificationsViewModel viewModel;

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final c = context.colors;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => TabBar(
        tabs: [
          for (final (i, f) in InboxFilter.values.indexed)
            Tab(
              child: Semantics(
                label: '${f.label}, ${viewModel.count(f)}',
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(f.label, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: controller.index == i ? Brand.orangeDeep : c.infoSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: controller.index == i ? null : Border.all(color: c.cardBorder),
                      ),
                      child: Text(
                        '${viewModel.count(f)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: controller.index == i ? Colors.white : c.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InboxList extends StatelessWidget {
  const _InboxList({required this.viewModel, required this.filter});

  final NotificationsViewModel viewModel;
  final InboxFilter filter;

  @override
  Widget build(BuildContext context) {
    final groups = viewModel.groups(filter);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (groups.isEmpty)
              _empty()
            else
              for (final g in groups) ...[
                SectionHeader(g.label),
                Padding(
                  padding: pagePadding,
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < g.messages.length; i++) ...[
                          if (i > 0) const Divider(indent: 76),
                          _MessageTile(
                            message: g.messages[i],
                            time: _timeLabel(g.label, viewModel.wallTime(g.messages[i])),
                            onTap: () => _open(context, g.messages[i]),
                            onDelete: () => _delete(context, g.messages[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            const SizedBox(height: 24),
            _StayInTheLoop(onManage: viewModel.openPreferences),
          ],
        ),
      ),
    );
  }

  Widget _empty() => switch (filter) {
    InboxFilter.alerts => const EmptyState(
      icon: Icons.alarm_off_rounded,
      title: 'No alerts yet',
      message: 'When you set a reminder for a planned bus or train, a note about it appears here.',
    ),
    InboxFilter.updates => const EmptyState(
      icon: Icons.sync_rounded,
      title: 'No updates',
      message: "We'll note here when the app's timetable data is refreshed.",
    ),
    InboxFilter.all => const EmptyState(
      icon: Icons.notifications_none_rounded,
      title: "You're all caught up",
      message: 'Messages from Commuttr about reminders and timetable updates will appear here.',
    ),
  };

  /// "08:32" today, "Yesterday, 18:20", "23 May, 12:30" before that.
  static String _timeLabel(String group, DateTime t) => switch (group) {
    NotificationsViewModel.today => DateFormat('HH:mm').format(t),
    NotificationsViewModel.yesterday => 'Yesterday, ${DateFormat('HH:mm').format(t)}',
    _ => DateFormat('d MMM, HH:mm').format(t),
  };

  void _open(BuildContext context, InboxMessage m) {
    viewModel.open(m);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheet).height * 0.8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _IconCircle(kind: m.kind),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(m.title, style: sheet.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _fullTime(viewModel.wallTime(m)),
                  style: sheet.text.bodySmall?.copyWith(color: sheet.colors.muted),
                ),
                const SizedBox(height: 16),
                SelectableText(m.body, style: sheet.text.bodyLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(sheet).pop();
                        _delete(context, m);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      label: const Text('Delete'),
                    ),
                    const Spacer(),
                    FilledButton(onPressed: () => Navigator.of(sheet).pop(), child: const Text('Close')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fullTime(DateTime t) => DateFormat('EEEE d MMMM y, HH:mm').format(t);

  void _delete(BuildContext context, InboxMessage m) {
    viewModel.delete(m);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Notification deleted')));
  }
}

/// Round icon for a message's kind.
class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.kind});

  final String kind;

  IconData get _icon {
    if (kind == InboxKind.reminder.name) return Icons.alarm_rounded;
    if (kind == InboxKind.update.name) return Icons.sync_rounded;
    return Icons.info_outline_rounded;
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.surfaceContainerHighest),
      child: Icon(_icon, size: 20, color: context.colors.accentText),
    ),
  );
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, required this.time, required this.onTap, required this.onDelete});

  final InboxMessage message;
  final String time;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final unread = !message.isRead;
    return Dismissible(
      key: ValueKey<int>(message.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Semantics(
        button: true,
        label: '${unread ? 'Unread. ' : ''}${message.title}. ${message.body}. $time',
        excludeSemantics: true,
        customSemanticsActions: {const CustomSemanticsAction(label: 'Delete'): onDelete},
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 6, 14),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  child: unread
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: c.accentText, shape: BoxShape.circle),
                        )
                      : null,
                ),
                const SizedBox(width: 4),
                _IconCircle(kind: message.kind),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              message.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(time, style: TextStyle(fontSize: 12, color: c.muted)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: c.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right, color: c.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "🔔 Stay in the loop" with a red-outlined "Manage" that opens Preferences.
class _StayInTheLoop extends StatelessWidget {
  const _StayInTheLoop({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: pagePadding,
      child: AppCard(
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Icon(Icons.notifications_active_outlined, color: c.accentText, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stay in the loop', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    'Turn on push notifications to get real-time updates about your journeys.',
                    style: TextStyle(fontSize: 13, color: c.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onManage,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.accentText,
                side: BorderSide(color: c.accentText),
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text('Manage', semanticsLabel: 'Manage notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
