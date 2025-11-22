import 'package:starter_app/src/features/onboarding/domain/preview_estimator.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// Simple implementation of [PreviewEstimator].
class SimplePreviewEstimator implements PreviewEstimator {
  /// Creates a simple estimator.
  const SimplePreviewEstimator();

  @override
  PreviewOutput estimate({
    required Goal goal,
    required double currentWeightKg,
    required double targetWeightKg,
    required double weeklyRateKg,
    required ActivityLevel activityLevel,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    // Note: Using simplified calorie calculation (see docs/TODO.md)
    var dailyKcal = 2000.0;
    if (goal == Goal.gain) dailyKcal += 500;
    if (goal == Goal.lose) dailyKcal -= 500;

    // Adjust for rate
    if (goal == Goal.lose) {
      // Faster loss (more negative rate) -> lower calories
      dailyKcal += weeklyRateKg * 1000;
    } else if (goal == Goal.gain) {
      // Faster gain (more positive rate) -> higher calories
      dailyKcal += weeklyRateKg * 1000;
    }

    // Adjust date based on rate
    final weightDiff = (targetWeightKg - currentWeightKg).abs();
    final rate = weeklyRateKg.abs();
    final weeks = rate > 0 ? weightDiff / rate : 0;
    final days = (weeks * 7).round();

    final endDate = DateTime.now().add(Duration(days: days));

    // Rough macro split
    final protein = (dailyKcal * 0.3) / 4;
    final fat = (dailyKcal * 0.3) / 9;
    final carbs = (dailyKcal * 0.4) / 4;

    return PreviewOutput(
      dailyKcal: dailyKcal,
      projectedEndDate: endDate,
      proteinGrams: protein.round(),
      carbsGrams: carbs.round(),
      fatGrams: fat.round(),
    );
  }

  @override
  PreviewBounds getBounds({
    required Goal goal,
    required double currentWeightKg,
  }) {
    if (goal == Goal.lose) {
      return PreviewBounds(
        minTargetKg: currentWeightKg * 0.5,
        maxTargetKg: currentWeightKg,
        minWeeklyRateKg: -1.5,
        maxWeeklyRateKg: 0,
      );
    } else if (goal == Goal.gain) {
      return PreviewBounds(
        minTargetKg: currentWeightKg,
        maxTargetKg: currentWeightKg * 1.5,
        minWeeklyRateKg: 0,
        maxWeeklyRateKg: 1,
      );
    } else {
      return PreviewBounds(
        minTargetKg: currentWeightKg,
        maxTargetKg: currentWeightKg,
        minWeeklyRateKg: 0,
        maxWeeklyRateKg: 0,
      );
    }
  }
}
