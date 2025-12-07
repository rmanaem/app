import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/active_session_view_model.dart';
import 'package:starter_app/src/features/training/presentation/widgets/active_exercise_card.dart';
import 'package:starter_app/src/features/training/presentation/widgets/exercise_context_sheet.dart';
import 'package:starter_app/src/features/training/presentation/widgets/micro_tuner_sheet.dart';
import 'package:starter_app/src/features/training/presentation/widgets/set_log_row.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/exercise_tuner_sheet.dart';

/// Active session page driven by [ActiveSessionViewModel].
class ActiveSessionPage extends StatelessWidget {
  /// Creates an active session page.
  const ActiveSessionPage({super.key});

  String _formatSessionTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final vm = context.watch<ActiveSessionViewModel>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.inkSubtle),
          onPressed: () => _onExit(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'ACTIVE SESSION',
              style: typography.caption.copyWith(
                fontSize: 10,
                letterSpacing: 2,
                color: colors.accent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatSessionTime(vm.sessionDurationSeconds),
              style: typography.body.copyWith(
                fontFamily: 'monospace',
                color: colors.ink,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 1. Calculate Result
              final result = vm.finishSession();

              // 2. Navigate to Summary (Replacing Active Session)
              // Using pushReplacement ensures Back button doesn't return
              // to the workout.
              context.pushReplacement(
                '/training/session/summary',
                extra: result,
              );
            },
            child: Text(
              'FINISH',
              style: typography.button.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.ink))
          : Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    spacing.gutter,
                    spacing.md,
                    spacing.gutter,
                    100,
                  ),
                  itemCount: vm.exercises.length + 1,
                  itemBuilder: (context, index) {
                    if (index == vm.exercises.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _AddExerciseRow(
                          onTap: () {
                            // ignore: discarded_futures - fire and forget
                            _handleAddExerciseFlow(context, vm);
                          },
                        ),
                      );
                    }

                    final exIndex = index;
                    final ex = vm.exercises[exIndex];
                    final sets = ex['sets'] as List;

                    return ActiveExerciseCard(
                      exerciseName: ex['name'] as String,
                      activeTimerSetIndex: vm.activeRestExerciseIndex == exIndex
                          ? vm.activeRestSetIndex
                          : null,
                      timerDuration: vm.timerSeconds,
                      timerTotal: vm.timerTotalSeconds,
                      onTimerAdd: () => vm.addTime(30),
                      onTimerSkip: vm.skipTimer,
                      onAddSet: () => vm.addSet(exIndex),
                      onEditNote: () => _openContextSheet(
                        context,
                        vm,
                        exIndex,
                        ex,
                        initialTab: ContextTab.note,
                      ),
                      onMoreOptions: () => _openContextSheet(
                        context,
                        vm,
                        exIndex,
                        ex,
                      ),
                      sets: sets.asMap().entries.map((entry) {
                        final setIndex = entry.key;
                        final s = entry.value as Map<String, dynamic>;
                        return SetLogRow(
                          setIndex: setIndex,
                          prevPerformance: '100x5',
                          weight: s['weight'] as double,
                          targetWeight: s['targetWeight'] as double?,
                          reps: s['reps'] as int,
                          targetReps: s['targetReps'] as int?,
                          rpe: (s['rpe'] as num).toDouble(),
                          targetRpe: (s['targetRpe'] as num?)?.toDouble(),
                          isCompleted: s['done'] as bool,
                          onCheck: () => vm.toggleSet(exIndex, setIndex),
                          onTapWeight: () => _showMicroTuner(
                            context,
                            title: 'SET ${setIndex + 1} LOAD',
                            unit: 'kg',
                            min: 0,
                            max: 300,
                            step: 2.5,
                            value: (s['weight'] is num)
                                ? (s['weight'] as num).toDouble()
                                : 0.0,
                            onChanged: (val) => vm.updateSet(
                              exIndex,
                              setIndex,
                              {'weight': val},
                            ),
                          ),
                          onTapReps: () => _showMicroTuner(
                            context,
                            title: 'SET ${setIndex + 1} REPS',
                            unit: 'reps',
                            min: 0,
                            max: 100,
                            step: 1,
                            isInteger: true,
                            value: (s['reps'] as int).toDouble(),
                            onChanged: (val) => vm.updateSet(
                              exIndex,
                              setIndex,
                              {'reps': val.round()},
                            ),
                          ),
                          onTapRpe: () => _showMicroTuner(
                            context,
                            title: 'SET ${setIndex + 1} RPE',
                            unit: 'RPE',
                            min: 1,
                            max: 10,
                            step: 1,
                            isInteger: true,
                            value: (s['rpe'] as num).toDouble(),
                            onChanged: (val) => vm.updateSet(
                              exIndex,
                              setIndex,
                              {'rpe': val},
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Future<void> _onExit(BuildContext context) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'CANCEL SESSION?',
          style: typography.title.copyWith(fontSize: 18, color: colors.ink),
        ),
        content: Text(
          'Are you sure you want to cancel? '
          'This invalidates the current workout.',
          style: typography.body.copyWith(color: colors.inkSubtle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'RESUME',
              style: typography.button.copyWith(color: colors.inkSubtle),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'CANCEL SESSION',
              style: typography.button.copyWith(color: colors.danger),
            ),
          ),
        ],
      ),
    );

    if (shouldExit ?? false) {
      if (context.mounted) {
        context.pop();
      }
    }
  }
}

