import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_program.dart';
import 'package:starter_app/src/features/training/program_builder/domain/repositories/program_builder_repository.dart';

/// ViewModel for reviewing/editing the program structure.
class ProgramStructureViewModel extends ChangeNotifier {
  /// Creates the view model and loads the draft.
  ProgramStructureViewModel(this._repository) {
    unawaited(_loadDraft());
  }

  final ProgramBuilderRepository _repository;

  DraftProgram? _draft;
  bool _isLoading = true;

  /// Current draft program (if any).
  DraftProgram? get draft => _draft;

  /// Loading state.
  bool get isLoading => _isLoading;

  Future<void> _loadDraft() async {
    _isLoading = true;
    notifyListeners();
    try {
      _draft = await _repository.getCurrentDraft();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes the current draft from the repository.
  Future<void> refresh() => _loadDraft();

  /// Loads an existing program by [programId] to edit its structure.
  Future<void> loadProgram(String programId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final program = await _repository.getProgramById(programId);
      if (program != null) {
        _draft = program;
      }
    } on Exception catch (e) {
      debugPrint('Failed to load program: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Placeholder hook for future workout editing navigation.
  void onEditWorkout(String workoutId) {
    // TODO(app-team): Navigate to Workout Editor Page
  }

  /// Publishes the program and exits the builder.
  Future<void> publishProgram(BuildContext context) async {
    if (_draft == null) return;

    try {
      await _repository.publishProgram(_draft!);

      if (context.mounted) {
        // Return true to indicate changes were made
        context.pop(true);
      }
    } on Exception catch (e) {
      debugPrint('Failed to publish program: $e');
    }
  }
}
