import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';

import '../../theme/app_theme.dart';
import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

  @override
  Widget builder(BuildContext context, StartupViewModel viewModel, Widget? child) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Image.asset('assets/images/commuttr-transparent.png', width: 180, fit: BoxFit.contain),
              const SizedBox(height: 20),
              //Text('Commuttr', style: context.text.headlineMedium),
              const SizedBox(height: 6),
              Text('Plan smarter. Move better.', style: TextStyle(color: context.colors.muted)),
              const Spacer(flex: 2),
              if (viewModel.failure == null) ...[
                const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)),
                const SizedBox(height: 14),
                Text(viewModel.status, style: TextStyle(color: context.colors.muted)),
              ] else ...[
                Text(viewModel.failure!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: viewModel.runStartupLogic, child: const Text('Try again')),
              ],
              const Spacer(),
              Text(
                'Independent app. Not affiliated with or endorsed by Golden Arrow Bus Services, '
                'MyCiTi (City of Cape Town) or Metrorail (PRASA).',
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(color: context.colors.muted),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) =>
      SchedulerBinding.instance.addPostFrameCallback((_) => viewModel.runStartupLogic());
}
