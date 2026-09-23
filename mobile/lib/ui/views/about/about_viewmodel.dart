import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../core/config.dart';
import '../../../services/settings_service.dart';
import '../../../services/support_service.dart';
import '../legal/legal_content.dart';

/// About (SPEC §5.19): version, timetable snapshot, sources and attribution.
class AboutViewModel extends FutureViewModel<String> {
  final _support = locator<SupportService>();
  final _settings = locator<SettingsService>();
  final _nav = locator<NavigationService>();

  static const osmCopyrightUrl = 'https://www.openstreetmap.org/copyright';
  static const myCitiUrl = 'https://www.myciti.org.za';

  /// The app version, e.g. "1.0.0+12"; "…" until loaded.
  String get version => data ?? '…';

  @override
  Future<String> futureToRun() => _support.appVersion();

  String get dataSnapshot {
    final v = _settings.dataVersion;
    return v == null || v.isEmpty ? 'Not loaded yet' : v;
  }

  String get lastRefreshed {
    final t = _settings.lastRefresh;
    return t == null
        ? 'Never, so the timetables that came with the app are in use'
        : DateFormat('d MMM yyyy, HH:mm').format(t.toLocal());
  }

  Future<void> openOfflineData() => _nav.navigateToOfflineDataView();
  Future<void> openTerms() => _nav.navigateToLegalView(kind: LegalKind.terms);
  Future<void> openPrivacy() => _nav.navigateToLegalView(kind: LegalKind.privacy);

  Future<bool> openGoldenArrow() => _open(AppConfig.goldenArrowUrl);
  Future<bool> openMetrorail() => _open(AppConfig.metrorailUrl);
  Future<bool> openMyCiti() => _open(myCitiUrl);
  Future<bool> openOsm() => _open(osmCopyrightUrl);

  Future<bool> _open(String url) async {
    try {
      return await _support.openUrl(url);
    } catch (_) {
      return false;
    }
  }
}
