import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../app/app.locator.dart';
import '../../data/models/models.dart';
import '../../services/connectivity_service.dart';
import '../../services/inbox_service.dart';
import '../theme/app_theme.dart';

/// Standard page padding.
const pagePadding = EdgeInsets.symmetric(horizontal: 16);

/// A bordered card, optionally tappable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.highlighted = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// An orange border, for the selected or most relevant item.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: highlighted ? Theme.of(context).colorScheme.primary : c.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// "Recommended routes ........ See all"
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 8, 8),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: context.text.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
        if (actionLabel != null && actionIcon != null)
          TextButton.icon(onPressed: onAction, icon: Icon(actionIcon, size: 20), label: Text(actionLabel!))
        else if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ),
  );
}

/// Bus or train, for lists and markers.
IconData transitIcon(OperatorRef operator) => operator.isTrain ? Icons.train_outlined : Icons.directions_bus_outlined;

/// The operator as a solid chip with its vehicle icon, and the route (bus number or train
/// line) as an outlined one. Commuttr's own colours for every operator: the app is
/// independent and must not look like any operator's branding.
class RouteBadge extends StatelessWidget {
  const RouteBadge({super.key, required this.routeNumber, this.operator = OperatorRef.goldenArrow});

  final String routeNumber;
  final OperatorRef operator;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final train = operator.isTrain;
    final chip = train ? const Color(0xFF2F3A45) : Brand.orangeDeep;
    return Semantics(
      label: train ? '${operator.name}, $routeNumber line' : '${operator.name} route $routeNumber',
      excludeSemantics: true,
      child: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: chip, borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(train ? Icons.train : Icons.directions_bus, size: 13, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  operator.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (routeNumber.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: c.muted),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                train ? '$routeNumber line' : routeNumber,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

/// The published cash fare, or nothing. A card price is never shown as "the" price.
class FareLabel extends StatelessWidget {
  const FareLabel(this.fare, {super.key, this.compact = true, this.cents});

  final Fare? fare;

  /// The amount to show when it is not the fare's own cash price: MyCiTi's saver fare.
  final int? cents;

  /// Just "R12.00" for lists; otherwise "R12.00 cash".
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cents = this.cents ?? fare?.cashCents;
    if (cents == null) return const SizedBox.shrink();
    return Semantics(
      label: 'Cash fare ${formatRands(cents)}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: context.colors.infoSurface, borderRadius: BorderRadius.circular(6)),
        child: Text(
          compact ? formatRands(cents) : '${formatRands(cents)} cash',
          style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// A small outlined tag: "approx.", "Fridays only", "Scheduled".
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key, this.icon, this.color});

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final col = color ?? context.colors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: col.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: col), const SizedBox(width: 3)],
          Text(
            label,
            style: TextStyle(fontSize: 11, color: col, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

enum BannerTone { info, warning, offline }

/// A one-line explanation above content: offline, out of date, public holiday.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.tone = BannerTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final BannerTone tone;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, ic) = switch (tone) {
      BannerTone.warning => (c.warningSurface, c.warning, Icons.warning_amber_rounded),
      BannerTone.offline => (c.infoSurface, c.muted, Icons.cloud_off_outlined),
      BannerTone.info => (c.infoSurface, c.muted, Icons.info_outline),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon ?? ic, size: 20, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: context.text.bodySmall?.copyWith(color: tone == BannerTone.warning ? fg : null),
              ),
            ),
            if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}

/// Shown under the app bar whenever requests are failing for lack of network.
class OfflineBanner extends StackedView<OfflineBannerModel> {
  const OfflineBanner({super.key});

  @override
  Widget builder(BuildContext context, OfflineBannerModel viewModel, Widget? child) {
    if (!viewModel.offline) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: InfoBanner(
        tone: BannerTone.offline,
        message: "You're offline. Showing saved timetables — new searches need a connection.",
      ),
    );
  }

  @override
  OfflineBannerModel viewModelBuilder(BuildContext context) => OfflineBannerModel();
}

class OfflineBannerModel extends ReactiveViewModel {
  final _connectivity = locator<ConnectivityService>();

  bool get offline => _connectivity.isOffline;

  @override
  List<ListenableServiceMixin> get listenableServices => [_connectivity];
}

/// Bell with an unread dot; opens the in-app notifications list.
class NotificationBell extends StackedView<NotificationBellModel> {
  const NotificationBell({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget builder(BuildContext context, NotificationBellModel viewModel, Widget? child) {
    final unread = viewModel.unread;
    return IconButton(
      tooltip: unread > 0 ? 'Notifications, $unread unread' : 'Notifications',
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: unread > 0,
        smallSize: 8,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.notifications_none_rounded),
      ),
    );
  }

  @override
  NotificationBellModel viewModelBuilder(BuildContext context) => NotificationBellModel();
}

class NotificationBellModel extends ReactiveViewModel {
  final _inbox = locator<InboxService>();

  int get unread => _inbox.unreadCount;

  @override
  List<ListenableServiceMixin> get listenableServices => [_inbox];
}

/// Icon, title, explanation, and what to do about it.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 44, color: context.colors.muted),
        const SizedBox(height: 12),
        Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          message,
          style: context.text.bodyMedium?.copyWith(color: context.colors.muted),
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
        if (secondary != null) ...[const SizedBox(height: 8), secondary!],
      ],
    ),
  );
}

/// A row in a settings-style list: icon, title, subtitle, chevron.
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final col = destructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: col),
      title: Text(title, style: TextStyle(color: col)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: TextStyle(color: context.colors.muted)),
      trailing: trailing ?? (onTap == null ? null : Icon(Icons.chevron_right, color: context.colors.muted)),
    );
  }
}

/// A bordered group of [NavRow]s with dividers, like the mockups' Preferences list.
class NavGroup extends StatelessWidget {
  const NavGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: pagePadding,
    child: AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const Divider(indent: 56), children[i]],
        ],
      ),
    ),
  );
}

/// The standing reminder that times come from printed timetables.
class ScheduledDisclaimer extends StatelessWidget {
  const ScheduledDisclaimer({super.key, this.extra, this.operator});

  final String? extra;

  /// Whose timetable; null for screens that mix operators.
  final OperatorRef? operator;

  @override
  Widget build(BuildContext context) {
    final o = operator;
    final source = o == null ? "the operators' published timetables" : "${o.name}'s published timetables";
    final vehicles = o == null ? 'Buses and trains' : (o.isTrain ? 'Trains' : 'Buses');
    final place = o?.isTrain == true ? 'station' : 'stop';
    return InfoBanner(
      message:
          'Scheduled times from $source — not live tracking. '
          '$vehicles can be early, late or cancelled. ${extra ?? 'Be at your $place 5–10 min early.'}',
    );
  }
}

/// Centered spinner with a label, for first loads.
class LoadingBlock extends StatelessWidget {
  const LoadingBlock({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!, style: TextStyle(color: context.colors.muted)),
          ],
        ],
      ),
    ),
  );
}
