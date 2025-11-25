import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// A massive tactile card for selecting a primary goal.
///
/// Selected cards pop with silver borders and "ignited" icon fills,
/// while idle cards remain dark steel with muted copy.
class GoalTile extends StatelessWidget {
  /// Creates a new goal tile.
  const GoalTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  /// Title displayed in uppercase on the card.
  final String title;

  /// Supporting text describing the goal.
  final String subtitle;

  /// Icon shown inside the circular badge.
  final IconData icon;

  /// Whether this tile is currently selected.
  final bool isSelected;

  /// Callback executed when the tile is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final s = Theme.of(context).extension<AppSpacing>()!;
    final t = Theme.of(context).extension<AppTypography>()!;

    final borderColor = isSelected ? c.accent : c.borderIdle;
    final iconBg = isSelected ? c.accent : c.surfaceHighlight;
    final iconColor = isSelected ? c.bg : c.inkSubtle;
    final titleColor = isSelected ? c.ink : c.inkSubtle;
    final subtitleColor = isSelected
        ? c.inkSubtle
        : c.inkSubtle.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          unawaited(Feedback.forTap(context));
        }
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.all(s.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBg,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: s.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: t.title.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: t.body.copyWith(
                      fontSize: 14,
                      height: 1.3,
                      color: subtitleColor,
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
