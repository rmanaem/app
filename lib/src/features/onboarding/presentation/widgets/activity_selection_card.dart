import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Industrial glass card used within the activity level picker.
class ActivitySelectionCard extends StatelessWidget {
  /// Creates the activity card.
  const ActivitySelectionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// Title describing the activity level.
  final String title;

  /// Supporting description.
  final String subtitle;

  /// Whether this level is currently active.
  final bool isSelected;

  /// Tap callback.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: isSelected
                ? colors.glassFill.withValues(alpha: 0.5)
                : colors.glassFill.withValues(alpha: 0.3),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? colors.ink.withValues(alpha: 0.5)
                      : colors.glassBorder.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: colors.accent.withValues(alpha: 0.1),
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md + 4),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? colors.ink : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? colors.ink
                                  : colors.inkSubtle.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 12,
                                    color: colors.bg,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: typography.title.copyWith(
                                  fontSize: 16,
                                  color: isSelected
                                      ? colors.ink
                                      : colors.ink.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: typography.caption.copyWith(
                                  height: 1.3,
                                  color: colors.inkSubtle,
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
            ),
          ),
        ),
      ),
    );
  }
}
