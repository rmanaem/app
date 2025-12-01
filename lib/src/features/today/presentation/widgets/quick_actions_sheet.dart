import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Global quick actions bottom sheet.
///
/// Displays action buttons for logging food, weight, or starting a workout.
/// Uses an inset design style where buttons appear recessed into the sheet.
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
    final typography = Theme.of(context).extension<AppTypography>()!;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.borderIdle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colors.borderIdle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SHORTCUTS',
                    style: typography.caption.copyWith(
                      color: colors.inkSubtle,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    Icons.shortcut,
                    color: colors.inkSubtle,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      label: 'LOG FOOD',
                      icon: Icons.restaurant,
                      onTap: onLogFood,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionTile(
                      label: 'WEIGH IN',
                      icon: Icons.monitor_weight_outlined,
                      onTap: onLogWeight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionTile(
                      label: 'WORKOUT',
                      icon: Icons.fitness_center,
                      onTap: onStartWorkout,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: colors.bg, // Darker background creates inset effect
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.borderIdle),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: colors.ink,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: typography.caption.copyWith(
                  color: colors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
