import 'package:meta/meta.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';

/// Snapshot of user inputs required to compute a preview estimate.
@immutable
class PreviewInput {
  /// Creates an immutable input bundle for a preview estimator.
  const PreviewInput({
    required this.goal,
    required this.height,
    required this.currentWeight,
    required this.ageYears,
    required this.activity,
    required this.targetWeight,
    required this.weeklyRateKg,
  });

  /// Goal selected during the onboarding flow.
  final Goal goal;

  /// User height measured as a [Stature].
  final Stature height;

  /// Current body weight baseline.
  final BodyWeight currentWeight;

  /// User age expressed in years.
  final int ageYears;

  /// Activity level used to scale energy expenditure.
  final ActivityLevel activity;

  /// Target body weight the user wants to hit.
  final BodyWeight targetWeight;

  /// Weekly change rate (kg/week) where the sign indicates gain or loss.
  final double weeklyRateKg;
}

/// Result produced by a preview estimator.
@immutable
class PreviewOutput {
  /// Creates computed preview outputs for the UI.
  const PreviewOutput({
    required this.dailyKcal,
    required this.projectedEndDate,
  });

  /// Daily calorie budget suggested by the estimator.
  final double dailyKcal;

  /// Estimated completion date for the phase, if measurable.
  final DateTime? projectedEndDate;
}

/// Signature for pluggable preview estimators.
typedef PreviewEstimator = PreviewOutput Function(PreviewInput input);
