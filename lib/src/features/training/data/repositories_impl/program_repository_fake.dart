import 'package:starter_app/src/features/training/domain/entities/program.dart';
import 'package:starter_app/src/features/training/domain/repositories/program_repository.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_program.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';
import 'package:uuid/uuid.dart';

/// A fake implementation of [ProgramRepository] using in-memory data.
class ProgramRepositoryFake implements ProgramRepository {
  final List<Program> _programs = [
    // Mock User Program
    Program(
      id: 'p1',
      name: 'Winter Bulk',
      split: ProgramSplit.ppl,
      description: 'Push Pull Legs - Hypertrophy Focus',
      lastPerformed: DateTime.now().subtract(const Duration(days: 2)),
      isActive: true,
      tags: ['Hypertrophy', '6 Days'],
    ),
    // Mock Templates
    const Program(
      id: 't1',
      name: 'Starting Strength',
      split: ProgramSplit.fullBody,
      description: 'The classic 3x5 barbell linear progression.',
      lastPerformed: null,
      isTemplate: true,
      tags: ['Beginner', 'Strength', '3 Days'],
    ),
    const Program(
      id: 't2',
      name: 'StrongLifts 5x5',
      split: ProgramSplit.fullBody,
      description: 'Simple and effective strength builder.',
      lastPerformed: null,
      isTemplate: true,
      tags: ['Novice', 'Strength', '3 Days'],
    ),
    const Program(
      id: 't3',
      name: 'PPL Classic',
      split: ProgramSplit.ppl,
      description: '6-day high volume split.',
      lastPerformed: null,
      isTemplate: true,
      tags: ['Intermediate', 'Volume', '6 Days'],
    ),
  ];
  final Map<String, DraftProgram> _programDetails = {
    'p1': const DraftProgram(
      id: 'p1',
      name: 'Winter Bulk',
      split: ProgramSplit.ppl,
      description: 'Push Pull Legs - Hypertrophy Focus',
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
        DraftWorkout(
          id: 'w1',
          name: 'Push A',
          description: 'Chest, Shoulders, Triceps',
        ),
        DraftWorkout(
          id: 'w2',
          name: 'Pull A',
          description: 'Back, Biceps, Rear Delts',
        ),
        DraftWorkout(
          id: 'w3',
          name: 'Legs A',
          description: 'Quads, Hamstrings, Calves',
        ),
      ],
    ),
    't1': const DraftProgram(
      id: 't1',
      name: 'Starting Strength',
      split: ProgramSplit.fullBody,
      description: 'The classic 3x5 barbell linear progression.',
      schedule: {0: true, 2: true, 4: true}, // Mon, Wed, Fri
      workouts: [
        DraftWorkout(
          id: 'w_ss_a',
          name: 'Workout A',
          description: 'Squat, Press, Deadlift',
        ),
        DraftWorkout(
          id: 'w_ss_b',
          name: 'Workout B',
          description: 'Squat, Bench, Power Clean',
        ),
      ],
    ),
    't2': const DraftProgram(
      id: 't2',
      name: 'StrongLifts 5x5',
      split: ProgramSplit.fullBody,
      description: 'Simple and effective strength builder.',
      schedule: {0: true, 2: true, 4: true},
      workouts: [
        DraftWorkout(
          id: 'w_sl_a',
          name: 'Workout A',
          description: 'Squat, Bench, Row',
        ),
        DraftWorkout(
          id: 'w_sl_b',
          name: 'Workout B',
          description: 'Squat, Press, Deadlift',
        ),
      ],
    ),
    't3': const DraftProgram(
      id: 't3',
      name: 'PPL Classic',
      split: ProgramSplit.ppl,
      description: '6-day high volume split.',
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
        DraftWorkout(
          id: 'w_ppl_push',
          name: 'Push',
          description: 'Chest/Shoulders/Triceps',
        ),
        DraftWorkout(
          id: 'w_ppl_pull',
          name: 'Pull',
          description: 'Back/Biceps',
        ),
        DraftWorkout(id: 'w_ppl_legs', name: 'Legs', description: 'Quads/Hams'),
      ],
    ),
  };

  @override
  Future<List<Program>> getAllPrograms() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _programs;
  }

  @override
  Future<void> setActiveProgram(String programId) async {
    // Update the in-memory list
    for (var i = 0; i < _programs.length; i++) {
      final p = _programs[i];
      if (p.id == programId) {
        _programs[i] = p.copyWith(isActive: true);
      } else if (p.isActive) {
        _programs[i] = p.copyWith(isActive: false);
      }
    }
  }

  @override
  Future<DraftProgram?> getProgramDetails(String programId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _programDetails[programId];
  }

  @override
  Future<void> deleteProgram(String programId) async {
    _programs.removeWhere((p) => p.id == programId);
  }

  @override
  Future<String> cloneProgram(String programId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // 1. Find the template details
    final templateDetails = _programDetails[programId];
    if (templateDetails == null) {
      throw Exception('Template not found');
    }

    // 2. Generate new ID
    final newId = const Uuid().v4();

    // 3. Create deep copy
    final newDetails = DraftProgram(
      id: newId,
      name: templateDetails.name, // Keep original name or append 'Copy'
      split: templateDetails.split,
      description: templateDetails.description,
      schedule: Map.from(templateDetails.schedule),
      workouts: templateDetails.workouts
          .map(
            (w) => DraftWorkout(
              id: const Uuid().v4(), // New ID for workout copy
              name: w.name,
              description: w.description,
            ),
          )
          .toList(),
    );

    // 4. Store details
    _programDetails[newId] = newDetails;

    // 5. Create and store metadata (ensure it's not marked as template)
    final templateMeta = _programs.firstWhere((p) => p.id == programId);
    final newMeta = Program(
      id: newId,
      name: templateMeta.name,
      split: templateMeta.split,
      description: templateMeta.description,
      lastPerformed: null,
      tags: List.from(templateMeta.tags),
    );
    _programs.insert(0, newMeta); // Prepend to list

    return newId;
  }

  @override
  Future<void> updateProgram(DraftProgram program) async {
    // 1. Update detailed storage
    if (_programDetails.containsKey(program.id)) {
      _programDetails[program.id] = program;
    } else {
      // In a real app this might be an error or an insert
      _programDetails[program.id] = program;
    }

    // 2. Update summary list (metadata)
    final index = _programs.indexWhere((p) => p.id == program.id);
    if (index != -1) {
      final old = _programs[index];
      _programs[index] = old.copyWith(
        name: program.name,
        // Description is not on Program entity unless we checked,
        // but DraftProgram has it. Let's assuming Program has it?
        // Program has: id, name, split, description...
        // Yes, checked file manually previously.
        description: program.description,
        split: program.split,
      );
    }
  }
}
