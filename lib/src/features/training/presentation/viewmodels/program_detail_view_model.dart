import 'dart:async'; // Add this for unawaited
import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/training/domain/entities/program.dart';
import 'package:starter_app/src/features/training/domain/repositories/program_repository.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_program.dart';

/// View state for the Program Details screen.
enum ProgramDetailViewState {
  /// Data is loading.
  loading,

  /// Data is fully loaded.
  loaded,

  /// An error occurred.
  error,
}

/// View model for the Program Detail sheet.
class ProgramDetailViewModel extends ChangeNotifier {
  /// Creates the view model.
  ProgramDetailViewModel({
    required this.programId,
    required ProgramRepository repository,
  }) : _repository = repository {
    unawaited(_load());
  }

  /// The ID of the program being viewed.
  final String programId;
  final ProgramRepository _repository;

  ProgramDetailViewState _state = ProgramDetailViewState.loading;
  DraftProgram? _programDetails;
  Program? _programMetadata;
  String? _errorMessage;

  /// Current view state.
  ProgramDetailViewState get state => _state;

  /// Full program details (available content varies by state).
  DraftProgram? get programDetails => _programDetails;

  /// Lightweight program metadata.
  Program? get programMetadata => _programMetadata;

  /// Error message, if any.
  String? get errorMessage => _errorMessage;

  /// Whether the program is a read-only template.
  bool get isTemplate => _programMetadata?.isTemplate ?? false;

  /// Whether the program is currently active.
  bool get isActive => _programMetadata?.isActive ?? false;

  /// Reloads program data.
  Future<void> refresh() => _load();

  Future<void> _load() async {
    _state = ProgramDetailViewState.loading;
    notifyListeners();

    try {
      // 1. Fetch metadata from the list (for isActive, isTemplate, tags)
      final allPrograms = await _repository.getAllPrograms();
      _programMetadata = allPrograms.firstWhere((p) => p.id == programId);

      // 2. Fetch full details for the schedule view
      _programDetails = await _repository.getProgramDetails(programId);

      if (_programDetails == null) {
        _errorMessage = 'Program details not found.';
        _state = ProgramDetailViewState.error;
      } else {
        _state = ProgramDetailViewState.loaded;
      }
    } on Exception catch (e) {
      _errorMessage = e.toString();
      _state = ProgramDetailViewState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Activates the current program.
  Future<void> activateProgram() async {
    await _repository.setActiveProgram(programId);
    // Update local metadata to reflect active state
    if (_programMetadata != null) {
      _programMetadata = _programMetadata!.copyWith(isActive: true);
      notifyListeners();
    }
  }

  /// Deletes the current program.
  Future<void> deleteProgram() async {
    await _repository.deleteProgram(programId);
  }

  /// Clones the current template, activates it, and returns the new program ID.
  Future<String> cloneAndStartProgram() async {
    // Don't change state since we're navigating away immediately
    // _state = ProgramDetailViewState.loading;
    // notifyListeners();

    try {
      // 1. Clone the program
      final newProgramId = await _repository.cloneProgram(programId);

      // 2. Activate the new program
      await _repository.setActiveProgram(newProgramId);

      return newProgramId;
    } on Exception catch (e) {
      _errorMessage = e.toString();
      _state = ProgramDetailViewState.error;
      notifyListeners();
      rethrow;
    }
  }
}
