// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedDialogGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/dialogs/onboarding/onboarding_dialog.dart';

enum DialogType { onboarding }

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final Map<DialogType, DialogBuilder> builders = {
    DialogType.onboarding: (context, request, completer) =>
        OnboardingDialog(request: request, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
