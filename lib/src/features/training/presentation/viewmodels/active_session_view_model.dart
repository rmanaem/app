import 'dart:async';

import 'package:flutter/material.dart';

/// ViewModel driving the Active Session experience.
class ActiveSessionViewModel extends ChangeNotifier {
  /// Creates an active session view model.
  ActiveSessionViewModel({required String workoutId}) {
    // ignore: discarded_futures - initialization logic in constructor
    _loadSession(workoutId);
  }

  bool _isLoading = true;
  bool _isTimerActive = false;
  int _restDurationSeconds = 90;
  int _timerSeconds = 90;
  int _timerTotalSeconds = 90;
  int? _activeRestExerciseIndex;
  int? _activeRestSetIndex;

  List<Map<String, dynamic>> _exercises = [];

  /// Whether the session is currently loading.
  bool get isLoading => _isLoading;

  /// Whether the global timer is currently active.
  bool get isTimerActive => _isTimerActive;

  /// The duration of the rest timer in seconds.
  int get restDurationSeconds => _restDurationSeconds;

  /// The current value of the timer in seconds.
  int get timerSeconds => _timerSeconds;

  /// The total duration of the timer in seconds.
  int get timerTotalSeconds => _timerTotalSeconds;

  /// The index of the exercise currently associated with the rest timer.
  int? get activeRestExerciseIndex => _activeRestExerciseIndex;

  /// The index of the set currently associated with the rest timer.
  int? get activeRestSetIndex => _activeRestSetIndex;

  /// The list of exercises in the active session.
  List<Map<String, dynamic>> get exercises => _exercises;

  Future<void> _loadSession(String workoutId) async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // MOCK DATA: Separating Targets vs Actuals
    // 'weight' = Actual (User Input)
    // 'targetWeight' = Plan (Read Only Context)
    _exercises = [
      {
        'name': 'Bench Press (Barbell)',
        'note': '',
        'sets': <Map<String, dynamic>>[
          {
            'weight': 100.0,
            'targetWeight': 100.0,
            'reps': 5,
            'targetReps': 5,
            'rpe': 8.0,
            'targetRpe': 8.0,
            'done': false,
          },
          {
            'weight': 100.0,
            'targetWeight': 100.0,
            'reps': 5,
            'targetReps': 5,
            'rpe': 8.0,
            'targetRpe': 8.0,
            'done': false,
          },
          // Example of Deviation: User planned 100, but did 90 last time?
          // Usually starts matched.
          {
            'weight': 100.0,
            'targetWeight': 100.0,
            'reps': 5,
            'targetReps': 5,
            'rpe': 8.0,
            'targetRpe': 8.0,
            'done': false,
          },
        ],
      },
      {
        'name': 'Incline Dumbbell Press',
        'note': 'Keep elbows tucked',
        'sets': <Map<String, dynamic>>[
          {
            'weight': 32.0,
            'targetWeight': 32.0,
            'reps': 10,
            'targetReps': 10,
            'rpe': 8.0,
            'targetRpe': 8.0,
            'done': false,
          },
          {
            'weight': 32.0,
            'targetWeight': 32.0,
            'reps': 10,
            'targetReps': 10,
            'rpe': 8.0,
            'targetRpe': 8.0,
            'done': false,
          },
        ],
      },
    ];

