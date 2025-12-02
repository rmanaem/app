import 'dart:async';

import 'package:flutter/foundation.dart';
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

  /// Placeholder hook for future workout editing navigation.
  void onEditWorkout(String workoutId) {
    // TODO(app-team): Navigate to Workout Editor Page
  }
}
