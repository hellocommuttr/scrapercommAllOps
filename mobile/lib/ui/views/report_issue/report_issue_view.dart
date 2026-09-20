import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../services/support_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../help/help_widgets.dart';
import 'report_issue_viewmodel.dart';

/// Two steps on one screen: write the report, then review exactly what will be sent.
/// Styled like Help & Support: large title with back arrow, bordered card groups,
/// orange accents and a full-width orange action.
class ReportIssueView extends StackedView<ReportIssueViewModel> {
  const ReportIssueView({super.key, this.report});

  final ReportContext? report;

  @override
  Widget builder(BuildContext context, ReportIssueViewModel viewModel, Widget? child) => PopScope(
    // Back from the review step returns to editing rather than losing the draft.
    canPop: !viewModel.reviewing,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) viewModel.edit();
    },
    child: Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: viewModel.reviewing ? _review(context, viewModel) : _form(context, viewModel),
            ),
          ),
        ),
      ),
    ),
  );

  List<Widget> _form(BuildContext context, ReportIssueViewModel vm) {
    final c = context.colors;
    return [
      const PushedHeader(title: 'Report an issue', subtitle: "Let us know if something isn't working."),
      const SizedBox(height: 16),
      Padding(
        padding: pagePadding,
        child: _OperatorNotice(
          onGoldenArrow: () => _openOperator(context, vm.openGoldenArrow, 'gabs.co.za'),
          onMyCiti: () => _openOperator(context, vm.openMyCiti, 'www.myciti.org.za'),
          onMetrorail: () => _openOperator(context, vm.openMetrorail, 'metrorail.co.za'),
        ),
      ),
      const HelpSectionTitle('What is it about?'),
      RadioGroup<IssueCategory>(
        groupValue: vm.category,
        onChanged: vm.selectCategory,
        child: GroupCard(
          indent: 16,
          children: [
            for (final cat in IssueCategory.values)
              RadioListTile<IssueCategory>(
                value: cat,
                activeColor: c.accentText,
                contentPadding: const EdgeInsets.only(left: 4, right: 16),
                title: Text(ReportIssueViewModel.labelFor(cat), style: const TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
      const HelpSectionTitle('Tell us more'),
      Padding(
        padding: pagePadding,
        child: TextField(
          controller: vm.descriptionController,
          minLines: 4,
          maxLines: 8,
          maxLength: 1000,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: vm.descriptionHint, labelText: 'Description (optional)'),
        ),
      ),
      if (vm.hasTripDetails)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: c.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Details of the trip you were looking at will be added for you.',
                  style: TextStyle(fontSize: 13, color: c.muted),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 20),
      Padding(
        padding: pagePadding,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: vm.canReview ? vm.review : null,
            child: vm.isBusy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('Review report'),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: pagePadding,
        child: Text(
          vm.category == null
              ? 'Choose what the report is about to continue.'
              : "Next you'll see everything that will be sent, before anything leaves your phone.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: c.muted),
        ),
      ),
    ];
  }

  List<Widget> _review(BuildContext context, ReportIssueViewModel vm) {
    final c = context.colors;
    return [
      const PushedHeader(title: 'Review report', subtitle: 'This is everything that will be sent to Commuttr.'),
      const SizedBox(height: 16),
      GroupCard(
        indent: 16,
        children: [
          _MetaRow(label: 'To', value: 'Commuttr support (${vm.supportEmail})'),
          _MetaRow(label: 'Subject', value: vm.subject),
        ],
      ),
      const SizedBox(height: 12),
      Padding(
        padding: pagePadding,
        child: Semantics(
          label: 'Report text',
          child: Container(
            constraints: const BoxConstraints(maxHeight: 360),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.cardBorder),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  vm.report ?? '',
                  style: context.text.bodySmall?.copyWith(fontFamily: 'monospace', height: 1.45),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      const Padding(
        padding: pagePadding,
        child: InfoBanner(
          icon: Icons.privacy_tip_outlined,
          message: 'This is everything that will be sent. Your location is not included.',
        ),
      ),
      const SizedBox(height: 16),
      if (vm.mailOpened)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: InfoBanner(
            icon: Icons.mark_email_read_outlined,
            message: 'Your email app should now be open. Press Send there to send the report to Commuttr.',
            actionLabel: 'Done',
            onAction: vm.done,
          ),
        ),
      if (vm.mailFailed) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: InfoBanner(
            tone: BannerTone.warning,
            message: "Couldn't open an email app. Copy the report and email it to ${vm.supportEmail}.",
          ),
        ),
        _wide(
          FilledButton.icon(
            onPressed: () => _copy(context, vm.copyReport, 'Report copied'),
            icon: const Icon(Icons.copy),
            label: const Text('Copy to clipboard'),
          ),
        ),
        const SizedBox(height: 8),
        _wide(
          OutlinedButton.icon(
            onPressed: () => _copy(context, vm.copyAddress, 'Email address copied'),
            icon: const Icon(Icons.alternate_email),
            label: Text('Copy ${vm.supportEmail}', overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(height: 8),
        _wide(TextButton(onPressed: vm.openEmail, child: const Text('Try the email app again'))),
      ] else
        _wide(
          FilledButton.icon(
            onPressed: vm.openEmail,
            icon: const Icon(Icons.mail_outline),
            label: const Text('Open email app'),
          ),
        ),
      const SizedBox(height: 8),
      _wide(TextButton(onPressed: vm.edit, child: const Text('Edit report'))),
    ];
  }

  Widget _wide(Widget child) => Padding(
    padding: pagePadding,
    child: SizedBox(width: double.infinity, child: child),
  );

  Future<void> _copy(BuildContext context, Future<void> Function() copy, String done) async {
    await copy();
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
  }

  Future<void> _openOperator(BuildContext context, Future<bool> Function() open, String site) async {
    final ok = await open();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Couldn't open a browser. Visit $site.")));
    }
  }

  @override
  ReportIssueViewModel viewModelBuilder(BuildContext context) => ReportIssueViewModel(report: report);
}

/// Who the report goes to, and where operator matters go instead.
class _OperatorNotice extends StatelessWidget {
  const _OperatorNotice({required this.onGoldenArrow, required this.onMyCiti, required this.onMetrorail});

  final VoidCallback onGoldenArrow;
  final VoidCallback onMyCiti;
  final VoidCallback onMetrorail;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: c.accentText),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reports go to the Commuttr team, not Golden Arrow, MyCiTi or Metrorail. For tickets, lost property, '
                  'complaints or service disruptions, contact the operator.',
                  style: TextStyle(fontSize: 13, height: 1.4, color: c.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: onGoldenArrow,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('gabs.co.za'),
              ),
              TextButton.icon(
                onPressed: onMyCiti,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('myciti.org.za'),
              ),
              TextButton.icon(
                onPressed: onMetrorail,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('metrorail.co.za'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: TextStyle(fontSize: 13, color: context.colors.muted)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}
