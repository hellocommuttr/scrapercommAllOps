import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../services/shell_service.dart';
import '../theme/app_theme.dart';

/// The five-tab bar from the designs: Home, Planner, Live Journey, Explore, Profile.
///
/// Shown on the tab shell and on screens pushed over it (Help, Notifications, Edit
/// profile, Terms), where tapping a tab closes the pushed screens and switches tab.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current, this.onSelect});

  final AppTab current;

  /// Defaults to popping back to the shell and switching tab.
  final ValueChanged<AppTab>? onSelect;

  static const _items = [
    (AppTab.home, Icons.home_outlined, Icons.home, 'Home'),
    (AppTab.planner, Icons.format_list_bulleted, Icons.format_list_bulleted, 'Planner'),
    (AppTab.trip, Icons.directions_bus_outlined, Icons.directions_bus, 'Live Journey'),
    (AppTab.explore, Icons.explore_outlined, Icons.explore, 'Explore'),
    (AppTab.profile, Icons.person_outline, Icons.person, 'Profile'),
  ];

  void _select(AppTab tab) {
    if (onSelect != null) return onSelect!(tab);
    locator<NavigationService>().popUntil((r) => r.isFirst);
    locator<ShellService>().go(tab);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.cardBorder)),
          ),
          child: Row(
            children: [
              for (final (tab, icon, selectedIcon, label) in _items)
                Expanded(
                  child: Semantics(
                    selected: tab == current,
                    button: true,
                    label: label,
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () => _select(tab),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tab == current ? selectedIcon : icon,
                            color: tab == current ? accent : c.muted,
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: tab == current ? accent : c.muted,
                              fontWeight: tab == current ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
