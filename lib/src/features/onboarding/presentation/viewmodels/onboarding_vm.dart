import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:starter_app/src/core/analytics/analytics_service.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/sex.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewstate/onboarding_goal_view_state.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewstate/onboarding_stats_view_state.dart';

/// ViewModel coordinating the onboarding flow across steps.
class OnboardingVm extends ChangeNotifier {
  /// Creates the ViewModel wired with [AnalyticsService].
  OnboardingVm(
    this._analytics, {
    Goal? initialGoal,
    UnitSystem initialUnitSystem = UnitSystem.metric,
  }) : _goalState = OnboardingGoalViewState(selected: initialGoal),
       _statsState = OnboardingStatsViewState(unitSystem: initialUnitSystem);

  final AnalyticsService _analytics;

  // --- Goal step state & intents ---
  OnboardingGoalViewState _goalState;

  /// Latest state exposed to the view.
  OnboardingGoalViewState get goalState => _goalState;

  /// Updates the selected [goal] and records the analytics event.
  void selectGoal(Goal goal) {
    if (_goalState.selected == goal) return;
    _goalState = _goalState.copyWith(selected: goal);
    notifyListeners();
    unawaited(_analytics.onboardingGoalSelected(goal.analyticsName));
  }

  /// Logs that the goal screen rendered.
  Future<void> logGoalScreenViewed() {
    return _analytics.onboardingGoalImpression();
  }

  /// Logs that the user moved to the next onboarding step.
  Future<void> logGoalNext() {
    if (!_goalState.canContinue) return Future.value();
    return _analytics.onboardingGoalNext(_goalState.selected!.analyticsName);
  }

  // --- Stats step state & intents ---
  OnboardingStatsViewState _statsState;
  GoalConfigurationState _goalConfigurationState =
      const GoalConfigurationState();

  /// Latest stats state for the units/details screen.
  OnboardingStatsViewState get statsState => _statsState;

  /// Cached goal configuration selections shown on the summary screen.
  GoalConfigurationState get goalConfigurationState => _goalConfigurationState;

  /// Toggle the unit system.
  void setUnitSystem(UnitSystem system) {
    if (_statsState.unitSystem == system) return;
    _statsState = _statsState.copyWith(unitSystem: system);
    notifyListeners();
    unawaited(_analytics.onboardingStatsUnitChanged(system.analyticsName));
  }

  /// Updates the date of birth.
  void setDob(DateTime dob) {
    final normalized = DateTime(dob.year, dob.month, dob.day);
    _statsState = _statsState.copyWith(dob: normalized);
    notifyListeners();
  }

  /// Updates height expressed in centimeters.
  void setHeightCm(double cm) {
    if (cm <= 0) return;
    _statsState = _statsState.copyWith(height: Stature.fromCm(cm));
    notifyListeners();
  }

  /// Updates height expressed via feet/inches.
  void setHeightImperial({required int ft, required double inch}) {
    if (ft < 0 || inch < 0) return;
    _statsState = _statsState.copyWith(
      height: Stature.fromImperial(ft: ft, inch: inch),
    );
    notifyListeners();
  }

  /// Updates weight stored internally as kilograms.
  void setWeightKg(double kg) {
    if (kg <= 0) return;
    _statsState = _statsState.copyWith(weight: BodyWeight.fromKg(kg));
    notifyListeners();
  }

  /// Updates weight stored internally as kilograms (provided pounds input).
  void setWeightLb(double lb) {
    if (lb <= 0) return;
    _statsState = _statsState.copyWith(weight: BodyWeight.fromLb(lb));
    notifyListeners();
  }

  /// Updates the baseline activity level.
  void setActivityLevel(ActivityLevel level) {
    if (_statsState.activity == level) return;
    _statsState = _statsState.copyWith(activity: level);
    notifyListeners();
  }

  /// Updates the biological sex for calculations.
  void setSex(Sex sex) {
    if (_statsState.sex == sex) return;
    _statsState = _statsState.copyWith(sex: sex);
    notifyListeners();
  }

  /// Logs that the stats screen rendered.
  Future<void> logStatsScreenViewed() {
    return _analytics.onboardingStatsImpression();
  }

  /// Logs that the user moved past the stats screen.
  Future<void> logStatsNext() {
    if (!_statsState.isValid) return Future.value();
    return _analytics.onboardingStatsNext(
      unitSystem: _statsState.unitSystem.analyticsName,
      activity: _statsState.activity!.analyticsName,
    );
  }

  /// Persists goal configuration choices so the summary screen can render
  /// without recompute.
  void setGoalConfigurationChoice({
    required double targetWeightKg,
    required double weeklyRateKg,
    required double dailyBudgetKcal,
    required DateTime projectedEndDate,
  }) {
    _goalConfigurationState = _goalConfigurationState.copyWith(
      targetWeightKg: targetWeightKg,
      weeklyRateKg: weeklyRateKg,
      dailyBudgetKcal: dailyBudgetKcal,
      projectedEndDate: projectedEndDate,
    );
    notifyListeners();
  }
}

/// Immutable state storing goal configuration selections produced on step 3.
class GoalConfigurationState {
  /// Creates an immutable configuration state snapshot.
  const GoalConfigurationState({
    this.targetWeightKg,
    this.weeklyRateKg,
    this.dailyBudgetKcal,
    this.projectedEndDate,
  });

  /// Stored target weight in kilograms.
  final double? targetWeightKg;

  /// Stored weekly rate (kg/week).
  final double? weeklyRateKg;

  /// Stored daily calorie budget.
  final double? dailyBudgetKcal;

  /// Stored projected completion date.
  final DateTime? projectedEndDate;

  /// Returns a copy with the provided fields replaced.
  GoalConfigurationState copyWith({
    double? targetWeightKg,
    double? weeklyRateKg,
    double? dailyBudgetKcal,
    DateTime? projectedEndDate,
  }) {
    return GoalConfigurationState(
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      weeklyRateKg: weeklyRateKg ?? this.weeklyRateKg,
      dailyBudgetKcal: dailyBudgetKcal ?? this.dailyBudgetKcal,
      projectedEndDate: projectedEndDate ?? this.projectedEndDate,
    );
  }
}
