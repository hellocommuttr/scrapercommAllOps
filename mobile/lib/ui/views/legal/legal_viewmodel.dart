import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../core/config.dart';
import '../../../services/support_service.dart';
import 'legal_content.dart';

class LegalViewModel extends BaseViewModel {
  LegalViewModel(this.kind) : document = legalDocument(kind);

  final LegalKind kind;
  final LegalDocument document;

  final _support = locator<SupportService>();
  final _nav = locator<NavigationService>();

  String get supportEmail => AppConfig.supportEmail;

  /// Returns false when no mail app is available, so the view can offer the address.
  Future<bool> emailUs() async {
    try {
      return await _support.emailSupport('Commuttr — ${kind.title}', '');
    } catch (_) {
      return false;
    }
  }

  Future<void> copySupportEmail() => Clipboard.setData(const ClipboardData(text: AppConfig.supportEmail));

  /// "I understand": nothing is recorded, the page just closes.
  void understood() => _nav.back();
}
