import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/onboarding/domain/preview_estimator.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/infrastructure/simple_preview_estimator.dart';

/// ViewModel powering the goal configuration sliders and metrics.
class GoalConfigurationVm extends ChangeNotifier {
  /// Creates the ViewModel bound to the provided onboarding stats.
  GoalConfigurationVm({
    required Goal goal,
    required Stature height,
    required BodyWeight currentWeight,
    required int ageYears,
    required ActivityLevel activity,
    required double initialTargetWeightKg,
    required double initialWeeklyRateKg,
    PreviewEstimator? estimator,
  }) : _goal = goal,
       _height = height,
       _currentWeight = currentWeight,
       _ageYears = ageYears,
       _activity = activity,
       _targetWeightKg = initialTargetWeightKg,
       _weeklyRateKg = initialWeeklyRateKg,
       _estimator = estimator ?? const SimplePreviewEstimator() {
    _recompute();
  }

  final Goal _goal;
  final Stature _height;
  final BodyWeight _currentWeight;
  final int _ageYears;
  final ActivityLevel _activity;
  final PreviewEstimator _estimator;

  double _targetWeightKg;
  double _weeklyRateKg;

  double _dailyKcal = 0;
  DateTime? _projectedEnd;

  /// Current slider value for the target weight (kg).
  double get targetWeightKg => _targetWeightKg;

  /// Current weekly rate expressed in kg/week.
  double get weeklyRateKg => _weeklyRateKg;

  /// Most recent calorie budget output from the estimator.
  double get dailyKcal => _dailyKcal;

  /// Projected end date for the selected target/rate combo.
  DateTime? get endDate => _projectedEnd;

  /// Absolute weekly mass delta ignoring sign.
  double get weeklyDeltaAbs => _weeklyRateKg.abs();

  /// Weekly delta as a percentage of current bodyweight.
  double get weeklyPercentBw => (weeklyDeltaAbs / _currentWeight.kg) * 100;

  /// Projected monthly mass delta (assuming four weeks).
  double get monthlyDeltaAbs => weeklyDeltaAbs * 4;

  /// Monthly delta as a percentage of bodyweight.
  double get monthlyPercentBw => weeklyPercentBw * 4;

  /// Minimum allowed target weight for the selected goal.
  double get minTargetKg => switch (_goal) {
    Goal.lose => _currentWeight.kg * 0.85,
    Goal.maintain => _currentWeight.kg * 0.98,
    Goal.gain => _currentWeight.kg * 0.90,
  };

  /// Maximum allowed target weight for the selected goal.
  double get maxTargetKg => switch (_goal) {
    Goal.lose => _currentWeight.kg,
    Goal.maintain => _currentWeight.kg * 1.02,
    Goal.gain => _currentWeight.kg * 1.10,
  };

  /// Minimum weekly rate expressed in kg/week.
  double get minRateKg => switch (_goal) {
    Goal.lose => -1.2,
    Goal.maintain => -0.30,
    Goal.gain => 0.20,
  };

  /// Maximum weekly rate expressed in kg/week.
  double get maxRateKg => switch (_goal) {
    Goal.lose => -0.20,
    Goal.maintain => 0.30,
    Goal.gain => 0.60,
  };

  /// Updates the current target weight value.
  void setTargetWeightKg(double value) {
    _targetWeightKg = value.clamp(minTargetKg, maxTargetKg);
    _recompute();
  }

  /// Updates the weekly rate while enforcing goal-aligned sign.
  void setWeeklyRateKg(double value) {
    final consistent = switch (_goal) {
      Goal.lose => -value.abs(),
      Goal.maintain => value,
      Goal.gain => value.abs(),
    };
    _weeklyRateKg = consistent.clamp(minRateKg, maxRateKg);
    _recompute();
  }

  void _recompute() {
    final output = _estimator.estimate(
      goal: _goal,
      heightCm: _height.cm,
      currentWeightKg: _currentWeight.kg,
      age: _ageYears,
      activityLevel: _activity,
      targetWeightKg: _targetWeightKg,
      weeklyRateKg: _weeklyRateKg,
      isMale: true,
    );
    _dailyKcal = output.dailyKcal;
    _projectedEnd = output.projectedEndDate;
    notifyListeners();
  }
}
