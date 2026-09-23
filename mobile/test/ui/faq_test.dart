import 'dart:convert';
import 'dart:io';

import 'package:commuttr/ui/theme/app_theme.dart';
import 'package:commuttr/ui/views/help/faq_entry.dart';
import 'package:commuttr/ui/views/help/help_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final entries = (jsonDecode(File('assets/content/faq.json').readAsStringSync()) as List)
      .cast<Map<String, dynamic>>()
      .map(FaqEntry.fromJson)
      .toList();

  testWidgets('an article opens and shows its answer', (tester) async {
    final entry = entries.firstWhere((e) => e.question == 'What is Commuttr?');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: ListView(children: [FaqCard(entries: [entry])])),
      ),
    );
    // Closed: the question shows, the answer does not.
    expect(find.text(entry.question), findsOneWidget);
    expect(find.text(entry.answer), findsNothing);

    await tester.tap(find.text(entry.question));
    await tester.pumpAndSettle();

    // Open: the answer is on screen as plain text. It used to be a SelectableText,
    // which the web build painted as a grey block, so every article looked empty.
    final answer = find.text(entry.answer);
    expect(answer, findsOneWidget);
    expect(find.byType(SelectableText), findsNothing);
    expect(tester.getSize(answer).height, greaterThan(0));
  });

  test('every article has a question and an answer', () {
    expect(entries, hasLength(42));
    expect(entries.where((e) => e.question.trim().isEmpty || e.answer.trim().isEmpty), isEmpty);
  });
}
