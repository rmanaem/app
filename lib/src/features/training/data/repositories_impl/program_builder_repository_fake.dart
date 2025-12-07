import 'package:starter_app/src/features/training/domain/repositories/program_repository.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_program.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';
import 'package:starter_app/src/features/training/program_builder/domain/repositories/program_builder_repository.dart';
import 'package:uuid/uuid.dart';

/// Fake repository that seeds a draft program in memory.
class ProgramBuilderRepositoryFake implements ProgramBuilderRepository {
  /// Creates a fake builder repository.
  ///
  /// Optionally injected with a [ProgramRepository] to fetch existing programs.
  ProgramBuilderRepositoryFake({ProgramRepository? programRepository})
    : _programRepository = programRepository;

  final ProgramRepository? _programRepository;
  DraftProgram? _currentDraft;

  @override
  Future<DraftProgram> createDraft({
    required String name,
    required ProgramSplit split,
    required Map<int, bool> schedule,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final workouts = _generateDefaultsForSplit(split);

    _currentDraft = DraftProgram(
      id: const Uuid().v4(),
      name: name,
      split: split,
      schedule: Map<int, bool>.from(schedule),
      workouts: workouts,
    );

    return _currentDraft!;
  }

  @override
  Future<DraftProgram?> getCurrentDraft() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _currentDraft;
  }

  @override
  Future<DraftProgram?> getProgramById(String id) async {
    // 1. Check if it's the current working draft
    if (_currentDraft?.id == id) {
      return _currentDraft;
    }

    // 2. Try fetching from the main program repository
    if (_programRepository != null) {
      final existingProgram = await _programRepository.getProgramDetails(id);
      if (existingProgram != null) {
        // Set this as the working draft
        _currentDraft = existingProgram;
        return existingProgram;
      }
    }

    // 3. Fallback to mock data for 'p1' (if not found in repo)
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (id == 'p1') {
      return const DraftProgram(
        id: 'p1',
        name: 'Winter Bulk',
        split: ProgramSplit.ppl,
        schedule: {
          0: true,
          1: true,
          2: true,
          3: false,
          4: true,
          5: true,
          6: false,
        },
        workouts: [
          DraftWorkout(id: 'w1', name: 'Push A', description: 'C,S,T'),
          DraftWorkout(id: 'w2', name: 'Pull A', description: 'B,RD,Bi'),
          DraftWorkout(id: 'w3', name: 'Legs A', description: 'Q,H,C'),
        ],
      );
    }
    return null;
  }

  @override
  Future<void> updateWorkout(String workoutId, DraftWorkout workout) async {
    if (_currentDraft == null) return;

    final newWorkouts = _currentDraft!.workouts.map((w) {
      return w.id == workoutId ? workout : w;
    }).toList();

    _currentDraft = DraftProgram(
      id: _currentDraft!.id,
      name: _currentDraft!.name,
      split: _currentDraft!.split,
      schedule: _currentDraft!.schedule,
      workouts: newWorkouts,
      description: _currentDraft!.description,
    );
  }

  @override
  Future<void> publishProgram(DraftProgram draft) async {
    // Sync current draft if it matches
    if (_currentDraft?.id == draft.id) {
      _currentDraft = draft;
    }

    // Call main repo update
    if (_programRepository != null) {
      await _programRepository.updateProgram(draft);
    }
  }

  List<DraftWorkout> _generateDefaultsForSplit(ProgramSplit split) {
    const uuid = Uuid();
    switch (split) {
      case ProgramSplit.ppl:
        return [
          DraftWorkout(
            id: uuid.v4(),
            name: 'Push A',
            description: 'Chest, Shoulders, Triceps',
          ),
          DraftWorkout(
            id: uuid.v4(),
            name: 'Pull A',
            description: 'Back, Rear Delts, Biceps',
          ),
          DraftWorkout(
            id: uuid.v4(),
            name: 'Legs A',
            description: 'Quads, Hamstrings, Calves',
          ),
        ];
      case ProgramSplit.upperLower:
        return [
          DraftWorkout(
            id: uuid.v4(),
            name: 'Upper A',
            description: 'Upper Body focus',
          ),
          DraftWorkout(
            id: uuid.v4(),
            name: 'Lower A',
            description: 'Lower Body focus',
          ),
        ];
      case ProgramSplit.fullBody:
        return [
          DraftWorkout(
            id: uuid.v4(),
            name: 'Full Body A',
            description: 'Compound movements',
          ),
          DraftWorkout(
            id: uuid.v4(),
            name: 'Full Body B',
            description: 'Accessory focus',
          ),
        ];
      case ProgramSplit.broSplit:
        return [
          DraftWorkout(
            id: uuid.v4(),
            name: 'Chest Day',
            description: 'International chest day',
          ),
          DraftWorkout(
            id: uuid.v4(),
            name: 'Back Day',
            description: 'Wings',
          ),
          DraftWorkout(
            id: uuid.v4(),
            name: 'Leg Day',
            description: 'The Wheelhouse',
          ),
          DraftWorkout(
            id: uuid.v4(),
            name: 'Arms',
            description: 'Gun show',
          ),
          DraftWorkout(
            id: uuid.v4(),
            name: 'Shoulders',
            description: 'Boulders',
          ),
        ];
      case ProgramSplit.custom:
        return [];
    }
  }
}
