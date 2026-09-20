import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../services/shell_service.dart';

/// The bottom-navigation shell. The selected tab lives in [ShellService] so any screen
/// can switch tabs.
class MainViewModel extends ReactiveViewModel {
  final _shell = locator<ShellService>();

  AppTab get tab => _shell.tab;

  void select(int index) => _shell.go(AppTab.values[index]);

  @override
  List<ListenableServiceMixin> get listenableServices => [_shell];
}
