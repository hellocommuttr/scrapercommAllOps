import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../theme/app_theme.dart';

class _Step {
  const _Step(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}

/// "How Commuttr works": three short, skippable cards shown the first time Home opens,
/// and again from Profile or Help.
class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({super.key, required this.request, required this.completer});

  final DialogRequest<dynamic> request;
  final void Function(DialogResponse<dynamic>) completer;

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  static const _steps = [
    _Step(
      Icons.alt_route_rounded,
      'Find your bus or train',
      'Pick where you are and where you\'re going. Commuttr shows the next Golden Arrow buses, '
          'MyCiTi buses and Metrorail trains for the day you travel, with the first and last one.',
    ),
    _Step(
      Icons.notifications_active_outlined,
      'Save it, get reminded',
      'Add a trip to your planner. On your phone we can remind you when it\'s time to leave, '
          'and when your stop is next, even with the app closed.',
    ),
    _Step(
      Icons.cloud_off_outlined,
      'Works offline, stays private',
      'Timetables are saved on your phone, so trips you\'ve looked up work without data. '
          'There\'s no account: your planner stays on this device.',
    ),
  ];

  final _pages = PageController();
  int _index = 0;

  bool get _last => _index == _steps.length - 1;

  void _close() => widget.completer(DialogResponse(confirmed: true));

  void _next() {
    if (_last) return _close();
    _pages.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = Theme.of(context).colorScheme.primary;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Semantics(header: true, child: Text('How Commuttr works', style: context.text.titleMedium)),
                  const Spacer(),
                  TextButton(onPressed: _close, child: const Text('Skip')),
                ],
              ),
              SizedBox(
                height: 270,
                child: PageView.builder(
                  controller: _pages,
                  itemCount: _steps.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final s = _steps[i];
                    // Scrolls, so large system text sizes never clip the explanation.
                    return Semantics(
                      label: 'Step ${i + 1} of ${_steps.length}',
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: accent, width: 1.5),
                              ),
                              child: Icon(s.icon, size: 34, color: accent),
                            ),
                            const SizedBox(height: 18),
                            Text(s.title, style: context.text.titleLarge, textAlign: TextAlign.center),
                            const SizedBox(height: 10),
                            Text(
                              s.body,
                              textAlign: TextAlign.center,
                              style: context.text.bodyMedium?.copyWith(color: c.muted, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _index ? accent : c.cardBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Times come from the operators\' published timetables, so they are scheduled, not live. '
                'Commuttr is independent and not affiliated with Golden Arrow, MyCiTi or Metrorail.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(color: c.muted),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _next, child: Text(_last ? 'Get started' : 'Next')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
