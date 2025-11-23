import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Card summarizing the user's training status for the week.
class TrainingSummaryCard extends StatelessWidget {
  /// Creates a training summary card for the Today tab.
  const TrainingSummaryCard({
    required this.nextTitle,
    required this.lastTitle,
    this.nextSubtitle,
    this.lastSubtitle,
    this.onTapNext,
    this.onTapLast,
    super.key,
  });

  /// Title for the upcoming workout.
  final String nextTitle;

  /// Subtitle for the upcoming workout (e.g. time/duration).
  final String? nextSubtitle;

  /// Title for the most recent workout.
  final String lastTitle;

  /// Subtitle for the most recent workout.
  final String? lastSubtitle;

  /// Callback when the next workout block is tapped.
  final VoidCallback? onTapNext;

  /// Callback when the last workout block is tapped.
  final VoidCallback? onTapLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
            'Training',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'This week',
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 16),
          _TrainingSection(
            label: 'Next',
            title: nextTitle,
            subtitle: nextSubtitle,
            onTap: onTapNext,
          ),
          const SizedBox(height: 16),
          _TrainingSection(
            label: 'Last',
            title: lastTitle,
            subtitle: lastSubtitle,
            onTap: onTapLast,
          ),
        ],
      ),
    );
  }
}

class _TrainingSection extends StatelessWidget {
  const _TrainingSection({
    required this.label,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final displayTitle = subtitle != null && subtitle!.isNotEmpty
        ? '$title · $subtitle'
        : title;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
        ),
        const SizedBox(height: 4),
        Text(
          displayTitle,
          style: textTheme.titleMedium?.copyWith(color: colors.ink),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      ),
    );
  }
}
