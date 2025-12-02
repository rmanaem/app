import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/domain/entities/training_day_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/workout_summary.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/training_overview_view_model.dart';
import 'package:starter_app/src/features/training/presentation/viewstate/training_overview_view_state.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// The main page for the Training feature, displaying a weekly overview,
/// next workout, and recent activity.
class TrainingPage extends StatelessWidget {
  /// Creates the Training page.
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<TrainingOverviewViewModel>();
    final state = vm.state;

    Widget child;
    if (state.isLoading) {
      child = Center(
        child: CircularProgressIndicator(color: colors.ink),
      );
    } else if (state.hasError) {
      child = _TrainingError(
        message: state.errorMessage ?? 'Unable to load training data.',
      );
    } else {
      child = _TrainingContent(
        state: state,
        onSelectDate: vm.onSelectDate,
        onStartNextWorkout: vm.onStartNextWorkout,
        onOpenLastWorkout: vm.onOpenLastWorkout,
        onViewProgram: vm.onViewProgram,
        onCreateProgram: vm.onCreateProgram,
        onViewHistory: vm.onViewHistory,
      );
    }

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: child,
        ),
      ),
    );
  }
}

class _TrainingContent extends StatelessWidget {
  const _TrainingContent({
    required this.state,
    required this.onSelectDate,
    required this.onStartNextWorkout,
    required this.onOpenLastWorkout,
    required this.onViewProgram,
    required this.onCreateProgram,
    required this.onViewHistory,
  });

  final TrainingOverviewViewState state;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onStartNextWorkout;
  final VoidCallback onOpenLastWorkout;
  final VoidCallback onViewProgram;
  final VoidCallback onCreateProgram;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TrainingHeader(weekLabel: 'This week'),
          const SizedBox(height: 24),
          _WeeklyProgress(
            completed: state.completedWorkouts,
            planned: state.plannedWorkouts,
          ),
          const SizedBox(height: 24),
          _WeekDaySelector(
            days: state.weekDays,
            selectedDate: state.selectedDate,
            onSelect: onSelectDate,
          ),
          const SizedBox(height: 32),
          if (state.nextWorkout != null)
            _NextWorkoutCard(
              workout: state.nextWorkout!,
              onStartPressed: onStartNextWorkout,
            ),
          if (state.nextWorkout != null) const SizedBox(height: 16),
          if (state.lastWorkout != null)
            _LastWorkoutCard(
              workout: state.lastWorkout!,
              onTap: onOpenLastWorkout,
            ),
          const SizedBox(height: 32),
          _TrainingActions(
            hasProgram: state.hasProgram,
            onViewProgram: onViewProgram,
            onCreateProgram: () => context.push('/training/builder'),
            onViewHistory: onViewHistory,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TrainingHeader extends StatelessWidget {
  const _TrainingHeader({required this.weekLabel});

  final String weekLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRAINING',
          style: typography.caption.copyWith(
            color: colors.inkSubtle,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          weekLabel,
          style: typography.display.copyWith(
            color: colors.ink,
          ),
        ),
      ],
    );
  }
}

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress({
    required this.completed,
    required this.planned,
  });

  final int completed;
  final int planned;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final progress = planned > 0 ? (completed / planned).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Volume',
              style: typography.caption.copyWith(color: colors.inkSubtle),
            ),
            Text(
              '$completed / $planned',
              style: typography.caption.copyWith(color: colors.ink),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colors.borderIdle,
          color: colors.ink,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
}

class _WeekDaySelector extends StatelessWidget {
  const _WeekDaySelector({
    required this.days,
    required this.selectedDate,
    required this.onSelect,
  });

  final List<TrainingDayOverview> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    if (days.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDay(day.date, selectedDate);

          final backgroundColor = isSelected ? colors.ink : colors.surface;
          final borderColor = isSelected ? colors.ink : colors.borderIdle;
          final textColor = isSelected ? colors.bg : colors.ink;
          final subtitleColor = isSelected
              ? colors.bg.withValues(alpha: 0.7)
              : colors.inkSubtle;

          final statusColor = switch (day.status) {
            TrainingDayStatus.completed =>
              isSelected ? colors.bg : colors.accent,
            TrainingDayStatus.planned => isSelected ? colors.bg : colors.ink,
            TrainingDayStatus.rest => Colors.transparent,
          };

          return GestureDetector(
            onTap: () => onSelect(day.date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLetter(day.date),
                    style: typography.caption.copyWith(
                      color: subtitleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.date.day.toString(),
                    style: typography.title.copyWith(
                      color: textColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _weekdayLetter(DateTime date) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return letters[date.weekday - 1];
  }
}

class _NextWorkoutCard extends StatelessWidget {
  const _NextWorkoutCard({
    required this.workout,
    required this.onStartPressed,
  });

  final WorkoutSummary workout;
  final VoidCallback onStartPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.borderActive),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEXT WORKOUT',
                style: typography.caption.copyWith(
                  color: colors.accent,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.bolt, color: colors.accent, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            workout.name,
            style: typography.display.copyWith(
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${workout.dayLabel} · ${workout.meta}',
            style: typography.body.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'START SESSION',
              onTap: onStartPressed,
              isPrimary: true,
              icon: Icons.play_arrow_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastWorkoutCard extends StatelessWidget {
  const _LastWorkoutCard({
    required this.workout,
    required this.onTap,
  });

  final WorkoutSummary workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: colors.borderIdle),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LAST WORKOUT',
                style: typography.caption.copyWith(
                  color: colors.inkSubtle,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workout.name,
                    style: typography.title.copyWith(color: colors.inkSubtle),
                  ),
                  Text(
                    workout.timeLabel,
                    style: typography.caption.copyWith(color: colors.inkSubtle),
                  ),
                ],
              ),
              if (workout.notePreview != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, size: 16, color: colors.inkSubtle),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          workout.notePreview!,
                          style: typography.caption.copyWith(
                            color: colors.ink,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainingActions extends StatelessWidget {
  const _TrainingActions({
    required this.hasProgram,
    required this.onViewProgram,
    required this.onCreateProgram,
    required this.onViewHistory,
  });

  final bool hasProgram;
  final VoidCallback onViewProgram;
  final VoidCallback onCreateProgram;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROGRAM',
          style: typography.caption.copyWith(
            color: colors.inkSubtle,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _OutlinedActionButton(
              label: 'View Program',
              onTap: onViewProgram,
            ),
            if (hasProgram)
              _OutlinedActionButton(
                label: 'History',
                onTap: onViewHistory,
              ),
            _OutlinedActionButton(
              label: 'Edit',
              onTap: onCreateProgram,
            ),
          ],
        ),
      ],
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: colors.borderIdle),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: typography.caption.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrainingError extends StatelessWidget {
  const _TrainingError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return Center(
      child: Text(
        message,
        style: typography.body.copyWith(color: colors.ink),
        textAlign: TextAlign.center,
      ),
    );
  }
}
