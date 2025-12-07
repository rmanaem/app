import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/features/training/domain/repositories/training_overview_repository.dart';
import 'package:starter_app/src/features/training/presentation/viewstate/training_overview_view_state.dart';

/// ViewModel responsible for orchestrating the training overview page.
class TrainingOverviewViewModel extends ChangeNotifier {
  /// Creates the ViewModel.
  TrainingOverviewViewModel({
    required TrainingOverviewRepository repository,
    DateTime? today,
  }) : _repository = repository,
       _today = today ?? DateTime.now(),
       _state = TrainingOverviewViewState.initial(today ?? DateTime.now()) {
    unawaited(load());
  }

  final TrainingOverviewRepository _repository;
  final DateTime _today;

  TrainingOverviewViewState _state;

  /// Latest view state exposed to the UI.
  TrainingOverviewViewState get state => _state;

  /// Loads the overview from the repository.
  Future<void> load() async {
    _emit(
      _state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
      ),
    );
    try {
      final overview = await _repository.getOverviewForWeek(_today);
      _emit(
        TrainingOverviewViewState(
          isLoading: false,
          selectedDate: overview.anchorDate,
          weekDays: overview.weekDays,
          nextWorkout: overview.nextWorkout,
          lastWorkout: overview.lastWorkout,
          hasProgram: overview.hasProgram,
          activeProgramId: overview.activeProgramId,
          completedWorkouts: overview.completedWorkouts,
          plannedWorkouts: overview.plannedWorkouts,
        ),
      );
    } on Exception catch (_) {
      _emit(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load training overview.',
          completedWorkouts: 0,
          plannedWorkouts: 0,
        ),
      );
    }
  }

  /// Updates the selected day in the week strip.
  void onSelectDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    _emit(_state.copyWith(selectedDate: normalized));
  }

  /// Triggered when the user starts the next workout.
  void onStartNextWorkout(BuildContext context) {
    if (_state.nextWorkout != null) {
      unawaited(context.push('/training/session/${_state.nextWorkout!.id}'));
    }
  }

  /// Triggered when the user opens the last workout summary.
  void onOpenLastWorkout(BuildContext context) {
    if (_state.lastWorkout != null) {
      unawaited(context.push('/training/history/${_state.lastWorkout!.id}'));
    }
  }

  /// Triggered when the user wants to view the current program.
  void onViewProgram() {
    // TODO(app-team): navigate to program overview.
  }

  /// Triggered when the user opts to create a new program.
  void onCreateProgram() {
    // TODO(app-team): navigate to program builder.
  }

  /// Triggered when the user wants to see history.
  void onViewHistory() {
    // TODO(app-team): open training history list.
  }

  void _emit(TrainingOverviewViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
