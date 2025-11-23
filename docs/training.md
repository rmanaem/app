# Training

Files & responsibilities

For this slice we only need one new UI file (domain/VM can come right after, but this gives you a target layout):

UI

lib/src/features/training/presentation/pages/training_page.dart

TrainingPage – public page wired into the app shell/tab.

_TrainingContent – main scrollable column.

_TrainingHeader – “Training · This week” top section.

_WeeklySummaryCard – planned vs completed workouts.

_NextWorkoutCard – “Next” session preview (+ start button).

_LastWorkoutCard – last session summary.

_ProgramOverviewCard – simple list of workouts in the current program.

All widgets take plain values as props, no repo/use-case access.
Later you’ll feed them from TrainingHomeViewModel/state exactly like Today.

training_page.dart – v1 layout

```dart
// lib/src/features/training/presentation/pages/training_page.dart

import 'package:flutter/material.dart';

import '../../../../app/design_system/app_colors.dart';

/// Main Training tab page.
///
/// For MVP this is a purely presentational scaffold with stubbed data.
/// Later, you can inject a TrainingHomeViewModel and pass its state into
/// [_TrainingContent] instead of the hard-coded values.
class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _TrainingContent(
            // TODO: replace these with values from TrainingHomeViewState.
            weekLabel: 'This week',
            completedWorkouts: 2,
            plannedWorkouts: 4,
            nextWorkoutName: 'Upper A',
            nextWorkoutDayLabel: 'Tomorrow',
            nextWorkoutSummary: '3 exercises · ~45 min',
            lastWorkoutName: 'Lower B',
            lastWorkoutDayLabel: 'Mon',
            lastWorkoutSummary: '4 exercises · 50 min',
            programName: 'Upper / Lower · 4x',
            programSubtitle: 'Mon · Tue · Thu · Fri',
            workoutsInProgram: const [
              _WorkoutListItemData(
                name: 'Upper A',
                detail: 'Chest · Shoulders · Triceps',
              ),
              _WorkoutListItemData(
                name: 'Lower B',
                detail: 'Quads · Glutes · Hamstrings',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: hook into "start next workout" flow.
        },
        child: const Icon(Icons.fitness_center),
      ),
    );
  }
}

class _TrainingContent extends StatelessWidget {
  const _TrainingContent({
    required this.weekLabel,
    required this.completedWorkouts,
    required this.plannedWorkouts,
    required this.nextWorkoutName,
    required this.nextWorkoutDayLabel,
    required this.nextWorkoutSummary,
    required this.lastWorkoutName,
    required this.lastWorkoutDayLabel,
    required this.lastWorkoutSummary,
    required this.programName,
    required this.programSubtitle,
    required this.workoutsInProgram,
  });

  final String weekLabel;
  final int completedWorkouts;
  final int plannedWorkouts;

  final String nextWorkoutName;
  final String nextWorkoutDayLabel;
  final String nextWorkoutSummary;

  final String lastWorkoutName;
  final String lastWorkoutDayLabel;
  final String lastWorkoutSummary;

  final String programName;
  final String programSubtitle;
  final List<_WorkoutListItemData> workoutsInProgram;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TrainingHeader(weekLabel: weekLabel),
          const SizedBox(height: 16),
          _WeeklySummaryCard(
            completed: completedWorkouts,
            planned: plannedWorkouts,
          ),
          const SizedBox(height: 12),
          _NextWorkoutCard(
            workoutName: nextWorkoutName,
            dayLabel: nextWorkoutDayLabel,
            summary: nextWorkoutSummary,
            onStartPressed: () {
              // TODO: navigate to logging view for next workout.
            },
          ),
          const SizedBox(height: 12),
          _LastWorkoutCard(
            workoutName: lastWorkoutName,
            dayLabel: lastWorkoutDayLabel,
            summary: lastWorkoutSummary,
          ),
          const SizedBox(height: 12),
          _ProgramOverviewCard(
            programName: programName,
            subtitle: programSubtitle,
            workouts: workoutsInProgram,
            onManageProgramPressed: () {
              // TODO: open program builder/selector in a later slice.
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ... (rest of doc as previously) 
```
