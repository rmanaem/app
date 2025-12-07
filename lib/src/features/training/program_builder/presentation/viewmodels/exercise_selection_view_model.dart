import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/training/program_builder/domain/repositories/program_builder_repository.dart';

/// Manages selection of exercises for a workout (temporary mock data).
class ExerciseSelectionViewModel extends ChangeNotifier {
  /// Creates the view model.
  ExerciseSelectionViewModel({
    required this.onAdd,
    required this.repository,
    this.isSingleSelect = false,
  }) {
    unawaited(_loadExercises());
  }

  /// The repository to fetch and create exercises.
  final ProgramBuilderRepository repository;

  /// Whether to allow only one exercise to be selected.
  final bool isSingleSelect;

  /// Callback invoked when exercises are confirmed.
  final void Function(List<Map<String, dynamic>>) onAdd;

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Set<String> _selectedIds = <String>{};

  List<Map<String, dynamic>> _allExercises = [];

  /// Whether the exercises are currently loading.
  bool get isLoading => _isLoading;

  Future<void> _loadExercises() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allExercises = await repository.getAllExercises();
    } on Exception catch (e) {
      debugPrint('Error loading exercises: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a custom exercise and selects it.
  Future<void> createCustomExercise(String name, String muscle) async {
    try {
      final newExercise = await repository.createCustomExercise(
        name: name,
        muscle: muscle,
      );

      // 1. Add to local list immediately
      _allExercises.add(newExercise);

      // 2. Select it automatically for the user
      toggleSelection(newExercise['id'] as String);

      // 3. Clear filters so the user sees what they just created
      _searchQuery = '';
      _selectedCategory = 'All';

      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error creating exercise: $e');
    }
  }

  /// Filtered list based on query/category.
  List<Map<String, dynamic>> get filteredExercises {
    return _allExercises.where((ex) {
      final matchesSearch = ex['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == 'All' || ex['muscle'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Selected exercise ids.
  Set<String> get selectedIds => _selectedIds;

  /// Current category.
  String get selectedCategory => _selectedCategory;

  /// Count of selected exercises.
  int get selectedCount => _selectedIds.length;

  /// Name of the single selected exercise (if any).
  String? get singleSelectedName {
    if (_selectedIds.isEmpty) return null;
    final id = _selectedIds.first;
    final exercise = _allExercises.firstWhere(
      (e) => e['id'] == id,
      orElse: () => <String, dynamic>{}, // Return empty map if not found
    );
    return exercise['name'] as String?;
  }

  /// The current search query.
  String get searchQuery => _searchQuery;

  /// Updates the search query.
  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Selects a category filter.
  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Toggles selection for an exercise id.
  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      if (isSingleSelect) {
        _selectedIds.clear(); // Enforce single select
      }
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Confirms selection and maps to default sets/reps.
  List<Map<String, dynamic>> confirmSelection() {
    final selectedExercises = _allExercises
        .where((ex) => _selectedIds.contains(ex['id']))
        .map(
          (ex) => {
            ...ex,
            'sets': 3,
            'reps': '10',
          },
        )
        .toList();
    debugPrint(
      'ExerciseSelectionViewModel: confirming selection '
      'count=${selectedExercises.length}',
    );
    onAdd(selectedExercises);
    return selectedExercises;
  }
}
