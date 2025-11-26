import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Banner surfaced when a plan drops below its minimum calorie floor.
class SafetyWarningBanner extends StatelessWidget {
  /// Creates the low-calorie warning banner.
  const SafetyWarningBanner({
    required this.minCalories,
    required this.onAcknowledge,
    required this.onCancel,
    super.key,
  });

  /// Safe minimum calories referenced in the copy.
  final double minCalories;

  /// Callback triggered when the user chooses to proceed.
  final VoidCallback onAcknowledge;

  /// Callback used for automatic adjustments.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final roundedMin = minCalories.round();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderIdle),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // THE SIGNAL: Keep this RED to indicate status.
            Container(
              width: 4,
              color: colors.danger,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: colors.danger,
                          size: 18,
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          'BELOW SAFE MINIMUM',
                          style: typography.caption.copyWith(
                            color: colors.ink,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.sm),
                    // Body
                    Text(
                      'Target is below the $roundedMin kcal floor. '
                      'Risks injury & muscle loss.',
                      style: typography.caption.copyWith(
                        color: colors.inkSubtle,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: spacing.md),
                    // Actions (Neutralized)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _TinyButton(
                          label: 'Auto-Adjust',
                          textColor: colors.ink,
                          isBordered: true,
                          onTap: onCancel,
                        ),
                        SizedBox(width: spacing.md),
                        _TinyButton(
                          label: 'Proceed',
                          textColor: colors.inkSubtle,
                          onTap: onAcknowledge,
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

class _TinyButton extends StatelessWidget {
  const _TinyButton({
    required this.label,
    required this.onTap,
    required this.textColor,
    this.isBordered = false,
  });

  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final bool isBordered;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isBordered
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.borderIdle),
              )
            : null,
        child: Text(
          label,
          style: typography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
