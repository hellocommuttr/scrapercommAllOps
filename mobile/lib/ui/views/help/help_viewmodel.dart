import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/config.dart';
import '../../../services/settings_service.dart';
import '../../../services/support_service.dart';
import '../../dialogs/onboarding/show_onboarding.dart';
import 'faq_entry.dart';
import 'help_topic_view.dart';

/// Help & Support: the bundled FAQ (works offline), the contact channels, and the routes
/// out — Golden Arrow, MyCiTi or Metrorail for anything about the buses and trains themselves,
/// SAPS in an emergency.
class HelpViewModel extends FutureViewModel<List<FaqEntry>> {
  final _support = locator<SupportService>();
  final _settings = locator<SettingsService>();
  final _nav = locator<NavigationService>();

  /// Owned here because the view is stateless; cleared by [clearSearch].
  final searchController = TextEditingController();

  String _query = '';

  String get query => _query;
  bool get searching => _query.trim().isNotEmpty;
  String get supportEmail => AppConfig.supportEmail;
  String get sapsNumber => AppConfig.sapsEmergency;
  String get supportHours => AppConfig.supportHours;
  String get supportPhone => AppConfig.supportPhone;
  bool get chatAvailable => AppConfig.supportChatUrl.isNotEmpty;
  bool get phoneAvailable => AppConfig.supportPhone.isNotEmpty;

  @override
  Future<List<FaqEntry>> futureToRun() async {
    final raw = await rootBundle.loadString('assets/content/faq.json');
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>().map(FaqEntry.fromJson).toList();
  }

  List<FaqEntry> get _all => data ?? const <FaqEntry>[];

  /// Search results across every topic.
  List<FaqEntry> get results => searching ? _all.where((e) => e.matches(_query.trim())).toList() : const [];

  List<FaqEntry> entriesFor(String topic) => _all.where((e) => e.topic == topic).toList();

  void search(String q) {
    _query = q;
    rebuildUi();
  }

  void clearSearch() {
    searchController.clear();
    _query = '';
    rebuildUi();
  }

  Future<void> openTopic(HelpTopic topic) async {
    await _nav.navigateToView(
      HelpTopicView(
        title: topic.title,
        subtitle: topic.subtitle,
        entries: entriesFor(topic.title),
        onReport: reportIssue,
      ),
    );
  }

  /// "Guides & tips": the app tour plus the "Using Commuttr" articles.
  Future<void> openGuides() async {
    await _nav.navigateToView(
      HelpTopicView(
        title: 'Guides & tips',
        subtitle: 'Helpful guides to help you get the most out of Commuttr',
        entries: entriesFor('Using Commuttr'),
        onTour: showOnboarding,
        onReport: reportIssue,
      ),
    );
  }

  /// Opens the mail app with a few device details that help us answer. Returns false
  /// when there is no mail app, so the view can offer the address to copy.
  Future<bool> emailUs() async {
    final body = [
      'Hi Commuttr,',
      '',
      '',
      '',
      '--- Device details (you can delete these) ---',
      'App version: ${await _support.appVersion()} (${_support.platformName})',
      'Timetable data: ${_settings.dataVersion ?? 'unknown'}',
    ].join('\n');
    return _safe(() => _support.emailSupport('Commuttr support', body));
  }

  Future<void> copySupportEmail() => Clipboard.setData(const ClipboardData(text: AppConfig.supportEmail));

  /// Only called when [chatAvailable].
  Future<bool> openChat() => _safe(() => _support.openUrl(AppConfig.supportChatUrl));

  /// Only called when [phoneAvailable].
  Future<bool> callUs() => _safe(() => _support.call(AppConfig.supportPhone));

  Future<void> reportIssue() => _nav.navigateToReportIssueView();

  Future<bool> openGoldenArrow() => _safe(() => _support.openUrl(AppConfig.goldenArrowUrl));

  Future<bool> openMetrorail() => _safe(() => _support.openUrl(AppConfig.metrorailUrl));

  Future<bool> openMyCiti() => _safe(() => _support.openUrl('https://www.myciti.org.za'));

  Future<bool> callSaps() => _safe(() => _support.call(AppConfig.sapsEmergency));

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// url_launcher can throw instead of returning false (e.g. no handler on some platforms).
  Future<bool> _safe(Future<bool> Function() f) async {
    try {
      return await f();
    } catch (_) {
      return false;
    }
  }
}
