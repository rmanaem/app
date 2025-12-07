import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/training/domain/entities/program.dart';
import 'package:starter_app/src/features/training/domain/repositories/program_repository.dart';

/// View model for the Program Library feature.
class ProgramLibraryViewModel extends ChangeNotifier {
  /// Creates the view model and loads programs.
  ProgramLibraryViewModel(this._repository) {
    unawaited(_load());
  }

  final ProgramRepository _repository;

  bool _isLoading = true;
  List<Program> _programs = [];
  int _selectedTabIndex = 0; // 0 = Mine, 1 = Templates

  /// Whether the data is currently loading.
  bool get isLoading => _isLoading;

  /// The currently selected tab index (0 for Mine, 1 for Templates).
  int get selectedTabIndex => _selectedTabIndex;

  /// Returns the list of programs filtered by the selected tab.
  List<Program> get filteredPrograms {
    if (_selectedTabIndex == 0) {
      return _programs.where((p) => !p.isTemplate).toList();
    }
    return _programs.where((p) => p.isTemplate).toList();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _programs = await _repository.getAllPrograms();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the selected tab index.
  void setTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  /// Sets the specified program as active.
  Future<void> activateProgram(String id) async {
    await _repository.setActiveProgram(id);
    await _load(); // Refresh state
  }

  /// Deletes the specified program.
  Future<void> deleteProgram(String id) async {
    await _repository.deleteProgram(id);
    await _load();
  }

  /// Manually refreshes the program list.
  Future<void> refresh() async {
    await _load();
  }
}
