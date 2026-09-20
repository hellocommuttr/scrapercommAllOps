import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../data/models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'explore_viewmodel.dart';
import 'explore_widgets.dart';
import 'route_widgets.dart';

/// Explore tab. Lives in MainView's IndexedStack, so it has no back button.
class ExploreView extends StackedView<ExploreViewModel> {
  const ExploreView({super.key});

  /// Search results shown inline before "Show all" opens the full list.
  static const _inlineLimit = 8;

  @override
  Widget builder(BuildContext context, ExploreViewModel viewModel, Widget? child) => Scaffold(
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _ExploreBody(viewModel: viewModel),
        ),
      ),
    ),
  );

  @override
  ExploreViewModel viewModelBuilder(BuildContext context) => ExploreViewModel();

  @override
  void onViewModelReady(ExploreViewModel viewModel) => viewModel.init();
}

class _ExploreBody extends StatefulWidget {
  const _ExploreBody({required this.viewModel});

  final ExploreViewModel viewModel;

  @override
  State<_ExploreBody> createState() => _ExploreBodyState();
}

class _ExploreBodyState extends State<_ExploreBody> {
  final _search = TextEditingController();
  final _timetablesKey = GlobalKey();
  final _popularKey = GlobalKey();

  ExploreViewModel get vm => widget.viewModel;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// One operator's routes, or every route when [operator] is null.
  Future<void> _openRouteList({OperatorRef? operator, String initialQuery = ''}) async {
    final routes = operator == null ? await vm.reloadRoutes() : await vm.routesFor(operator);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            RouteListPage(routes: routes, onOpen: vm.openRoute, operator: operator, initialQuery: initialQuery),
      ),
    );
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.05);
  }

  void _openOffers() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => OfferListPage(offers: vm.offers, onOpen: vm.openOffer),
    ),
  );

  void _openPopularList() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PopularRouteListPage(routes: vm.popular, onOpen: vm.openPopular),
    ),
  );

  void _clear() {
    _search.clear();
    vm.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.muted;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Explore',
                        style: context.text.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('Discover routes, timetables and more.', style: TextStyle(color: muted, fontSize: 14)),
                  ],
                ),
              ),
              NotificationBell(onPressed: vm.openNotifications),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const OfflineBanner(),
        Padding(
          padding: pagePadding,
          child: TextField(
            controller: _search,
            onChanged: (v) {
              vm.search(v);
              setState(() {});
            },
            textInputAction: TextInputAction.search,
            onSubmitted: (v) {
              if (v.trim().isNotEmpty && vm.results.isNotEmpty) _openRouteList(initialQuery: v);
            },
            decoration: InputDecoration(
              hintText: 'Search for routes, areas or partners',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(tooltip: 'Clear search', icon: const Icon(Icons.close), onPressed: _clear),
            ),
          ),
        ),
        if (vm.isSearching) ..._searchResults(context) else ..._discover(context),
      ],
    );
  }

  List<Widget> _searchResults(BuildContext context) {
    final results = vm.results;
    final offers = vm.offerResults;
    final shown = results.take(ExploreView._inlineLimit).toList();
    return [
      if (offers.isNotEmpty) ...[
        SectionHeader(offers.length == 1 ? '1 partner offer' : '${offers.length} partner offers'),
        for (final o in offers)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 76 + MediaQuery.textScalerOf(context).scale(124),
              child: OfferBanner(offer: o, onOpen: () => vm.openOffer(o)),
            ),
          ),
      ],
      SectionHeader(
        results.length == 1 ? '1 route' : '${results.length} routes',
        actionLabel: results.length > shown.length ? 'Show all' : null,
        onAction: () => _openRouteList(initialQuery: vm.query),
      ),
      if (results.isEmpty)
        const EmptyState(
          icon: Icons.search_off,
          title: 'No routes match',
          message: 'Try part of a place name, such as "Bellville" or "Khayelitsha". Route search works offline.',
        )
      else
        Padding(
          padding: pagePadding,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < shown.length; i++) ...[
                  if (i > 0) const Divider(indent: 56),
                  RouteTile(route: shown[i], onTap: () => vm.openRoute(shown[i])),
                ],
              ],
            ),
          ),
        ),
    ];
  }

  List<Widget> _discover(BuildContext context) {
    final goldenArrow = vm.operatorFor(OperatorRef.goldenArrow);
    final metrorail = vm.operatorFor(OperatorRef.metrorail);
    final myciti = vm.operatorFor(OperatorRef.myciti);
    final popular = vm.popularShown;
    return [
      const SectionHeader('Quick access'),
      Padding(
        padding: pagePadding,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _QuickTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Timetables',
                  selected: true,
                  hint: 'Shows bus and train timetables',
                  onTap: () => _scrollTo(_timetablesKey),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTile(icon: Icons.near_me_outlined, label: 'Nearby stops', onTap: vm.openNearbyStops),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTile(
                  icon: Icons.alt_route_rounded,
                  label: 'Popular routes',
                  onTap: () => _scrollTo(_popularKey),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickTile(icon: Icons.star_outline_rounded, label: 'Favourites', onTap: vm.openFavourites),
              ),
            ],
          ),
        ),
      ),
      if (vm.offers.isNotEmpty) ...[
        SectionHeader('Partner offers', actionLabel: 'See all', onAction: _openOffers),
        OfferCarousel(offers: vm.offers, onOpen: vm.openOffer),
      ],
      SectionHeader('Timetables', key: _timetablesKey, actionLabel: 'See all', onAction: _openRouteList),
      Padding(
        padding: pagePadding,
        child: AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              OperatorTimetableRow(
                logo: 'Golden\nArrow',
                name: goldenArrow.name,
                train: false,
                onTap: () => _openRouteList(operator: goldenArrow),
              ),
              const Divider(indent: 72),
              OperatorTimetableRow(
                logo: 'MyCiTi',
                name: myciti.name,
                train: false,
                onTap: () => _openRouteList(operator: myciti),
              ),
              const Divider(indent: 72),
              OperatorTimetableRow(
                logo: 'Metrorail',
                name: metrorail.name,
                train: true,
                onTap: () => _openRouteList(operator: metrorail),
              ),
            ],
          ),
        ),
      ),
      SectionHeader(
        'Popular routes',
        key: _popularKey,
        actionLabel: vm.popular.isEmpty ? null : 'See all',
        onAction: _openPopularList,
      ),
      if (popular.isEmpty)
        Padding(
          padding: pagePadding,
          child: Text('Trips you search for often will appear here.', style: TextStyle(color: context.colors.muted)),
        )
      else
        Padding(
          padding: pagePadding,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < popular.length; i++) ...[
                  if (i > 0) const Divider(indent: 72),
                  PopularRouteRow(route: popular[i], onTap: () => vm.openPopular(popular[i])),
                ],
              ],
            ),
          ),
        ),
      const SizedBox(height: 16),
    ];
  }
}

/// One of the four "Quick access" tiles. The selected one (Timetables) is orange.
class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.icon, required this.label, required this.onTap, this.selected = false, this.hint});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final col = selected ? c.accentText : Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: col, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: col, fontWeight: selected ? FontWeight.w600 : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
