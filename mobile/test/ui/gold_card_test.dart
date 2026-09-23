import 'package:commuttr/data/models/models.dart';
import 'package:commuttr/ui/theme/app_theme.dart';
import 'package:commuttr/ui/views/trip_detail/trip_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// What the Fare block says about Golden Arrow's Gold Card.
///
/// GO EASY is a bundle of rides: 5 for R134.00, 10 for R248.50, 48 for R1,093.00, used
/// whenever the rider travels. The screen read "Gold Card weekly, any number of trips
/// that week" and "monthly, any number of trips that month", which is a season ticket -
/// a different product. Somebody commuting twice a day would have run out on the Friday
/// of the second week believing they had paid for the month. The five-ride bundle was in
/// the data all along and was never shown.
void main() {
  const fare = Fare(
    fiveRideCents: 13400,
    weeklyCents: 24850,
    monthlyCents: 109300,
    basis: 'go_easy',
  );

  Future<void> pumpFare(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: SingleChildScrollView(child: FareCard(fare: fare, operator: OperatorRef.goldenArrow)),
      ),
    ),
  );

  testWidgets('all three bundles are shown, by rides and by price', (tester) async {
    await pumpFare(tester);

    expect(find.text('5 rides · R26.80 a ride'), findsOneWidget);
    expect(find.text('R134.00'), findsOneWidget);
    expect(find.text('10 rides · R24.85 a ride'), findsOneWidget);
    expect(find.text('R248.50'), findsOneWidget);
    expect(find.text('48 rides · R22.77 a ride'), findsOneWidget);
    expect(find.text('R1093.00'), findsOneWidget);
  });

  testWidgets('nothing claims a week or a month of travel', (tester) async {
    await pumpFare(tester);

    expect(find.textContaining('any number of trips'), findsNothing);
    expect(find.textContaining('weekly'), findsNothing);
    expect(find.textContaining('monthly'), findsNothing);
    // Still says what it is and where it does not work.
    expect(find.textContaining('No price for a single trip'), findsOneWidget);
    expect(find.textContaining('Not valid to or from Atlantis'), findsOneWidget);
  });
}
