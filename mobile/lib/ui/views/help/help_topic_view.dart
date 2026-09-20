import 'package:flutter/material.dart';

import '../../../services/shell_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/common.dart';
import 'faq_entry.dart';
import 'help_widgets.dart';

/// A "Popular topics" tile (or "Guides & tips") opened from Help & Support: the FAQ
/// entries for that topic. The entries come from the Help screen's already-loaded FAQ,
/// so this page has no state of its own.
class HelpTopicView extends StatelessWidget {
  const HelpTopicView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.entries,
    this.onTour,
    this.onReport,
  });

  final String title;
  final String subtitle;
  final List<FaqEntry> entries;

  /// When set, a "Take the tour" card opens the app walkthrough (Guides & tips).
  final VoidCallback? onTour;

  /// When set, a closing "Still need help?" row opens Report an issue.
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
    body: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              PushedHeader(title: title, subtitle: subtitle),
              if (onTour != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: pagePadding,
                  child: AppCard(
                    onTap: onTour,
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_outline, color: context.colors.accentText, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Take the tour', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(
                                'A quick walk through how Commuttr works',
                                style: TextStyle(fontSize: 13, color: context.colors.muted),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: context.colors.muted),
                      ],
                    ),
                  ),
                ),
              ],
              HelpSectionTitle(onTour != null ? 'Guides' : 'Articles'),
              if (entries.isEmpty)
                const EmptyState(
                  icon: Icons.article_outlined,
                  title: 'No articles yet',
                  message: "We're still writing these. Email us and we'll help.",
                )
              else
                FaqCard(entries: entries),
              if (onReport != null) ...[
                const HelpSectionTitle('Still need help?'),
                GroupCard(
                  children: [
                    NavRow(
                      icon: Icons.flag_outlined,
                      title: 'Report an issue',
                      subtitle: "Let us know if something isn't working",
                      onTap: onReport,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
