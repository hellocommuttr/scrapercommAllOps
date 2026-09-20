import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../widgets/app_bottom_nav.dart';
import '../explore/explore_view.dart';
import '../home/home_view.dart';
import '../on_trip/on_trip_view.dart';
import '../planner/planner_view.dart';
import '../profile/profile_view.dart';
import 'main_viewmodel.dart';

class MainView extends StackedView<MainViewModel> {
  const MainView({super.key});

  @override
  Widget builder(BuildContext context, MainViewModel viewModel, Widget? child) => Scaffold(
    // IndexedStack keeps each tab's scroll position and loaded data.
    body: IndexedStack(
      index: viewModel.tab.index,
      children: const [HomeView(), PlannerView(), OnTripView(), ExploreView(), ProfileView()],
    ),
    bottomNavigationBar: AppBottomNav(current: viewModel.tab, onSelect: (t) => viewModel.select(t.index)),
  );

  @override
  MainViewModel viewModelBuilder(BuildContext context) => MainViewModel();
}