Future<void> _openContextSheet(
  BuildContext context,
  ActiveSessionViewModel vm,
  int index,
  Map<String, dynamic> ex, {
  ContextTab initialTab = ContextTab.edit,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ExerciseContextSheet(
      exerciseName: ex['name'] as String,
      initialNote: ex['note'] as String?,
      initialRestSeconds: vm.restDurationSeconds,
      initialTab: initialTab,
      onSaveNote: (newNote) {
        vm.updateExerciseNote(index, newNote);
      },
      onRemove: () {
        Navigator.pop(ctx);
        vm.removeExercise(index);
      },
      onSwap: () {
        Navigator.pop(ctx);
        unawaited(_handleSwapFlow(context, vm, index));
      },
      onUpdateRest: vm.updateRestDuration,
    ),
  );
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
          color: colors.surface.withValues(alpha: 0.3), // Ghost style
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.borderIdle.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: colors.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'ADD EXERCISE',
              style: typography.button.copyWith(
                color: colors.accent, // Primary color as requested
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (in _showMicroTuner area, replace it or add new helper)

/// Helper to open the Micro Tuner Sheet.
Future<void> _showMicroTuner(
  BuildContext context, {
  required String title,
  required String unit,
  required double min,
  required double max,
  required double step,
  required double value,
  required ValueChanged<double> onChanged,
  bool isInteger = false,
}) async {
  final result = await showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (ctx) => MicroTunerSheet(
      title: title,
      initialValue: value,
      unit: unit,
      min: min,
      max: max,
      step: step,
      isInteger: isInteger,
    ),
  );

  if (result != null) {
    onChanged(result);
  }
}

// -----------------------------------------------------------------------------
// INTERCEPTOR FLOWS
// -----------------------------------------------------------------------------

/// The "Interceptor" Flow for Adding: Selection -> Tuner -> VM
Future<void> _handleAddExerciseFlow(
  BuildContext context,
  ActiveSessionViewModel vm,
) async {
  // 1. Open Selection (Single Select Mode)
  // Wait for the result from the selection page
  final selected = await context.push<List<Map<String, dynamic>>>(
    '/training/builder/editor/select',
    extra: {
      'isSingleSelect': true,
      'submitButtonText': 'ADD',
    },
  );

  if (selected != null && selected.isNotEmpty) {
    final ex = selected.first;
    // 2. Open Tuner with Defaults
    if (!context.mounted) return;
    await _openTunerForConfig(context, ex, (config) {
      // 3. Commit to VM
      vm.appendExercise({
        ...ex,
        ...config,
      });
    });
  }
}

/// The "Interceptor" Flow for Swapping: Selection -> Tuner -> VM
Future<void> _handleSwapFlow(
  BuildContext context,
  ActiveSessionViewModel vm,
  int index,
) async {
  final selected = await context.push<List<Map<String, dynamic>>>(
    '/training/builder/editor/select',
    extra: {
      'isSingleSelect': true,
    },
  );

  if (selected != null && selected.isNotEmpty) {
    final ex = selected.first;
    // 2. Open Tuner
    if (!context.mounted) return;
    await _openTunerForConfig(context, ex, (config) {
      // 3. Commit Replace
      vm.replaceExercise(index, {
        ...ex,
        ...config,
      });
    });
  }
}

/// Helper to open the Tuner and return configuration.
Future<void> _openTunerForConfig(
  BuildContext context,
  Map<String, dynamic> exerciseBase,
  ValueChanged<Map<String, dynamic>> onConfirm,
) async {
  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (ctx) => ExerciseTunerSheet(
      exerciseName: exerciseBase['name'] as String,
      muscleGroup: exerciseBase['muscle'] as String? ?? 'MUSCLE',
      initialWeight: 20,
      initialRestSeconds: 90,
    ),
  );

  if (result != null) {
    onConfirm(result);
  }
}
