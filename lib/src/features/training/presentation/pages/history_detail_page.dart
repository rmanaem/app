import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/domain/entities/completed_workout.dart';
import 'package:starter_app/src/features/training/domain/repositories/history_repository.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/history_detail_view_model.dart';

/// A page displaying the details of a completed workout session.
class HistoryDetailPage extends StatelessWidget {
  /// Creates a [HistoryDetailPage] for the given [workoutId].
  const HistoryDetailPage({required this.workoutId, super.key});

  /// The ID of the workout to display.
  final String workoutId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return ChangeNotifierProvider(
      create: (context) => HistoryDetailViewModel(
        workoutId: workoutId,
        repository: context.read<HistoryRepository>(),
      ),
      child: Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          backgroundColor: colors.bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.ink),
            onPressed: () => context.pop(),
          ),
          title: const Text('SESSION DETAIL'),
        ),
        body: const _HistoryDetailContent(),
      ),
    );
  }
}

class _HistoryDetailContent extends StatelessWidget {
  const _HistoryDetailContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryDetailViewModel>();
    final colors = Theme.of(context).extension<AppColors>()!;

    if (vm.state == HistoryDetailViewState.loading) {
      return Center(child: CircularProgressIndicator(color: colors.ink));
    }

    if (vm.state == HistoryDetailViewState.error) {
      return Center(
        child: Text(
          vm.errorMessage ?? 'Error',
          style: TextStyle(color: colors.ink),
        ),
      );
    }

    final workout = vm.workout!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return ListView(
      padding: spacing.edgeAll(spacing.gutter),
      children: [
        // 1. Header Stats
        _SessionHeader(workout: workout),
        SizedBox(height: spacing.xxl),

        if (workout.note != null && workout.note!.isNotEmpty) ...[
          _SessionNoteSection(note: workout.note!),
          SizedBox(height: spacing.xxl),
        ],

        // 3. Exercise List
        if (workout.exercises.isEmpty)
          Center(
            child: Text(
              'No exercises recorded.',
              style: typography.body.copyWith(color: colors.inkSubtle),
            ),
          )
        else
          ...workout.exercises.map((ex) {
            return _ReadOnlyExerciseCard(
              name: ex['name'] as String,
              sets: (ex['sets'] as List).cast<Map<String, dynamic>>(),
              notes: ex['notes'] as String?,
            );
          }),
      ],
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.workout});
  final CompletedWorkout workout;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypography>()!;
    final colors = Theme.of(context).extension<AppColors>()!;
    final dateStr = DateFormat(
      'EEEE, MMMM d',
    ).format(workout.completedAt).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr,
          style: typography.caption.copyWith(
            color: colors.inkSubtle,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          workout.name,
          style: typography.display.copyWith(fontSize: 32, height: 1.1),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatBadge(
              icon: Icons.timer_outlined,
              label: workout.formattedDuration,
            ),
            const SizedBox(width: 12),
            _StatBadge(
              icon: Icons.fitness_center,
              label: '${workout.formattedVolume} kg',
            ),
            const SizedBox(width: 12),
            _StatBadge(
              icon: Icons.emoji_events_outlined,
              label: '${workout.prCount} PRs',
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderIdle),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colors.inkSubtle),
          const SizedBox(width: 6),
          Text(
            label,
            style: typography.caption.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionNoteSection extends StatelessWidget {
  const _SessionNoteSection({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceHighlight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderIdle.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SESSION NOTES',
            style: typography.caption.copyWith(
              fontSize: 10,
              color: colors.inkSubtle,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: typography.body.copyWith(
              color: colors.ink,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyExerciseCard extends StatelessWidget {
  const _ReadOnlyExerciseCard({
    required this.name,
    required this.sets,
    this.notes,
  });
  final String name;
  final List<Map<String, dynamic>> sets;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderIdle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: typography.title.copyWith(fontSize: 18),
                ),
                // EXERCISE NOTE (New)
                if (notes != null && notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.bg.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.borderIdle.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 14,
                          color: colors.inkSubtle,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notes!,
                            style: typography.body.copyWith(
                              fontSize: 12,
                              color: colors.inkSubtle,
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(height: 1, color: colors.borderIdle.withValues(alpha: 0.5)),

          // Sets Table
          ...sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      style: typography.caption.copyWith(
                        color: colors.inkSubtle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Weight (Hero)
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${set['kg']} kg',
                      style: typography.body.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: colors.ink, // Bright
                      ),
                    ),
                  ),
                  // Reps (Upgraded to Co-Hero)
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${set['reps']} reps',
                      style: typography.body.copyWith(
                        fontFamily: 'monospace',
                        fontWeight:
                            FontWeight.w600, // Slightly less heavy than weight
                        color: colors
                            .ink, // CHANGED: Now Bright White (was inkSubtle)
                      ),
                    ),
                  ),
                  // RPE (Remains Context)
                  Expanded(
                    child: Text(
                      '@${(set['rpe'] as num).round()}',
                      textAlign: TextAlign.end,
                      style: typography.caption.copyWith(
                        color: colors.inkSubtle, // Keeps Grey
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
