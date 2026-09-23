import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../core/config.dart';
import '../../../services/support_service.dart';

/// Report an issue (SPEC §5.16): pick a category, describe it, see the exact report,
/// then hand it to the mail app. Nothing is sent by the app itself.
class ReportIssueViewModel extends BaseViewModel {
  ReportIssueViewModel({ReportContext? report})
    : reportContext = report ?? const ReportContext(),
      // Opened from a trip, the most likely problem is the time; the commuter can change it.
      _category = report?.rideKey != null || report?.boardTime != null ? IssueCategory.busDidNotCome : null;

  final _support = locator<SupportService>();
  final _nav = locator<NavigationService>();

  /// What the commuter was looking at when they tapped "Report a problem".
  final ReportContext reportContext;

  /// Owned here because the view is stateless.
  final descriptionController = TextEditingController();

  IssueCategory? _category;
  String? _report;
  String? _reportId;
  bool _mailOpened = false;
  bool _mailFailed = false;

  IssueCategory? get category => _category;

  /// The exact text that will be sent; non-null once the commuter taps "Review report".
  String? get report => _report;
  bool get reviewing => _report != null;
  bool get mailOpened => _mailOpened;
  bool get mailFailed => _mailFailed;
  bool get canReview => _category != null && !isBusy;
  bool get hasTripDetails =>
      reportContext.fromName != null || reportContext.routeLabel != null || reportContext.rideKey != null;
  String get supportEmail => AppConfig.supportEmail;
  String get subject =>
      'Commuttr report${_reportId == null ? '' : ' $_reportId'}: ${_category == null ? '' : labelFor(_category!)}';

  /// The wording shown for each category. Commuttr covers buses and trains, so the
  /// labels name both; the enum itself lives in SupportService.
  static String labelFor(IssueCategory c) => switch (c) {
    IssueCategory.busDidNotCome => "The bus or train didn't come / times are wrong",
    _ => c.label,
  };

  String get descriptionHint => switch (_category) {
    IssueCategory.busDidNotCome =>
      'Which stop or station, and what time did you expect the bus or train? What happened instead?',
    // Matched by name so the hint is ready as soon as a fare category is added to the enum.
    final IssueCategory c when c.name == 'wrongFare' =>
      'Which journey, what fare did Commuttr show, and what fare is right (and where did you see it)?',
    IssueCategory.wrongStop => 'Which stop or station, and where should it be?',
    IssueCategory.appProblem => 'What were you trying to do, and what went wrong?',
    IssueCategory.suggestion => 'What would make Commuttr better for you?',
    _ => 'Tell us what happened',
  };

  void selectCategory(IssueCategory? c) {
    _category = c;
    rebuildUi();
  }

  Future<void> review() async {
    final c = _category;
    if (c == null) return;
    await runBusyFuture(() async {
      _report = await _support.buildReport(c, descriptionController.text, reportContext);
      // buildReport puts "Report ID: <id>" on the first line.
      final first = _report!.split('\n').first;
      _reportId = first.startsWith('Report ID: ') ? first.substring('Report ID: '.length).trim() : null;
      _mailOpened = false;
      _mailFailed = false;
    }());
  }

  void edit() {
    _report = null;
    _reportId = null;
    _mailFailed = false;
    _mailOpened = false;
    rebuildUi();
  }

  Future<void> openEmail() async {
    final r = _report;
    if (r == null) return;
    bool ok;
    try {
      ok = await _support.emailSupport(subject, r);
    } catch (_) {
      ok = false;
    }
    _mailOpened = ok;
    _mailFailed = !ok;
    rebuildUi();
  }

  /// Copies subject and report together, so pasting into any mail app gives us both.
  Future<void> copyReport() =>
      Clipboard.setData(ClipboardData(text: 'To: ${AppConfig.supportEmail}\nSubject: $subject\n\n${_report ?? ''}'));

  Future<void> copyAddress() => Clipboard.setData(const ClipboardData(text: AppConfig.supportEmail));

  Future<bool> openGoldenArrow() => _open(AppConfig.goldenArrowUrl);

  Future<bool> openMetrorail() => _open(AppConfig.metrorailUrl);

  Future<bool> openMyCiti() => _open('https://www.myciti.org.za');

  Future<bool> _open(String url) async {
    try {
      return await _support.openUrl(url);
    } catch (_) {
      return false;
    }
  }

  void done() => _nav.back();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
