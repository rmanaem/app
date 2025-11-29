import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/sex.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/goal_configuration_vm.dart';

void main() {
  group('GoalConfigurationVm Regression Tests', () {
    test('adjustToSafeRate sets rate to keep calories at minimum', () {
      // Setup: User with TDEE approx 2500 (Male, 80kg, 180cm, 30yo, Moderate)
      // BMR = (10*80) + (6.25*180) - (5*30) + 5 = 800 + 1125 - 150 + 5 = 1780
      // TDEE = 1780 * 1.55 = 2759 kcal

      final vm = GoalConfigurationVm(
        goal: Goal.lose,
        sex: Sex.male,
        currentWeight: BodyWeight.fromKg(80),
        height: Stature.fromCm(180),
        ageYears: 30,
        activity: ActivityLevel.moderatelyActive,
        initialTargetWeightKg: 75,
        initialWeeklyRateKg: -1, // -1100 kcal deficit -> 1659 kcal (Below 1800)
      );

      // Verify initial state is unsafe
      expect(vm.showingSafetyWarning, isTrue);
      expect(vm.dailyKcal, equals(1800)); // Clamped

      // Act: Adjust to safe rate
      vm.adjustToSafeRate();

      // Verify
      expect(vm.showingSafetyWarning, isFalse);

      // Expected Safe Rate:
      // 1800 = 2759 + (Rate * 1100)
      // Rate * 1100 = 1800 - 2759 = -959
      // Rate = -959 / 1100 ≈ -0.87 kg/week
      expect(vm.weeklyRateKg, closeTo(-0.87, 0.01));

      // Calories should be exactly 1800 (or very close)
      expect(vm.dailyKcal, closeTo(1800, 1));
    });
  });
}
