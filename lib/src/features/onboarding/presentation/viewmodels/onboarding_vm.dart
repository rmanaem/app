import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:starter_app/src/core/analytics/analytics_service.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewstate/onboarding_goal_view_state.dart';

/// ViewModel for the onboarding goal selection step.
class OnboardingVm extends ChangeNotifier {
  /// Creates the ViewModel wired with [AnalyticsService].
  OnboardingVm(this._analytics);

  final AnalyticsService _analytics;

  OnboardingGoalViewState _goalState = const OnboardingGoalViewState();

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
}
