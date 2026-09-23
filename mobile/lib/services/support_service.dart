import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app.locator.dart';
import '../core/config.dart';
import '../core/service_day.dart';
import '../data/db/app_database.dart';
import 'cached_api_service.dart';
import 'favourites_service.dart';
import 'inbox_service.dart';
import 'planner_service.dart';
import 'reference_data_service.dart';
import 'reminder_service.dart';
import 'settings_service.dart';

/// What a problem report is about, so support can reproduce it without an account.
class ReportContext {
  const ReportContext({
    this.fromName,
    this.fromId,
    this.toName,
    this.toId,
    this.serviceDate,
    this.dayType,
    this.routeLabel,
    this.timetableNumber,
    this.rideKey,
    this.boardTime,
    this.pdfUrl,
    this.fromCache,
    this.fetchedAt,
    this.errorCode,
  });

  final String? fromName;
  final int? fromId;
  final String? toName;
  final int? toId;
  final String? serviceDate;
  final String? dayType;
  final String? routeLabel;
  final String? timetableNumber;
  final String? rideKey;
  final String? boardTime;
  final String? pdfUrl;
  final bool? fromCache;
  final DateTime? fetchedAt;
  final String? errorCode;
}

enum IssueCategory {
  busDidNotCome('The bus or train didn\'t come / times are wrong'),
  wrongFare('A fare is wrong'),
  wrongStop('A stop is missing or in the wrong place'),
  appProblem('Something in the app isn\'t working'),
  suggestion('A suggestion'),
  other('Something else');

  const IssueCategory(this.label);
  final String label;
}

/// Help, reports, sharing and the commuter's data (export, import, erase).
class SupportService {
  SupportService({SettingsService? settings}) : _settings = settings ?? locator<SettingsService>();

  final SettingsService _settings;

  Future<String> appVersion() async {
    try {
      final p = await PackageInfo.fromPlatform();
      return '${p.version}+${p.buildNumber}';
    } catch (_) {
      return 'unknown';
    }
  }

  String get platformName => kIsWeb ? 'web' : defaultTargetPlatform.name;

  /// The report body, shown to the commuter in full before anything is sent. No
  /// location is included — only the stops they searched between.
  Future<String> buildReport(IssueCategory category, String description, ReportContext ctx) async {
    final id =
        'CT-${DateTime.now().toUtc().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}'
        '${Random().nextInt(1296).toRadixString(36).toUpperCase().padLeft(2, '0')}';
    final lines = <String>[
      'Report ID: $id',
      'Category: ${category.label}',
      '',
      description.trim().isEmpty ? '(no description)' : description.trim(),
      '',
      '--- Details for Commuttr support ---',
      'App version: ${await appVersion()} ($platformName)',
      'Timetable data: ${_settings.dataVersion ?? 'unknown'}',
      'Last refreshed: ${_settings.lastRefresh?.toLocal().toString() ?? 'never (bundled data)'}',
      'Reported at (Cape Town): ${const SastClock().wallClock.toString().substring(0, 16)}',
      if (ctx.fromName != null) 'From: ${ctx.fromName}${ctx.fromId != null ? ' (stop ${ctx.fromId})' : ''}',
      if (ctx.toName != null) 'To: ${ctx.toName}${ctx.toId != null ? ' (stop ${ctx.toId})' : ''}',
      if (ctx.serviceDate != null) 'Travel date: ${ctx.serviceDate} (${ctx.dayType ?? ''})',
      if (ctx.routeLabel != null) 'Route: ${ctx.routeLabel} [${ctx.timetableNumber ?? ''}]',
      if (ctx.boardTime != null) 'Scheduled departure: ${ctx.boardTime}',
      if (ctx.rideKey != null) 'Ride: ${ctx.rideKey}',
      if (ctx.pdfUrl != null) 'Official timetable: ${ctx.pdfUrl}',
      if (ctx.fromCache != null) 'Shown from saved data: ${ctx.fromCache! ? 'yes' : 'no'}',
      if (ctx.fetchedAt != null) 'Data fetched: ${ctx.fetchedAt!.toLocal().toString().substring(0, 16)}',
      if (ctx.errorCode != null) 'Error: ${ctx.errorCode}',
    ];
    return lines.join('\n');
  }

