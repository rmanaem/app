import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:starter_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full onboarding flow happy path', (tester) async {
    // 1. Launch App
    await app.main();
    await tester.pumpAndSettle();

    // 2. Welcome Screen -> Get Started
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // 3. Goal Selection
    expect(find.text("What's your goal?"), findsOneWidget);
    await tester.tap(find.text('Lose weight'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // 4. Stats Entry
    expect(find.text('Tell us about you'), findsOneWidget);

    // Fill DOB
    await tester.tap(find.text('Date of Birth'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('Confirm'),
    ); // Assuming default picker value is valid
    await tester.pumpAndSettle();

    // Fill Height
    await tester.tap(find.text('Height'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    // Fill Weight
    await tester.tap(find.text('Weight'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    // Fill Activity
    await tester.tap(find.text('Activity Level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moderate')); // Select an option
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // 5. Plan Preview
    expect(find.text('Daily Calories'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // 6. Summary
    expect(find.text('Ready to start?'), findsOneWidget);
    await tester.tap(find.text('Start tracking'));
    await tester.pumpAndSettle();

    // 7. Verify Shell (Today Tab)
    expect(find.text('Today'), findsOneWidget);
    expect(find.byIcon(Icons.dashboard), findsOneWidget);
  });
}
