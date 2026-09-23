import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../services/shell_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/common.dart';
import 'faq_entry.dart';
import 'help_viewmodel.dart';
import 'help_widgets.dart';

/// Help & Support, as in the mockup: search, Popular topics, Contact us, Other resources
/// and the safety card. The "we're not Golden Arrow, MyCiTi or Metrorail" routing lives in the
/// FAQ answers and the safety sheet.
class HelpView extends StackedView<HelpViewModel> {
  const HelpView({super.key});

  @override
  Widget builder(BuildContext context, HelpViewModel viewModel, Widget? child) => Scaffold(
    bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
    body: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const PushedHeader(
                title: 'Help & Support',
                subtitle: "We're here to help. Find answers or get in touch with our team.",
                trailing: _SupportIllustration(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: pagePadding,
                child: TextField(
                  controller: viewModel.searchController,
                  onChanged: viewModel.search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search for help articles',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: viewModel.query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: viewModel.clearSearch,
                          ),
                  ),
                ),
              ),
              if (viewModel.searching) ..._results(context, viewModel) else ..._topics(context, viewModel),
              const HelpSectionTitle('Contact us'),
              GroupCard(
                children: [
                  _ContactRow(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chat with us',
                    tag: 'Recommended',
                    subtitle: viewModel.chatAvailable
                        ? 'Live support available ${viewModel.supportHours}, daily'
                        : 'Coming soon',
                    onTap: () => _chat(context, viewModel),
                  ),
                  _ContactRow(
                    icon: Icons.mail_outline,
                    title: 'Email us',
                    subtitle: 'We usually respond within 24 hours',
                    onTap: () => _emailUs(context, viewModel),
                  ),
                  _ContactRow(
                    icon: Icons.call_outlined,
                    title: 'Call us',
                    subtitle: viewModel.phoneAvailable ? viewModel.supportPhone : 'Coming soon',
                    hours: viewModel.supportHours,
                    onTap: () => _call(context, viewModel),
                  ),
                ],
              ),
              const HelpSectionTitle('Other resources'),
              GroupCard(
                children: [
                  NavRow(
                    icon: Icons.menu_book_outlined,
                    title: 'Guides & tips',
                    subtitle: 'Helpful guides to help you get the most out of Commuttr',
                    onTap: viewModel.openGuides,
                  ),
                  NavRow(
                    icon: Icons.flag_outlined,
                    title: 'Report an issue',
                    subtitle: "Let us know if something isn't working",
                    onTap: viewModel.reportIssue,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: pagePadding,
                child: _SafetyCard(onReport: () => _safetySheet(context, viewModel)),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  List<Widget> _topics(BuildContext context, HelpViewModel vm) => [
    const HelpSectionTitle('Popular topics'),
    Padding(
      padding: pagePadding,
      child: _TopicGrid(onTap: vm.openTopic),
    ),
    if (vm.hasError)
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: InfoBanner(
          tone: BannerTone.warning,
          message: "The help articles couldn't be loaded. You can still email us or report an issue below.",
        ),
      ),
  ];

  List<Widget> _results(BuildContext context, HelpViewModel vm) {
    if (vm.isBusy) return const [LoadingBlock(label: 'Loading help…')];
    final items = vm.results;
    return [
      HelpSectionTitle('Results for “${vm.query.trim()}”'),
      if (items.isEmpty)
        EmptyState(
          icon: Icons.search_off,
          title: 'No articles found',
          message: 'Try different words, or email us and we’ll help.',
          actionLabel: 'Email us',
          onAction: () => _emailUs(context, vm),
        )
      else
        FaqCard(entries: items, showTopic: true),
    ];
  }

  void _snack(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), action: action, duration: const Duration(seconds: 6)));
  }

  Future<void> _chat(BuildContext context, HelpViewModel vm) async {
    if (!vm.chatAvailable) {
      _snack(
        context,
        'Live chat is coming soon. Email us meanwhile',
        action: SnackBarAction(label: 'Email us', onPressed: () => _emailUs(context, vm)),
      );
      return;
    }
    final ok = await vm.openChat();
    if (!ok && context.mounted) _snack(context, "Couldn't open live chat. Please email us instead.");
  }

  Future<void> _call(BuildContext context, HelpViewModel vm) async {
    if (!vm.phoneAvailable) {
      _snack(
        context,
        'Our phone line is coming soon. Email us meanwhile',
        action: SnackBarAction(label: 'Email us', onPressed: () => _emailUs(context, vm)),
      );
      return;
    }
    final ok = await vm.callUs();
    if (!ok && context.mounted) _snack(context, "Couldn't start a call here. Dial ${vm.supportPhone} from a phone.");
  }

  Future<void> _emailUs(BuildContext context, HelpViewModel vm) async {
    final ok = await vm.emailUs();
    if (ok || !context.mounted) return;
    _snack(
      context,
      "Couldn't open an email app. Write to us at ${vm.supportEmail}.",
      action: SnackBarAction(
        label: 'Copy',
        onPressed: () async {
          await vm.copySupportEmail();
          if (context.mounted) _snack(context, 'Email address copied');
        },
      ),
    );
  }

  Future<void> _open(BuildContext context, Future<bool> Function() open, String fallback) async {
    final ok = await open();
    if (!ok && context.mounted) _snack(context, fallback);
  }

  Future<void> _safetySheet(BuildContext context, HelpViewModel vm) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) {
      final accent = sheet.colors.accentText;
      final muted = sheet.colors.muted;
      Widget row(IconData icon, String title, String subtitle, VoidCallback onTap, {bool emergency = false}) =>
          ListTile(
            leading: Icon(icon, color: emergency ? Theme.of(sheet).colorScheme.error : accent),
            title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: muted)),
            trailing: Icon(Icons.chevron_right, color: accent),
            onTap: () {
              Navigator.of(sheet).pop();
              onTap();
            },
          );
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Semantics(
                  header: true,
                  child: const Text('Report safety issue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'If anyone is in danger, call SAPS first. Incidents on a bus or train are handled by the operator.',
                  style: TextStyle(fontSize: 14, color: muted),
                ),
              ),
              row(
                Icons.local_police_outlined,
                'Emergency: call SAPS ${vm.sapsNumber}',
                'For crime or danger right now',
                () => _open(context, vm.callSaps, "Couldn't start a call here. Dial ${vm.sapsNumber} from a phone."),
                emergency: true,
              ),
              const Divider(indent: 56),
              row(
                Icons.directions_bus_outlined,
                'Report to Golden Arrow',
                'Buses, drivers and bus stops: gabs.co.za',
                () => _open(context, vm.openGoldenArrow, "Couldn't open a browser. Visit gabs.co.za."),
              ),
              const Divider(indent: 56),
              row(
                Icons.directions_bus_outlined,
                'Report to MyCiTi',
                'MyCiTi buses, stations and stops: myciti.org.za',
                () => _open(context, vm.openMyCiti, "Couldn't open a browser. Visit www.myciti.org.za."),
              ),
              const Divider(indent: 56),
              row(
                Icons.train_outlined,
                'Report to Metrorail',
                'Trains, stations and staff: metrorail.co.za',
                () => _open(context, vm.openMetrorail, "Couldn't open a browser. Visit metrorail.co.za."),
              ),
              const Divider(indent: 56),
              row(Icons.flag_outlined, 'Tell Commuttr', 'Something unsafe or wrong in the app', vm.reportIssue),
            ],
          ),
        ),
      );
    },
  );

  @override
  HelpViewModel viewModelBuilder(BuildContext context) => HelpViewModel();
}

