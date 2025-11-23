import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/training/domain/entities/training_day_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/workout_summary.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/training_overview_view_model.dart';
import 'package:starter_app/src/features/training/presentation/viewstate/training_overview_view_state.dart';

/// Training tab showing the weekly overview.
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
      child = const Center(child: CircularProgressIndicator());
    } else if (state.hasError) {
      child = _TrainingError(
        message: state.errorMessage ?? 'Something went wrong.',
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
          const SizedBox(height: 16),
          _WeeklySummaryCard(
            completed: state.completedWorkouts,
            planned: state.plannedWorkouts,
          ),
          const SizedBox(height: 12),
          _TrainingWeekStrip(
            days: state.weekDays,
            selectedDate: state.selectedDate,
            onSelect: onSelectDate,
          ),
          const SizedBox(height: 16),
          if (state.nextWorkout != null)
            _NextWorkoutCard(
              workout: state.nextWorkout!,
              onStartPressed: onStartNextWorkout,
            ),
          if (state.nextWorkout != null) const SizedBox(height: 12),
          if (state.lastWorkout != null)
            _LastWorkoutCard(
              workout: state.lastWorkout!,
              onTap: onOpenLastWorkout,
            ),
          const SizedBox(height: 12),
          _TrainingActionsRow(
            hasProgram: state.hasProgram,
            onViewProgram: onViewProgram,
            onCreateProgram: onCreateProgram,
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRAINING',
          style: textTheme.labelSmall?.copyWith(
            color: colors.inkSubtle,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          weekLabel,
          style: textTheme.headlineSmall?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TrainingWeekStrip extends StatelessWidget {
  const _TrainingWeekStrip({
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
    final textTheme = Theme.of(context).textTheme;
    if (days.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDay(day.date, selectedDate);
          final chipColor = isSelected ? colors.ink : colors.surface2;
          final textColor = isSelected ? colors.bg : colors.ink;
          final statusColor = switch (day.status) {
            TrainingDayStatus.completed => colors.accent,
            TrainingDayStatus.planned => colors.ink,
            TrainingDayStatus.rest => colors.ringTrack,
          };

          return GestureDetector(
            onTap: () => onSelect(day.date),
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: const BorderRadius.all(Radius.circular(14)),
                border: Border.all(color: colors.ringTrack),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLetter(day.date),
                    style: textTheme.labelSmall?.copyWith(
                      color: textColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    day.date.day.toString(),
                    style: textTheme.titleMedium?.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.ringTrack),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next',
                  style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
                ),
                const SizedBox(height: 4),
                Text(
                  workout.name,
                  style: textTheme.titleMedium?.copyWith(color: colors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  '${workout.dayLabel} · ${workout.meta}',
                  style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onStartPressed,
            style: TextButton.styleFrom(
              foregroundColor: colors.bg,
              backgroundColor: colors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
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
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: colors.ringTrack),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last',
                style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
              ),
              const SizedBox(height: 4),
              Text(
                workout.name,
                style: textTheme.titleMedium?.copyWith(color: colors.ink),
              ),
              const SizedBox(height: 2),
              Text(
                '${workout.dayLabel} · ${workout.timeLabel}',
                style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
              ),
              if (workout.notePreview != null) ...[
                const SizedBox(height: 8),
                Text(
                  '“${workout.notePreview!}”',
                  style: textTheme.bodySmall?.copyWith(color: colors.ink),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainingActionsRow extends StatelessWidget {
  const _TrainingActionsRow({
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Program',
          style: textTheme.titleMedium?.copyWith(color: colors.ink),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionChip(
              label: 'View program',
              onTap: onViewProgram,
              colors: colors,
            ),
            if (hasProgram)
              _ActionChip(
                label: 'View history',
                onTap: onViewHistory,
                colors: colors,
              ),
            _ActionChip(
              label: 'Create program',
              onTap: onCreateProgram,
              colors: colors,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.ringTrack),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: colors.ink),
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
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(color: colors.ink),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({
    required this.completed,
    required this.planned,
  });

  final int completed;
  final int planned;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final onTrack = completed >= planned && planned > 0;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.ringTrack),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completed / $planned',
                  style: textTheme.headlineMedium?.copyWith(
                    color: colors.ink,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Workouts completed',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.inkSubtle,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                onTrack ? 'On track' : 'Keep going',
                style: textTheme.bodyMedium?.copyWith(color: colors.ink),
              ),
              const SizedBox(height: 4),
              Text(
                'Based on your current program.',
                style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
