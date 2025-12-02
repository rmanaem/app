import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';

/// Represents a program currently under construction.
class DraftProgram {
  /// Creates a draft program.
  const DraftProgram({
    required this.id,
    required this.name,
    required this.split,
    required this.schedule,
    required this.workouts,
  });

  /// Unique identifier for the draft.
  final String id;

  /// Program name.
  final String name;

  /// Selected split type.
  final ProgramSplit split;

  /// Map of Day Index (0=Mon) to Active Status.
  final Map<int, bool> schedule;

  /// The list of workouts defined in this program.
  final List<DraftWorkout> workouts;

  /// Returns the workout assigned to a specific day index, if any.
  /// For the MVP, we auto-assign workouts based on the split pattern.
  DraftWorkout? getWorkoutForDay(int dayIndex) {
    if (workouts.isEmpty) return null;
    if (schedule[dayIndex] ?? false) {
      return workouts[dayIndex % workouts.length];
    }
    return null;
  }
}