/// Headset with an orange chat bubble, drawn from icons (no image asset).
class _SupportIllustration extends StatelessWidget {
  const _SupportIllustration();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 84,
      height: 72,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Icon(Icons.headset_mic_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Stack(
              alignment: const Alignment(0, -0.2),
              children: [
                Icon(Icons.chat_bubble, size: 36, color: context.colors.accentText),
                const Icon(Icons.more_horiz, size: 20, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Popular topics: three across, two down, as designed; each row as tall as its tallest
/// tile. Icon on top, title, grey subtitle with a chevron beside it.
class _TopicGrid extends StatelessWidget {
  const _TopicGrid({required this.onTap});

  final ValueChanged<HelpTopic> onTap;

  static const _perRow = 3;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < helpTopics.length; i += _perRow) ...[
        if (i > 0) const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = i; j < i + _perRow; j++) ...[
                if (j > i) const SizedBox(width: 8),
                Expanded(
                  child: j < helpTopics.length
                      ? _TopicTile(topic: helpTopics[j], onTap: onTap)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      ],
    ],
  );
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic, required this.onTap});

  final HelpTopic topic;
  final ValueChanged<HelpTopic> onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${topic.title}. ${topic.subtitle}',
    excludeSemantics: true,
    child: AppCard(
      padding: const EdgeInsets.fromLTRB(10, 14, 6, 12),
      onTap: () => onTap(topic),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Icon(topic.icon, color: context.colors.accentText, size: 30)),
          const SizedBox(height: 12),
          Text(topic.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  topic.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, height: 1.3, color: context.colors.muted),
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.muted, size: 18),
            ],
          ),
        ],
      ),
    ),
  );
}

/// A Contact us row: outline icon, title (with an optional orange-outline tag), grey
/// subtitle, and an orange chevron, optionally preceded by orange hours.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.tag,
    this.hours,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? tag;
  final String? hours;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accentText;
    return Semantics(
      button: true,
      label: [title, subtitle, if (hours != null) 'Hours $hours'].join('. '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
            child: Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 16)),
                          if (tag != null) TagChip(tag!, color: accent),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: context.colors.muted)),
                    ],
                  ),
                ),
                if (hours != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    hours!,
                    style: TextStyle(fontSize: 13, color: accent, fontWeight: FontWeight.w600),
                  ),
                ],
                Icon(Icons.chevron_right, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.onReport});

  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accentText;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.14)),
                child: Icon(Icons.shield_outlined, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: const Text(
                        'Safety is our priority',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'See something suspicious? Report it to help keep our community safe.',
                      style: TextStyle(fontSize: 13, height: 1.4, color: context.colors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(onPressed: onReport, child: const Text('Report safety issue')),
          ),
        ],
      ),
    );
  }
}
