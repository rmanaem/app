import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/features/training/domain/entities/completed_workout.dart';
import 'package:starter_app/src/features/training/domain/entities/training_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/workout_summary.dart';
import 'package:starter_app/src/features/training/domain/repositories/history_repository.dart';
import 'package:starter_app/src/features/training/domain/repositories/training_overview_repository.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/active_session_view_model.dart';

// Mocks
class MockHistoryRepository implements HistoryRepository {
  CompletedWorkout? savedWorkout;

  @override
  Future<void> saveWorkout(CompletedWorkout workout) async {
    savedWorkout = workout;
  }

  @override
  Future<List<CompletedWorkout>> getHistory() async => [];

  @override
  Future<CompletedWorkout?> getCompletedWorkoutById(String id) async => null;
}

class MockTrainingOverviewRepository implements TrainingOverviewRepository {
  String? completedWorkoutId;
  String? markedAsCompletedId;
  WorkoutSummary? latestCompletedWorkout;

  @override
  Future<TrainingOverview> getOverviewForWeek(DateTime anchorDate) async {
    throw UnimplementedError();
  }

  @override
  Future<void> markWorkoutAsCompleted(
    String workoutId, {
    String? completedWorkoutId,
  }) async {
    markedAsCompletedId = workoutId;
    this.completedWorkoutId = completedWorkoutId;
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> setLatestCompletedWorkout(WorkoutSummary workout) async {
    latestCompletedWorkout = workout;
  }
}

void main() {
  group('ActiveSessionViewModel', () {
    late ActiveSessionViewModel vm;
    late MockHistoryRepository mockHistoryRepository;
    late MockTrainingOverviewRepository mockTrainingOverviewRepository;

    setUp(() async {
      mockHistoryRepository = MockHistoryRepository();
      mockTrainingOverviewRepository = MockTrainingOverviewRepository();

      vm = ActiveSessionViewModel(
        workoutId: '123',
        historyRepository: mockHistoryRepository,
        repository: mockTrainingOverviewRepository,
      );
      // Wait for mock data load
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });

    test('Initializes correctly with mock data', () {
      expect(vm.isLoading, false);
      expect(vm.exercises.length, 2);
      expect(vm.restDurationSeconds, 90);
    });

    // ... (existing tests)

    test('saveSession saves to history and marks as completed', () async {
      final workout = CompletedWorkout(
        id: 'test-id',
        name: 'Test Workout',
        completedAt: DateTime.now(),
        durationSeconds: 3600,
        totalVolumeKg: 10000,
        totalSets: 10,
        prCount: 0,
        exerciseCount: 5,
      );

      await vm.saveSession(workout);

      // Verify History Repo called
      expect(mockHistoryRepository.savedWorkout, workout);
      // Ensure exercises are preserved if we passed them (though the test above
      // creates the object manually)
    });

    test('finishSession maps exercises correctly', () {
      // 1. Setup a session with some data
      // (The VM starts with data from _loadSession in constructor, wait for it)
      expect(vm.exercises.length, 2);

      // 2. Mark some sets as done
      vm
        ..toggleSet(0, 0) // Ex 1, Set 1
        ..toggleSet(1, 0); // Ex 2, Set 1

      // 3. Finish
      final result = vm.finishSession();

      // 4. Verify
      expect(result.exerciseCount, 2);
      expect(result.exercises.length, 2);

      // Check first exercise mapping
      final ex1 = result.exercises[0];
      expect(ex1['name'], 'Bench Press (Barbell)');
      expect((ex1['sets'] as List).length, 1);

      final firstSet = (ex1['sets'] as List)[0] as Map<String, dynamic>;
      expect(
        firstSet['kg'],
        100.0,
      ); // Check key mapping 'weight' -> 'kg'

      // Check total volume
      // Ex 1 Set 1: 100 * 5 = 500
      // Ex 2 Set 1: 32 * 10 = 320
      // Total = 820
      expect(result.totalVolumeKg, 820);
    });

    test('saveSession saves to history and marks as completed', () async {
      final workout = CompletedWorkout(
        id: 'test-id',
        name: 'Test Workout',
        completedAt: DateTime.now(),
        durationSeconds: 3600,
        totalVolumeKg: 10000,
        totalSets: 10,
        prCount: 0,
        exerciseCount: 5,
      );

      await vm.saveSession(workout);

      // Verify History Repo called
      expect(mockHistoryRepository.savedWorkout, workout);

      // Verify Overview Repo called with correct IDs
      expect(mockTrainingOverviewRepository.markedAsCompletedId, 'next-1');
      expect(mockTrainingOverviewRepository.completedWorkoutId, 'test-id');
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
