import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// The main page for the Training feature, showing weekly status and sessions.
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
      child = Center(child: CircularProgressIndicator(color: colors.ink));
    } else if (state.hasError) {
      child = _TrainingError(
        message: state.errorMessage ?? 'System Error.',
      );
    } else {
      child = _TrainingContent(
        state: state,
        onSelectDate: vm.onSelectDate,
        onStartNextWorkout: vm.onStartNextWorkout,
        onOpenLastWorkout: vm.onOpenLastWorkout,
        onViewProgram: () => context.push('/training/library'),
        onCreateProgram: () {
          final programId = state.activeProgramId;
          if (programId != null) {
            unawaited(context.push('/training/builder/structure/$programId'));
          } else {
            unawaited(context.push('/training/builder'));
          }
        },
        onViewHistory: () => context.push('/training/history'),
        onQuickStart: () {
          // ignore: discarded_futures - fire and forget
          vm.onStartFreestyle(context);
        },
      );
    }

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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

    // Check if the next workout is marked as completed
    final isNextCompleted = state.nextWorkout?.isCompleted ?? false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: spacing.lg),
          const _TrainingHeader(dateLabel: 'MONDAY, DEC 12'),
          SizedBox(height: spacing.xl),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _VolumeGauge(
              completed: state.completedWorkouts,
              planned: state.plannedWorkouts,
            ),
          ),
          SizedBox(height: spacing.lg),
          _WeekStrip(
            days: state.weekDays,
            selectedDate: state.selectedDate,
            onSelect: onSelectDate,
          ),
          SizedBox(height: spacing.xxl),
          if (state.hasProgram) ...[
            if (state.nextWorkout != null)
              if (isNextCompleted)
                _CompletedSessionMainCard(
                  workout: state.nextWorkout!,
                  onView: () {
                    // Navigate to history detail for this specific completed
                    // session. Since it's 'next-1', we assume history handles
                    // it. For this task, I'll direct it to history via push
                    // directly.
                    unawaited(
                      context.push(
                        '/training/history/${state.nextWorkout!.id}',
                      ),
                    );
                  },
                )
              else
                _SmartWorkoutCard(
                  workout: state.nextWorkout!,
                  onStart: () => onStartNextWorkout(context),
                )
            else
              const _RestDayCard(),
          ] else
            _GhostProgramCard(
              onCreate: onCreateProgram,
              onQuickStart: onQuickStart,
            ),

          // Always show the "Previous Session" tile if it exists
          if (state.hasProgram && state.lastWorkout != null) ...[
            SizedBox(height: spacing.lg),
            _LastSessionTile(
              workout: state.lastWorkout!,
              onTap: () => onOpenLastWorkout(context),
            ),
          ],
          if (state.hasProgram) ...[
            SizedBox(height: spacing.xxl),
            _ProgramControls(
              onViewProgram: onViewProgram,
              onHistory: onViewHistory,
              onEdit: onCreateProgram,
              onQuickStart: onQuickStart,
            ),
          ],
          SizedBox(height: spacing.xxl),
        ],
      ),
    );
  }
}

class _CompletedSessionMainCard extends StatelessWidget {
  const _CompletedSessionMainCard({
    required this.workout,
    required this.onView,
  });

  final WorkoutSummary workout;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderIdle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S SESSION",
                      style: typography.caption.copyWith(
                        color: colors.accent,
                        letterSpacing: 2,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.name,
                      style: typography.display.copyWith(fontSize: 28),
                    ),
                    Text(
                      workout.meta,
                      style: typography.body.copyWith(color: colors.inkSubtle),
                    ),
                  ],
                ),
                Icon(Icons.check_circle, color: colors.accent, size: 24),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AppButton(
              label: 'VIEW DETAILS',
              isPrimary: true, // Matches "Start Session" style
              onTap: onView,
            ),
          ),
        ],
      ),
    );
  }
}

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
          'TODAY',
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
          style: typography.display.copyWith(
            fontSize: 24,
            color: colors.ink,
          ),
        ),
      ],
    );
  }
}

class _VolumeGauge extends StatelessWidget {
  const _VolumeGauge({required this.completed, required this.planned});

