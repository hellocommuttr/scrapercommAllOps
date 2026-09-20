import 'dart:async';

import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/shell_service.dart';
import '../../../services/support_service.dart';

/// Commuttr has no accounts, so "Log out" and "Delete account" both clear this device
/// and restart at the splash. Returns false when the commuter cancelled.
Future<bool> confirmAndEraseDevice({
  required String title,
  required String confirmLabel,
  String description = 'This clears your profile, planner and favourites from this device.',
}) async {
  final r = await locator<DialogService>().showConfirmationDialog(
    title: title,
    description: description,
    confirmationTitle: confirmLabel,
    cancelTitle: 'Cancel',
    barrierDismissible: true,
  );
  if (!(r?.confirmed ?? false)) return false;
  await locator<SupportService>().eraseEverything();
  locator<ShellService>().go(AppTab.home);
  unawaited(locator<NavigationService>().clearStackAndShow(Routes.startupView));
  return true;
}
