import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// Visual card that presents an onboarding [Goal].
class GoalCard extends StatelessWidget {
  /// Creates a selectable card for the provided [goal].
  const GoalCard({
    required this.goal,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// Goal surfaced by the card.
  final Goal goal;

  /// Whether [goal] is currently selected.
  final bool selected;

  /// Callback invoked when the user taps the card.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final borderColor = selected ? colors.ink : colors.ringTrack;
    final fill = Theme.of(context).brightness == Brightness.dark
        ? colors.surface2
        : colors.surface2;

    return Semantics(
      button: true,
      selected: selected,
      label: goal.title,
      hint: 'Double tap to select ${goal.title}',
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            border: Border.all(width: 2, color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                _iconFor(goal),
                color: colors.ink,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: colors.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: colors.inkSubtle),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.radio_button_checked, color: colors.ink)
              else
                Icon(Icons.radio_button_unchecked, color: colors.inkSubtle),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(Goal goal) => switch (goal) {
    Goal.lose => Icons.trending_down,
    Goal.maintain => Icons.remove,
    Goal.gain => Icons.trending_up,
  };
}
