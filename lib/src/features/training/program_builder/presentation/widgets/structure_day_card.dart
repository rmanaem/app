import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';

/// A ceramic-style card representing a single day in the program structure.
class StructureDayCard extends StatelessWidget {
  /// Creates the day card.
  const StructureDayCard({
    required this.dayName,
    required this.workout,
    required this.isRestDay,
    this.onTap,
    super.key,
  });

  /// Day label (e.g., MONDAY).
  final String dayName;

  /// Workout assigned to the day, if any.
  final DraftWorkout? workout;

  /// Whether the day is a rest day.
  final bool isRestDay;

  /// Tap handler for editing the workout.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isRestDay ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: isRestDay ? colors.bg : colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRestDay ? colors.borderIdle : colors.borderActive,
              ),
              boxShadow: !isRestDay
                  ? [
                      BoxShadow(
                        color: colors.bg.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isRestDay ? colors.borderIdle : colors.accent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: !isRestDay
                        ? [
                            BoxShadow(
                              color: colors.accent.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName.toUpperCase(),
                        style: typography.caption.copyWith(
                          color: isRestDay ? colors.inkSubtle : colors.accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRestDay ? 'REST DAY' : (workout?.name ?? 'Untitled'),
                        style: typography.title.copyWith(
                          color: isRestDay ? colors.inkSubtle : colors.ink,
                          fontSize: 18,
                        ),
                      ),
                      if (!isRestDay && workout?.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          workout!.description,
                          style: typography.body.copyWith(
                            color: colors.inkSubtle,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isRestDay)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.inkSubtle,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
