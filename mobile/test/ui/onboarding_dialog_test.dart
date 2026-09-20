import 'package:commuttr/ui/dialogs/onboarding/onboarding_dialog.dart';
import 'package:commuttr/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';

Future<List<DialogResponse<dynamic>>> pumpDialog(WidgetTester tester) async {
  final responses = <DialogResponse<dynamic>>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: OnboardingDialog(request: DialogRequest(), completer: responses.add),
      ),
    ),
  );
  return responses;
}

void main() {
  testWidgets('walks through three steps and finishes', (tester) async {
    final responses = await pumpDialog(tester);
    expect(find.text('Find your bus or train'), findsOneWidget);
    expect(find.textContaining('scheduled, not live'), findsOneWidget);
    expect(find.textContaining('not affiliated with Golden Arrow, MyCiTi or Metrorail'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Save it, get reminded'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Works offline, stays private'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    expect(responses.single.confirmed, isTrue);
  });

  testWidgets('can be skipped from the first step', (tester) async {
    final responses = await pumpDialog(tester);
    await tester.tap(find.text('Skip'));
    expect(responses, hasLength(1));
  });
}
