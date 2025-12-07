import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:starter_app/src/features/training/domain/entities/completed_workout.dart';
import 'package:starter_app/src/features/training/domain/repositories/history_repository.dart';

/// ViewModel for the History (Logbook) page.
class HistoryViewModel extends ChangeNotifier {
  /// Creates the view model and triggers initial load.
  HistoryViewModel(this._repository) {
    unawaited(_load());
  }

  final HistoryRepository _repository;
  bool _isLoading = true;
  List<CompletedWorkout> _workouts = [];

  /// Whether the history is currently loading.
  bool get isLoading => _isLoading;

  /// The list of completed workouts.
  List<CompletedWorkout> get workouts => _workouts;

  /// Group workouts by "Month Year" (e.g., "DECEMBER 2023").
  Map<String, List<CompletedWorkout>> get groupedWorkouts {
    final groups = <String, List<CompletedWorkout>>{};
    for (final workout in _workouts) {
      final key = DateFormat(
        'MMMM yyyy',
      ).format(workout.completedAt).toUpperCase();
      if (!groups.containsKey(key)) groups[key] = [];
      groups[key]!.add(workout);
    }
    return groups;
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _workouts = await _repository.getHistory();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
