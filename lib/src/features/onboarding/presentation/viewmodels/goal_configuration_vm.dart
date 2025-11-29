import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/onboarding/domain/preview_estimator.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/sex.dart';
import 'package:starter_app/src/features/onboarding/infrastructure/standard_preview_estimator.dart';

/// ViewModel powering the goal configuration sliders and metrics.
class GoalConfigurationVm extends ChangeNotifier {
  /// Creates the ViewModel bound to the provided onboarding stats.
  GoalConfigurationVm({
    required Goal goal,
    required Sex sex,
    required Stature height,
    required BodyWeight currentWeight,
    required int ageYears,
    required ActivityLevel activity,
    required double initialTargetWeightKg,
    required double initialWeeklyRateKg,
    PreviewEstimator? estimator,
  }) : _goal = goal,
       _sex = sex,
       _height = height,
       _currentWeight = currentWeight,
       _ageYears = ageYears,
       _activity = activity,
       _targetWeightKg = initialTargetWeightKg,
       _weeklyRateKg = initialWeeklyRateKg,
       _estimator = estimator ?? const StandardPreviewEstimator() {
    _recompute();
  }

  final Goal _goal;
  final Sex _sex;
  final Stature _height;
  final BodyWeight _currentWeight;
  final int _ageYears;
  final ActivityLevel _activity;
  final PreviewEstimator _estimator;

  double _targetWeightKg;
  double _weeklyRateKg;

  double _dailyKcal = 0;
  DateTime? _projectedEnd;

  // Safety override state
  bool _allowBelowMinimum = false;
  bool _isBelowSafeMinimum = false;
  double? _safeMinimumKcal;

  bool get _isMale => _sex == Sex.male;

  /// Current slider value for the target weight (kg).
  double get targetWeightKg => _targetWeightKg;

  /// Current weekly rate expressed in kg/week.
  double get weeklyRateKg => _weeklyRateKg;

  /// Most recent calorie budget output from the estimator.
  double get dailyKcal => _dailyKcal;

  /// Projected end date for the selected target/rate combo.
  DateTime? get endDate => _projectedEnd;

  /// Whether user has acknowledged safety warning and allowed below minimum.
  bool get allowBelowMinimum => _allowBelowMinimum;

  /// Whether current configuration would result in calories below safe minimum.
  bool get isBelowSafeMinimum => _isBelowSafeMinimum;

  /// The safe minimum calorie value (gender-specific), or null if above
  /// minimum.
  double? get safeMinimumKcal => _safeMinimumKcal;

  /// Whether to show the safety warning banner.
  bool get showingSafetyWarning => _isBelowSafeMinimum && !_allowBelowMinimum;

  /// True when the configured goal is maintenance.
  bool get isMaintenance => _goal == Goal.maintain;

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

  /// User acknowledges safety warning and allows going below minimum.
  void acknowledgeSafetyWarning() {
    _allowBelowMinimum = true;
    _recompute(); // Recalculate with override
  }

  /// Reset safety override (return to safe defaults).
  void resetSafetyOverride() {
    _allowBelowMinimum = false;
    _recompute();
  }

  /// Adjusts the weekly rate to the maximum safe deficit.
  ///
  /// Calculates the rate that would result in exactly the minimum safe
  /// calorie intake (1800/1200 kcal) and updates the slider.
  void adjustToSafeRate() {
    // 1. Get TDEE by estimating at maintenance (0 kg/week)
    final maintenanceOutput = _estimator.estimate(
      goal: _goal,
      heightCm: _height.cm,
      currentWeightKg: _currentWeight.kg,
      age: _ageYears,
      activityLevel: _activity,
      targetWeightKg: _targetWeightKg,
      weeklyRateKg: 0,
      isMale: _isMale,
    );

    final tdee = maintenanceOutput.dailyKcal;
    final minSafe = _isMale ? 1800.0 : 1200.0;

    // 2. Calculate safe rate: Rate = (MinSafe - TDEE) / 1100
    // 1100 = 7700 kcal/kg / 7 days
    var safeRate = (minSafe - tdee) / 1100;

    // 3. Clamp to allowed rate bounds
    safeRate = safeRate.clamp(minRateKg, maxRateKg);

    // 4. Apply
    _weeklyRateKg = safeRate;
    _allowBelowMinimum = false;
    _recompute();
  }

  void _recompute() {
    final weightForCalculation = isMaintenance
        ? _targetWeightKg
        : _currentWeight.kg;

    final output = _estimator.estimate(
      goal: _goal,
      heightCm: _height.cm,
      currentWeightKg: weightForCalculation,
      age: _ageYears,
      activityLevel: _activity,
      targetWeightKg: _targetWeightKg,
      weeklyRateKg: _weeklyRateKg,
      isMale: _isMale,
      allowBelowMinimum: _allowBelowMinimum, // NEW
    );
    _dailyKcal = output.dailyKcal;
    _projectedEnd = output.projectedEndDate;
    _isBelowSafeMinimum = output.isBelowSafeMinimum; // NEW
    _safeMinimumKcal = output.safeMinimumKcal; // NEW
    notifyListeners();
  }
}
