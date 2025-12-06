import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';

import 'package:starter_app/src/features/training/program_builder/presentation/pages/exercise_selection_page.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/viewmodels/exercise_selection_view_model.dart';

// Mocks
class MockExerciseSelectionViewModel extends ChangeNotifier
    implements ExerciseSelectionViewModel {
  MockExerciseSelectionViewModel({this.isSingleSelect = false});

  @override
  bool isSingleSelect;

  @override
  int get selectedCount => 1;

  @override
  String? get singleSelectedName => 'Mock Exercise';

  @override
  List<Map<String, dynamic>> get filteredExercises => [
    {'id': '1', 'name': 'Mock Exercise', 'muscle': 'Chest'},
  ];

  @override
  Set<String> get selectedIds => {'1'};

  @override
  String get selectedCategory => 'All';

  @override
  void updateSearch(String query) {}

  @override
  void selectCategory(String category) {}

  @override
  void toggleSelection(String id) {}

  @override
  List<Map<String, dynamic>> confirmSelection() => [];

  @override
  void Function(List<Map<String, dynamic>>) get onAdd => (_) {};
}

void main() {
  Widget createWidget({
    required bool isSingleSelect,
    String? submitButtonText,
  }) {
    return MaterialApp(
      theme: makeTheme(AppColors.dark, dark: true),
      home: ChangeNotifierProvider<ExerciseSelectionViewModel>(
        create: (_) =>
            MockExerciseSelectionViewModel(isSingleSelect: isSingleSelect),
        child: ExerciseSelectionPage(
          isSingleSelect: isSingleSelect,
          submitButtonText: submitButtonText,
        ),
      ),
    );
  }

  group('ExerciseSelectionPage Regression Tests', () {
    testWidgets('Displays "ADD" button when isSingleSelect is false', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(isSingleSelect: false));
      await tester.pumpAndSettle();

      expect(find.textContaining('ADD'), findsOneWidget);
      expect(find.textContaining('SWAP'), findsNothing);
    });

    testWidgets('Displays "SWAP" button when isSingleSelect is true', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(isSingleSelect: true));
      await tester.pumpAndSettle();

      expect(find.textContaining('SWAP'), findsOneWidget);
      expect(find.textContaining('ADD'), findsNothing);
    });
    testWidgets('Displays custom text if provided', (tester) async {
      await tester.pumpWidget(
        createWidget(isSingleSelect: true, submitButtonText: 'CUSTOM ADD'),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('CUSTOM ADD'), findsOneWidget);
      expect(find.textContaining('SWAP'), findsNothing);
    });
  });
}
