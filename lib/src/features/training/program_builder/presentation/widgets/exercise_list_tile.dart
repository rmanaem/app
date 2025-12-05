import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// List tile for an exercise selection row.
class ExerciseListTile extends StatelessWidget {
  /// Creates an exercise list tile.
  const ExerciseListTile({
    required this.name,
    required this.muscle,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// Exercise name.
  final String name;

  /// Primary muscle group.
  final String muscle;

  /// Selection flag.
  final bool isSelected;

  /// Tap handler.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.borderIdle.withValues(alpha: 0.3)),
          ),
          color: isSelected ? colors.surfaceHighlight : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? colors.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? colors.accent : colors.borderIdle,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: colors.bg)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: typography.body.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? colors.ink
                          : colors.ink.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    muscle.toUpperCase(),
                    style: typography.caption.copyWith(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: colors.inkSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
