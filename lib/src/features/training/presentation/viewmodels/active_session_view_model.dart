import 'dart:async';

import 'package:flutter/foundation.dart';

/// ViewModel driving the Active Session experience.
class ActiveSessionViewModel extends ChangeNotifier {
  ActiveSessionViewModel({required String workoutId}) {
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

  bool get isLoading => _isLoading;
  bool get isTimerActive => _isTimerActive;
  int get restDurationSeconds => _restDurationSeconds;
  int get timerSeconds => _timerSeconds;
  int get timerTotalSeconds => _timerTotalSeconds;
  int? get activeRestExerciseIndex => _activeRestExerciseIndex;
  int? get activeRestSetIndex => _activeRestSetIndex;
  List<Map<String, dynamic>> get exercises => _exercises;

  Future<void> _loadSession(String workoutId) async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _exercises = <Map<String, dynamic>>[
      {
        'name': 'Bench Press (Barbell)',
        'sets': <Map<String, dynamic>>[
          {'weight': 100.0, 'reps': 5, 'rpe': 8.0, 'done': false},
          {'weight': 100.0, 'reps': 5, 'rpe': 8.0, 'done': false},
          {'weight': 100.0, 'reps': 5, 'rpe': 8.0, 'done': false},
        ],
      },
      {
        'name': 'Incline Dumbbell Press',
        'sets': <Map<String, dynamic>>[
          {'weight': 32.0, 'reps': 10, 'rpe': 8.0, 'done': false},
          {'weight': 32.0, 'reps': 10, 'rpe': 8.0, 'done': false},
        ],
      },
    ];

    _isLoading = false;
    notifyListeners();
  }

  void toggleSet(int exerciseIndex, int setIndex) {
    final set = _exercises[exerciseIndex]['sets'][setIndex];
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

  void addSet(int exerciseIndex) {
    final exercise = _exercises[exerciseIndex];
    final sets = exercise['sets'] as List<Map<String, dynamic>>;
    final lastSet = sets.isNotEmpty
        ? sets.last
        : <String, dynamic>{'weight': 20.0, 'reps': 10, 'rpe': 8.0};
    sets.add({
      'weight': lastSet['weight'],
      'reps': lastSet['reps'],
      'rpe': lastSet['rpe'],
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

  void addTime(int seconds) {
    _timerSeconds += seconds;
    _timerTotalSeconds += seconds;
    notifyListeners();
  }

  void skipTimer() {
    _stopTimer();
  }

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

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
