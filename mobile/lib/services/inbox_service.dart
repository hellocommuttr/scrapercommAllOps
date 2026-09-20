import 'package:drift/drift.dart';
import 'package:stacked/stacked.dart';

import '../app/app.locator.dart';
import '../data/db/app_database.dart';

enum InboxKind { update, reminder, info }

/// The in-app notifications list. Written by the app itself (timetable data refreshed,
/// reminders set); there is no push service or disruption feed behind it.
class InboxService with ListenableServiceMixin {
  InboxService({AppDatabase? db}) : _db = db ?? locator<AppDatabase>() {
    listenToReactiveValues([_unread]);
  }

  final AppDatabase _db;
  final ReactiveValue<int> _unread = ReactiveValue(0);

  int get unreadCount => _unread.value;

  Future<void> refreshCount() async {
    _unread.value = await _db.inboxMessages.count(where: (m) => m.isRead.equals(false)).getSingle();
  }

  Future<List<InboxMessage>> all() =>
      (_db.select(_db.inboxMessages)..orderBy([(m) => OrderingTerm.desc(m.createdAt)])).get();

  Future<void> post(InboxKind kind, String title, String body) async {
    await _db
        .into(_db.inboxMessages)
        .insert(
          InboxMessagesCompanion.insert(
            kind: kind.name,
            title: title,
            body: body,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    await refreshCount();
    notifyListeners();
  }

  Future<void> markRead(int id) async {
    await (_db.update(
      _db.inboxMessages,
    )..where((m) => m.id.equals(id))).write(const InboxMessagesCompanion(isRead: Value(true)));
    await refreshCount();
  }

  Future<void> markAllRead() async {
    await _db.update(_db.inboxMessages).write(const InboxMessagesCompanion(isRead: Value(true)));
    await refreshCount();
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.inboxMessages)..where((m) => m.id.equals(id))).go();
    await refreshCount();
    notifyListeners();
  }
}
