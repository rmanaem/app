import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/plan/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/today/domain/usecases/get_current_plan.dart';
import 'package:starter_app/src/features/today/presentation/viewstate/today_view_state.dart';

/// ViewModel for the today dashboard page.
///
/// Manages the state and business logic for displaying the user's
/// daily nutrition progress and plan information.
class TodayViewModel extends ChangeNotifier {
  /// Creates the ViewModel with the required use case.
  TodayViewModel({required GetCurrentPlan getCurrentPlan})
    : _getCurrentPlan = getCurrentPlan {
    unawaited(_loadData());
  }

  final GetCurrentPlan _getCurrentPlan;

  late TodayViewState _state = const TodayViewState(isLoading: true);

  /// Current view state exposed to the UI.
  TodayViewState get state => _state;

  Future<void> _loadData() async {
    _updateState(_state.copyWith(isLoading: true));

    try {
      final plan = await _getCurrentPlan();

      if (plan != null) {
        _updateState(
          TodayViewState(
            plan: plan,
            consumedCalories: (plan.dailyCalories * 0.6).round(), // Mock data
            consumedProtein: (plan.proteinGrams * 0.8).round(),
            consumedFat: (plan.fatGrams * 0.4).round(),
            consumedCarbs: (plan.carbGrams * 0.5).round(),
            planLabel: _planLabelFor(plan),
            // Mock workout/weight data for now
            nextWorkoutTitle: 'Upper A',
            nextWorkoutSubtitle: 'Tomorrow · ~45 min',
            lastWorkoutTitle: 'Mon · 42 min',
            lastWorkoutSubtitle: 'Bench 5×5 @ 80 kg',
            lastWeightKg: 82.4,
            weightDeltaLabel: '-0.4 kg vs last week',
            hasWeightTrend: true,
          ),
        );
      } else {
        // No plan yet: keep page usable, cards can show "no plan" copy.
        _updateState(const TodayViewState());
      }
    } on Exception catch (_) {
      _updateState(
        const TodayViewState(
          errorMessage: 'Failed to load plan.',
        ),
      );
    }
  }

  // --- Goal-dependent gauge logic ---

  /// Returns true if we should celebrate hitting the target (Gain).
  bool get isBulking => state.plan?.goal == Goal.gain;

  /// Returns true if we are restricting calories (Lose/Maintain).
  bool get isRestricting =>
      state.plan?.goal == Goal.lose || state.plan?.goal == Goal.maintain;

  /// Main number for the gauge (consumed for bulking, remaining otherwise).
  String get heroValue {
    final target = state.plan?.dailyCalories.round() ?? 2000;
    final consumed = state.consumedCalories;

    if (isBulking) {
      return '$consumed';
    }
    final remaining = target - consumed;
    return '$remaining';
  }

  /// Label under the hero number.
  String get heroLabel => isBulking ? 'KCAL CONSUMED' : 'KCAL REMAINING';

  /// Subtitle context for the gauge.
  String get gaugeSubtitle {
    final target = state.plan?.dailyCalories.round() ?? 0;
    final eaten = state.consumedCalories;
    if (isBulking) {
      final left = (target - eaten).clamp(0, 9999);
      return '$left LEFT TO GO';
    }
    return '$eaten CONSUMED / $target TARGET';
  }

  /// Percentage 0.0 → 1.0 for the gauge.
  double get gaugePercent {
    final target = state.plan?.dailyCalories ?? 1;
    final eaten = state.consumedCalories.toDouble();
    return (eaten / target).clamp(0.0, 1.0);
  }

  /// Gauge state flags to allow color messaging in the UI layer.
  bool get isOverBudget =>
      isRestricting &&
      state.consumedCalories > (state.plan?.dailyCalories ?? 0);

  /// Returns true when a bulking plan has met or exceeded the calorie goal.
  bool get isTargetHit =>
      isBulking && state.consumedCalories >= (state.plan?.dailyCalories ?? 0);

  String _planLabelFor(UserPlan plan) {
    final goal = plan.goal;
    final goalLabel = switch (goal) {
      Goal.lose => 'Lose',
      Goal.maintain => 'Maintain',
      Goal.gain => 'Gain',
    };
    return '$goalLabel · Standard';
  }

  void _updateState(TodayViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
