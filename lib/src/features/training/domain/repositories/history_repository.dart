import 'package:starter_app/src/features/training/domain/entities/completed_workout.dart';

/// Repository for fetching workout history.
abstract class HistoryRepository {
  /// Returns all completed workouts, sorted by date (newest first).
  Future<List<CompletedWorkout>> getHistory();

  /// Returns a specific completed workout by [id].
  Future<CompletedWorkout?> getCompletedWorkoutById(String id);
}
