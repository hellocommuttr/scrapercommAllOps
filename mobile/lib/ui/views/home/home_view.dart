import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/service_day.dart';
import '../../../data/models/models.dart';
import '../../../services/journey_service.dart';
import '../../../services/shell_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ride_card.dart';
import 'home_viewmodel.dart';

/// Home, as designed: greeting, "Where we commuting to?", From/To, Depart now / Filter,
/// the quick-nav row, Recommended routes, Your planner and Explore.
class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) => Scaffold(
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: viewModel.canSearch ? viewModel.search : () async {},
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                _Header(viewModel),
                _SearchCard(viewModel),
                _WhenRow(viewModel),
                // _QuickNav(viewModel),
                const OfflineBanner(),
                ..._recommended(context, viewModel),
                if (viewModel.plannerCard != null) _PlannerCard(viewModel),
                _ExploreRow(viewModel),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  // ---------------------------------------------------------------- Recommended routes

  List<Widget> _recommended(BuildContext context, HomeViewModel vm) {
    final header = const SectionHeader('Recommended routes', padding: EdgeInsets.fromLTRB(20, 20, 8, 10));
    if (vm.searching) return [header, const LoadingBlock(label: 'Finding routes…')];
    final problem = vm.problem;
    if (problem != null) return [header, _ProblemView(vm, problem)];
    final o = vm.outcome;
    if (o == null) {
      return [
        header,
        Padding(
          padding: pagePadding,
          child: AppCard(
            child: Row(
              children: [
                Icon(Icons.alt_route, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 14),
                const Expanded(child: Text('Choose where you\'re going to see recommended routes.')),
              ],
            ),
          ),
        ),
      ];
    }
    // The best of each operator, until asked: a screen of near-identical cards buries the
    // answer, but one card per operator lets a rider compare bus, MyCiTi and train.
    final headline = o.bestPerOperator;
    final rides = vm.showAll ? o.rides : headline;
    final more = o.rides.length - headline.length;
    return [
      header,
      Padding(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._banners(vm, o).expand((w) => [w, const SizedBox(height: 8)]),
            for (final r in rides) ...[
              RideCard(ride: r, minutesUntil: vm.minutesUntil(r), onTap: () => vm.openRide(r)),
              const SizedBox(height: 10),
            ],
            if (more > 0)
              _MoreButton(
                label: vm.showAll ? 'Show fewer' : 'View $more more ${more == 1 ? 'route' : 'routes'}',
                expanded: vm.showAll,
                onTap: vm.toggleShowAll,
              ),
            ..._emptyStates(vm, o),
            if (o.connections.isNotEmpty) ..._connections(context, vm, o),
          ],
        ),
      ),
    ];
  }

  List<Widget> _banners(HomeViewModel vm, JourneySearchOutcome o) {
    const clock = SastClock();
    final out = <Widget>[];
    if (o.holidayName != null) {
      out.add(
        InfoBanner(
          tone: BannerTone.warning,
          icon: Icons.celebration_outlined,
          message: o.holidayFallback
              ? '${o.holidayName}: Sunday times shown. Confirm holiday service with the operator.'
              : '${o.holidayName}: public holiday timetable.',
        ),
      );
    }
    if (o.fromCache) {
      out.add(InfoBanner(tone: BannerTone.offline, message: 'Saved ${_ago(o.fetchedAt)}. Pull down to refresh.'));
    }
    final last = o.lastBus;
    if (o.date == clock.today && last != null) {
      final left = clock.minutesUntil(o.date, last.boardMinutes);
      if (left > 0 && left <= 60) {
        out.add(
          InfoBanner(
            tone: BannerTone.warning,
            icon: Icons.nightlight_outlined,
            message: 'Last ${o.vehicle} today departs at ${last.boardTime}.',
          ),
        );
      }
    }
    return out;
  }

  List<Widget> _emptyStates(HomeViewModel vm, JourneySearchOutcome o) {
    if (o.rides.isNotEmpty) return const [];
    final today = const SastClock().today;
    if (o.allDay.isNotEmpty) {
      // "No more trains today" names the vehicles we FOUND, and reads as the vehicles the
      // rider ASKED FOR. With no filter on, someone who searched for any way to get there
      // is told about trains and left wondering whether the buses were looked at at all.
      //
      // So the heading no longer claims what they searched for, and where only one kind
      // runs and nothing was filtered out, the answer to "what about the buses?" is said
      // rather than left to be inferred.
      final oneKind = o.kinds.length == 1 && o.hiddenByOperator == 0;
      final when = o.date == today ? 'today' : 'that day';
      final only = oneKind ? 'Only ${o.vehicles} run between these two $when. ' : '';
      return [
        EmptyState(
          icon: Icons.bedtime_outlined,
          title: 'No more departures $when',
          message: o.allDay.length == 1
              ? '${only}The only ${o.vehicle} $when departs at ${o.firstBus!.boardTime}.'
              : '${only}The last ${o.vehicle} departed at ${o.lastBus!.boardTime}. '
                    'The first is at ${o.firstBus!.boardTime}.',
          actionLabel: o.date == today ? 'See tomorrow' : 'See the whole day',
          onAction: o.date == today ? vm.seeTomorrow : vm.seeFullDay,
        ),
      ];
    }
    if (o.otherDayTypes.isNotEmpty) {
      return [
        EmptyState(
          icon: Icons.event_busy_outlined,
          // The day the RIDER asked about, not the one we fell back to. On a public
          // holiday this said "No sunday service on this trip", which is a fact about our
          // fallback and not about their journey.
          title: o.holidayFallback
              ? 'No ${o.holidayName ?? 'public holiday'} service on this trip'
              : 'No ${o.dayType.label.toLowerCase()} service on this trip',
          message: '${_cap(o.vehicles)} run on: ${o.otherDayTypes.map((d) => d.label).join(', ')}.',
          actionLabel: 'Change date',
          onAction: vm.openFilters,
        ),
      ];
    }
    // "Nothing connects these two" would be a lie with a trip on screen that does.
    if (o.connections.isNotEmpty) return const [];
    // Nor when trips with a change do run that day, only not at the time chosen.
    final day = o.allDayConnections;
    if (day.isNotEmpty) {
      return [
        EmptyState(
          icon: Icons.bedtime_outlined,
          title: 'No more trips with a change ${o.date == today ? 'today' : 'at that time'}',
          message:
              'The first leaves at ${day.first.legs.first.boardTime} and the last at ${day.last.legs.first.boardTime}.',
          actionLabel: 'See the whole day',
          onAction: vm.setAllDay,
        ),
      ];
    }
    // Nothing was found - but "nothing runs" and "we did not finish looking" are different
    // answers and only one of them is a fact about Cape Town. Where the network is dense
    // the search can be cut short on time, and saying "no bus or train connects these two"
    // on the strength of that is a claim nobody established. CAPE TOWN to BELLVILLE was
    // shown as impossible for a while on exactly this path.
    if (o.searchIncomplete) {
      return [
        EmptyState(
          icon: Icons.hourglass_empty,
          title: 'We could not finish checking this journey',
          message: 'This is a busy part of the network and the search timed out. '
              'It does not mean there is no way to get there.',
          actionLabel: 'Try again',
          onAction: vm.search,
        ),
      ];
    }
    return [
      EmptyState(
        icon: Icons.wrong_location_outlined,
        title: o.hiddenByOperator > 0 ? 'Nothing from the transport modes you chose' : 'No route found',
        message: !o.from.isStop || !o.to.isStop
            ? 'Try the nearest stop or station instead of an address.'
            : 'No bus or train connects these two, even with one change.',
        actionLabel: 'Report a missing route',
        onAction: vm.reportProblem,
      ),
    ];
  }

  /// "2 buses", said by the journey rather than by the chosen filter: a trip made of two
  /// trains read "2 buses" whenever the rider had chosen All, because the fallback for
  /// "no mode chosen" is bus. The journey knows what it is.
  static String _legsPhrase(Connection con) {
    final kinds = {for (final l in con.legs) l.operator.kind};
    final word = kinds.length == 1 ? (kinds.first == 'train' ? 'trains' : 'buses') : 'rides';
    return '${con.legs.length} $word';
  }

  /// The vehicle for a journey with a change: its own, when every leg is the same kind,
  /// and the interchange arrows when they are not.
  ///
  /// Two trains are a train journey and two buses a bus one. A journey that is both is
  /// neither, and drawing it as a bus would be a small lie about the half of it that is a
  /// train - so it gets the symbol for changing instead.
  static IconData _connectionIcon(Connection con) {
    final kinds = {for (final l in con.legs) l.operator.kind};
    if (kinds.length != 1) return Icons.multiple_stop;
    return transitIcon(con.legs.first.operator);
  }

  List<Widget> _connections(BuildContext context, HomeViewModel vm, JourneySearchOutcome o) {
    final c = context.colors;
    final first = o.connections.first;
    final changeAt = first.changeAt.map(titleCase).join(' then ');
    // One per operator, as the direct routes above do. See bestConnectionPerOperator.
    final headline = o.bestConnectionPerOperator;
    final shown = vm.showAllConnections ? o.connections : headline;
    final weekday = dayTypeFor(o.date) == DayType.weekday;
    final more = o.connections.length - headline.length;
    return [
      const SizedBox(height: 2),
      SectionHeader('Journeys with a change', padding: const EdgeInsets.fromLTRB(0, 18, 0, 10)),
      InfoBanner(
        tone: o.hasAnyDirectService ? BannerTone.info : BannerTone.warning,
        icon: o.hasAnyDirectService ? Icons.alt_route : Icons.warning_amber_outlined,
        message: o.hasAnyDirectService
            ? 'You can also get from ${titleCase(o.from.name)} to ${titleCase(o.to.name)} by taking '
                  '${_legsPhrase(first)}, changing at $changeAt.'
            : 'No direct ${o.vehicle} from ${titleCase(o.from.name)} to ${titleCase(o.to.name)}. You can still '
                  'get there by taking ${_legsPhrase(first)}, changing at $changeAt.',
      ),
      const SizedBox(height: 10),
      for (final con in shown) ...[
        AppCard(
          onTap: () => vm.openConnection(con),
          child: Row(
            children: [
              // The same duration block the direct routes carry, so the two lists can be
              // read down one column. It was missing here, which left the one number a
              // rider compares journeys by - how long this takes - buried in a line of
              // small print while every card above it shouted it.
              //
              // The total, not a leg: riding, waiting at the change and riding again.
              // Narrower than the 62 the direct cards use. A change card carries two
              // operator badges and an arrow where a direct one carries a single badge, and
              // at 62 they wrapped onto two lines on a 375px phone. The number still lines
              // up down the column, which is the point of it.
              SizedBox(
                width: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: con.totalMinutes == null ? '–' : '${con.totalMinutes!.round()}',
                            style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: ' min', style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(_connectionIcon(con), color: c.muted, size: 24),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 62,
                color: c.cardBorder,
                margin: const EdgeInsets.only(right: 10),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final (i, leg) in con.legs.indexed) ...[
                          if (i > 0) Icon(Icons.arrow_forward, size: 14, color: c.muted),
                          RouteBadge(routeNumber: leg.routeNumber, operator: leg.operator),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${titleCase(con.legs.first.fromName)} → ${titleCase(con.legs.last.toName)}',
                      style: TextStyle(color: c.muted),
                    ),
                    // "1 change" whatever the journey: three buses have two changes, and
                    // this card said one while listing both stops.
                    Text(
                      '${con.changeAt.length == 1 ? '1 change' : '${con.changeAt.length} changes'} at '
                      '${con.changeAt.map(titleCase).join(', ')}',
                      style: TextStyle(color: c.muted),
                    ),
                    // What separates one of these from the next is the wait at the change,
                    // so it belongs on the card and not only inside it.
                    if (con.waitMinutes != null)
                      Text(
                        '${formatDuration(con.waitMinutes!)} waiting',
                        style: TextStyle(color: (con.waitMinutes ?? 0) > 60 ? c.accentText : c.muted, fontSize: 12),
                      ),
                    // What each ride costs, so the total beside it can be checked.
                    if (con.legFaresOn(weekday: weekday) case final legFares?)
                      Text(
                        con.oneTicket ? '$legFares on their own' : legFares,
                        style: TextStyle(color: c.muted, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (con.priceOn(weekday: weekday) case final price?) ...[
                    FareLabel(con.fare, cents: price),
                    Text(
                      con.fare?.isMyciti == true ? 'one fare' : (con.oneTicket ? 'one ticket' : 'total'),
                      style: TextStyle(color: c.muted, fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Departs ${con.legs.first.boardTime}',
                    style: TextStyle(color: c.accentText, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  if (DayType.fromApi(con.dayType) case final day?)
                    Text(day.covers, style: TextStyle(color: c.muted, fontSize: 12)),
                ],
              ),
              Icon(Icons.chevron_right, color: c.muted),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
      if (more > 0)
        _MoreButton(
          label: vm.showAllConnections ? 'Show fewer' : 'View $more more ${more == 1 ? 'way' : 'ways'} with a change',
          expanded: vm.showAllConnections,
          onTap: vm.toggleShowAllConnections,
        ),
    ];
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes} min ago';
    if (d.inDays < 1) return '${d.inHours} h ago';
    return '${d.inDays} day${d.inDays == 1 ? '' : 's'} ago';
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) => viewModel.init();
}

String _cap(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// "View 4 more routes" under the one card shown, and "Show fewer" once opened.
class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.label, required this.expanded, required this.onTap});

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Icon(expanded ? Icons.expand_less : Icons.expand_more, color: context.colors.muted),
        ],
      ),
    ),
  );
}

