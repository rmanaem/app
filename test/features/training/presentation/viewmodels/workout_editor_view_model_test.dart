import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_program.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';
import 'package:starter_app/src/features/training/program_builder/domain/repositories/program_builder_repository.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/viewmodels/workout_editor_view_model.dart';

class MockProgramBuilderRepository extends Mock
    implements ProgramBuilderRepository {}

void main() {
  late MockProgramBuilderRepository repository;
  late WorkoutEditorViewModel viewModel;

  setUp(() {
    repository = MockProgramBuilderRepository();

    // Mock successful draft loading
    when(() => repository.getCurrentDraft()).thenAnswer(
      (_) async => const DraftProgram(
        id: 'draft_1',
        name: 'Test Program',
        split: ProgramSplit.ppl,
        schedule: {},
        workouts: [
          DraftWorkout(id: 'w1', name: 'Push Day', description: ''),
        ],
      ),
    );

    viewModel = WorkoutEditorViewModel(
      repository: repository,
      workoutId: 'w1',
    );
  });

  group('WorkoutEditorViewModel', () {
    test(
      'removeExercise removes item at index and notifies listeners',
      () async {
        // Wait for initial load to complete
        await viewModel.loadFuture;

        // Verify initial state (seeded mock exercises for 'Push')
        expect(viewModel.exercises.length, 3);
        final firstExerciseKey = viewModel.exercises[0]['_key'];

        // Track listener calls
        var listenerCallCount = 0;
        // Act: Remove the first exercise
        viewModel
          ..addListener(() {
            listenerCallCount++;
          })
          ..removeExercise(0);

        // Assert
        expect(viewModel.exercises.length, 2);
        expect(viewModel.exercises[0]['_key'], isNot(firstExerciseKey));
        expect(listenerCallCount, 1);
      },
    );

    test('removeExercise does nothing if index is out of bounds', () async {
      // Wait for initial load
      await viewModel.loadFuture;
      expect(viewModel.exercises.length, 3);

      // Track listener calls
      var listenerCallCount = 0;
      // Act: Try to remove invalid index
      viewModel
        ..addListener(() {
          listenerCallCount++;
        })
        ..removeExercise(99);

      // Assert
      expect(viewModel.exercises.length, 3);
      expect(listenerCallCount, 0);
    });

    test('onExercisesAdded assigns unique keys to new exercises', () async {
      await viewModel.loadFuture;
      final initialCount = viewModel.exercises.length;

      final newExercises = [
        {'name': 'New Ex 1'},
        {'name': 'New Ex 2'},
      ];

      viewModel.onExercisesAdded(newExercises);

      expect(viewModel.exercises.length, initialCount + 2);

      final addedEx1 = viewModel.exercises[initialCount];
      final addedEx2 = viewModel.exercises[initialCount + 1];

      expect(addedEx1['_key'], isNotNull);
      expect(addedEx2['_key'], isNotNull);
      expect(addedEx1['_key'], isNot(addedEx2['_key']));
    });

    test('reorderExercises moves item and notifies listeners', () async {
      await viewModel.loadFuture;

      // Initial: [Bench, Overhead, Incline]
      final initialFirst = viewModel.exercises[0];
      final initialSecond = viewModel.exercises[1];

      // Track listener calls
      var listenerCallCount = 0;
      // Move first item (Bench) to index 2 (after Overhead)
      // Note: reorderExercises expects oldIndex and newIndex from
      // ReorderableListView. If moving down, newIndex includes the item itself,
      // so index 2 means insert at 2.
      // 0 (Bench), 1 (Overhead), 2 (Incline)
      // Move 0 to 2 -> [Overhead, Bench, Incline]
      viewModel
        ..addListener(() {
          listenerCallCount++;
        })
        ..reorderExercises(0, 2);

      expect(listenerCallCount, 1);
      expect(viewModel.exercises[0]['name'], initialSecond['name']); // Overhead
      expect(viewModel.exercises[1]['name'], initialFirst['name']); // Bench
    });
  });
}
