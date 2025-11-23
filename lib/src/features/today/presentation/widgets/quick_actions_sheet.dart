import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Global quick actions bottom sheet.
class QuickActionsSheet extends StatelessWidget {
  /// Creates the quick actions sheet.
  const QuickActionsSheet({
    required this.onLogFood,
    required this.onLogWeight,
    required this.onStartWorkout,
    super.key,
  });

  /// Opens the sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLogFood,
    required VoidCallback onLogWeight,
    required VoidCallback onStartWorkout,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return QuickActionsSheet(
          onLogFood: () {
            Navigator.of(sheetContext).pop();
            onLogFood();
          },
          onLogWeight: () {
            Navigator.of(sheetContext).pop();
            onLogWeight();
          },
          onStartWorkout: () {
            Navigator.of(sheetContext).pop();
            onStartWorkout();
          },
        );
      },
    );
  }

  /// Callback for the "Log food" action.
  final VoidCallback onLogFood;

  /// Callback for the "Log weight" action.
  final VoidCallback onLogWeight;

  /// Callback for the "Workout" action.
  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: ColoredBox(
        color: colors.bg.withValues(alpha: 0.6),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
                bottom: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 4, bottom: 12),
                    decoration: BoxDecoration(
                      color: colors.ringTrack,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: colors.inkSubtle,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Shortcuts',
                            style: textTheme.titleMedium?.copyWith(
                              color: colors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune),
                        color: colors.inkSubtle,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickActionIconButton(
                        label: 'Log food',
                        icon: Icons.restaurant_outlined,
                        onTap: onLogFood,
                      ),
                      _QuickActionIconButton(
                        label: 'Log weight',
                        icon: Icons.monitor_weight_outlined,
                        onTap: onLogWeight,
                      ),
                      _QuickActionIconButton(
                        label: 'Workout',
                        icon: Icons.fitness_center_outlined,
                        onTap: onStartWorkout,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fast access to the actions you use most.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.inkSubtle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionIconButton extends StatelessWidget {
  const _QuickActionIconButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: colors.surface2,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(
                icon,
                size: 22,
                color: colors.ink,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colors.ink),
        ),
      ],
    );
  }
}
