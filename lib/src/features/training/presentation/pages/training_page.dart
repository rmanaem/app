import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_layout.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/domain/entities/training_day_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/workout_summary.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/training_overview_view_model.dart';
import 'package:starter_app/src/features/training/presentation/viewstate/training_overview_view_state.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// The main page for the Training feature.
class TrainingPage extends StatelessWidget {
  /// Creates the training page.
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<TrainingOverviewViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: state.isLoading
            ? Center(child: CircularProgressIndicator(color: colors.ink))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _TrainingVoidContent(
                  state: state,
                  onSelectDate: vm.onSelectDate,
                  onStartNextWorkout: vm.onStartNextWorkout,
                  onOpenLastWorkout: vm.onOpenLastWorkout,
                  onViewProgram: () =>
                      unawaited(context.push('/training/library')),
                  onCreateProgram: () {
                    final pid = state.activeProgramId;
                    if (pid != null) {
                      unawaited(
                        context.push('/training/builder/structure/$pid'),
                      );
                    } else {
                      unawaited(context.push('/training/builder'));
                    }
                  },
                  onViewHistory: () =>
                      unawaited(context.push('/training/history')),
                  onQuickStart: () => vm.onStartFreestyle(context),
                ),
              ),
      ),
    );
  }
}

class _TrainingVoidContent extends StatelessWidget {
  const _TrainingVoidContent({
    required this.state,
    required this.onSelectDate,
    required this.onStartNextWorkout,
    required this.onOpenLastWorkout,
    required this.onViewProgram,
    required this.onCreateProgram,
    required this.onViewHistory,
    required this.onQuickStart,
  });

  final TrainingOverviewViewState state;
  final ValueChanged<DateTime> onSelectDate;
  final void Function(BuildContext) onStartNextWorkout;
  final void Function(BuildContext) onOpenLastWorkout;
  final VoidCallback onViewProgram;
  final VoidCallback onCreateProgram;
  final VoidCallback onViewHistory;
  final VoidCallback onQuickStart;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final colors = Theme.of(context).extension<AppColors>()!;

    final isNextCompleted = state.nextWorkout?.isCompleted ?? false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header (Date + Volume Gauge)
          SizedBox(height: spacing.lg),
          _TrainingHeader(dateLabel: state.dateLabel),

          SizedBox(height: spacing.xl),

