import 'package:flutter/foundation.dart';

/// Manages selection of exercises for a workout (temporary mock data).
class ExerciseSelectionViewModel extends ChangeNotifier {
  /// Creates the view model.
  ExerciseSelectionViewModel({
    required this.onAdd,
    this.isSingleSelect = false,
  });

  /// Whether to allow only one exercise to be selected.
  final bool isSingleSelect;

  /// Callback invoked when exercises are confirmed.
  final void Function(List<Map<String, dynamic>>) onAdd;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Set<String> _selectedIds = <String>{};

  /// Temporary mock data (replace with ExerciseRepository later).
  final List<Map<String, dynamic>> _allExercises = <Map<String, dynamic>>[
    {'id': '1', 'name': 'Bench Press (Barbell)', 'muscle': 'Chest'},
    {'id': '2', 'name': 'Bench Press (Dumbbell)', 'muscle': 'Chest'},
    {'id': '3', 'name': 'Incline Bench Press', 'muscle': 'Chest'},
    {'id': '4', 'name': 'Cable Fly', 'muscle': 'Chest'},
    {'id': '5', 'name': 'Squat (Barbell)', 'muscle': 'Legs'},
    {'id': '6', 'name': 'Leg Press', 'muscle': 'Legs'},
    {'id': '7', 'name': 'Bulgarian Split Squat', 'muscle': 'Legs'},
    {'id': '8', 'name': 'Deadlift (Conventional)', 'muscle': 'Back'},
    {'id': '9', 'name': 'Pull Up', 'muscle': 'Back'},
    {'id': '10', 'name': 'Lat Pulldown', 'muscle': 'Back'},
    {'id': '11', 'name': 'Overhead Press', 'muscle': 'Shoulders'},
    {'id': '12', 'name': 'Lateral Raise', 'muscle': 'Shoulders'},
    {'id': '13', 'name': 'Tricep Extension', 'muscle': 'Arms'},
    {'id': '14', 'name': 'Bicep Curl', 'muscle': 'Arms'},
  ];

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
