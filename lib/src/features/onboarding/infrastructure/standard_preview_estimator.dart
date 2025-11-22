import 'package:starter_app/src/features/onboarding/domain/preview_estimator.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// Standard implementation of [PreviewEstimator] using Mifflin-St Jeor
/// equation for BMR/TDEE calculations with evidence-based calorie bounds.
class StandardPreviewEstimator implements PreviewEstimator {
  /// Creates a [StandardPreviewEstimator].
  const StandardPreviewEstimator();

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
    bool allowBelowMinimum = false,
  }) {
    // STEP 1: BASAL METABOLIC RATE (Mifflin-St Jeor)
    // Formula: BMR = (10 × weight) + (6.25 × height) − (5 × age) + S
    // S = +5 for males, -161 for females
    final s = isMale ? 5 : -161;
    final bmr = (10 * currentWeightKg) + (6.25 * heightCm) - (5 * age) + s;

    // STEP 2: TOTAL DAILY ENERGY EXPENDITURE (TDEE)
    final tdee = bmr * activityLevel.tdeeMultiplier;

    // STEP 3: CALORIE TARGET
    // 1 kg body fat ≈ 7700 kcal
    // Daily adjustment = (weekly rate × 7700) / 7 days
    final dailyAdjustment = (weeklyRateKg * 7700) / 7;
    final calculatedCalories = tdee + dailyAdjustment;

    // Safety bounds (evidence-based: ACSM, NIH guidelines)
    final minCalories = isMale ? 1800.0 : 1200.0;
    final maxCalories = tdee * 1.5; // Prevent >50% surplus

    // Check if below safe minimum
    final isBelowMinimum = calculatedCalories < minCalories;

    // Apply bounds based on override flag
    final targetCalories = allowBelowMinimum
        ? calculatedCalories.clamp(500.0, maxCalories) // Absolute min: 500
        : calculatedCalories.clamp(minCalories, maxCalories);

    // STEP 4: MACRO SPLIT (Performance-Focused)
    // Protein: 2.0g per kg bodyweight (optimal for muscle preservation)
    final proteinGrams = (2.0 * currentWeightKg).round();

    // Fat: 0.8g per kg bodyweight (hormonal health minimum)
    final fatGrams = (0.8 * currentWeightKg).round();

    // Carbs: Remainder of calorie budget
    // 1g Protein = 4 kcal, 1g Fat = 9 kcal, 1g Carb = 4 kcal
    final usedCalories = (proteinGrams * 4) + (fatGrams * 9);
    final remainingCalories = targetCalories.round() - usedCalories;
    var carbGrams = (remainingCalories / 4).round();
    if (carbGrams < 0) carbGrams = 0; // Edge case: extreme deficit

    // STEP 5: END DATE PROJECTION
    final totalWeightDiff = targetWeightKg - currentWeightKg;

    var weeksToGoal = 0.0;
    if (weeklyRateKg.abs() > 0.001) {
      // Avoid division by zero
      weeksToGoal = totalWeightDiff / weeklyRateKg;
    }
    if (weeksToGoal < 0) weeksToGoal = 0; // Prevent negative time

    final projectedEndDate = DateTime.now().add(
      Duration(days: (weeksToGoal * 7).round()),
    );

    return PreviewOutput(
      dailyKcal: targetCalories,
      projectedEndDate: projectedEndDate,
      proteinGrams: proteinGrams,
      carbsGrams: carbGrams,
      fatGrams: fatGrams,
      isBelowSafeMinimum: isBelowMinimum,
      safeMinimumKcal: isBelowMinimum ? minCalories : null,
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
