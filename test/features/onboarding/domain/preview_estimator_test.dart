import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/features/onboarding/domain/preview_estimator.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/infrastructure/simple_preview_estimator.dart';

void main() {
  group('PreviewEstimator', () {
    late PreviewEstimator estimator;

    setUp(() {
      estimator = const SimplePreviewEstimator();
    });

    test('calculates higher calories for gain than loss', () {
      final loss = estimator.estimate(
        goal: Goal.lose,
        currentWeightKg: 80,
        targetWeightKg: 75,
        weeklyRateKg: -0.5,
        activityLevel: ActivityLevel.moderate,
        heightCm: 180,
        age: 30,
        isMale: true,
      );

      final gain = estimator.estimate(
        goal: Goal.gain,
        currentWeightKg: 80,
        targetWeightKg: 85,
        weeklyRateKg: 0.5,
        activityLevel: ActivityLevel.moderate,
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
        activityLevel: ActivityLevel.moderate,
        heightCm: 180,
        age: 30,
        isMale: true,
      );

      final fast = estimator.estimate(
        goal: Goal.lose,
        currentWeightKg: 80,
        targetWeightKg: 70,
        weeklyRateKg: -1,
        activityLevel: ActivityLevel.moderate,
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
        activityLevel: ActivityLevel.moderate,
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
  });
}
