import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Ceramic dual monitor showing two stats side-by-side.
class DualMonitorPanel extends StatelessWidget {
  /// Creates a dual monitor with two labeled readouts.
  const DualMonitorPanel({
    required this.label1,
    required this.value1,
    required this.unit1,
    required this.label2,
    required this.value2,
    required this.unit2,
    super.key,
  });

  /// Label for the first statistic (left side).
  final String label1;

  /// Value text for the first statistic.
  final String value1;

  /// Unit label for the first statistic.
  final String unit1;

  /// Label for the second statistic (right side).
  final String label2;

  /// Value text for the second statistic.
  final String value2;

  /// Unit label for the second statistic.
  final String unit2;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    return Container(
      height: 120,
      padding: EdgeInsets.symmetric(horizontal: spacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.borderIdle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              label: label1,
              value: value1,
              unit: unit1,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: colors.borderIdle.withValues(alpha: 0.5),
          ),
          Expanded(
            child: _StatColumn(
              label: label2,
              value: value2,
              unit: unit2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: typography.caption.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 10,
            color: colors.inkSubtle,
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          value,
          style: typography.title.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: colors.ink,
            height: 1,
          ),
        ),
        if (unit.isNotEmpty) ...[
          SizedBox(height: spacing.xs),
          Text(
            unit.toUpperCase(),
            style: typography.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.accent,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
