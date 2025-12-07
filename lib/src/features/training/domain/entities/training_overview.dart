import 'package:meta/meta.dart';
import 'package:starter_app/src/features/training/domain/entities/training_day_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/workout_summary.dart';

/// Aggregated overview for a training week.
@immutable
class TrainingOverview {
  /// Creates a training overview snapshot.
  const TrainingOverview({
    required this.anchorDate,
    required this.weekDays,
    required this.hasProgram,
    required this.completedWorkouts,
    required this.plannedWorkouts,
    this.nextWorkout,
    this.lastWorkout,
    this.activeProgramId,
  });

  /// Anchor date (usually today) for the overview.
  final DateTime anchorDate;

  /// Seven-day strip entries surrounding [anchorDate].
  final List<TrainingDayOverview> weekDays;

  /// Upcoming workout summary, if available.
  final WorkoutSummary? nextWorkout;

  /// Most recently completed workout summary, if available.
  final WorkoutSummary? lastWorkout;

  /// Whether the user currently has a program configured.
  final bool hasProgram;

  /// Completed workouts count for the week.
  final int completedWorkouts;

  /// Planned workouts count for the week.
  final int plannedWorkouts;

  /// The ID of the currently active program, if any.
  final String? activeProgramId;
}
