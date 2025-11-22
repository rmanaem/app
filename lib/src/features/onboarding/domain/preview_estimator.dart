import 'package:meta/meta.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// Interface for pluggable preview estimators.
abstract class PreviewEstimator {
  /// Computes the preview output based on the provided inputs.
  ///
  /// If [allowBelowMinimum] is false (default), calories are clamped to
  /// evidence-based minimums (1800 kcal for males, 1200 kcal for females).
  /// When true, user has acknowledged safety warning and lower values
  /// are allowed.
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
  });

  /// Computes safe bounds for target weight and weekly rate.
  PreviewBounds getBounds({
    required Goal goal,
    required double currentWeightKg,
  });
}

/// Bounds for target weight and weekly rate.
class PreviewBounds {
  /// Creates immutable bounds.
  const PreviewBounds({
    required this.minTargetKg,
    required this.maxTargetKg,
    required this.minWeeklyRateKg,
    required this.maxWeeklyRateKg,
  });

  /// Minimum allowed target weight in kg.
  final double minTargetKg;

  /// Maximum allowed target weight in kg.
  final double maxTargetKg;

  /// Minimum allowed weekly rate in kg (negative for loss).
  final double minWeeklyRateKg;

  /// Maximum allowed weekly rate in kg.
  final double maxWeeklyRateKg;
}

/// Result produced by a preview estimator.
@immutable
class PreviewOutput {
  /// Creates computed preview outputs for the UI.
  const PreviewOutput({
    required this.dailyKcal,
    required this.projectedEndDate,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
    this.fatGrams = 0,
    this.isBelowSafeMinimum = false,
    this.safeMinimumKcal,
  });

  /// Daily calorie budget suggested by the estimator.
  final double dailyKcal;

  /// Estimated completion date for the phase, if measurable.
  final DateTime projectedEndDate;

  /// Protein target in grams.
  final int proteinGrams;

  /// Carbs target in grams.
  final int carbsGrams;

  /// Fat target in grams.
  final int fatGrams;

  /// Whether the calculated calories are below the recommended safe minimum.
  ///
  /// When true, UI should display a warning and allow user to acknowledge.
  final bool isBelowSafeMinimum;

  /// The safe minimum calorie value for this user (gender-specific).
  ///
  /// Null if calculation is above minimum. When non-null, indicates the
  /// recommended minimum that was (or could be) enforced.
  final double? safeMinimumKcal;
}
