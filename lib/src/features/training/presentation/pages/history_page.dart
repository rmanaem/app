import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_layout.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/domain/entities/completed_workout.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/history_view_model.dart';

/// A page displaying the user's workout logbook.
class HistoryPage extends StatelessWidget {
  /// Creates the [HistoryPage].
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'LOGBOOK',
          style: typography.caption.copyWith(
            letterSpacing: 2,
            color: colors.inkSubtle,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.ink))
          : ListView.builder(
              padding: spacing.edgeAll(spacing.gutter),
              itemCount: vm.groupedWorkouts.length,
              itemBuilder: (context, index) {
                final monthKey = vm.groupedWorkouts.keys.elementAt(index);
                final workouts = vm.groupedWorkouts[monthKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 8),
                      child: Text(
                        monthKey,
                        style: typography.caption.copyWith(
                          color: colors.inkSubtle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Workout List
                    ...workouts.map((w) => _HistoryCard(workout: w)),

                    SizedBox(height: spacing.lg),
                  ],
                );
              },
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.workout});

  final CompletedWorkout workout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final layout = Theme.of(context).extension<AppLayout>()!;

    final dayNum = DateFormat('d').format(workout.completedAt);
    final dayName = DateFormat('E').format(workout.completedAt).toUpperCase();

    return GestureDetector(
      onTap: () async {
        await context.push('/training/history/${workout.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderIdle, width: layout.strokeMd),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 1. Date Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.borderIdle),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNum,
                        style: typography.title.copyWith(
                          fontSize: 18,
                          height: 1,
                        ),
                      ),
                      Text(
                        dayName,
                        style: typography.caption.copyWith(
                          fontSize: 9,
                          color: colors.inkSubtle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // 2. Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: typography.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: colors.inkSubtle,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workout.formattedDuration,
                            style: typography.caption.copyWith(
                              color: colors.inkSubtle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.fitness_center,
                            size: 12,
                            color: colors.inkSubtle,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.formattedVolume} kg',
                            style: typography.caption.copyWith(
                              color: colors.inkSubtle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. PR Badge (If applicable)
                if (workout.prCount > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: colors.accent,
                    ),
                  ),
              ],
            ),

            // NEW: Note Snippet Footer
            if (workout.note != null && workout.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.bg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 12,
                      color: colors.inkSubtle,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        workout.note!,
                        style: typography.caption.copyWith(
                          color: colors.inkSubtle,
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
    );
  }
}
