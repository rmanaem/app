import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/src/features/onboarding/domain/preview_estimator.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/goal_configuration_vm.dart';

class MockPreviewEstimator extends Mock implements PreviewEstimator {}

void main() {
  group('GoalConfigurationVm', () {
    late PreviewEstimator mockEstimator;
    late GoalConfigurationVm vm;

    setUp(() {
      registerFallbackValue(Goal.lose);
      registerFallbackValue(ActivityLevel.moderate);
      mockEstimator = MockPreviewEstimator();

      // Stub estimator estimate
      when(
        () => mockEstimator.estimate(
          goal: any(named: 'goal'),
          currentWeightKg: any(named: 'currentWeightKg'),
          targetWeightKg: any(named: 'targetWeightKg'),
          weeklyRateKg: any(named: 'weeklyRateKg'),
          activityLevel: any(named: 'activityLevel'),
          heightCm: any(named: 'heightCm'),
          age: any(named: 'age'),
          isMale: any(named: 'isMale'),
        ),
      ).thenReturn(
        PreviewOutput(
          dailyKcal: 2000,
          projectedEndDate: DateTime.now().add(const Duration(days: 30)),
          proteinGrams: 150,
          carbsGrams: 200,
          fatGrams: 70,
        ),
      );

      vm = GoalConfigurationVm(
        goal: Goal.lose,
        height: Stature.fromCm(180),
        currentWeight: BodyWeight.fromKg(80),
        ageYears: 30,
        activity: ActivityLevel.moderate,
        initialTargetWeightKg: 75,
        initialWeeklyRateKg: -0.5,
        estimator: mockEstimator,
      );
    });

    test('initializes with correct values', () {
      expect(vm.targetWeightKg, 75);
      expect(vm.weeklyRateKg, -0.5);
      expect(vm.dailyKcal, 2000);
    });

    test('updating target weight updates state and re-estimates', () {
      vm.setTargetWeightKg(72);
      expect(vm.targetWeightKg, 72);
      verify(
        () => mockEstimator.estimate(
          goal: any(named: 'goal'),
          currentWeightKg: any(named: 'currentWeightKg'),
          targetWeightKg: 72,
          weeklyRateKg: any(named: 'weeklyRateKg'),
          activityLevel: any(named: 'activityLevel'),
          heightCm: any(named: 'heightCm'),
          age: any(named: 'age'),
          isMale: any(named: 'isMale'),
        ),
      ).called(1);
    });

    test('updating weekly rate updates state and re-estimates', () {
      vm.setWeeklyRateKg(-0.8);
      expect(vm.weeklyRateKg, -0.8);
      verify(
        () => mockEstimator.estimate(
          goal: any(named: 'goal'),
          currentWeightKg: any(named: 'currentWeightKg'),
          targetWeightKg: any(named: 'targetWeightKg'),
          weeklyRateKg: -0.8,
          activityLevel: any(named: 'activityLevel'),
          heightCm: any(named: 'heightCm'),
          age: any(named: 'age'),
          isMale: any(named: 'isMale'),
        ),
      ).called(1);
    });
  });
}
