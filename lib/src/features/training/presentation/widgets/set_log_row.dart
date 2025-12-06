import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Single set entry row showing weight, reps, RPE, and completion state.
/// Single set entry row showing weight, reps, RPE, and completion state.
class SetLogRow extends StatelessWidget {
  /// Creates a [SetLogRow].
  const SetLogRow({
    required this.setIndex,
    required this.prevPerformance,
    required this.weight,
    required this.reps,
    required this.rpe,
    required this.isCompleted,
    required this.onCheck,
    required this.onTapWeight,
    required this.onTapReps,
    required this.onTapRpe,
    // TARGETS (Optional)
    this.targetWeight,
    this.targetReps,
    this.targetRpe,
    super.key,
  });

  /// The index of this set in the list (0-based).
  final int setIndex;

  /// The previous performance string (e.g. "100x5").
  final String prevPerformance;

  /// The weight in kg.
  final double weight;

  /// The number of reps.
  final int reps;

  /// The RPE value.
  final double rpe;

  /// Target weight for this set.
  final double? targetWeight;

  /// Target reps for this set.
  final int? targetReps;

  /// Target RPE for this set.
  final double? targetRpe;

  /// Whether the set is marked as completed.
  final bool isCompleted;

  /// Callback when the checkmark is tapped.
  final VoidCallback onCheck;

  /// Callback when the weight is tapped.
  final VoidCallback onTapWeight;

  /// Callback when the reps are tapped.
  final VoidCallback onTapReps;

  /// Callback when the RPE is tapped.
  final VoidCallback onTapRpe;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    // Dim the row if completed
    final opacity = isCompleted ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        margin: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            // 1. Set Index
            SizedBox(
              width: 40,
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.transparent
                        : colors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${setIndex + 1}',
                    style: typography.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isCompleted ? colors.inkSubtle : colors.ink,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Weight Input (Smart)
            Expanded(
              flex: 3,
              child: _SmartInput(
                value: weight,
                target: targetWeight,
                unit: 'kg',
                onTap: onTapWeight,
                // Helper to format doubles nicely
                formatter: (val) {
                  if (val is double) {
                    return val.toStringAsFixed(1).replaceAll('.0', '');
                  }
                  return val.toString();
                },
              ),
            ),

            // 3. Reps Input (Smart)
            Expanded(
              flex: 2,
              child: _SmartInput(
                value: reps,
                target: targetReps,
                unit: 'reps',
                onTap: onTapReps,
                formatter: (val) => val.toString(),
              ),
            ),

            // 4. RPE Input (Smart)
            Expanded(
              flex: 2,
              child: _SmartInput(
                value: rpe,
                target: targetRpe,
                unit: 'RPE',
                onTap: onTapRpe,
                formatter: (val) {
                  if (val is double) {
                    return val.toStringAsFixed(1).replaceAll('.0', '');
                  }
                  return val.toString();
                },
              ),
            ),

            const SizedBox(width: 12),

            // 5. Checkbox
            GestureDetector(
              onTap: () {
                unawaited(HapticFeedback.mediumImpact());
                onCheck();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted ? colors.ink : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted ? colors.ink : colors.borderIdle,
                    width: isCompleted ? 0 : 2,
                  ),
                ),
                child: isCompleted
                    ? Icon(Icons.check, color: colors.bg, size: 26)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A premium input that shows Actual vs Target context.
class _SmartInput extends StatelessWidget {
  const _SmartInput({
    required this.value,
    required this.unit,
    required this.onTap,
    required this.formatter,
    this.target,
  });

  final dynamic value;
  final dynamic target;
  final String unit;
  final VoidCallback onTap;
  final String Function(dynamic) formatter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    // Visual logic: Is the actual value different from the target?
    // Note: We use a small epsilon for doubles to avoid floating point issues
    var isDeviation = false;
    if (target != null) {
      if (value is double && target is double) {
        isDeviation = ((value as double) - (target as double)).abs() > 0.01;
      } else {
        isDeviation = value != target;
      }
    }

    // Text Color: White if hit, Accent (Silver) if deviation
    final textColor = isDeviation ? colors.accent : colors.ink;

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      child: ColoredBox(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // HERO VALUE (Actual)
            Text(
              formatter(value),
              style: typography.title.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
                fontFamily: 'monospace',
              ),
            ),

            // CONTEXT ROW (Unit + Target)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  unit,
                  style: typography.caption.copyWith(
                    fontSize: 10,
                    color: colors.inkSubtle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Only show target if it exists and there IS a deviation
                if (isDeviation && target != null) ...[
                  Text(
                    ' / ',
                    style: typography.caption.copyWith(
                      fontSize: 10,
                      color: colors.inkSubtle.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    formatter(target),
                    style: typography.caption.copyWith(
                      fontSize: 10,
                      color: colors.inkSubtle, // Ghost color
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
