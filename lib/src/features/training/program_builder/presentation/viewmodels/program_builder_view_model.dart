import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_program.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';
import 'package:starter_app/src/features/training/program_builder/domain/repositories/program_builder_repository.dart';

/// Manages state for configuring a training program.
class ProgramBuilderViewModel extends ChangeNotifier {
  /// Creates the view model.
  ProgramBuilderViewModel(this._repository);

  final ProgramBuilderRepository _repository;

  String _programName = '';
  ProgramSplit _selectedSplit = ProgramSplit.ppl;

  /// Active training days keyed by weekday index (0 = Monday).
  final Map<int, bool> _schedule = <int, bool>{
    0: true,
    1: true,
    2: true,
    3: true,
    4: true,
    5: false,
    6: false,
  };

  /// The current program name.
  String get programName => _programName;

  /// The currently selected split.
  ProgramSplit get selectedSplit => _selectedSplit;

  /// Read-only schedule map.
  Map<int, bool> get schedule => Map<int, bool>.unmodifiable(_schedule);

  /// Whether the configuration can be saved.
  bool get isValid => _programName.isNotEmpty && _schedule.containsValue(true);
  DraftProgram? _draft;

  /// The draft created after saving.
  DraftProgram? get draft => _draft;

  /// Updates the program name.
  void setName(String name) {
    _programName = name;
    notifyListeners();
  }

  /// Updates the selected split.
  void setSplit(ProgramSplit split) {
    if (_selectedSplit == split) return;
    _selectedSplit = split;
    unawaited(HapticFeedback.selectionClick());
    notifyListeners();
  }

  /// Toggles the active state for a weekday.
  void toggleDay(int dayIndex) {
    if (dayIndex < 0 || dayIndex > 6) return;
    _schedule[dayIndex] = !(_schedule[dayIndex] ?? false);
    unawaited(HapticFeedback.lightImpact());
    notifyListeners();
  }

  /// Saves the program to the repository.
  Future<void> saveProgram() async {
    if (!isValid) return;
    unawaited(HapticFeedback.heavyImpact());
    _draft = await _repository.createDraft(
      name: _programName,
      split: _selectedSplit,
      schedule: _schedule,
    );
  }
}