  /// Opens the mail app addressed to Commuttr support. Returns false if none is available.
  Future<bool> emailSupport(String subject, String body) => launchUrl(
    Uri(scheme: 'mailto', path: AppConfig.supportEmail, query: _encodeQuery({'subject': subject, 'body': body})),
  );

  String _encodeQuery(Map<String, String> params) =>
      params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');

  Future<bool> openUrl(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  Future<bool> call(String number) => launchUrl(Uri(scheme: 'tel', path: number));

  Future<void> shareText(String text, {String? subject}) =>
      SharePlus.instance.share(ShareParams(text: text, subject: subject));

  Future<void> shareApp() => shareText(
    'I use Commuttr to check Golden Arrow, MyCiTi and Metrorail times in Cape Town. '
    'It works offline once a trip has been looked up.\n\n'
    'Get it here: ${AppConfig.shareUrl}',
    subject: 'Commuttr: bus and train times for Cape Town',
  );

  // ---------------------------------------------------------------- the commuter's data

  /// Everything the commuter created, as JSON: planner, favourites, history, settings.
  Future<String> exportData() async {
    final planner = await locator<PlannerService>().exportRows();
    final favourites = await locator<FavouritesService>().exportAll();
    return const JsonEncoder.withIndent(' ').convert({
      'format': 'commuttr-backup',
      'version': 1,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'planner': planner,
      ...favourites,
      'settings': _settings.all,
    });
  }

  /// Merge a backup into this device. Throws [FormatException] on a file that isn't one.
  Future<void> importData(String text) async {
    final j = jsonDecode(text);
    if (j is! Map<String, dynamic> || j['format'] != 'commuttr-backup') {
      throw const FormatException('This is not a Commuttr backup file.');
    }
    await locator<PlannerService>().importRows(((j['planner'] as List?) ?? const []).cast<Map<String, dynamic>>());
    await locator<FavouritesService>().importAll(j);
    final settings = (j['settings'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ?? {};
    settings.remove('data_version');
    settings.remove('active_journey');
    await _settings.importAll(settings);
  }

  /// Download the latest stops and routes, then drop saved searches so they are fetched
  /// fresh. Nothing is cleared unless the download worked, so a failed refresh offline
  /// never leaves the commuter with less than they had. Keeps the planner, and keeps
  /// pinned responses (the commute, planner trips). Returns whether it succeeded.
  Future<bool> refreshTimetableData() async {
    await locator<ReferenceDataService>().seedIfNeeded();
    final ok = await locator<ReferenceDataService>().refresh();
    if (!ok) return false;
    await locator<CachedApiService>().clearUnpinned();
    await locator<InboxService>().post(
      InboxKind.update,
      'Timetable data refreshed',
      'Stops and routes are up to date. Search your trips again while you have signal to save them for offline.',
    );
    return true;
  }

  /// Share the backup as a `.json` file, so it can be picked again with "Import backup".
  Future<void> shareBackupFile() async {
    final json = await exportData();
    final day = const SastClock().today.iso;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(utf8.encode(json), mimeType: 'application/json', name: 'commuttr-backup-$day.json')],
        fileNameOverrides: ['commuttr-backup-$day.json'],
        subject: 'Commuttr backup',
      ),
    );
  }

  /// Delete everything on this device and start again.
  Future<void> eraseEverything() async {
    await locator<ReminderService>().cancelAll();
    await locator<AppDatabase>().eraseEverything();
    _settings.clearMemory();
    await _settings.load();
    await locator<ReferenceDataService>().seedIfNeeded();
  }
}