/// Round avatar: the profile photo if there is one, else an outline person.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.photoBase64, this.size = 52});

  final String? photoBase64;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bytes = photoBase64 == null ? null : base64Decode(photoBase64!);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.card,
        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1.5),
        image: bytes == null ? null : DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
      ),
      child: bytes == null ? Icon(Icons.person_outline, size: size * 0.55) : null,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.vm);

  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Semantics(
              button: true,
              label: 'Profile',
              child: GestureDetector(
                onTap: vm.openProfile,
                child: ProfileAvatar(photoBase64: vm.photoBase64),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(vm.greeting, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
            NotificationBell(onPressed: vm.openNotifications),
          ],
        ),
        const SizedBox(height: 22),
        Semantics(
          header: true,
          child: Text(
            'Where we commuting to?',
            style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 4),
        Text('Plan smarter. Move better.', style: TextStyle(color: context.colors.muted, fontSize: 15)),
        const SizedBox(height: 16),
      ],
    ),
  );
}

class _SearchCard extends StatelessWidget {
  const _SearchCard(this.vm);

  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget field({
      required String label,
      required Endpoint? value,
      required Widget icon,
      required VoidCallback onTap,
      required VoidCallback onClear,
    }) => Semantics(
      button: true,
      label: value == null ? 'Choose $label' : '$label: ${value.displayName}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
          child: Row(
            children: [
              SizedBox(width: 24, child: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: context.text.bodySmall?.copyWith(color: c.muted)),
                    const SizedBox(height: 2),
                    Text(
                      value?.displayName ?? (label == 'From' ? 'Where are you?' : 'Where to?'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: value == null ? c.muted : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (value != null)
                IconButton(
                  tooltip: 'Clear $label',
                  onPressed: onClear,
                  icon: Icon(Icons.close, size: 20, color: c.muted),
                ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  field(
                    label: 'From',
                    value: vm.from,
                    icon: const Icon(Icons.radio_button_unchecked, size: 20),
                    onTap: vm.pickFrom,
                    onClear: vm.clearFrom,
                  ),
                  const Divider(),
                  field(
                    label: 'To',
                    value: vm.to,
                    icon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                    onTap: vm.pickTo,
                    onClear: vm.clearTo,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: 'Swap From and To',
            excludeSemantics: true,
            child: Material(
              shape: CircleBorder(side: BorderSide(color: c.cardBorder)),
              color: c.card,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: vm.from == null && vm.to == null ? null : vm.swap,
                child: const SizedBox(width: 52, height: 52, child: Icon(Icons.swap_vert)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhenRow extends StatelessWidget {
  const _WhenRow(this.vm);

  final HomeViewModel vm;

  Future<void> _pick(BuildContext context, {required bool arrive}) async {
    final now = const SastClock().minutesNow.round();
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now ~/ 60 % 24, minute: now % 60),
      helpText: arrive ? 'Arrive by' : 'Depart at',
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (t == null) return;
    final m = t.hour * 60 + t.minute;
    await (arrive ? vm.setWhen(arriveBy: m) : vm.setWhen(departAt: m));
  }

  @override
  Widget build(BuildContext context) {
    final count = vm.filters.activeCount;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          PopupMenuButton<String>(
            tooltip: 'When',
            onSelected: (v) => switch (v) {
              'now' => vm.setWhen(),
              'allDay' => vm.setAllDay(),
              'depart' => _pick(context, arrive: false),
              'arrive' => _pick(context, arrive: true),
              _ => null,
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'now', child: Text('Depart now')),
              PopupMenuItem(value: 'allDay', child: Text('All day')),
              PopupMenuItem(value: 'depart', child: Text('Depart at…')),
              PopupMenuItem(value: 'arrive', child: Text('Arrive by…')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, color: onSurface, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    vm.filters.departAfter == null && vm.filters.arriveBy == null && vm.filters.date == null
                        ? 'Depart now'
                        : vm.whenLabel,
                    style: const TextStyle(fontSize: 15),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: onSurface),
                ],
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: vm.openFilters,
            style: TextButton.styleFrom(foregroundColor: onSurface),
            child: Row(
              children: [
                const Text('Filter', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 10),
                Badge(isLabelVisible: count > 0, label: Text('$count'), child: const Icon(Icons.tune)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The five shortcuts under the search, with Search selected.
class _QuickNav extends StatelessWidget {
  const _QuickNav(this.vm);

  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    final items = [
      (Icons.search, 'Search', null as AppTab?),
      (Icons.format_list_bulleted, 'Planner', AppTab.planner),
      (Icons.directions_bus_outlined, 'Live Journey', AppTab.trip),
      (Icons.explore_outlined, 'Explore', AppTab.explore),
      (Icons.person_outline, 'Profile', AppTab.profile),
    ];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: c.infoSurface,
        border: Border.symmetric(horizontal: BorderSide(color: c.cardBorder)),
      ),
      child: Row(
        children: [
          for (final (icon, label, tab) in items)
            Expanded(
              child: InkWell(
                onTap: tab == null ? null : () => vm.goTab(tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: tab == null ? accent : Colors.transparent, width: 2)),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: tab == null ? accent : null, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: tab == null ? accent : null),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProblemView extends StatelessWidget {
  const _ProblemView(this.vm, this.problem);

  final HomeViewModel vm;
  final SearchProblem problem;

  @override
  Widget build(BuildContext context) => switch (problem) {
    SearchProblem.notSavedOffline => EmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'This trip isn\'t saved for offline',
      message: 'Connect once to search it. After that it works without data.',
      actionLabel: 'Try again',
      onAction: vm.search,
    ),
    SearchProblem.rejected => EmptyState(
      icon: Icons.error_outline,
      title: 'We couldn\'t plan that trip',
      message: 'Try choosing a stop or station from the list for both From and To.',
      actionLabel: 'Report a problem',
      onAction: vm.reportProblem,
    ),
    SearchProblem.server => EmptyState(
      icon: Icons.cloud_sync_outlined,
      title: 'Commuttr is having trouble',
      message: 'Please try again in a minute.',
      actionLabel: 'Try again',
      onAction: vm.search,
    ),
    // Not "we couldn't plan that trip": nothing is wrong with what the rider asked for,
    // and unlike a rejected request this one works on a second go.
    SearchProblem.busy => EmptyState(
      icon: Icons.hourglass_empty,
      title: 'Commuttr is busy right now',
      message: 'Too many searches at once. Give it a few seconds and try again.',
      actionLabel: 'Try again',
      onAction: vm.search,
    ),
  };
}

/// "Your planner": the next saved journey as two numbered stops and Start journey.
class _PlannerCard extends StatelessWidget {
  const _PlannerCard(this.vm);

  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final j = vm.plannerCard!;
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    String stopLine(Endpoint e) => e.isStop ? 'Stop ID: ${e.id.toString().padLeft(4, '0')}' : 'Map point';
    Widget stop(String n, String name, String sub) => Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent, width: 1.5),
          ),
          child: Text(
            n,
            style: TextStyle(color: accent, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
              Text(sub, style: TextStyle(color: c.muted, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
    return Column(
      children: [
        const SectionHeader('Your planner', padding: EdgeInsets.fromLTRB(20, 20, 8, 10)),
        Padding(
          padding: pagePadding,
          child: AppCard(
            onTap: vm.openPlanned,
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 16),
            child: Column(
              children: [
                // On its own line with the menu, not floated over the card: as a
                // Positioned it ran under the three dots and off the edge, so a
                // Metrorail line came out as "Metrorail Souther".
                //
                // Left, on the card's own edge, with the stop numbers and the button
                // below it. Right-aligned it started a second column of one, and the
                // journey beneath read as though it had been pushed out of line.
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        // "Metrorail Southern line", as the rest of the app words it.
                        '${j.operator.name} ${j.routeNumber}${j.operator.isTrain ? ' line' : ''}',
                        style: TextStyle(color: accent, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      tooltip: 'More',
                      icon: const Icon(Icons.more_vert),
                      onSelected: (v) => v == 'view' ? vm.openPlanned() : vm.openPlanner(),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'view', child: Text('View trip')),
                        PopupMenuItem(value: 'planner', child: Text('Open planner')),
                      ],
                    ),
                  ],
                ),
                stop('1', j.from.displayName, 'Departs ${j.boardTime}  •  ${stopLine(j.from)}'),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: SizedBox(height: 18, child: CustomPaint(painter: _DashPainter(accent))),
                  ),
                ),
                stop('2', j.to.displayName, j.arriveTime == null ? 'Arrival not published' : 'Arrives ${j.arriveTime}'),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: vm.startingJourney ? null : vm.startPlanned,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Spacer(), Text('Start journey'), Spacer(), Icon(Icons.arrow_forward)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    for (double y = 0; y < size.height; y += 5) {
      canvas.drawLine(Offset(0, y), Offset(0, (y + 3).clamp(0, size.height)), p);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

class _ExploreRow extends StatelessWidget {
  const _ExploreRow(this.vm);

  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final c = context.colors;
    Widget tile(IconData icon, String title, String sub, VoidCallback onTap) => Expanded(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 26),
            const SizedBox(height: 10),
            Text(title, style: context.text.titleSmall),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(sub, style: TextStyle(color: c.muted, fontSize: 12)),
                ),
                Icon(Icons.arrow_forward, size: 16, color: c.muted),
              ],
            ),
          ],
        ),
      ),
    );
    return Column(
      children: [
        SectionHeader(
          'Explore',
          actionLabel: 'See all',
          onAction: vm.openExplore,
          padding: const EdgeInsets.fromLTRB(20, 20, 8, 10),
        ),
        Padding(
          padding: pagePadding,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tile(
                  Icons.directions_bus_outlined,
                  'Golden Arrow Timetables',
                  'Plan your trip with up-to-date schedules.',
                  vm.openExplore,
                ),
                const SizedBox(width: 10),
                tile(
                  Icons.campaign_outlined,
                  'Partner updates',
                  'Discover offers and updates from our mobility partners.',
                  vm.openExplore,
                ),
                const SizedBox(width: 10),
                tile(
                  Icons.location_on_outlined,
                  'Plan better',
                  'Tips and guides to help you travel smarter.',
                  vm.openHelp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
