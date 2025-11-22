import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/onboarding_goal_page.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewstate/onboarding_goal_view_state.dart';

class MockOnboardingVm extends Mock implements OnboardingVm {}

void main() {
  group('OnboardingGoalPage', () {
    late OnboardingVm mockVm;

    setUp(() {
      mockVm = MockOnboardingVm();
      when(() => mockVm.goalState).thenReturn(const OnboardingGoalViewState());
      when(() => mockVm.logGoalScreenViewed()).thenAnswer((_) async {});
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<OnboardingVm>.value(
        value: mockVm,
        child: MaterialApp(
          theme: makeTheme(AppColors.light, dark: false),
          home: const OnboardingGoalPage(),
        ),
      );
    }

    testWidgets('renders title and options', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text("What's your primary goal?"), findsOneWidget);
      expect(find.text('Lose Weight'), findsOneWidget);
      expect(find.text('Maintain Weight'), findsOneWidget);
      expect(find.text('Gain Weight'), findsOneWidget);
    });

    testWidgets('tapping an option updates VM', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Lose Weight'));
      verify(() => mockVm.selectGoal(Goal.lose)).called(1);
    });

    testWidgets('Next button is disabled initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final nextButton = find.widgetWithText(FilledButton, 'Next');
      expect(tester.widget<FilledButton>(nextButton).onPressed, isNull);
    });

    testWidgets('Next button is enabled when canContinue is true', (
      tester,
    ) async {
      when(
        () => mockVm.goalState,
      ).thenReturn(const OnboardingGoalViewState(selected: Goal.lose));
      await tester.pumpWidget(createWidgetUnderTest());

      final nextButton = find.widgetWithText(FilledButton, 'Next');
      expect(tester.widget<FilledButton>(nextButton).onPressed, isNotNull);
    });
  });
}
