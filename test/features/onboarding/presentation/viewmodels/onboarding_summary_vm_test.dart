import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/src/features/onboarding/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/onboarding/domain/usecases/save_user_plan.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/navigation/onboarding_summary_arguments.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_summary_vm.dart';

class MockSaveUserPlan extends Mock implements SaveUserPlan {}

void main() {
  group('OnboardingSummaryVm', () {
    late SaveUserPlan mockSaveUserPlan;
    late OnboardingSummaryVm vm;
    late OnboardingSummaryArguments args;

    setUp(() {
      mockSaveUserPlan = MockSaveUserPlan();
      args = OnboardingSummaryArguments(
        goal: Goal.lose,
        dob: DateTime(1990),
        heightCm: 180,
        weightKg: 80,
        activity: ActivityLevel.moderatelyActive,
        targetWeightKg: 75,
        weeklyRateKg: -0.5,
        dailyCalories: 2000,
        projectedEnd: DateTime.now().add(const Duration(days: 30)),
      );
      vm = OnboardingSummaryVm(
        saveUserPlan: mockSaveUserPlan,
        goal: args.goal,
        dob: args.dob,
        heightCm: args.heightCm,
        currentWeightKg: args.weightKg,
        activity: args.activity,
        targetWeightKg: args.targetWeightKg,
        weeklyRateKg: args.weeklyRateKg,
        dailyCalories: args.dailyCalories.toDouble(),
        projectedEndDate: args.projectedEnd,
        createdAt: DateTime.now(),
      );

      registerFallbackValue(
        UserPlan(
          goal: Goal.lose,
          dob: DateTime(1990),
          heightCm: 180,
          currentWeightKg: 80,
          activity: ActivityLevel.moderatelyActive,
          targetWeightKg: 75,
          weeklyRateKg: -0.5,
          dailyCalories: 2000,
          proteinGrams: 150,
          fatGrams: 70,
          carbGrams: 200,
          projectedEndDate: DateTime(2024, 6),
          createdAt: DateTime.now(),
        ),
      );
    });

    test('initial state matches arguments', () {
      expect(vm.state.goal, args.goal);
      expect(vm.state.targetWeightKg, args.targetWeightKg);
      expect(vm.state.dailyCalories, args.dailyCalories);
    });

    test('savePlan calls use case and returns ID', () async {
      when(() => mockSaveUserPlan(any())).thenAnswer((_) async => 'plan_123');

      final id = await vm.savePlan();

      expect(id, 'plan_123');
      verify(() => mockSaveUserPlan(any())).called(1);
    });

    test('savePlan sets isSaving state', () async {
      when(() => mockSaveUserPlan(any())).thenAnswer((_) async {
        expect(vm.state.isSaving, isTrue);
        return 'plan_123';
      });

      await vm.savePlan();
      expect(vm.state.isSaving, isFalse);
    });
  });
}
