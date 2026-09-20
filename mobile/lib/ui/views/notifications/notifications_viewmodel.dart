import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/service_day.dart';
import '../../../data/db/app_database.dart';
import '../../../services/inbox_service.dart';

/// The tabs of the inbox: "Updates" are timetable refreshes and info messages, "Alerts" are reminders.
enum InboxFilter {
  all('All'),
  updates('Updates'),
  alerts('Alerts');

  const InboxFilter(this.label);
  final String label;

  bool accepts(InboxMessage m) => switch (this) {
    InboxFilter.all => true,
    InboxFilter.updates => m.kind == InboxKind.update.name || m.kind == InboxKind.info.name,
    InboxFilter.alerts => m.kind == InboxKind.reminder.name,
  };
}

/// A day heading and the messages under it.
class InboxGroup {
  const InboxGroup(this.label, this.messages);
  final String label;
  final List<InboxMessage> messages;
}

/// In-app notifications (SPEC §5.17). Messages are written by the app on this phone;
/// there is no push or disruption feed behind them.
class NotificationsViewModel extends BaseViewModel {
  NotificationsViewModel({SastClock clock = const SastClock()}) : _clock = clock;

  static const today = 'Today';
  static const yesterday = 'Yesterday';
  static const earlier = 'Earlier';

  final _inbox = locator<InboxService>();
  final _nav = locator<NavigationService>();
  final SastClock _clock;

  List<InboxMessage> _messages = const [];

  bool get hasUnread => _messages.any((m) => !m.isRead);

  int count(InboxFilter filter) => _messages.where(filter.accepts).length;

  Future<void> load() => runBusyFuture(_reload());

  Future<void> _reload() async {
    _messages = await _inbox.all();
    rebuildUi();
  }

  /// Cape Town wall-clock time for a message, matching the rest of the app (SPEC §3).
  /// Like [SastClock.wallClock], a UTC-flagged DateTime whose fields read as SAST
  /// (fixed UTC+2 — South Africa has no daylight saving).
  DateTime wallTime(InboxMessage m) =>
      DateTime.fromMillisecondsSinceEpoch(m.createdAt, isUtc: true).add(const Duration(hours: 2));

  /// Messages for [filter], grouped Today / Yesterday / Earlier, newest first.
  List<InboxGroup> groups(InboxFilter filter) {
    final wallNow = _clock.wallClock;
    final todayDate = DateTime.utc(wallNow.year, wallNow.month, wallNow.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));
    final buckets = <String, List<InboxMessage>>{today: [], yesterday: [], earlier: []};
    for (final m in _messages.where(filter.accepts)) {
      final t = wallTime(m);
      final day = DateTime.utc(t.year, t.month, t.day);
      final key = !day.isBefore(todayDate) ? today : (day == yesterdayDate ? yesterday : earlier);
      buckets[key]!.add(m);
    }
    return [
      for (final e in buckets.entries)
        if (e.value.isNotEmpty) InboxGroup(e.key, e.value),
    ];
  }

  /// Opening a message marks it read.
  Future<void> open(InboxMessage m) async {
    if (m.isRead) return;
    _messages = [for (final x in _messages) x.id == m.id ? x.copyWith(isRead: true) : x];
    rebuildUi();
    await _inbox.markRead(m.id);
  }

  Future<void> markAllRead() async {
    _messages = [for (final x in _messages) x.copyWith(isRead: true)];
    rebuildUi();
    await _inbox.markAllRead();
  }

  /// Removed from the list first so a swiped-away tile never reappears mid-animation.
  Future<void> delete(InboxMessage m) async {
    _messages = _messages.where((x) => x.id != m.id).toList();
    rebuildUi();
    await _inbox.delete(m.id);
  }

  Future<void> openPreferences() => _nav.navigateToPreferencesView();
}
