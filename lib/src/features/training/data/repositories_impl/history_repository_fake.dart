import 'package:starter_app/src/features/training/domain/entities/completed_workout.dart';
import 'package:starter_app/src/features/training/domain/repositories/history_repository.dart';

/// Fake implementation of [HistoryRepository] with mock data.
class HistoryRepositoryFake implements HistoryRepository {
  @override
  Future<List<CompletedWorkout>> getHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _getMockWorkouts();
  }

  @override
  Future<CompletedWorkout?> getCompletedWorkoutById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final workouts = _getMockWorkouts();
    return workouts.cast<CompletedWorkout?>().firstWhere(
      (w) => w?.id == id,
      orElse: () => null,
    );
  }

  List<CompletedWorkout> _getMockWorkouts() {
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
    ];
  }
}
