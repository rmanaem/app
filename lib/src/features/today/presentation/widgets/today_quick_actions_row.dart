import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Horizontal row of quick actions for the Today tab.
class TodayQuickActionsRow extends StatelessWidget {
  /// Creates the quick actions row for Today.
  const TodayQuickActionsRow({
    required this.onLogFood,
    required this.onLogWeight,
    required this.onStartWorkout,
    super.key,
  });

  /// Triggered when the user taps "Log food".
  final VoidCallback onLogFood;

  /// Triggered when the user taps "Log weight".
  final VoidCallback onLogWeight;

  /// Triggered when the user taps "Start workout".
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.restaurant,
            label: 'Log food',
            colors: colors,
            textTheme: textTheme,
            onTap: onLogFood,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.monitor_weight,
            label: 'Log weight',
            colors: colors,
            textTheme: textTheme,
            onTap: onLogWeight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.fitness_center,
            label: 'Start workout',
            colors: colors,
            textTheme: textTheme,
            onTap: onStartWorkout,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.colors,
    required this.textTheme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final AppColors colors;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            border: Border.all(color: colors.ringTrack),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: colors.ink,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
