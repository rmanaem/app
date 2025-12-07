import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/training/domain/entities/completed_workout.dart';
import 'package:starter_app/src/features/training/domain/repositories/history_repository.dart';

/// State of the [HistoryDetailViewModel].
enum HistoryDetailViewState {
  /// Data is loading.
  loading,

  /// Data requested is loaded.
  loaded,

  /// An error occurred.
  error,
}

/// View model for the History Detail page.
class HistoryDetailViewModel extends ChangeNotifier {
  /// Creates the view model and triggers initial load.
  HistoryDetailViewModel({
    required this.workoutId,
    required HistoryRepository repository,
  }) : _repository = repository {
    unawaited(_load());
  }

  /// ID of the workout to fetch.
  final String workoutId;
  final HistoryRepository _repository;

  HistoryDetailViewState _state = HistoryDetailViewState.loading;
  CompletedWorkout? _workout;
  String? _errorMessage;

  /// Current state of the view model.
  HistoryDetailViewState get state => _state;

  /// The fetched workout detail.
  CompletedWorkout? get workout => _workout;

  /// Error message, if any.
  String? get errorMessage => _errorMessage;

  Future<void> _load() async {
    _state = HistoryDetailViewState.loading;
    notifyListeners();

    try {
      _workout = await _repository.getCompletedWorkoutById(workoutId);
      if (_workout == null) {
        _errorMessage = 'Workout not found.';
        _state = HistoryDetailViewState.error;
      } else {
        _state = HistoryDetailViewState.loaded;
      }
    } on Exception catch (e) {
      _errorMessage = e.toString();
      _state = HistoryDetailViewState.error;
    } finally {
      notifyListeners();
    }
  }
}
