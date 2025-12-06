import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// A dense, technical card representing an exercise and its target sets.
class ExerciseModuleCard extends StatelessWidget {
  /// Creates the exercise module card.
  const ExerciseModuleCard({
    required this.index,
    required this.exerciseName,
    required this.muscleGroup,
    required this.setCount,
    required this.repRange,
    required this.rpe,
    this.targetWeight,
    this.restTime = '90s', // Default or passed in
    this.onTap,
    super.key,
  });

  /// Position index (zero-based) for display.
  final int index;

  /// Exercise display name.
  final String exerciseName;

  /// Targeted muscle group label.
  final String muscleGroup;

  /// Number of sets.
  final int setCount;

  /// Repetition range (e.g., "8-10").
  final String repRange;

  /// RPE Target
  final String rpe;

  /// Target load (e.g., "80kg"), nullable for bodyweight moves.
  final String? targetWeight;

  /// Rest time between sets.
  final String restTime;

  /// Tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Container(
      margin: spacing.edgeV(spacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderIdle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: spacing.edgeAll(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // High Contrast Index Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accent, // Silver/White
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (index + 1).toString().padLeft(2, '0'),
                        style: typography.caption.copyWith(
                          color: colors.bg, // Black text
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  exerciseName,
                                  style: typography.title.copyWith(
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Subtle Edit Affordance
                              const SizedBox(width: 6),
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: colors.inkSubtle.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                          Text(
                            muscleGroup.toUpperCase(),
                            style: typography.caption.copyWith(
                              fontSize: 10,
                              letterSpacing: 1,
                              color: colors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Reorder Handle
                    Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color: colors.inkSubtle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
                // Technical Grid (5 columns)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.borderIdle.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricColumn(label: 'SETS', value: '$setCount'),
                      ),
                      _VerticalDivider(color: colors.borderIdle),
                      Expanded(
                        flex: 2,
                        child: _MetricColumn(
                          label: 'LOAD',
                          value: targetWeight ?? '-',
                        ),
                      ),
                      _VerticalDivider(color: colors.borderIdle),
                      Expanded(
                        child: _MetricColumn(label: 'REPS', value: repRange),
                      ),
                      _VerticalDivider(color: colors.borderIdle),
                      Expanded(
                        child: _MetricColumn(label: 'RPE', value: rpe),
                      ),
                      _VerticalDivider(color: colors.borderIdle),
                      Expanded(
                        flex: 2,
                        child: _MetricColumn(
                          label: 'REST',
                          value: restTime,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      children: [
        Text(
          label,
          style: typography.caption.copyWith(
            fontSize: 9,
            color: colors.inkSubtle,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: typography.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.ink,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 24, color: color.withValues(alpha: 0.3));
  }
}
