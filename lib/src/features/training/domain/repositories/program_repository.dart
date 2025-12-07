import 'package:starter_app/src/features/training/domain/entities/program.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_program.dart';

/// Repository for managing the user's program library.
abstract class ProgramRepository {
  /// Fetches all programs (user created + templates).
  Future<List<Program>> getAllPrograms();

  /// Fetches the full details of a program.
  Future<DraftProgram?> getProgramDetails(String programId);

  /// Sets a program as the "Active" protocol.
  Future<void> setActiveProgram(String programId);

  /// Deletes a user-created program.
  Future<void> deleteProgram(String programId);

  /// Clones a template program to the user's library and returns the new ID.
  Future<String> cloneProgram(String programId);

  /// Updates an existing program with new details.
  Future<void> updateProgram(DraftProgram program);
}
