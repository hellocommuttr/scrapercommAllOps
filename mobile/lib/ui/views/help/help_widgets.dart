import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'faq_entry.dart';

/// The pushed-screen header from the mockups: back arrow and a large bold title on one
/// line, with an optional grey subtitle under it. Used by Help, its topic lists, Report
/// an issue and the legal pages.
class PushedHeader extends StatelessWidget {
  const PushedHeader({super.key, required this.title, this.subtitle, this.trailing, this.onBack});

  final String title;
  final String? subtitle;

  /// Shown to the right of the subtitle (the Help illustration).
  final Widget? trailing;

  /// Defaults to popping the route.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: context.text.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          if (sub != null || trailing != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: sub == null
                        ? const SizedBox.shrink()
                        : Text(sub, style: TextStyle(fontSize: 14, height: 1.4, color: context.colors.muted)),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 12), trailing!],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Section header without the default action padding, matching the other Help sections.
class HelpSectionTitle extends StatelessWidget {
  const HelpSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
    child: Semantics(
      header: true,
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    ),
  );
}

/// One bordered card with rows separated by hairlines.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children, this.indent = 56});

  final List<Widget> children;
  final double indent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: pagePadding,
    child: AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) Divider(indent: indent), children[i]],
        ],
      ),
    ),
  );
}

/// FAQ questions as an accordion inside one bordered card.
class FaqCard extends StatelessWidget {
  const FaqCard({super.key, required this.entries, this.showTopic = false});

  final List<FaqEntry> entries;

  /// Shows each entry's topic under the question (search results mix topics).
  final bool showTopic;

  @override
  Widget build(BuildContext context) => GroupCard(
    indent: 0,
    children: [for (final e in entries) _FaqTile(entry: e, showTopic: showTopic)],
  );
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.entry, required this.showTopic});

  final FaqEntry entry;
  final bool showTopic;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accentText;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ExpansionTile(
      // Keyed by question so expansion state follows the entry while filtering.
      key: PageStorageKey<String>('faq:${entry.question}'),
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedAlignment: Alignment.centerLeft,
      textColor: accent,
      iconColor: accent,
      collapsedTextColor: onSurface,
      collapsedIconColor: onSurface,
      title: Text(entry.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: showTopic ? Text(entry.topic, style: TextStyle(fontSize: 13, color: context.colors.muted)) : null,
      children: [
        // Plain Text, not SelectableText: on the web build the selectable one paints a
        // grey block where the answer should be, so every article looked empty.
        Text(entry.answer, style: TextStyle(fontSize: 14, height: 1.5, color: context.colors.muted)),
      ],
    );
  }
}
