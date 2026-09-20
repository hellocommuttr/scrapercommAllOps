import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../app/app.locator.dart';
import 'inbox_service.dart';
import 'planner_service.dart';

/// Phone notifications scheduled from the timetable: "time to leave" before a planned
/// bus or train, and "your stop is next" during a trip. Scheduled with the OS, so they fire with
/// the app closed — no push server involved.
///
/// Times are timetable times, not live ones; every notification says so.
/// On the web there is no reliable background scheduling, so reminders are unavailable.
class ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  late final tz.Location _capeTown;

  bool get isSupported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  static const _channel = AndroidNotificationDetails(
    'trip_reminders',
    'Trip reminders',
    channelDescription: 'Time-to-leave and get-off reminders, based on scheduled times',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
  );

  static const _details = NotificationDetails(
    android: _channel,
    iOS: DarwinNotificationDetails(interruptionLevel: InterruptionLevel.timeSensitive),
  );

  Future<void> init() async {
    if (!isSupported || _ready) return;
    tzdata.initializeTimeZones();
    _capeTown = tz.getLocation('Africa/Johannesburg');
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Ask for permission, at the moment the commuter first sets a reminder.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  /// Stable notification ids per journey: leave = even, get off = odd.
  int _id(String journeyId, int slot) => (journeyId.hashCode & 0x3fffffff) * 2 + slot;

  /// Schedule "time to leave" [leadMinutes] before departure. Returns false if the time
  /// has already passed or reminders are unavailable.
  Future<bool> scheduleLeave(PlannedJourney j, int leadMinutes) async {
    if (!isSupported) return false;
    await init();
    final at = j.departsAt.subtract(Duration(minutes: leadMinutes));
    if (!at.isAfter(DateTime.now())) return false;
    await _plugin.zonedSchedule(
      id: _id(j.id, 0),
      scheduledDate: tz.TZDateTime.from(at, _capeTown),
      notificationDetails: _details,
      // Inexact is accurate to a minute or two and needs no exact-alarm permission.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: 'Time to leave for the ${j.boardTime} ${j.operator.vehicle}',
      body:
          '${j.operator.name} ${j.routeNumber} from ${j.from.displayName} is scheduled at ${j.boardTime}. '
          'Scheduled time — the ${j.operator.vehicle} may be early or late.',
      payload: j.id,
    );
    await locator<InboxService>().post(
      InboxKind.reminder,
      'Reminder set',
      "We'll remind you $leadMinutes min before the ${j.boardTime} ${j.operator.vehicle} from ${j.from.displayName}.",
    );
    return true;
  }

  /// Schedule "your stop is next" at the scheduled time of the stop before [j]'s last.
  Future<bool> scheduleGetOff(PlannedJourney j) async {
    if (!isSupported) return false;
    final stops = j.trip?.stops ?? const [];
    final timed = stops.where((s) => s.minutes != null).toList();
    if (timed.length < 2) return false;
    await init();
    final prev = timed[timed.length - 2];
    var minutes = prev.minutes!;
    if (minutes < j.boardMinutes) minutes += 1440;
    final at = j.date.at(minutes);
    if (!at.isAfter(DateTime.now())) return false;
    await _plugin.zonedSchedule(
      id: _id(j.id, 1),
      scheduledDate: tz.TZDateTime.from(at, _capeTown),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: 'Your stop is coming up',
      body: 'Get ready to get off at ${j.to.displayName}. Based on the timetable — watch for your stop.',
      payload: j.id,
    );
    return true;
  }

  /// Whether a get-off reminder is still scheduled with the OS for this journey.
  Future<bool> hasGetOff(String journeyId) async {
    if (!isSupported) return false;
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((p) => p.id == _id(journeyId, 1));
  }

  Future<void> cancelFor(String journeyId) async {
    if (!isSupported || !_ready) return;
    await _plugin.cancel(id: _id(journeyId, 0));
    await _plugin.cancel(id: _id(journeyId, 1));
  }

  Future<void> cancelGetOff(String journeyId) async {
    if (!isSupported || !_ready) return;
    await _plugin.cancel(id: _id(journeyId, 1));
  }

  Future<void> cancelAll() async {
    if (!isSupported || !_ready) return;
    await _plugin.cancelAll();
  }
}
