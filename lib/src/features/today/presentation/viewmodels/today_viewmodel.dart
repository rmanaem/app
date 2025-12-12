import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/nutrition/domain/repositories/food_log_repository.dart';
import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/plan/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/today/domain/usecases/get_current_plan.dart';
import 'package:starter_app/src/features/today/presentation/viewstate/today_view_state.dart';
import 'package:starter_app/src/features/training/domain/repositories/training_overview_repository.dart';

/// ViewModel for the today dashboard page.
class TodayViewModel extends ChangeNotifier {
  /// Creates a new [TodayViewModel].
  TodayViewModel({
    required GetCurrentPlan getCurrentPlan,
    required FoodLogRepository foodLogRepository,
    required TrainingOverviewRepository trainingRepository,
  }) : _getCurrentPlan = getCurrentPlan,
       _foodLogRepository = foodLogRepository,
       _trainingRepository = trainingRepository {
    unawaited(_loadData());
  }

  final GetCurrentPlan _getCurrentPlan;
  final FoodLogRepository _foodLogRepository;
  final TrainingOverviewRepository _trainingRepository;

  late TodayViewState _state = const TodayViewState(isLoading: true);

  /// Reflects the current state of the view model.
  TodayViewState get state => _state;

  /// Refreshes the dashboard data.
  Future<void> refresh() => _loadData();

  Future<void> _loadData() async {
    _updateState(_state.copyWith(isLoading: true));

    try {
      // 1. Fetch Plan (Targets)
      final plan = await _getCurrentPlan();

      // 2. Fetch Nutrition Log (Consumed)
      final today = DateTime.now();
      final log = await _foodLogRepository.getLogForDate(today);

      var consumedCals = 0;
      var consumedPro = 0;
      var consumedCarb = 0;
      var consumedFat = 0;

      for (final entry in log.entries) {
        consumedCals += entry.calories;
        consumedPro += entry.proteinGrams;
        consumedCarb += entry.carbGrams;
        consumedFat += entry.fatGrams;
      }

      // 3. Fetch Training (Next Workout)
      final trainingData = await _trainingRepository.getOverviewForWeek(today);
      final nextWorkout = trainingData.nextWorkout;

      if (plan != null) {
        _updateState(
          TodayViewState(
            plan: plan,
            consumedCalories: consumedCals,
            consumedProtein: consumedPro,
            consumedFat: consumedFat,
            consumedCarbs: consumedCarb,
            planLabel: _planLabelFor(plan),

            // Real Workout Data
            nextWorkoutTitle: nextWorkout?.name ?? 'REST DAY',
            nextWorkoutSubtitle: nextWorkout != null
                ? nextWorkout.meta
                : 'Active Recovery',

            // Keep Weight Mocked until Weight Repo is ready (or pass from Plan)
            lastWeightKg: plan.currentWeightKg,
            weightDeltaLabel: '-0.4 kg vs last week',
            hasWeightTrend: true,
          ),
        );
      } else {
        _updateState(const TodayViewState());
      }
    } on Exception catch (_) {
      _updateState(
        const TodayViewState(
          errorMessage: 'Failed to sync dashboard.',
        ),
      );
    }
  }

  // --- Goal Logic ---

  /// Whether the user's goal is to gain weight.
  bool get isBulking => state.plan?.goal == Goal.gain;

  /// Whether the user's goal is to lose or maintain weight.
  bool get isRestricting =>
      state.plan?.goal == Goal.lose || state.plan?.goal == Goal.maintain;

  /// The primary value to display in the hero section (e.g. calories left).
  String get heroValue {
    final target = state.plan?.dailyCalories.round() ?? 2000;
    final consumed = state.consumedCalories;

    if (isBulking) {
      return '$consumed';
    }
    final remaining = target - consumed;
    return '${remaining.clamp(0, 9999)}';
  }

  /// The label for the hero value.
  String get heroLabel => isBulking ? 'KCAL CONSUMED' : 'KCAL LEFT';

  /// The subtitle for the circular gauge.
  String get gaugeSubtitle {
    final target = state.plan?.dailyCalories.round() ?? 0;
    final eaten = state.consumedCalories;
    return '$eaten / $target';
  }

  /// The percentage (0.0 to 1.0) for the circular gauge.
  double get gaugePercent {
    final target = state.plan?.dailyCalories ?? 1;
    final eaten = state.consumedCalories.toDouble();
    return (eaten / target).clamp(0.0, 1.0);
  }

  /// Whether the user has exceeded their daily calorie budget.
  bool get isOverBudget =>
      isRestricting &&
      state.consumedCalories > (state.plan?.dailyCalories ?? 0);

  /// Whether the user has reached their daily calorie target (for bulking).
  bool get isTargetHit =>
      isBulking && state.consumedCalories >= (state.plan?.dailyCalories ?? 0);

  String _planLabelFor(UserPlan plan) {
    // Basic goal formatter
    final goal = plan.goal.toString().split('.').last.toUpperCase();
    return goal;
  }

  void _updateState(TodayViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
