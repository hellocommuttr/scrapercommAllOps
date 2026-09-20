import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../services/favourites_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../legal/legal_content.dart';
import '../preferences/preference_rows.dart';
import 'page_layout.dart';
import 'profile_viewmodel.dart';
import 'profile_widgets.dart';

/// The Profile tab. It lives in MainView's IndexedStack, so it has no back button.
class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  Widget builder(BuildContext context, ProfileViewModel viewModel, Widget? child) {
    final vm = viewModel;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ConstrainedListView(
          top: 0,
          children: [
            PageHeader(
              title: 'Profile',
              trailing: NotificationBell(onPressed: vm.openNotifications),
            ),
            _Header(viewModel: vm),
            const Padding(padding: EdgeInsets.fromLTRB(16, 24, 16, 0), child: Divider(height: 1)),
            SectionHeader('My planner', actionLabel: 'View all', onAction: vm.openPlanner),
            Padding(
              padding: pagePadding,
              child: _PlannerCard(viewModel: vm),
            ),
            SectionHeader('Favourites', actionLabel: 'Edit', onAction: vm.openFavourites),
            Padding(
              padding: pagePadding,
              child: _FavouriteTiles(viewModel: vm),
            ),
            const SectionHeader('Preferences'),
            const PreferenceRows(),
            const SectionHeader('Support & more'),
            NavGroup(
              children: [
                NavRow(icon: Icons.help_outline_rounded, title: 'Help & support', onTap: vm.openHelp),
                NavRow(icon: Icons.share_outlined, title: 'Share Commuttr', onTap: vm.shareApp),
                NavRow(
                  icon: Icons.description_outlined,
                  title: 'Terms & privacy',
                  onTap: () => _chooseLegal(context, vm),
                ),
                NavRow(icon: Icons.info_outline_rounded, title: 'About Commuttr', onTap: vm.openAbout),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: AccentOutlinedButton(
                icon: Icons.logout_rounded,
                label: 'Log out',
                expand: true,
                onPressed: vm.isBusy ? null : vm.logOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseLegal(BuildContext context, ProfileViewModel vm) async {
    final kind = await showModalBottomSheet<LegalKind>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Semantics(
                header: true,
                child: const Text('Terms & privacy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms & Conditions'),
              trailing: Icon(Icons.chevron_right, color: context.colors.muted),
              onTap: () => Navigator.pop(context, LegalKind.terms),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: Icon(Icons.chevron_right, color: context.colors.muted),
              onTap: () => Navigator.pop(context, LegalKind.privacy),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (kind != null) vm.openLegal(kind);
  }

  @override
  ProfileViewModel viewModelBuilder(BuildContext context) => ProfileViewModel();

  @override
  void onViewModelReady(ProfileViewModel viewModel) => viewModel.init();
}

/// Large avatar on the left; name, location and "Edit profile" beside it.
class _Header extends StatelessWidget {
  const _Header({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.muted;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          ProfileAvatar(photoBase64: viewModel.photoBase64, radius: 50),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(viewModel.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(viewModel.location, style: TextStyle(color: muted)),
                const SizedBox(height: 12),
                AccentOutlinedButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit profile',
                  onPressed: viewModel.editProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Route icon circle, "N upcoming journeys", "You have N saved journeys for today.", chevron.
class _PlannerCard extends StatelessWidget {
  const _PlannerCard({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: '${viewModel.upcomingTitle}. ${viewModel.todaySummary}',
      excludeSemantics: true,
      child: AppCard(
        onTap: viewModel.openPlanner,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.accentText.withValues(alpha: 0.14)),
              child: Icon(Icons.route_outlined, color: c.accentText),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(viewModel.upcomingTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(viewModel.todaySummary, style: TextStyle(fontSize: 13, color: c.muted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.muted),
          ],
        ),
      ),
    );
  }
}

/// Home, Work, Saved routes and Nearby stops: four in a row, two when text is large.
class _FavouriteTiles extends StatelessWidget {
  const _FavouriteTiles({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final tiles = [
      FavouriteTile(
        icon: Icons.home_outlined,
        title: 'Home',
        subtitle: vm.homeSubtitle,
        onTap: () => vm.tapPlace(PlaceKind.home),
      ),
      FavouriteTile(
        icon: Icons.work_outline_rounded,
        title: 'Work',
        subtitle: vm.workSubtitle,
        onTap: () => vm.tapPlace(PlaceKind.work),
      ),
      FavouriteTile(
        icon: Icons.star_outline_rounded,
        title: 'Saved routes',
        subtitle: vm.savedRoutesSubtitle,
        onTap: vm.openFavourites,
      ),
      FavouriteTile(
        icon: Icons.location_on_outlined,
        title: 'Nearby stops',
        subtitle: vm.nearbySubtitle,
        onTap: vm.openNearbyStops,
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final perRow = box.maxWidth / scale >= 300 ? 4 : 2;
        final rows = <Widget>[];
        for (var i = 0; i < tiles.length; i += perRow) {
          if (i > 0) rows.add(const SizedBox(height: 8));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = i; j < i + perRow; j++) ...[
                    if (j > i) const SizedBox(width: 8),
                    Expanded(child: tiles[j]),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}
