import 'package:starter_app/src/features/training/domain/entities/completed_workout.dart';
import 'package:starter_app/src/features/training/domain/repositories/history_repository.dart';

/// Fake implementation of [HistoryRepository] with mock data.
class HistoryRepositoryFake implements HistoryRepository {
  /// Creates a [HistoryRepositoryFake] and populates it with initial data.
  HistoryRepositoryFake() {
    _workouts.addAll(_initialMockWorkouts());
  }

  final List<CompletedWorkout> _workouts = [];

  @override
  Future<List<CompletedWorkout>> getHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // Return copy sorted by date desc
    return List.of(_workouts)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  @override
  Future<CompletedWorkout?> getCompletedWorkoutById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _workouts.cast<CompletedWorkout?>().firstWhere(
      (w) => w?.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<void> saveWorkout(CompletedWorkout workout) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _workouts.add(workout);
  }

  List<CompletedWorkout> _initialMockWorkouts() {
    // Mock Data: A rich history of gains
    return [
      CompletedWorkout(
        id: '1',
        name: 'Upper Body Power',
        completedAt: DateTime.now().subtract(
          const Duration(days: 1),
        ), // Yesterday
        durationSeconds: 3600 + (15 * 60), // 1h 15m
        totalVolumeKg: 12500,
        prCount: 1,
        totalSets: 15,
        exerciseCount: 5,
        note: 'Solid session. Felt strong on bench.',
      ),
      CompletedWorkout(
        id: '2',
        name: 'Lower Body Hypertrophy',
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        durationSeconds: 3600 + (5 * 60), // 1h 05m
        totalVolumeKg: 18200, // Legs = Volume
        prCount: 0,
        totalSets: 12,
        exerciseCount: 4,
      ),
      CompletedWorkout(
        id: '3',
        name: 'Push A',
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        durationSeconds: 2700, // 45m
        totalVolumeKg: 8400,
        prCount: 2,
        totalSets: 14,
        exerciseCount: 4,
      ),
      CompletedWorkout(
        id: '4',
        name: 'Pull A',
        completedAt: DateTime(2023, 11, 28), // Last Month
        durationSeconds: 3000,
        totalVolumeKg: 9100,
        prCount: 0,
        totalSets: 16,
        exerciseCount: 5,
      ),
      CompletedWorkout(
        id: 'last-1',
        name: 'Lower B',
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        durationSeconds: 2520, // 42 min
        totalVolumeKg: 10500,
        prCount: 1,
        totalSets: 12,
        exerciseCount: 4,
        note: 'Focus on bracing on squats.',
        exercises: [
          {
            'name': 'Back Squat',
            'muscle': 'Legs',
            'note': 'Beltless. Felt good depth.',
            'sets': [
              {'kg': 100.0, 'reps': 5, 'rpe': 7.0},
              {'kg': 105.0, 'reps': 5, 'rpe': 8.0},
              {'kg': 105.0, 'reps': 5, 'rpe': 8.5},
            ],
          },
          {
            'name': 'Romanian Deadlift',
            'muscle': 'Legs',
            'sets': [
              {'kg': 120.0, 'reps': 8, 'rpe': 8.0},
              {'kg': 120.0, 'reps': 8, 'rpe': 8.5},
              {'kg': 120.0, 'reps': 8, 'rpe': 9.0},
            ],
          },
          {
            'name': 'Leg Extension',
            'muscle': 'Legs',
            'note': 'Slow eccentric.',
            'sets': [
              {'kg': 60.0, 'reps': 12, 'rpe': 9.0},
              {'kg': 60.0, 'reps': 12, 'rpe': 9.5},
              {'kg': 60.0, 'reps': 12, 'rpe': 10.0},
            ],
          },
          {
            'name': 'Calf Raise',
            'muscle': 'Legs',
            'sets': [
              {'kg': 80.0, 'reps': 15, 'rpe': 8.0},
              {'kg': 80.0, 'reps': 15, 'rpe': 8.5},
              {'kg': 80.0, 'reps': 15, 'rpe': 9.0},
            ],
          },
        ],
      ),
    ];
  }
}
