import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Warning banner displayed when user's calorie target is below the
/// recommended safe minimum (1800 kcal for males, 1200 kcal for females).
class SafetyWarningBanner extends StatelessWidget {
  /// Creates a safety warning banner.
  const SafetyWarningBanner({
    required this.minCalories,
    required this.onAcknowledge,
    required this.onCancel,
    super.key,
  });

  /// The safe minimum calorie threshold being warned about.
  final double minCalories;

  /// Callback when user acknow ledges and wants to proceed anyway.
  final VoidCallback onAcknowledge;

  /// Callback when user wants to adjust their goal instead.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.warning, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: colors.warning, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Below Safe Minimum',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your calorie intake is below the recommended minimum of '
            '${minCalories.round()} kcal/day. This may lead to:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.ink,
            ),
          ),
          const SizedBox(height: 8),
          _buildBullet(context, colors, 'Nutrient deficiencies'),
          _buildBullet(context, colors, 'Muscle loss'),
          _buildBullet(context, colors, 'Metabolic slowdown'),
          _buildBullet(context, colors, 'Reduced energy levels'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                child: Text(
                  'Adjust Goal',
                  style: TextStyle(color: colors.ink),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onAcknowledge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.warning,
                  foregroundColor: colors.surface,
                ),
                child: const Text('I Understand, Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(BuildContext context, AppColors colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.inkSubtle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.inkSubtle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
