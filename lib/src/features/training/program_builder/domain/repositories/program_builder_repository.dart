import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_program.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';

/// Repository contract for creating and managing draft programs.
abstract class ProgramBuilderRepository {
  /// Creates a new draft and seeds it with default workouts
  /// based on the [split].
  Future<DraftProgram> createDraft({
    required String name,
    required ProgramSplit split,
    required Map<int, bool> schedule,
  });

  /// Retrieves the current draft being edited.
  Future<DraftProgram?> getCurrentDraft();

  /// Retrieves a specific program by [id] for editing.
  Future<DraftProgram?> getProgramById(String id);

  /// Updates a specific workout within the current draft.
  Future<void> updateWorkout(String workoutId, DraftWorkout workout);

  /// Publishes the current draft to the main program library.
  Future<void> publishProgram(DraftProgram draft);

  /// Creates a new custom exercise and adds it to the user's library.
  Future<Map<String, dynamic>> createCustomExercise({
    required String name,
    required String muscle,
  });

  /// Fetches all available exercises (System + Custom).
  Future<List<Map<String, dynamic>>> getAllExercises();
}
