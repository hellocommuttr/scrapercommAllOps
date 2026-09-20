import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/config.dart';
import '../../../services/shell_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/common.dart';
import '../help/help_widgets.dart';
import 'legal_content.dart';
import 'legal_viewmodel.dart';

/// Terms & Conditions or Privacy Policy, as in the mockup: intro, last-updated date, one
/// accordion card of numbered sections, the footer note and "I understand".
class LegalView extends StackedView<LegalViewModel> {
  const LegalView({super.key, required this.kind});

  final LegalKind kind;

  @override
  Widget builder(BuildContext context, LegalViewModel viewModel, Widget? child) {
    final doc = viewModel.document;
    final muted = context.colors.muted;
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                PushedHeader(title: kind.title, subtitle: doc.intro),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Last updated: $legalLastUpdated', style: TextStyle(fontSize: 13, color: muted)),
                      ),
                    ],
                  ),
                ),
                GroupCard(
                  indent: 0,
                  children: [
                    for (var i = 0; i < doc.sections.length; i++)
                      _SectionTile(
                        number: i + 1,
                        section: doc.sections[i],
                        initiallyExpanded: i == 0,
                        onEmail: () => _emailUs(context, viewModel),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: pagePadding,
                  child: InfoBanner(message: doc.footer),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: pagePadding,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: viewModel.understood, child: const Text('I understand')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _emailUs(BuildContext context, LegalViewModel vm) async {
    final ok = await vm.emailUs();
    if (ok || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Couldn't open an email app. Write to us at ${vm.supportEmail}."),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(label: 'Copy', onPressed: vm.copySupportEmail),
      ),
    );
  }

  @override
  LegalViewModel viewModelBuilder(BuildContext context) => LegalViewModel(kind);
}

/// One numbered section: orange title and ⌃ while open, plain title and ⌄ while closed.
class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.number,
    required this.section,
    required this.initiallyExpanded,
    required this.onEmail,
  });

  final int number;
  final LegalSection section;
  final bool initiallyExpanded;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accentText;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      textColor: accent,
      iconColor: accent,
      collapsedTextColor: onSurface,
      collapsedIconColor: onSurface,
      title: Semantics(
        header: true,
        child: Text('$number. ${section.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      children: [for (final p in section.paragraphs) _Paragraph(text: p, onEmail: onEmail)],
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.text, required this.onEmail});

  final String text;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 14, height: 1.5, color: context.colors.muted);
    final bullet = text.startsWith('• ');
    final body = bullet ? text.substring(2) : text;
    const email = AppConfig.supportEmail;
    final at = body.indexOf(email);

    Widget content;
    if (at < 0) {
      content = Text(body, style: style);
    } else {
      // The support address in orange; the whole paragraph is the tap target so it is
      // large enough to hit.
      content = Semantics(
        link: true,
        hint: 'Opens your email app',
        child: InkWell(
          onTap: onEmail,
          borderRadius: BorderRadius.circular(6),
          child: Text.rich(
            TextSpan(
              style: style,
              children: [
                TextSpan(text: body.substring(0, at)),
                TextSpan(
                  text: email,
                  style: TextStyle(
                    color: context.colors.accentText,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: context.colors.accentText,
                  ),
                ),
                TextSpan(text: body.substring(at + email.length)),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: bullet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 10),
                  child: Text('•', style: style.copyWith(color: context.colors.accentText)),
                ),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}
