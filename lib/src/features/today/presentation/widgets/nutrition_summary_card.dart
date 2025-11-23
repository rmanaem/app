import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Card showing today's calorie and macro status.
///
/// Intended for use on the Today tab. All numbers are passed in as plain
/// integers so this widget stays purely presentational.
class NutritionSummaryCard extends StatelessWidget {
  /// Creates a nutrition summary card for today's intake.
  const NutritionSummaryCard({
    required this.consumedCalories,
    required this.targetCalories,
    required this.consumedProtein,
    required this.targetProtein,
    required this.consumedCarbs,
    required this.targetCarbs,
    required this.consumedFat,
    required this.targetFat,
    super.key,
    this.onTap,
  });

  /// Calories consumed today.
  final int consumedCalories;

  /// Daily calorie target.
  final int targetCalories;

  /// Protein consumed today.
  final int consumedProtein;

  /// Daily protein target.
  final int targetProtein;

  /// Carbs consumed today.
  final int consumedCarbs;

  /// Daily carbs target.
  final int targetCarbs;

  /// Fat consumed today.
  final int consumedFat;

  /// Daily fat target.
  final int targetFat;

  /// Optional tap handler. If provided, the card becomes tappable and
  /// shows ink feedback; if null, it's static.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final remainingCalories = (targetCalories - consumedCalories).clamp(
      0,
      targetCalories,
    );

    final card = Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.ringTrack),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Nutrition',
                style: textTheme.titleMedium?.copyWith(color: colors.ink),
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: colors.inkSubtle,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Today’s intake',
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 16),
          _CaloriesRow(
            consumedCalories: consumedCalories,
            targetCalories: targetCalories,
            remainingCalories: remainingCalories,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MacroStat(
                  label: 'Protein',
                  consumed: consumedProtein,
                  target: targetProtein,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroStat(
                  label: 'Carbs',
                  consumed: consumedCarbs,
                  target: targetCarbs,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroStat(
                  label: 'Fats',
                  consumed: consumedFat,
                  target: targetFat,
                  unit: 'g',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Based on your current plan.',
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class _CaloriesRow extends StatelessWidget {
  const _CaloriesRow({
    required this.consumedCalories,
    required this.targetCalories,
    required this.remainingCalories,
  });

  final int consumedCalories;
  final int targetCalories;
  final int remainingCalories;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                remainingCalories.toString(),
                style: textTheme.headlineLarge?.copyWith(
                  color: colors.ink,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'kcal remaining',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.inkSubtle,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Calories',
              style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
            ),
            const SizedBox(height: 4),
            Text(
              '$consumedCalories / $targetCalories kcal',
              style: textTheme.titleMedium?.copyWith(color: colors.ink),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
  });

  final String label;
  final int consumed;
  final int target;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: colors.ringTrack),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 4),
          Text(
            '$consumed / $target $unit',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
        ],
      ),
    );
  }
}
