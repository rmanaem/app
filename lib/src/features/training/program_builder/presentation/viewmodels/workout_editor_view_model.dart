import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';
import 'package:starter_app/src/features/training/program_builder/domain/repositories/program_builder_repository.dart';

/// ViewModel for editing a single workout within a draft program.
class WorkoutEditorViewModel extends ChangeNotifier {
  /// Creates the view model.
  WorkoutEditorViewModel({
    required ProgramBuilderRepository repository,
    required String workoutId,
  }) : _repository = repository,
       _workoutId = workoutId {
    unawaited(_loadWorkout());
  }

  final ProgramBuilderRepository _repository;
  final String _workoutId;

  DraftWorkout? _workout;
  bool _isLoading = true;

  // Temporary local state for the UI until real exercises exist.
  List<Map<String, dynamic>> _exercises = <Map<String, dynamic>>[];

  /// Current workout.
  DraftWorkout? get workout => _workout;

  /// Loading flag.
  bool get isLoading => _isLoading;

  /// Exercises for the workout (placeholder structure).
  List<Map<String, dynamic>> get exercises => _exercises;

  Future<void> _loadWorkout() async {
    _isLoading = true;
    notifyListeners();

    final draft = await _repository.getCurrentDraft();
    if (draft != null) {
      _workout = draft.workouts.firstWhere(
        (w) => w.id == _workoutId,
        orElse: () => const DraftWorkout(
          id: '',
          name: '',
          description: '',
        ),
      );
      if (_workout != null && _workout!.id.isNotEmpty && _exercises.isEmpty) {
        _exercises = _seedMockExercises(_workout!.name);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _seedMockExercises(String workoutName) {
    if (workoutName.contains('Push')) {
      return <Map<String, dynamic>>[
        {
          'name': 'Bench Press (Barbell)',
          'muscle': 'Chest',
          'sets': 3,
          'reps': '5-8',
          'weight': 60.0,
          'rest': 180,
        },
        {
          'name': 'Overhead Press',
          'muscle': 'Shoulders',
          'sets': 3,
          'reps': '8-10',
          'weight': 40.0,
          'rest': 120,
        },
        {
          'name': 'Incline Dumbbell Press',
          'muscle': 'Chest',
          'sets': 3,
          'reps': '10-12',
          'weight': 24.0,
          'rest': 90,
        },
      ];
    }
    if (workoutName.contains('Pull')) {
      return <Map<String, dynamic>>[
        {
          'name': 'Deadlift',
          'muscle': 'Back',
          'sets': 3,
          'reps': '5',
          'weight': 100.0,
          'rest': 300,
        },
        {
          'name': 'Pull Ups',
          'muscle': 'Back',
          'sets': 3,
          'reps': 'AMRAP',
          'weight': 0.0,
          'rest': 90,
        },
      ];
    }
    return <Map<String, dynamic>>[];
  }

  /// Reorders exercises in the local list.
  void reorderExercises(int oldIndex, int newIndex) {
    var targetIndex = newIndex;
    if (oldIndex < targetIndex) {
      targetIndex -= 1;
    }
    final item = _exercises.removeAt(oldIndex);
    _exercises.insert(targetIndex, item);
    notifyListeners();
    // TODO(app-team): persist ordering
  }

  /// Updates a single exercise entry.
  void updateExercise(int index, Map<String, dynamic> updates) {
    if (index < 0 || index >= _exercises.length) return;
    _exercises[index] = {
      ..._exercises[index],
      ...updates,
    };
    notifyListeners();
  }

  /// Adds exercises returned from the selection page.
  void onExercisesAdded(List<Map<String, dynamic>> newExercises) {
    _exercises.addAll(newExercises);
    notifyListeners();
  }

  /// Navigates to the exercise selection page and wires the callback.
  Future<void> addExercises(BuildContext context) async {
    try {
      // We don't need the result here because we passed the callback 'extra'.
      // However, if your router setup passes data back via 'pop(result)',
      // you would handle it here. Currently using the callback approach via
      // 'extra' in the router definition.
      await context.push(
        '/training/builder/editor/select',
        extra: onExercisesAdded,
      );
    } on Exception catch (e) {
      debugPrint('Navigation failed: $e');
    }
  }
}
