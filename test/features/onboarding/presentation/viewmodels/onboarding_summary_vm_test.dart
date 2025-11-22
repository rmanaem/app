import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/src/features/onboarding/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/onboarding/domain/repositories/plan_repository.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/navigation/onboarding_summary_arguments.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_summary_vm.dart';

class MockPlanRepository extends Mock implements PlanRepository {}

void main() {
  group('OnboardingSummaryVm', () {
    late PlanRepository mockRepo;
    late OnboardingSummaryVm vm;
    late OnboardingSummaryArguments args;

    setUp(() {
      mockRepo = MockPlanRepository();
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
        repository: mockRepo,
        goal: args.goal,
        dob: args.dob,
        heightCm: args.heightCm,
        currentWeightKg: args.weightKg,
        activity: args.activity,
        targetWeightKg: args.targetWeightKg,
        weeklyRateKg: args.weeklyRateKg,
        dailyCalories: args.dailyCalories,
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
          projectedEndDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
    });

    test('initial state matches arguments', () {
      expect(vm.state.goal, args.goal);
      expect(vm.state.targetWeightKg, args.targetWeightKg);
      expect(vm.state.dailyCalories, args.dailyCalories);
    });

    test('savePlan calls repository and returns ID', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async => 'plan_123');

      final id = await vm.savePlan();

      expect(id, 'plan_123');
      verify(() => mockRepo.save(any())).called(1);
    });

    test('savePlan sets isSaving state', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async {
        expect(vm.state.isSaving, isTrue);
        return 'plan_123';
      });

      await vm.savePlan();
      expect(vm.state.isSaving, isFalse);
    });
  });
}
