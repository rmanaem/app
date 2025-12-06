import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/active_session_view_model.dart';
import 'package:starter_app/src/features/training/presentation/widgets/active_exercise_card.dart';
import 'package:starter_app/src/features/training/presentation/widgets/exercise_context_sheet.dart';
import 'package:starter_app/src/features/training/presentation/widgets/set_log_row.dart';

/// Active session page driven by [ActiveSessionViewModel].
class ActiveSessionPage extends StatelessWidget {
  const ActiveSessionPage({super.key});

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
          onPressed: () => context.pop(),
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
              '00:24:12',
              style: typography.body.copyWith(
                fontFamily: 'monospace',
                color: colors.ink,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
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
                  itemCount: vm.exercises.length,
                  itemBuilder: (context, exIndex) {
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
                      onMoreOptions: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => ExerciseContextSheet(
                            exerciseName: ex['name'] as String,
                            initialRestSeconds: vm.restDurationSeconds,
                            onRemove: () => Navigator.pop(ctx),
                            onSwap: () => Navigator.pop(ctx),
                            onSaveNote: (_) => Navigator.pop(ctx),
                            onUpdateRest: vm.updateRestDuration,
                          ),
                        );
                      },
                      sets: sets.asMap().entries.map((entry) {
                        final setIndex = entry.key;
                        final s = entry.value as Map<String, dynamic>;
                        return SetLogRow(
                          setIndex: setIndex,
                          prevPerformance: '100x5',
                          weight: s['weight'] as double,
                          reps: s['reps'] as int,
                          rpe: (s['rpe'] as num).toDouble(),
                          isCompleted: s['done'] as bool,
                          onCheck: () => vm.toggleSet(exIndex, setIndex),
                          onTapWeight: () {},
                          onTapReps: () {},
                          onTapRpe: () {},
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
