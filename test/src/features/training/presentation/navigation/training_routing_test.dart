import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/app/app.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:starter_app/src/features/training/presentation/pages/active_session_page.dart';
import 'package:starter_app/src/features/training/presentation/pages/session_summary_page.dart';
import 'package:starter_app/src/features/training/presentation/pages/training_page.dart';

void main() {
  testWidgets(
    'Navigating to /training/session/summary resolves to SessionSummaryPage',
    (tester) async {
      // 1. Pump the app
      await tester.pumpWidget(const App(envName: 'test'));
      await tester.pumpAndSettle();

      // 2. Navigate to the summary page
      // (mimicking the deep link or internal navigation)
      final context = tester.element(find.byType(WelcomePage));

      // We need to pass the extra object as required by the route
      final result = SessionResult(
        durationSeconds: 60,
        totalVolume: 1000,
        totalSets: 5,
        prCount: 1,
      );

      context.go('/training/session/summary', extra: result);
      await tester.pumpAndSettle();

      // 3. Verify SessionSummaryPage is present
      expect(find.byType(SessionSummaryPage), findsOneWidget);

      // 4. Verification of the bug fix:
      // Ensure ActiveSessionPage is NOT present.
      // If route ordering was wrong, 'summary' would be captured as :workoutId,
      // and ActiveSessionPage would be rendered.
      expect(find.byType(ActiveSessionPage), findsNothing);
    },
  );

  testWidgets(
    'Navigating to /training/session/123 resolves to ActiveSessionPage',
    (tester) async {
      await tester.pumpWidget(const App(envName: 'test'));
      await tester.pumpAndSettle();

      tester.element(find.byType(WelcomePage)).go('/training/session/123');
      await tester.pumpAndSettle();

      expect(find.byType(ActiveSessionPage), findsOneWidget);
      expect(find.byType(SessionSummaryPage), findsNothing);
    },
  );
  testWidgets(
    'Return to Dashboard button navigates to /training',
    (tester) async {
      await tester.pumpWidget(const App(envName: 'test'));
      await tester.pumpAndSettle();

      // 1. Start at Summary Page
      final context = tester.element(find.byType(WelcomePage));
      final result = SessionResult(
        durationSeconds: 10,
        totalVolume: 100,
        totalSets: 1,
      );
      context.go('/training/session/summary', extra: result);
      await tester.pumpAndSettle();

      expect(find.byType(SessionSummaryPage), findsOneWidget);

      // 2. Tap Return to Dashboard
      await tester.tap(find.text('RETURN TO DASHBOARD'));
      await tester.pumpAndSettle();

      // 3. Verify Navigation
      expect(find.byType(SessionSummaryPage), findsNothing);
      expect(find.byType(TrainingPage), findsOneWidget);
    },
  );
}
