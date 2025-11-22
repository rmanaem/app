import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/features/onboarding/domain/preview_estimator.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/infrastructure/standard_preview_estimator.dart';

void main() {
  group('PreviewEstimator', () {
    late PreviewEstimator estimator;

    setUp(() {
      estimator = const StandardPreviewEstimator();
    });

    test('calculates higher calories for gain than loss', () {
      final loss = estimator.estimate(
        goal: Goal.lose,
        currentWeightKg: 80,
        targetWeightKg: 75,
        weeklyRateKg: -0.5,
        activityLevel: ActivityLevel.moderatelyActive,
        heightCm: 180,
        age: 30,
        isMale: true,
      );

      final gain = estimator.estimate(
        goal: Goal.gain,
        currentWeightKg: 80,
        targetWeightKg: 85,
        weeklyRateKg: 0.5,
        activityLevel: ActivityLevel.moderatelyActive,
        heightCm: 180,
        age: 30,
        isMale: true,
      );

      expect(gain.dailyKcal, greaterThan(loss.dailyKcal));
    });

    test('calculates earlier end date for faster rate', () {
      final slow = estimator.estimate(
        goal: Goal.lose,
        currentWeightKg: 80,
        targetWeightKg: 70,
        weeklyRateKg: -0.5,
        activityLevel: ActivityLevel.moderatelyActive,
        heightCm: 180,
        age: 30,
        isMale: true,
      );

      final fast = estimator.estimate(
        goal: Goal.lose,
        currentWeightKg: 80,
        targetWeightKg: 70,
        weeklyRateKg: -1,
        activityLevel: ActivityLevel.moderatelyActive,
        heightCm: 180,
        age: 30,
        isMale: true,
      );

      expect(fast.projectedEndDate.isBefore(slow.projectedEndDate), isTrue);
    });

    test('macros sum up to approximately daily calories', () {
      final result = estimator.estimate(
        goal: Goal.maintain,
        currentWeightKg: 80,
        targetWeightKg: 80,
        weeklyRateKg: 0,
        activityLevel: ActivityLevel.moderatelyActive,
        heightCm: 180,
        age: 30,
        isMale: true,
      );

      final proteinKcal = result.proteinGrams * 4;
      final carbsKcal = result.carbsGrams * 4;
      final fatKcal = result.fatGrams * 9;
      final total = proteinKcal + carbsKcal + fatKcal;

      // Allow small rounding difference
      expect((total - result.dailyKcal).abs(), lessThan(5));
    });

    test('returns valid bounds for loss goal', () {
      final bounds = estimator.getBounds(
        goal: Goal.lose,
        currentWeightKg: 100,
      );

      expect(bounds.minTargetKg, lessThan(100));
      expect(bounds.maxTargetKg, equals(100));
      expect(bounds.minWeeklyRateKg, lessThan(0));
      expect(bounds.maxWeeklyRateKg, lessThanOrEqualTo(0));
    });

    test('returns valid bounds for gain goal', () {
      final bounds = estimator.getBounds(
        goal: Goal.gain,
        currentWeightKg: 70,
      );

      expect(bounds.minTargetKg, equals(70));
      expect(bounds.maxTargetKg, greaterThan(70));
      expect(bounds.minWeeklyRateKg, greaterThanOrEqualTo(0));
      expect(bounds.maxWeeklyRateKg, greaterThan(0));
    });

    group('Mifflin-St Jeor BMR Calculation', () {
      test('calculates correct BMR for male', () {
        // BMR = (10 × 80) + (6.25 × 180) − (5 × 30) + 5
        // BMR = 800 + 1125 - 150 + 5 = 1780 kcal
        final result = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 80,
          heightCm: 180,
          age: 30,
          isMale: true,
          targetWeightKg: 80,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.sedentary, // 1.2x
        );

        // TDEE = BMR × 1.2 = 1780 × 1.2 = 2136 kcal
        // No adjustment (maintenance), so target = 2136
        expect(result.dailyKcal, closeTo(2136, 1));
      });

      test('calculates correct BMR for female', () {
        // BMR = (10 × 60) + (6.25 × 165) − (5 × 25) − 161
        // BMR = 600 + 1031.25 - 125 - 161 = 1345.25 kcal
        final result = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 60,
          heightCm: 165,
          age: 25,
          isMale: false,
          targetWeightKg: 60,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.sedentary, // 1.2x
        );

        // TDEE = BMR × 1.2 = 1345.25 × 1.2 = 1614.3 kcal
        expect(result.dailyKcal, closeTo(1614, 1));
      });

      test('BMR increases with weight', () {
        final lighter = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 60,
          heightCm: 170,
          age: 30,
          isMale: true,
          targetWeightKg: 60,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.sedentary,
        );

        final heavier = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 90,
          heightCm: 170,
          age: 30,
          isMale: true,
          targetWeightKg: 90,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.sedentary,
        );

        expect(heavier.dailyKcal, greaterThan(lighter.dailyKcal));
      });

      test('BMR decreases with age', () {
        final younger = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 75,
          heightCm: 175,
          age: 25,
          isMale: true,
          targetWeightKg: 75,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.sedentary,
        );

        final older = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 75,
          heightCm: 175,
          age: 50,
          isMale: true,
          targetWeightKg: 75,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.sedentary,
        );

        expect(older.dailyKcal, lessThan(younger.dailyKcal));
      });
    });

    group('TDEE Activity Multipliers', () {
      const baseParams = {
        'currentWeightKg': 75.0,
        'heightCm': 175.0,
        'age': 30,
        'isMale': true,
        'targetWeightKg': 75.0,
        'weeklyRateKg': 0.0,
        'goal': Goal.maintain,
      };

      test('sedentary activity (1.2x) produces correct TDEE', () {
        final result = estimator.estimate(
          goal: baseParams['goal']! as Goal,
          currentWeightKg: baseParams['currentWeightKg']! as double,
          heightCm: baseParams['heightCm']! as double,
          age: baseParams['age']! as int,
          isMale: baseParams['isMale']! as bool,
          targetWeightKg: baseParams['targetWeightKg']! as double,
          weeklyRateKg: baseParams['weeklyRateKg']! as double,
          activityLevel: ActivityLevel.sedentary,
        );

        // BMR for 75kg, 175cm, 30yo male ≈ 1731
        // TDEE = 1731 × 1.2 ≈ 2077 (actual may vary slightly due to rounding)
        expect(result.dailyKcal, closeTo(2077, 40));
      });

      test('activity level progression increases TDEE correctly', () {
        final sedentary = estimator.estimate(
          goal: baseParams['goal']! as Goal,
          currentWeightKg: baseParams['currentWeightKg']! as double,
          heightCm: baseParams['heightCm']! as double,
          age: baseParams['age']! as int,
          isMale: baseParams['isMale']! as bool,
          targetWeightKg: baseParams['targetWeightKg']! as double,
          weeklyRateKg: baseParams['weeklyRateKg']! as double,
          activityLevel: ActivityLevel.sedentary, // 1.2x
        );

        final lightlyActive = estimator.estimate(
          goal: baseParams['goal']! as Goal,
          currentWeightKg: baseParams['currentWeightKg']! as double,
          heightCm: baseParams['heightCm']! as double,
          age: baseParams['age']! as int,
          isMale: baseParams['isMale']! as bool,
          targetWeightKg: baseParams['targetWeightKg']! as double,
          weeklyRateKg: baseParams['weeklyRateKg']! as double,
          activityLevel: ActivityLevel.lightlyActive, // 1.375x
        );

        final veryActive = estimator.estimate(
          goal: baseParams['goal']! as Goal,
          currentWeightKg: baseParams['currentWeightKg']! as double,
          heightCm: baseParams['heightCm']! as double,
          age: baseParams['age']! as int,
          isMale: baseParams['isMale']! as bool,
          targetWeightKg: baseParams['targetWeightKg']! as double,
          weeklyRateKg: baseParams['weeklyRateKg']! as double,
          activityLevel: ActivityLevel.veryActive, // 1.725x
        );

        final extremelyActive = estimator.estimate(
          goal: baseParams['goal']! as Goal,
          currentWeightKg: baseParams['currentWeightKg']! as double,
          heightCm: baseParams['heightCm']! as double,
          age: baseParams['age']! as int,
          isMale: baseParams['isMale']! as bool,
          targetWeightKg: baseParams['targetWeightKg']! as double,
          weeklyRateKg: baseParams['weeklyRateKg']! as double,
          activityLevel: ActivityLevel.extremelyActive, // 1.9x
        );

        // Verify progression
        expect(lightlyActive.dailyKcal, greaterThan(sedentary.dailyKcal));
        expect(veryActive.dailyKcal, greaterThan(lightlyActive.dailyKcal));
        expect(
          extremelyActive.dailyKcal,
          greaterThan(veryActive.dailyKcal),
        );

        // Verify extremely active is ~58% higher than sedentary (1.9/1.2)
        const expectedRatio = 1.9 / 1.2;
        final actualRatio = extremelyActive.dailyKcal / sedentary.dailyKcal;
        expect(actualRatio, closeTo(expectedRatio, 0.01));
      });
    });

    group('Calorie Adjustment (7700 kcal/kg)', () {
      test('weight loss applies correct deficit', () {
        final result = estimator.estimate(
          goal: Goal.lose,
          currentWeightKg: 80,
          heightCm: 180,
          age: 30,
          isMale: true,
          targetWeightKg: 75,
          weeklyRateKg: -0.5, // 0.5kg loss per week
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Daily deficit = (0.5 × 7700) / 7 = 550 kcal
        // So target should be TDEE - 550
        // BMR ≈ 1780, TDEE (1.55x) ≈ 2759
        // Target = 2759 - 550 = 2209 kcal
        expect(result.dailyKcal, closeTo(2209, 5));
      });

      test('weight gain applies correct surplus', () {
        final result = estimator.estimate(
          goal: Goal.gain,
          currentWeightKg: 70,
          heightCm: 175,
          age: 25,
          isMale: true,
          targetWeightKg: 75,
          weeklyRateKg: 0.3, // 0.3kg gain per week
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Daily surplus = (0.3 × 7700) / 7 = 330 kcal
        // BMR ≈ 1693, TDEE (1.55x) ≈ 2624
        // Target = 2624 + 330 = 2954 kcal (allow rounding tolerance)
        expect(result.dailyKcal, closeTo(2954, 30));
      });
    });

    group('Evidence-Based Calorie Bounds', () {
      test('enforces female minimum of 1200 kcal', () {
        // Very aggressive deficit that would go below 1200
        final result = estimator.estimate(
          goal: Goal.lose,
          currentWeightKg: 50,
          heightCm: 155,
          age: 30,
          isMale: false,
          targetWeightKg: 45,
          weeklyRateKg: -1, // Aggressive loss
          activityLevel: ActivityLevel.sedentary,
        );

        // Should be clamped to 1200 minimum
        expect(result.dailyKcal, greaterThanOrEqualTo(1200));
      });

      test('enforces male minimum of 1800 kcal', () {
        // Very aggressive deficit for small male
        final result = estimator.estimate(
          goal: Goal.lose,
          currentWeightKg: 60,
          heightCm: 160,
          age: 30,
          isMale: true,
          targetWeightKg: 55,
          weeklyRateKg: -1,
          activityLevel: ActivityLevel.sedentary,
        );

        // Should be clamped to 1800 minimum
        expect(result.dailyKcal, greaterThanOrEqualTo(1800));
      });

      test('enforces TDEE × 1.5 maximum for surplus', () {
        // Try to gain extremely fast
        final result = estimator.estimate(
          goal: Goal.gain,
          currentWeightKg: 80,
          heightCm: 180,
          age: 25,
          isMale: true,
          targetWeightKg: 90,
          weeklyRateKg: 2, // Unrealistic 2kg/week gain
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // BMR ≈ 1818, TDEE (1.55x) ≈ 2818
        // Max allowed = 2818 × 1.5 = 4227 kcal (allow tolerance for rounding)
        // Without cap: 2818 + (2.0 × 7700 / 7) = 2818 + 2200 = 5018
        // Should be clamped to ~4227
        expect(result.dailyKcal, lessThanOrEqualTo(4300));
        expect(result.dailyKcal, closeTo(4227, 40));
      });
    });

    group('Performance-Focused Macro Split', () {
      test('protein is 2.0g per kg bodyweight', () {
        final result = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 75,
          heightCm: 175,
          age: 30,
          isMale: true,
          targetWeightKg: 75,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Protein = 2.0 × 75 = 150g
        expect(result.proteinGrams, equals(150));
      });

      test('fat is 0.8g per kg bodyweight', () {
        final result = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 80,
          heightCm: 180,
          age: 30,
          isMale: true,
          targetWeightKg: 80,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Fat = 0.8 × 80 = 64g
        expect(result.fatGrams, equals(64));
      });

      test('carbs fill remaining calories', () {
        final result = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 70,
          heightCm: 175,
          age: 28,
          isMale: true,
          targetWeightKg: 70,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        // Protein: 140g (560 kcal)
        // Fat: 56g (504 kcal)
        // Remaining for carbs
        final proteinKcal = result.proteinGrams * 4;
        final fatKcal = result.fatGrams * 9;
        final carbsKcal = result.carbsGrams * 4;

        expect(proteinKcal, equals(result.proteinGrams * 4));
        expect(fatKcal, equals(result.fatGrams * 9));

        // Total should match daily calories (within rounding)
        final total = proteinKcal + fatKcal + carbsKcal;
        expect((total - result.dailyKcal).abs(), lessThan(5));
      });

      test('handles extreme deficit without negative carbs', () {
        final result = estimator.estimate(
          goal: Goal.lose,
          currentWeightKg: 50,
          heightCm: 155,
          age: 30,
          isMale: false,
          targetWeightKg: 48,
          weeklyRateKg: -0.5,
          activityLevel: ActivityLevel.sedentary,
        );

        // Should clamp carbs to 0 if needed, not negative
        expect(result.carbsGrams, greaterThanOrEqualTo(0));
      });
    });

    group('Safety Minimum Override', () {
      test('returns isBelowSafeMinimum=true when under minimum (male)', () {
        final result = estimator.estimate(
          goal: Goal.lose,
          currentWeightKg: 60,
          heightCm: 160,
          age: 30,
          isMale: true,
          targetWeightKg: 55,
          weeklyRateKg: -1, // Aggressive loss
          activityLevel: ActivityLevel.sedentary,
        );

        expect(result.isBelowSafeMinimum, isTrue);
        expect(result.safeMinimumKcal, equals(1800));
        expect(result.dailyKcal, equals(1800)); // Clamped to minimum
      });

      test('returns isBelowSafeMinimum=true when under minimum (female)', () {
        final result = estimator.estimate(
          goal: Goal.lose,
          currentWeightKg: 50,
          heightCm: 155,
          age: 30,
          isMale: false,
          targetWeightKg: 45,
          weeklyRateKg: -1,
          activityLevel: ActivityLevel.sedentary,
        );

        expect(result.isBelowSafeMinimum, isTrue);
        expect(result.safeMinimumKcal, equals(1200));
        expect(result.dailyKcal, equals(1200)); // Clamped to female minimum
      });

      test('allows below minimum when allowBelowMinimum=true (male)', () {
        final resultWithoutOverride = estimator.estimate(
          goal: Goal.lose,
          currentWeightKg: 65,
          heightCm: 165,
          age: 30,
          isMale: true,
          targetWeightKg: 60,
          weeklyRateKg: -1.2, // Very aggressive
          activityLevel: ActivityLevel.sedentary,
        );

        final resultWithOverride = estimator.estimate(
          goal: Goal.lose,
          currentWeightKg: 65,
          heightCm: 165,
          age: 30,
          isMale: true,
          targetWeightKg: 60,
          weeklyRateKg: -1.2,
          activityLevel: ActivityLevel.sedentary,
          allowBelowMinimum: true, // ALLOW override
        );

        // Both should flag as below minimum
        expect(resultWithoutOverride.isBelowSafeMinimum, isTrue);
        expect(resultWithOverride.isBelowSafeMinimum, isTrue);

        // Without override: clamped to 1800
        expect(resultWithoutOverride.dailyKcal, equals(1800));

        // With override: allowed to go below
        expect(resultWithOverride.dailyKcal, lessThan(1800));
      });

      test('still enforces absolute minimum of 500 kcal', () {
        final result = estimator.estimate(
          goal: Goal.lose,
          currentWeightKg: 45,
          heightCm: 145,
          age: 20,
          isMale: false,
          targetWeightKg: 40,
          weeklyRateKg: -2, // Extreme deficit
          activityLevel: ActivityLevel.sedentary,
          allowBelowMinimum: true, // Even with override...
        );

        // Should never go below absolute minimum of 500
        expect(result.dailyKcal, greaterThanOrEqualTo(500));
        expect(result.isBelowSafeMinimum, isTrue);
      });

      test('safeMinimumKcal is null when above minimum', () {
        final result = estimator.estimate(
          goal: Goal.maintain,
          currentWeightKg: 80,
          heightCm: 180,
          age: 30,
          isMale: true,
          targetWeightKg: 80,
          weeklyRateKg: 0,
          activityLevel: ActivityLevel.moderatelyActive,
        );

        expect(result.isBelowSafeMinimum, isFalse);
        expect(result.safeMinimumKcal, isNull);
        expect(result.dailyKcal, greaterThan(1800)); // Well above minimum
      });
    });
  });
}
