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
  const WorkoutEditorPage({this.isQuickStart = false, super.key});

  /// Whether this editor is being used for a quick start session.
  final bool isQuickStart;

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
          onPressed: () async {
            if (!isQuickStart) {
              await vm.save();
            }
            if (context.mounted) context.pop();
          },
        ),
        title: Column(
          children: [
            Text(
              isQuickStart ? 'QUICK START' : 'EDIT WORKOUT',
              style: typography.caption.copyWith(
                fontSize: 10,
                letterSpacing: 2,
                color: colors.inkSubtle,
              ),
            ),
            if (!vm.isLoading && vm.workout != null)
              Text(
                isQuickStart ? 'FREESTYLE' : vm.workout!.name.toUpperCase(),
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
                      ? _EmptyState(
                          colors: colors,
                          typography: typography,
                          onAdd: () => unawaited(vm.addExercises(context)),
                        )
                      : ReorderableListView.builder(
                          padding: spacing.edgeAll(spacing.gutter),
                          itemCount: vm.exercises.length + 1,
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex >= vm.exercises.length) {
                              newIndex = vm.exercises.length;
                            }
                            vm.reorderExercises(oldIndex, newIndex);
                          },
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              elevation: 10,
                              shadowColor: Colors.black,
                              child: child,
                            );
                          },
                          itemBuilder: (context, index) {
                            if (index == vm.exercises.length) {
                              return Padding(
                                key: const ValueKey('add_button'),
                                padding: const EdgeInsets.only(top: 8),
                                child: _AddExerciseRow(
                                  onTap: () => unawaited(
                                    vm.addExercises(context),
                                  ),
                                ),
                              );
                            }

                            final ex = vm.exercises[index];
                            return Dismissible(
                              key: ValueKey(ex['_key'] as String),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                color: colors.danger,
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colors.ink,
                                ),
                              ),
                              onDismissed: (_) {
                                vm.removeExercise(index);
                              },
                              child: ExerciseModuleCard(
                                index: index,
                                exerciseName: ex['name'] as String,
                                muscleGroup: ex['muscle'] as String,
                                setCount: ex['sets'] as int,
                                repRange: ex['reps'] as String,
                                targetWeight: _formatWeight(ex['weight']),
                                restTime: _formatRestDisplay(ex['rest']),
                                rpe: _formatRpe(ex['rpe']),
                                onTap: () async {
                                  await _openTuner(context, vm, index, ex);
                                },
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.gutter,
                    0,
                    spacing.gutter,
                    spacing.gutter + 20,
                  ),
                  child: AppButton(
                    label: isQuickStart ? 'START SESSION' : 'CONFIRM WORKOUT',
                    icon: isQuickStart ? Icons.play_arrow_rounded : null,
                    isPrimary: true,
                    onTap: () async {
                      if (isQuickStart) {
                        vm.startFreestyleSession(context);
                      } else {
                        await vm.save();
                        if (context.mounted) context.pop();
                      }
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

String _formatRpe(dynamic rpe) {
  if (rpe == null) return '8';
  final numeric = rpe is num ? rpe : num.tryParse(rpe.toString());
  if (numeric == null) return '8';
  final value = numeric.toDouble();
  return value.toStringAsFixed(1).replaceAll('.0', '');
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
  const _EmptyState({
    required this.colors,
    required this.typography,
    required this.onAdd,
  });

  final AppColors colors;
  final AppTypography typography;
  final VoidCallback onAdd;

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
            'Add exercises to build the workout.',
            style: typography.body.copyWith(
              color: colors.inkSubtle.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.borderIdle),
              ),
              child: Text(
                '+ ADD EXERCISE',
                style: typography.button.copyWith(
                  color: colors.ink,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddExerciseRow extends StatelessWidget {
  const _AddExerciseRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.borderIdle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: colors.inkSubtle, size: 20),
            const SizedBox(width: 8),
            Text(
              'ADD EXERCISE',
              style: typography.button.copyWith(
                color: colors.ink,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