  final int completed;
  final int planned;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Row(
      children: [
        Text(
          'WEEKLY VOLUME',
          style: typography.caption.copyWith(fontSize: 10),
        ),
        const Spacer(),
        Text(
          '$completed / $planned',
          style: typography.caption.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
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
        ),
      ],
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
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
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

class _SmartWorkoutCard extends StatelessWidget {
  const _SmartWorkoutCard({required this.workout, required this.onStart});

  final WorkoutSummary workout;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final layout = Theme.of(context).extension<AppLayout>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderIdle, width: layout.strokeLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT SESSION',
                      style: typography.caption.copyWith(
                        color: colors.accent,
                        letterSpacing: 2,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.name,
                      style: typography.display.copyWith(fontSize: 28),
                    ),
                    Text(
                      workout.meta,
                      style: typography.body.copyWith(color: colors.inkSubtle),
                    ),
                  ],
                ),
                Icon(Icons.fitness_center, color: colors.accent, size: 24),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AppButton(
              label: 'START SESSION',
              icon: Icons.play_arrow_rounded,
              isPrimary: true,
              onTap: onStart,
            ),
          ),
        ],
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
          // 1. The Empty State Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceHighlight.withValues(alpha: 0.5),
            ),
            child: Icon(Icons.grid_view, size: 32, color: colors.inkSubtle),
          ),
          SizedBox(height: spacing.md),

          // 2. The Prompt
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

          // 3. Primary Action: Build
          AppButton(
            label: 'BUILD PROGRAM',
            icon: Icons.add,
            isPrimary: true, // Prominent
            onTap: onCreate,
          ),

          SizedBox(height: spacing.md),

          // 4. Secondary Action: Freestyle
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

class _LastSessionTile extends StatelessWidget {
  const _LastSessionTile({required this.workout, required this.onTap});

  final WorkoutSummary workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final layout = Theme.of(context).extension<AppLayout>()!;

    // Check if the workout was completed today
    // We can assume 'completedAt' or similar data is used to populate this
    // summary. However, WorkoutSummary doesn't strictly have a DateTime field
    // visible here yet found in the interface. Ideally, we'd check
    // `workout.completedAt` if available, or rely on `dayLabel`.
    // The fake repo populates dayLabel. Let's assume for now we can infer from
    // `dayLabel` == 'TODAY'
    // or if we need to check the ID/Metadata.
    // But wait, the fake repo logic for "Implicit Rolling" said:
    // "If a Freestyle workout was done Today: Shows COMPLETED TODAY".

    // If [timeLabel] says "DONE" or [dayLabel] says "TODAY" and it's
    // completed? Actually, let's look at what the Fake Repo provides for the
    // Context Tile. The Fake Repo returns `lastWorkout`.
    // If we want "COMPLETED TODAY", the Repo should probably set the label to
    // "TODAY".

    final isToday = workout.dayLabel == 'TODAY';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Use a slightly more active background if it's today?
          color: isToday
              ? colors.surfaceHighlight.withValues(alpha: 0.8)
              : colors.surfaceHighlight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday
                ? colors.accent.withValues(alpha: 0.3)
                : colors.borderIdle.withValues(alpha: 0.5),
            width: layout.strokeSm,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isToday ? Icons.check_circle : Icons.history,
              color: isToday ? colors.accent : colors.inkSubtle,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'COMPLETED TODAY' : 'PREVIOUS SESSION',
                    style: typography.caption.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isToday ? colors.accent : colors.inkSubtle,
                    ),
                  ),
                  Text(
                    workout.name,
                    style: typography.body.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!isToday)
              Text(
                '48h ago',
                // TODO(app-team): Real relative time
                style: typography.caption.copyWith(color: colors.inkSubtle),
              ),
          ],
        ),
      ),
    );
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final layout = Theme.of(context).extension<AppLayout>()!;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderIdle, width: layout.strokeSm),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.snooze, size: 32, color: colors.accent),
            const SizedBox(height: 16),
            Text(
              'REST & RECOVER',
              style: typography.title.copyWith(color: colors.ink),
            ),
            const SizedBox(height: 8),
            Text(
              'Growth happens when you sleep.',
              style: typography.body.copyWith(color: colors.inkSubtle),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramControls extends StatelessWidget {
  const _ProgramControls({
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

    // Using a Column of two Rows to create a 2x2 Grid
    // Using Expanded ensures buttons are equal width
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ControlPill(
                label: 'Library', // "Program" -> Library (Clearer)
                icon: Icons.grid_view,
                onTap: onViewProgram,
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: _ControlPill(
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
              child: _ControlPill(
                label: 'Freestyle',
                icon: Icons.bolt,
                onTap: onQuickStart,
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: _ControlPill(
                label: 'Structure', // "Edit" -> Structure (Clearer)
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

class _ControlPill extends StatelessWidget {
  const _ControlPill({
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
    final layout = Theme.of(context).extension<AppLayout>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.borderIdle, width: layout.strokeMd),
        ),
        // Changed to MainAxisAlignment.center to handle Expanded width
        // gracefully
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

class _TrainingError extends StatelessWidget {
  const _TrainingError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
