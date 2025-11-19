import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/core/analytics/analytics_service.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/onboarding_stats_page.dart';

class _FakeAnalyticsService implements AnalyticsService {
  @override
  Future<void> onboardingGoalImpression() async {}

  @override
  Future<void> onboardingGoalNext(String goal) async {}

  @override
  Future<void> onboardingGoalSelected(String goal) async {}

  @override
  Future<void> onboardingStatsImpression() async {}

  @override
  Future<void> onboardingStatsNext({
    required String unitSystem,
    required String activity,
  }) async {}

  @override
  Future<void> onboardingStatsUnitChanged(String unitSystem) async {}
}

void main() {
  testWidgets(
    'stats page renders with default values',
    (tester) async {
      await tester.pumpWidget(
        Provider<AnalyticsService>.value(
          value: _FakeAnalyticsService(),
          child: MaterialApp(
            theme: makeTheme(AppColors.light, dark: false),
            home: const OnboardingStatsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('About you'), findsOneWidget);
      expect(find.text('Date of birth'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'height picker opens and interacts without exceptions',
    (tester) async {
      await tester.pumpWidget(
        Provider<AnalyticsService>.value(
          value: _FakeAnalyticsService(),
          child: MaterialApp(
            theme: makeTheme(AppColors.light, dark: false),
            home: const OnboardingStatsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Height'));
      await tester.pumpAndSettle();

      expect(find.text('Height'), findsNWidgets(2)); // card + sheet title
      expect(
        () => tester.drag(
          find.byType(CupertinoPicker).first,
          const Offset(0, -50),
        ),
        returnsNormally,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
