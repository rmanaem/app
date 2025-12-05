import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/viewmodels/workout_editor_view_model.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/exercise_module_card.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/exercise_tuner_sheet.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Editor for a single workout's exercise list.
class WorkoutEditorPage extends StatelessWidget {
  /// Creates the editor page.
  const WorkoutEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final vm = context.watch<WorkoutEditorViewModel>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'EDIT WORKOUT',
              style: typography.caption.copyWith(
                fontSize: 10,
                letterSpacing: 2,
                color: colors.inkSubtle,
              ),
            ),
            if (!vm.isLoading && vm.workout != null)
              Text(
                vm.workout!.name.toUpperCase(),
                style: typography.title.copyWith(fontSize: 16),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.ink))
          : Column(
              children: [
                Expanded(
                  child: vm.exercises.isEmpty
                      ? _EmptyState(colors: colors, typography: typography)
                      : ReorderableListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            spacing.gutter,
                            spacing.gutter,
                            spacing.gutter,
                            100,
                          ),
                          itemCount: vm.exercises.length,
                          onReorder: vm.reorderExercises,
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              elevation: 10,
                              shadowColor: Colors.black,
                              child: child,
                            );
                          },
                          itemBuilder: (context, index) {
                            final ex = vm.exercises[index];
                            return ExerciseModuleCard(
                              key: ValueKey(ex['name']),
                              index: index,
                              exerciseName: ex['name'] as String,
                              muscleGroup: ex['muscle'] as String,
                              setCount: ex['sets'] as int,
                              repRange: ex['reps'] as String,
                              targetWeight: _formatWeight(ex['weight']),
                              restTime: _formatRestDisplay(ex['rest']),
                              onTap: () async {
                                await _openTuner(context, vm, index, ex);
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  // MATCHING PADDING from ProgramBuilderPage
                  padding: EdgeInsets.fromLTRB(
                    spacing.gutter,
                    0,
                    spacing.gutter,
                    spacing.gutter + 20,
                  ),
                  child: AppButton(
                    label: 'ADD EXERCISE',
                    icon: Icons.add,
                    isPrimary: true,
                    onTap: () {
                      unawaited(vm.addExercises(context));
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

int _parseRestSeconds(dynamic rest) {
  if (rest == null) return 90;
  final restStr = rest.toString();
  if (restStr.contains(':')) {
    final parts = restStr.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
  }
  final digitString = RegExp(
    r'\d+',
  ).allMatches(restStr).map((m) => m.group(0) ?? '').join();
  return int.tryParse(digitString) ?? 90;
}

double _parseWeight(dynamic weight) {
  if (weight == null) return 20;
  if (weight is num) return weight.toDouble();
  final str = weight.toString();
  final digits = RegExp(r'\d+(\.\d+)?').firstMatch(str)?.group(0);
  return double.tryParse(digits ?? '') ?? 20;
}

String? _formatWeight(dynamic weight) {
  if (weight == null) return null;
  final numeric = weight is num ? weight : num.tryParse(weight.toString());
  if (numeric == null) return weight.toString();
  final value = numeric.toDouble();
  final text = value.toStringAsFixed(1).replaceAll('.0', '');
  return '$text kg';
}

String _formatRestDisplay(dynamic rest) {
  final seconds = _parseRestSeconds(rest);
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  return '$minutes:${remaining.toString().padLeft(2, '0')}';
}

Future<void> _openTuner(
  BuildContext context,
  WorkoutEditorViewModel vm,
  int index,
  Map<String, dynamic> ex,
) async {
  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (ctx) => ExerciseTunerSheet(
      exerciseName: ex['name'] as String,
      muscleGroup: ex['muscle'] as String,
      initialSets: ex['sets'] as int? ?? 3,
      initialReps:
          int.tryParse(
            ex['reps'].toString().split('-').first,
          ) ??
          10,
      initialWeight: _parseWeight(ex['weight']),
      initialRestSeconds: _parseRestSeconds(ex['rest']),
      initialRpe: (ex['rpe'] as num?)?.toDouble() ?? 8.0,
      initialNotes: ex['notes'] as String?,
    ),
  );

  if (result != null) {
    vm.updateExercise(index, {
      'sets': result['sets'],
      'weight': result['weight'],
      'reps': result['reps'].toString(),
      'rest': result['rest'],
      'rpe': result['rpe'],
      'notes': result['notes'],
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.typography});

  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_off_rounded,
            size: 48,
            color: colors.borderIdle,
          ),
          const SizedBox(height: 16),
          Text(
            'NO EXERCISES',
            style: typography.title.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 8),
          Text(
            'Add exercises to build the circuit.',
            style: typography.body.copyWith(
              color: colors.inkSubtle.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
