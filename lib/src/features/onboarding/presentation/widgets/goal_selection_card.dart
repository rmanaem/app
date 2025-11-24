import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// A premium glass card for goal selection.
///
/// Features a dense smoked glass background that lights up with a steel
/// border when selected.
class GoalSelectionCard extends StatelessWidget {
  /// Creates a dense glass card for selecting a [Goal].
  const GoalSelectionCard({
    required this.goal,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// Goal represented by the card.
  final Goal goal;

  /// Primary label.
  final String title;

  /// Supporting copy.
  final String subtitle;

  /// Icon displayed inside the switch-like capsule.
  final IconData icon;

  /// Whether the card is selected.
  final bool isSelected;

  /// Callback when pressed.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.glassFill.withValues(alpha: 0.4)
                  : colors.glassFill,
              border: Border.all(
                color: isSelected ? colors.ink : colors.glassBorder,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: colors.accent.withValues(alpha: 0.1),
                highlightColor: colors.accent.withValues(alpha: 0.05),
                child: Padding(
                  padding: EdgeInsets.all(spacing.lg),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? colors.ink : colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : colors.glassBorder,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? colors.bg : colors.ink,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: typography.title.copyWith(
                                fontSize: 16,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w700,
                                color: colors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: typography.body.copyWith(
                                fontSize: 14,
                                color: colors.inkSubtle,
                                height: 1.3,
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
    );
  }
}
