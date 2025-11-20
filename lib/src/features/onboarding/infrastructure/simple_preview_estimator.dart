import 'package:starter_app/src/features/onboarding/domain/preview_estimator.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// Basic estimator used by the onboarding preview step.
/// Replace with validated coach logic when ready.
class SimplePreviewEstimator {
  /// Creates a simple, conservative preview estimator.
  const SimplePreviewEstimator();

  /// Estimates preview outputs with simplified heuristics.
  PreviewOutput call(PreviewInput input) {
    final weightKg = input.currentWeight.kg;
    final activityFactor = switch (input.activity) {
      ActivityLevel.low => 1.4,
      ActivityLevel.moderate => 1.6,
      ActivityLevel.high => 1.8,
    };

    final tdee = 22.0 * weightKg * activityFactor;
    final dailyDelta = (input.weeklyRateKg * 7700.0) / 7.0;
    final dailyBudget = (tdee + dailyDelta).clamp(900.0, 5000.0);

    DateTime? projectedEnd;
    if (input.goal != Goal.maintain && input.weeklyRateKg.abs() > 0.0001) {
      final deltaKg = (input.targetWeight.kg - weightKg).abs();
      final weeks = (deltaKg / input.weeklyRateKg.abs()).clamp(0.0, 520.0);
      projectedEnd = DateTime.now().add(Duration(days: (weeks * 7).round()));
    }

    return PreviewOutput(
      dailyKcal: dailyBudget,
      projectedEndDate: projectedEnd,
    );
  }
}