    _isLoading = false;
    notifyListeners();
  }

  /// Toggles the completion status of a set.
  void toggleSet(int exerciseIndex, int setIndex) {
    final sets = _exercises[exerciseIndex]['sets'] as List<dynamic>;
    final set = sets[setIndex] as Map<String, dynamic>;
    set['done'] = !(set['done'] as bool);

    if (set['done'] as bool) {
      _activeRestExerciseIndex = exerciseIndex;
      _activeRestSetIndex = setIndex;
      _startTimer(_restDurationSeconds);
    } else {
      if (_activeRestExerciseIndex == exerciseIndex &&
          _activeRestSetIndex == setIndex) {
        _stopTimer();
      }
    }
    notifyListeners();
  }

  /// Updates a specific field of a specific set.
  void updateSet(
    int exerciseIndex,
    int setIndex,
    Map<String, dynamic> newData, {
    bool propagateToFuture = false,
  }) {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) return;
    final exercise = _exercises[exerciseIndex];
    final sets = exercise['sets'] as List<dynamic>;

    if (setIndex < 0 || setIndex >= sets.length) return;

    // 1. Update the current set
    (sets[setIndex] as Map<String, dynamic>).addAll(newData);

    // 2. Ripple Logic
    if (propagateToFuture) {
      for (var i = setIndex + 1; i < sets.length; i++) {
        final futureSet = sets[i] as Map<String, dynamic>;

        // Only update if the future set is NOT done yet
        if (futureSet['done'] == false) {
          // Update Targets (The Plan for the session)
          if (newData.containsKey('weight')) {
            futureSet['targetWeight'] = newData['weight'];
            futureSet['weight'] = newData['weight']; // Pre-fill actual too
          }
          if (newData.containsKey('reps')) {
            futureSet['targetReps'] = newData['reps'];
            futureSet['reps'] = newData['reps'];
          }
          if (newData.containsKey('rpe')) {
            futureSet['targetRpe'] = newData['rpe'];
            futureSet['rpe'] = newData['rpe'];
          }
        }
      }
    }

    notifyListeners();
  }

  /// Adds a new set to the exercise at [exerciseIndex].
  void addSet(int exerciseIndex) {
    final exercise = _exercises[exerciseIndex];
    final sets = exercise['sets'] as List<dynamic>;
    final lastSet = sets.isNotEmpty
        ? sets.last as Map<String, dynamic>
        : <String, dynamic>{
            'weight': 20.0,
            'targetWeight': 20.0,
            'reps': 10,
            'targetReps': 10,
            'rpe': 8.0,
            'targetRpe': 8.0,
          };

    sets.add({
      'weight': lastSet['weight'],
      'targetWeight': lastSet['targetWeight'],
      'reps': lastSet['reps'],
      'targetReps': lastSet['targetReps'],
      'rpe': lastSet['rpe'],
      'targetRpe': lastSet['targetRpe'],
      'done': false,
    });
    notifyListeners();
  }

  Timer? _ticker;

  void _startTimer(int durationSeconds) {
    _timerTotalSeconds = durationSeconds;
    _timerSeconds = durationSeconds;
    _isTimerActive = true;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _ticker?.cancel();
    _isTimerActive = false;
    _activeRestExerciseIndex = null;
    _activeRestSetIndex = null;
    notifyListeners();
  }

  /// Adds [seconds] to the current timer.
  void addTime(int seconds) {
    _timerSeconds += seconds;
    _timerTotalSeconds += seconds;
    notifyListeners();
  }

  /// Skips the rest timer.
  void skipTimer() {
    _stopTimer();
  }

  /// Updates the rest duration preference and restarts the timer if active.
  void updateRestDuration(int seconds) {
    _restDurationSeconds = seconds;
    if (_isTimerActive) {
      _startTimer(seconds);
    } else {
      _timerSeconds = seconds;
      _timerTotalSeconds = seconds;
      notifyListeners();
    }
  }

  /// Updates the note for a specific exercise.
  void updateExerciseNote(int exerciseIndex, String note) {
    if (exerciseIndex < 0 || exerciseIndex >= _exercises.length) return;

    final updatedExercise = Map<String, dynamic>.from(_exercises[exerciseIndex])
      ..['note'] = note;

    _exercises[exerciseIndex] = updatedExercise;
    notifyListeners();
  }

  /// Removes the exercise at [index].
  void removeExercise(int index) {
    if (index < 0 || index >= _exercises.length) return;
    _exercises.removeAt(index);
    notifyListeners();
  }

  /// Appends a fully configured exercise to the end of the session.
  void appendExercise(Map<String, dynamic> config) {
    final setsCount = config['sets'] is int
        ? config['sets'] as int
        : int.tryParse(config['sets'].toString()) ?? 3;

    final weight = config['weight'] is num
        ? (config['weight'] as num).toDouble()
        : double.tryParse(config['weight'].toString()) ?? 20.0;

    final reps = config['reps'] is int
        ? config['reps'] as int
        : int.tryParse(config['reps'].toString()) ?? 10;

    final rpe = config['rpe'] is num
        ? (config['rpe'] as num).toDouble()
        : double.tryParse(config['rpe'].toString()) ?? 8.0;

    final sets = List.generate(
      setsCount,
      (_) => {
        'weight': weight,
        'targetWeight': weight,
        'reps': reps,
        'targetReps': reps,
        'rpe': rpe,
        'targetRpe': rpe,
        'done': false,
      },
    );

    _exercises.add({
      'name': config['name'], // From Selection
      'muscle': config['muscle'], // From Selection
      'note': config['notes'] ?? '', // From Tuner
      'rest': config['rest'], // From Tuner
      'sets': sets,
    });
    notifyListeners();
  }

  /// Replaces an exercise at [index] with a new configuration.
  void replaceExercise(int index, Map<String, dynamic> config) {
    if (index < 0 || index >= _exercises.length) return;

    final setsCount = config['sets'] is int
        ? config['sets'] as int
        : int.tryParse(config['sets'].toString()) ?? 3;

    final weight = config['weight'] is num
        ? (config['weight'] as num).toDouble()
        : double.tryParse(config['weight'].toString()) ?? 20.0;

    final reps = config['reps'] is int
        ? config['reps'] as int
        : int.tryParse(config['reps'].toString()) ?? 10;

    final rpe = config['rpe'] is num
        ? (config['rpe'] as num).toDouble()
        : double.tryParse(config['rpe'].toString()) ?? 8.0;

    // We generate new sets based on the Tuner configuration
    final newSets = List.generate(
      setsCount,
      (_) => {
        'weight': weight,
        'targetWeight': weight,
        'reps': reps,
        'targetReps': reps,
        'rpe': rpe,
        'targetRpe': rpe,
        'done': false,
      },
    );

    _exercises[index] = {
      'name': config['name'],
      'muscle': config['muscle'],
      'note': config['notes'] ?? '',
      'rest': config['rest'],
      'sets': newSets,
    };
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
