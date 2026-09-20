import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.dialogs.dart';
import '../../../app/app.locator.dart';
import '../../../services/settings_service.dart';

/// Show "How Commuttr works" and remember that it was seen.
Future<void> showOnboarding() async {
  await locator<DialogService>().showCustomDialog(variant: DialogType.onboarding, barrierDismissible: false);
  await locator<SettingsService>().markOnboardingSeen();
}
