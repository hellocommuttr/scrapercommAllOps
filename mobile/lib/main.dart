import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/app.bottomsheets.dart';
import 'app/app.dialogs.dart';
import 'app/app.locator.dart';
import 'app/app.router.dart';
import 'core/crash_reporting.dart';
import 'services/settings_service.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  // Before runApp, so a crash while the first screen builds is still reported.
  CrashReporting.install();
  runApp(const CommuttrApp());
}

class CommuttrApp extends StackedView<CommuttrAppModel> {
  const CommuttrApp({super.key});

  @override
  Widget builder(BuildContext context, CommuttrAppModel viewModel, Widget? child) => MaterialApp(
    title: 'Commuttr',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: viewModel.themeMode,
    initialRoute: Routes.startupView,
    onGenerateRoute: StackedRouter().onGenerateRoute,
    navigatorKey: StackedService.navigatorKey,
    navigatorObservers: [StackedService.routeObserver],
    // Accessibility preferences from Profile: larger text, bold text, reduced motion.
    builder: (context, child) {
      final mq = MediaQuery.of(context);
      return MediaQuery(
        data: mq.copyWith(
          textScaler: TextScaler.linear(mq.textScaler.scale(1) * viewModel.textScale),
          boldText: mq.boldText || viewModel.boldText,
          disableAnimations: mq.disableAnimations || viewModel.reduceMotion,
        ),
        child: child!,
      );
    },
  );

  @override
  CommuttrAppModel viewModelBuilder(BuildContext context) => CommuttrAppModel();
}

/// Rebuilds the app when the theme or accessibility preferences change.
class CommuttrAppModel extends ReactiveViewModel {
  final _settings = locator<SettingsService>();

  ThemeMode get themeMode => _settings.themeMode;
  double get textScale => _settings.textScale;
  bool get boldText => _settings.boldText;
  bool get reduceMotion => _settings.reduceMotion;

  @override
  List<ListenableServiceMixin> get listenableServices => [_settings];
}
