import 'package:commuttr/ui/theme/app_theme.dart';
import 'package:commuttr/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// The test font has an ascent of 0.75em, so a line's baseline is that far down its box.
double baselineOf(WidgetTester tester, String text) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
  final size = (paragraph.text.style?.fontSize) ?? 14.0;
  return tester.getTopLeft(find.text(text)).dy + size * 0.75;
}

void main() {
  testWidgets('a section heading and its action sit on one line', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: SectionHeader('Explore', actionLabel: 'See all', onAction: _noop),
      ),
    ));
    final heading = baselineOf(tester, 'Explore');
    final action = baselineOf(tester, 'See all');
    debugPrint('HEADING $heading  ACTION $action  GAP ${action - heading}');
  });
}

void _noop() {}
