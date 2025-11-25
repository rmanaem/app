import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// A premium alert banner shown when calorie targets drop below the safe floor.
class SafetyWarningBanner extends StatelessWidget {
  /// Creates a banner warning about unsafe calorie targets.
  const SafetyWarningBanner({
    required this.minCalories,
    required this.onAcknowledge,
    required this.onCancel,
    super.key,
  });

  /// Safe minimum calories used for copy.
  final double minCalories;

  /// Callback when the user proceeds despite the warning.
  final VoidCallback onAcknowledge;

  /// Callback when the user wants to auto-adjust the plan.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final alertColor = colors.danger;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: alertColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: alertColor),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.gpp_maybe_rounded,
                          color: alertColor,
                          size: 20,
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          'BELOW SAFE MINIMUM',
                          style: typography.caption.copyWith(
                            color: alertColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.md),
                    Text(
                      'Your target is below the recommended '
                      '${minCalories.round()} kcal floor. '
                      'This increases injury risk and muscle loss.',
                      style: typography.body.copyWith(
                        fontSize: 14,
                        color: colors.ink,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: spacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: onCancel,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              'Auto-Adjust',
                              style: typography.button.copyWith(
                                fontSize: 13,
                                color: colors.ink,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        InkWell(
                          onTap: onAcknowledge,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: alertColor.withValues(alpha: 0.5),
                              ),
                              borderRadius: BorderRadius.circular(100),
                              color: alertColor.withValues(alpha: 0.1),
                            ),
                            child: Text(
                              'Proceed Anyway',
                              style: typography.button.copyWith(
                                fontSize: 13,
                                color: alertColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
