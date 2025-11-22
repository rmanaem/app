import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/features/onboarding/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/onboarding/domain/repositories/plan_repository.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/navigation/onboarding_summary_arguments.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/onboarding_summary_page.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_summary_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';

class MockPlanRepository extends Mock implements PlanRepository {}

class FakeUserPlan extends Fake implements UserPlan {}

void main() {
  group('OnboardingSummaryPage', () {
    late PlanRepository mockRepo;
    late OnboardingSummaryVm vm;

    setUpAll(() {
      registerFallbackValue(FakeUserPlan());
    });

    setUp(() {
      mockRepo = MockPlanRepository();
      when(() => mockRepo.save(any())).thenAnswer((_) async => 'planId');

      vm = OnboardingSummaryVm(
        goal: Goal.lose,
        dob: DateTime(1990),
        heightCm: 180,
        currentWeightKg: 80,
        activity: ActivityLevel.moderatelyActive,
        targetWeightKg: 75,
        weeklyRateKg: -0.5,
        dailyCalories: 2000,
        projectedEndDate: DateTime(2024, 12, 31),
        createdAt: DateTime.now(),
        repository: mockRepo,
      );
    });

    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          Provider<PlanRepository>.value(value: mockRepo),
          ChangeNotifierProvider<OnboardingSummaryVm>.value(value: vm),
        ],
        child: MaterialApp(
          theme: makeTheme(AppColors.light, dark: false),
          home: OnboardingSummaryPage(
            args: OnboardingSummaryArguments(
              goal: Goal.lose,
              dob: DateTime(1990),
              heightCm: 180,
              weightKg: 80,
              activity: ActivityLevel.moderatelyActive,
              targetWeightKg: 75,
              weeklyRateKg: -0.5,
              dailyCalories: 2000,
              projectedEnd: DateTime.now(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders summary data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingProgressBar), findsOneWidget);
      expect(find.text('Review your plan'), findsOneWidget);
      expect(find.text('Summary of your plan'), findsOneWidget);

      // Scroll to nutrition card
      // await tester.scrollUntilVisible(find.text('2000'), 500);
      // expect(find.text('2000'), findsOneWidget); // Calories
      // expect(find.text('kcal'), findsOneWidget);
    });

    testWidgets('tapping Get started saves plan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final button = find.byType(FilledButton);
      await tester.scrollUntilVisible(button, 500);
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pump(); // Start saving

      verify(() => mockRepo.save(any())).called(1);
    });
  });
}
