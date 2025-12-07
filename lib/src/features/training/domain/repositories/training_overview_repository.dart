import 'package:starter_app/src/features/training/domain/entities/training_overview.dart';

/// Repository contract for retrieving training week overviews.
abstract class TrainingOverviewRepository {
  /// Returns overview data for the week containing [anchorDate].
  Future<TrainingOverview> getOverviewForWeek(DateTime anchorDate);

  /// Hint that underlying data should refresh (no-op for the fake repo).
  Future<void> refresh();

  /// Marks a specific workout as completed for the day.
  /// Marks a specific workout (from the plan) as completed.
  ///
  /// [completedWorkoutId] is the ID of the actual session record in history,
  /// used for linking.
  Future<void> markWorkoutAsCompleted(
    String workoutId, {
    String? completedWorkoutId,
  });
}
