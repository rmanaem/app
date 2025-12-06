import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/active_session_view_model.dart';

void main() {
  group('ActiveSessionViewModel', () {
    late ActiveSessionViewModel vm;

    setUp(() async {
      vm = ActiveSessionViewModel(workoutId: '123');
      // Wait for mock data load
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });

    test('Initializes correctly with mock data', () {
      expect(vm.isLoading, false);
      expect(vm.exercises.length, 2);
      expect(vm.restDurationSeconds, 90);
    });

    test('toggleSet starts and stops timer correctly', () {
      // 1. Mark set as Done -> Should start timer
      vm.toggleSet(0, 0);
      expect(((vm.exercises[0]['sets'] as List)[0] as Map)['done'], true);
      expect(vm.isTimerActive, true);
      expect(vm.activeRestExerciseIndex, 0);
      expect(vm.activeRestSetIndex, 0);

      // 2. Mark same set as Undone -> Should stop timer
      vm.toggleSet(0, 0);
      expect(((vm.exercises[0]['sets'] as List)[0] as Map)['done'], false);
      expect(vm.isTimerActive, false);
      expect(vm.activeRestExerciseIndex, null);
    });

    test('updateSet updates single set values', () {
      vm.updateSet(0, 0, {'weight': 105.0});
      expect(((vm.exercises[0]['sets'] as List)[0] as Map)['weight'], 105.0);
    });

    test(
      'updateSet with propagateToFuture (Ripple Update) works correctly',
      () {
        // Setup: ensure subsequent sets are NOT done
        expect(((vm.exercises[0]['sets'] as List)[1] as Map)['done'], false);
        expect(((vm.exercises[0]['sets'] as List)[2] as Map)['done'], false);

        // Update set 0 with ripple
        vm.updateSet(
          0,
          0,
          {'weight': 110.0, 'reps': 6, 'rpe': 9.0},
          propagateToFuture: true,
        );

        // Check Set 0 (Source)
        final set0 = (vm.exercises[0]['sets'] as List)[0] as Map;
        expect(set0['weight'], 110.0);
        expect(set0['reps'], 6);

        // Check Set 1 (Future) - Should be updated
        final set1 = (vm.exercises[0]['sets'] as List)[1] as Map;
        expect(set1['targetWeight'], 110.0); // Target updated
        expect(set1['weight'], 110.0); // Actual pre-filled
        expect(set1['targetReps'], 6);
        expect(set1['targetRpe'], 9.0);

        // Check Set 2 (Future) - Should be updated
        final set2 = (vm.exercises[0]['sets'] as List)[2] as Map;
        expect(set2['targetWeight'], 110.0);
      },
    );

    test('Ripple logic does NOT update completed sets', () {
      // Setup: Mark set 1 as done
      vm.toggleSet(0, 1);
      expect(((vm.exercises[0]['sets'] as List)[1] as Map)['done'], true);

      // Update set 0 with ripple
      vm.updateSet(
        0,
        0,
        {'weight': 120.0},
        propagateToFuture: true,
      );

      // Set 1 (Done) should NOT change
      final set1 = (vm.exercises[0]['sets'] as List)[1] as Map;
      expect(set1['targetWeight'], 100.0); // Original value
      expect(set1['weight'], 100.0);

      // Set 2 (Not Done) SHOULD change
      final set2 = (vm.exercises[0]['sets'] as List)[2] as Map;
      expect(set2['targetWeight'], 120.0);
    });

    test('addSet adds a new set inheriting previous values', () {
      // Initial count
      final initialCount = (vm.exercises[0]['sets'] as List).length;

      // Add set
      vm.addSet(0);

      final sets = vm.exercises[0]['sets'] as List;
      expect(sets.length, initialCount + 1);

      final lastSet = sets.last as Map;
      final secondLastSet = sets[sets.length - 2] as Map;

      // Should inherit weight/reps
      expect(lastSet['weight'], secondLastSet['weight']);
      expect(lastSet['reps'], secondLastSet['reps']);
      expect(lastSet['done'], false);
    });

    test('Timer manipulation works', () {
      vm.toggleSet(0, 0); // Start timer
      final initialTimer = vm.timerSeconds;

      vm.addTime(30);
      expect(vm.timerSeconds, initialTimer + 30);
      expect(vm.timerTotalSeconds, initialTimer + 30);

      vm.skipTimer();
      expect(vm.isTimerActive, false);
      expect(vm.activeRestExerciseIndex, null);
    });

    test('appendExercise adds a configured exercise', () {
      final config = {
        'name': 'New Exercise',
        'muscle': 'Legs',
        'notes': 'Some notes',
        'rest': '60',
        'sets': 4,
        'weight': 50.0,
        'reps': 12,
        'rpe': 7.0,
      };

      vm.appendExercise(config);

      expect(vm.exercises.length, 3);
      final newEx = vm.exercises.last;
      expect(newEx['name'], 'New Exercise');
      expect(newEx['note'], 'Some notes');
      expect((newEx['sets'] as List).length, 4);

      final firstSet = (newEx['sets'] as List)[0] as Map;
      expect(firstSet['weight'], 50.0);
      expect(firstSet['reps'], 12);
    });

    test('replaceExercise swaps exercise and resets sets', () {
      // Replace the first exercise (which has 3 sets of 100kg)
      final config = {
        'name': 'Swapped Exercise',
        'muscle': 'Chest',
        'notes': 'New note',
        'rest': '120',
        'sets': 2, // Changing set count
        'weight': 80.0,
        'reps': 8,
        'rpe': 9.0,
      };

      vm.replaceExercise(0, config);

      final updatedEx = vm.exercises[0];
      expect(updatedEx['name'], 'Swapped Exercise');
      expect((updatedEx['sets'] as List).length, 2);

      final firstSet = (updatedEx['sets'] as List)[0] as Map;
      expect(firstSet['weight'], 80.0);
    });

    test('removeExercise removes exercise at index', () {
      final initialCount = vm.exercises.length;
      vm.removeExercise(0);
      expect(vm.exercises.length, initialCount - 1);
      expect(
        vm.exercises[0]['name'],
        'Incline Dumbbell Press',
      ); // Second one is now first
    });
  });
}
