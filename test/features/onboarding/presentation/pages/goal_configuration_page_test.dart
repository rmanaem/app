import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/goal_configuration_page.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewstate/onboarding_goal_view_state.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewstate/onboarding_stats_view_state.dart';

class MockOnboardingVm extends Mock implements OnboardingVm {}

void main() {
  group('GoalConfigurationPage', () {
    late OnboardingVm mockVm;

    setUp(() {
      mockVm = MockOnboardingVm();
      when(() => mockVm.goalState).thenReturn(
        const OnboardingGoalViewState(selected: Goal.lose),
      );
      when(() => mockVm.statsState).thenReturn(
        OnboardingStatsViewState(
          dob: DateTime(1990),
          height: Stature.fromCm(180),
          weight: BodyWeight.fromKg(80),
          activity: ActivityLevel.moderatelyActive,
          unitSystem: UnitSystem.metric,
        ),
      );
      // Also mock goalConfigurationState as it might be accessed
      when(() => mockVm.goalConfigurationState).thenReturn(
        const GoalConfigurationState(),
      );
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<OnboardingVm>.value(
        value: mockVm,
        child: MaterialApp(
          theme: makeTheme(AppColors.light, dark: false),
          home: const GoalConfigurationPage(),
        ),
      );
    }

    testWidgets('renders metrics and sliders', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for VM initialization
      await tester.pumpAndSettle();

      expect(find.text('initial daily budget'), findsOneWidget);
      expect(find.text('projected end date'), findsOneWidget);
      expect(find.text('What is your target weight?'), findsOneWidget);
      expect(find.text('What is your target goal rate?'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('renders Next button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    });

    testWidgets('Adjust Goal button fixes unsafe rate', (tester) async {
      // Setup: Force unsafe condition via stats (Small Male)
      // BMR ~1517.
      // Sedentary (1.2) -> TDEE 1821. Min loss (-0.2) -> 1601 (Still Unsafe!)
      // Lightly Active (1.375) -> TDEE 2086.
      // Default Rate -0.5 -> 1536 (Unsafe)
      // Safe Rate exists: (1800 - 2086)/1100 = -0.26 kg/week.

      when(() => mockVm.goalState).thenReturn(
        const OnboardingGoalViewState(
          selected: Goal.lose,
        ),
      );

      when(() => mockVm.statsState).thenReturn(
        OnboardingStatsViewState(
          dob: DateTime(1990),
          height: Stature.fromCm(170),
          weight: BodyWeight.fromKg(60),
          activity: ActivityLevel.lightlyActive, // Changed from sedentary
          unitSystem: UnitSystem.metric,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 1. Verify Warning Banner is present
      expect(find.text('Below Safe Minimum'), findsOneWidget);
      expect(find.text('Adjust Goal'), findsOneWidget);

      // 2. Tap "Adjust Goal"
      await tester.tap(find.text('Adjust Goal'));
      await tester.pumpAndSettle();

      // 3. Verify Warning Banner is GONE
      expect(find.text('Below Safe Minimum'), findsNothing);

      // 4. Verify slider moved (optional, but good check)
      // Since we can't easily read slider value, we rely on banner
      // disappearance which confirms the VM updated the state to a safe value.
    });
  });
}
