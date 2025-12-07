import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';
import 'package:starter_app/src/features/training/program_builder/domain/repositories/program_builder_repository.dart';
import 'package:uuid/uuid.dart';

/// ViewModel for the Workout Editor page.
class WorkoutEditorViewModel extends ChangeNotifier {
  /// Creates the view model.
  WorkoutEditorViewModel({
    required ProgramBuilderRepository repository,
    required String workoutId,
  }) : _repository = repository,
       _workoutId = workoutId {
    _loadFuture = _loadWorkout();
  }

  final ProgramBuilderRepository _repository;
  final String _workoutId;

  bool _isLoading = true;
  DraftWorkout? _workout;
  final List<Map<String, dynamic>> _exercises = [];
  late final Future<void> _loadFuture;

  /// Whether the workout data is loading.
  bool get isLoading => _isLoading;

  /// The workout being edited.
  DraftWorkout? get workout => _workout;

  /// The list of exercises in this workout.
  List<Map<String, dynamic>> get exercises => List.unmodifiable(_exercises);

  /// Future that completes when the initial load is finished.
  /// Exposed for testing purposes to avoid flaky delays.
  @visibleForTesting
  Future<void> get loadFuture => _loadFuture;

  Future<void> _loadWorkout() async {
    try {
      final draft = await _repository.getCurrentDraft();
      if (draft != null) {
        _workout = draft.workouts.firstWhere(
          (w) => w.id == _workoutId,
          orElse: () => DraftWorkout(
            id: _workoutId,
            name: 'New Workout',
            description: '',
          ),
        );

        // Load existing exercises from draft if available
        if (_workout!.exercises.isNotEmpty) {
          _exercises
            ..clear()
            ..addAll(_workout!.exercises);
        } else if (_exercises.isEmpty) {
          // Otherwise seed mock data
          _exercises.addAll(_seedMockExercises(_workout!.name));
        }

        // Ensure all exercises have a unique key for UI stability
        const uuid = Uuid();
        for (var i = 0; i < _exercises.length; i++) {
          if (_exercises[i]['_key'] == null) {
            _exercises[i] = {
              ..._exercises[i],
              '_key': uuid.v4(),
            };
          }
        }
      }
    } on Exception catch (e) {
      debugPrint('Error loading workout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _seedMockExercises(String workoutName) {
    final exercises = <Map<String, dynamic>>[];
    const uuid = Uuid();

    if (workoutName.contains('Push')) {
      exercises.addAll([
        {
          '_key': uuid.v4(),
          'name': 'Bench Press (Barbell)',
          'muscle': 'Chest',
          'sets': 3,
          'reps': '5-8',
          'weight': 60.0,
          'rest': 180,
        },
        {
          '_key': uuid.v4(),
          'name': 'Overhead Press',
          'muscle': 'Shoulders',
          'sets': 3,
          'reps': '8-10',
          'weight': 40.0,
          'rest': 120,
        },
        {
          '_key': uuid.v4(),
          'name': 'Incline Dumbbell Press',
          'muscle': 'Chest',
          'sets': 3,
          'reps': '10-12',
          'weight': 24.0,
          'rest': 90,
        },
      ]);
    } else if (workoutName.contains('Pull')) {
      exercises.addAll([
        {
          '_key': uuid.v4(),
          'name': 'Deadlift',
          'muscle': 'Back',
          'sets': 3,
          'reps': '5',
          'weight': 100.0,
          'rest': 300,
        },
        {
          '_key': uuid.v4(),
          'name': 'Pull Ups',
          'muscle': 'Back',
          'sets': 3,
          'reps': 'AMRAP',
          'weight': 0.0,
          'rest': 90,
        },
      ]);
    }
    return exercises;
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

  /// Removes an exercise from the local list.
  void removeExercise(int index) {
    if (index < 0 || index >= _exercises.length) return;
    _exercises.removeAt(index);
    notifyListeners();
  }

  /// Adds exercises returned from the selection page.
  void onExercisesAdded(List<Map<String, dynamic>> newExercises) {
    const uuid = Uuid();
    final withKeys = newExercises.map((e) {
      return {
        ...e,
        '_key': uuid.v4(),
      };
    }).toList();

    _exercises.addAll(withKeys);
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

  /// Saves the current workout state to the repository.
  Future<void> save() async {
    if (_workout == null) return;

    final updated = DraftWorkout(
      id: _workout!.id,
      name: _workout!.name,
      description: _workout!.description,
      exercises: List.from(_exercises),
    );

    // Optimistic update local
    _workout = updated;

    await _repository.updateWorkout(_workoutId, updated);
  }

  /// Launches a freestyle session with the current exercises.
  void startFreestyleSession(BuildContext context) {
    if (_workout == null && _exercises.isEmpty) return;

    // Create a temporary draft for the session
    final workout = DraftWorkout(
      id: 'freestyle_${DateTime.now().millisecondsSinceEpoch}',
      name: _workout?.name ?? 'Freestyle Workout',
      description: 'Quick Start Session',
      exercises: List.from(_exercises),
    );

    // Navigate directly to Active Session, passing the object
    unawaited(
      context.push(
        '/training/session/freestyle',
        extra: workout,
      ),
    );
  }
}