          // 2. Weekly Volume (Void Style)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _VolumeVoidGauge(
              completed: state.completedWorkouts,
              planned: state.plannedWorkouts,
            ),
          ),

          SizedBox(height: spacing.lg),

          // 3. Week Strip
          _WeekStrip(
            days: state.weekDays,
            selectedDate: state.selectedDate,
            onSelect: onSelectDate,
          ),

          SizedBox(height: spacing.xxl),

          // 4. THE RAIL: Program Context
          // If a program is active, we show the timeline.
          if (state.hasProgram) ...[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // THE RAIL (Left)
                  Column(
                    children: [
                      // Top Dot (Previous)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.inkSubtle.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // The Line
                      Expanded(
                        child: Container(
                          width: 2,
                          color: colors.ink.withValues(alpha: 0.1),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                      // Bottom Dot (Active)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors.bg,
                          border: Border.all(color: colors.accent, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 20),

                  // THE CONTENT (Right)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A. Last Session (Context)
                        if (state.lastWorkout != null)
                          _LastSessionVoidTile(
                            workout: state.lastWorkout!,
                            onTap: () => onOpenLastWorkout(context),
                          )
                        else
                          // Placeholder space if no history
                          const SizedBox(height: 40),

                        const SizedBox(height: 32),

                        // B. Next Session (Hero)
                        if (state.nextWorkout != null)
                          if (isNextCompleted)
                            _CompletedSessionVoidHero(
                              workout: state.nextWorkout!,
                              onView: () => context.push(
                                '/training/history/${state.nextWorkout!.id}',
                              ),
                            )
                          else
                            _NextSessionVoidHero(
                              workout: state.nextWorkout!,
                              onStart: () => onStartNextWorkout(context),
                            )
                        else
                          const _RestDayVoidHero(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else
            // No Program State
            _GhostProgramCard(
              onCreate: onCreateProgram,
              onQuickStart: onQuickStart,
            ),

          SizedBox(height: spacing.xxl),

          // 5. Grid Controls (Library, History)
          if (state.hasProgram)
            _VoidProgramControls(
              onViewProgram: onViewProgram,
              onHistory: onViewHistory,
              onEdit: onCreateProgram,
              onQuickStart: onQuickStart,
            ),

          SizedBox(height: spacing.xxl),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// VOID WIDGETS
// -----------------------------------------------------------------------------

class _TrainingHeader extends StatelessWidget {
  const _TrainingHeader({required this.dateLabel});

  final String dateLabel;

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
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateLabel.toUpperCase(),
          style: typography.display.copyWith(fontSize: 24, color: colors.ink),
        ),
      ],
    );
  }
}

class _VolumeVoidGauge extends StatelessWidget {
  const _VolumeVoidGauge({required this.completed, required this.planned});

  final int completed;
  final int planned;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Row(
      children: [
        Expanded(
          child: Text(
            'WEEKLY VOLUME',
            style: typography.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.inkSubtle,
            ),
          ),
        ),
        Text(
          '$completed / $planned',
          style: typography.caption.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: planned > 0 ? completed / planned : 0,
              backgroundColor: colors.surfaceHighlight,
              color: colors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _LastSessionVoidTile extends StatelessWidget {
  const _LastSessionVoidTile({required this.workout, required this.onTap});
  final WorkoutSummary workout;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final isToday = workout.dayLabel == 'TODAY';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isToday ? 'COMPLETED TODAY' : 'PREVIOUS SESSION',
                  style: typography.caption.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: colors.inkSubtle,
                  ),
                ),
                const Spacer(),
                if (!isToday)
                  Text(
                    '48h ago',
                    style: typography.caption.copyWith(
                      fontSize: 9,
                      color: colors.inkSubtle.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),

            Row(
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    style: typography.body.copyWith(
                      color: colors.inkSubtle,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.inkSubtle.withValues(alpha: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NextSessionVoidHero extends StatelessWidget {
  const _NextSessionVoidHero({required this.workout, required this.onStart});
  final WorkoutSummary workout;
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 2, height: 14, color: colors.accent),
            const SizedBox(width: 8),
            Text(
              'NEXT SESSION',
              style: typography.caption.copyWith(
                color: colors.accent,
                letterSpacing: 1.5,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          workout.name,
          style: typography.display.copyWith(
            fontSize: 40,
            color: colors.ink,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          workout.meta,
          style: typography.body.copyWith(
            color: colors.inkSubtle,
            fontSize: 14,
          ),
        ), // "3 exercises · ~45 min"

        const SizedBox(height: 32),

        AppButton(
          label: 'START SESSION',
          icon: Icons.play_arrow_rounded,
          isPrimary: true,
          onTap: onStart,
        ),
      ],
    );
  }
}

class _CompletedSessionVoidHero extends StatelessWidget {
  const _CompletedSessionVoidHero({
    required this.workout,
    required this.onView,
  });
  final WorkoutSummary workout;
  final VoidCallback onView;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: colors.accent),
            const SizedBox(width: 8),
            Text(
              'SESSION COMPLETE',
              style: typography.caption.copyWith(
                color: colors.accent,
                letterSpacing: 1.5,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          workout.name,
          style: typography.display.copyWith(
            fontSize: 40,
            color: colors.ink,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 32),
        AppButton(
          label: 'VIEW SUMMARY',
          // Outline (isPrimary defaults to false)
          onTap: onView,
        ),
      ],
    );
  }
}

class _RestDayVoidHero extends StatelessWidget {
  const _RestDayVoidHero();
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.snooze, size: 16, color: colors.inkSubtle),
            const SizedBox(width: 8),
            Text(
              'REST DAY',
              style: typography.caption.copyWith(
                color: colors.inkSubtle,
                letterSpacing: 1.5,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Active Recovery',
          style: typography.display.copyWith(
            fontSize: 40,
            color: colors.inkSubtle,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Growth happens when you sleep.',
          style: typography.body.copyWith(
            color: colors.inkSubtle.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _VoidProgramControls extends StatelessWidget {
  const _VoidProgramControls({
    required this.onViewProgram,
    required this.onHistory,
    required this.onEdit,
    required this.onQuickStart,
  });

  final VoidCallback onViewProgram;
  final VoidCallback onHistory;
  final VoidCallback onEdit;
  final VoidCallback onQuickStart;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _VoidControlPill(
                label: 'Library',
                icon: Icons.grid_view,
                onTap: onViewProgram,
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: _VoidControlPill(
                label: 'History',
                icon: Icons.history,
                onTap: onHistory,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.sm),
        Row(
          children: [
            Expanded(
              child: _VoidControlPill(
                label: 'Freestyle',
                icon: Icons.bolt,
                onTap: onQuickStart,
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: _VoidControlPill(
                label: 'Structure',
                icon: Icons.tune,
                onTap: onEdit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VoidControlPill extends StatelessWidget {
  const _VoidControlPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderIdle),
          color: Colors.transparent, // Void
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: colors.ink),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: typography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.days,
    required this.selectedDate,
    required this.onSelect,
  });
  final List<TrainingDayOverview> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;
  @override
  Widget build(BuildContext context) {
    const dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isSelected = day.date.day == selectedDate.day;
        final label = dayLabels[day.date.weekday - 1];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _DayKey(
              label: label,
              date: day.date.day.toString(),
              status: day.status,
              isActive: isSelected,
              onTap: () => onSelect(day.date),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DayKey extends StatelessWidget {
  const _DayKey({
    required this.label,
    required this.date,
    required this.status,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final String date;
  final TrainingDayStatus status;
  final bool isActive;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final layout = Theme.of(context).extension<AppLayout>()!;
    var statusColor = Colors.transparent;
    if (status == TrainingDayStatus.completed) statusColor = colors.accent;
    if (status == TrainingDayStatus.planned) statusColor = colors.borderIdle;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 64,
        decoration: BoxDecoration(
          color: isActive ? colors.surface : colors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? colors.borderActive : colors.borderIdle,
            width: isActive ? layout.strokeLg : layout.strokeMd,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: typography.caption.copyWith(
                fontSize: 9,
                color: isActive
                    ? colors.inkSubtle
                    : colors.inkSubtle.withValues(alpha: 0.5),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: typography.title.copyWith(
                fontSize: 16,
                color: isActive ? colors.ink : colors.inkSubtle,
              ),
            ),
            const SizedBox(height: 4),
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
  }
}

class _GhostProgramCard extends StatelessWidget {
  const _GhostProgramCard({required this.onCreate, required this.onQuickStart});

  final VoidCallback onCreate;
  final VoidCallback onQuickStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final layout = Theme.of(context).extension<AppLayout>()!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderIdle, width: layout.strokeSm),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceHighlight.withValues(alpha: 0.5),
            ),
            child: Icon(Icons.grid_view, size: 32, color: colors.inkSubtle),
          ),
          SizedBox(height: spacing.md),
          Text(
            'NO ACTIVE PROTOCOL',
            style: typography.caption.copyWith(
              letterSpacing: 2,
              color: colors.inkSubtle,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'System idle. Initialize training engine.',
            textAlign: TextAlign.center,
            style: typography.body.copyWith(
              color: colors.inkSubtle.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          SizedBox(height: spacing.xl),
          AppButton(
            label: 'BUILD PROGRAM',
            icon: Icons.add,
            isPrimary: true,
            onTap: onCreate,
          ),
          SizedBox(height: spacing.md),
          InkWell(
            onTap: onQuickStart,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 16, color: colors.accent),
                  const SizedBox(width: 8),
                  Text(
                    'QUICK FREESTYLE SESSION',
                    style: typography.button.copyWith(
                      color: colors.accent,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
