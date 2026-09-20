import 'package:stacked/stacked.dart';

import '../data/models/models.dart';

enum AppTab { home, planner, trip, explore, profile }

/// Which bottom-navigation tab is showing, so one screen can send the commuter to
/// another tab ("Add journey" -> Home, "Start trip" -> On my trip).
class ShellService with ListenableServiceMixin {
  ShellService() {
    listenToReactiveValues([_tab]);
  }

  final ReactiveValue<AppTab> _tab = ReactiveValue(AppTab.home);

  AppTab get tab => _tab.value;

  /// A trip another screen asked Home to search for (a saved or frequent trip).
  (Endpoint, Endpoint)? pendingSearch;

  void go(AppTab tab) => _tab.value = tab;

  /// A start point another screen chose ("Plan from here" on a nearby stop).
  Endpoint? pendingFrom;

  void planFrom(Endpoint from) {
    pendingFrom = from;
    _tab.value = AppTab.home;
    notifyListeners();
  }

  void searchOnHome(Endpoint from, Endpoint to) {
    pendingSearch = (from, to);
    _tab.value = AppTab.home;
    notifyListeners();
  }
}
