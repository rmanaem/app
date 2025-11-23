import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Card summarizing recent weight and short-term trend.
class WeightSummaryCard extends StatelessWidget {
  /// Creates a weight summary card for the Today tab.
  const WeightSummaryCard({
    required this.lastWeightLabel,
    this.trendLabel,
    this.showTrend = false,
    this.onWeighIn,
    this.onTap,
    super.key,
  });

  /// Latest weight label (e.g. "82.4 kg" or empty state text).
  final String lastWeightLabel;

  /// Short trend descriptor (e.g. "-0.4 kg vs last week").
  final String? trendLabel;

  /// Whether to render a simple trend visual placeholder.
  final bool showTrend;

  /// Invoked when the "Weigh in" CTA is pressed.
  final VoidCallback? onWeighIn;

  /// Invoked when the whole card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

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
          Text(
            'Weight',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Last 7 days',
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lastWeightLabel,
                style: textTheme.titleLarge?.copyWith(color: colors.ink),
              ),
              if (trendLabel != null)
                Text(
                  trendLabel!,
                  style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
                  textAlign: TextAlign.right,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (showTrend)
            Row(
              children: List.generate(
                7,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == 6 ? 0 : 4,
                    ),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.ringTrack,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Text(
              'Not enough data for a trend yet.',
              style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onWeighIn,
              child: Text(
                'Weigh in',
                style: textTheme.bodyMedium?.copyWith(color: colors.accent),
              ),
            ),
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
