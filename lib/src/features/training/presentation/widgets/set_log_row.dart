import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Single set entry row showing weight, reps, RPE, and completion state.
class SetLogRow extends StatelessWidget {
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
    super.key,
  });

  final int setIndex;
  final String prevPerformance;
  final double weight;
  final int reps;
  final double rpe;
  final bool isCompleted;
  final VoidCallback onCheck;
  final VoidCallback onTapWeight;
  final VoidCallback onTapReps;
  final VoidCallback onTapRpe;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final opacity = isCompleted ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        margin: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
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
            Expanded(
              flex: 3,
              child: _TactileInput(
                value: weight.toStringAsFixed(1).replaceAll('.0', ''),
                unit: 'kg',
                onTap: onTapWeight,
              ),
            ),
            Expanded(
              flex: 2,
              child: _TactileInput(
                value: '$reps',
                unit: 'reps',
                onTap: onTapReps,
              ),
            ),
            Expanded(
              flex: 2,
              child: _TactileInput(
                value: rpe.toStringAsFixed(0),
                unit: 'RPE',
                onTap: onTapRpe,
              ),
            ),
            const SizedBox(width: 12),
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

class _TactileInput extends StatelessWidget {
  const _TactileInput({
    required this.value,
    required this.unit,
    required this.onTap,
  });

  final String value;
  final String unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

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
            Text(
              value,
              style: typography.title.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.ink,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              unit,
              style: typography.caption.copyWith(
                fontSize: 10,
                color: colors.inkSubtle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
