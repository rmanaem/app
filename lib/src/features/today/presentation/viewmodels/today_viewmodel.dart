import 'dart:async';
import 'package:flutter/foundation.dart';
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

  /// Remaining calories for today based on consumed vs target.
  int get remainingCalories =>
      (state.plan?.dailyCalories.round() ?? 0) - state.consumedCalories;

  Future<void> _loadData() async {
    _updateState(_state.copyWith(isLoading: true));

    try {
      final plan = await _getCurrentPlan();

      // TEMPORARY: Pre-fill some consumed data to visualize the UI
      if (plan != null) {
        _updateState(
          TodayViewState(
            plan: plan,
            consumedCalories: (plan.dailyCalories * 0.6).round(),
            consumedProtein: (plan.proteinGrams * 0.8).round(),
            consumedFat: (plan.fatGrams * 0.4).round(),
            consumedCarbs: (plan.carbGrams * 0.5).round(),
          ),
        );
      } else {
        _updateState(
          const TodayViewState(
            errorMessage: 'No plan found.',
          ),
        );
      }
    } on Exception catch (_) {
      _updateState(
        const TodayViewState(
          errorMessage: 'Failed to load plan.',
        ),
      );
    }
  }

  void _updateState(TodayViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
