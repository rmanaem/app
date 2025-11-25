import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/activity_selection_card.dart';

/// Presents a full-height sheet for picking an [ActivityLevel].
Future<ActivityLevel?> showActivityLevelSheet({
  required BuildContext context,
  required ActivityLevel? current,
}) {
  final colors = Theme.of(context).extension<AppColors>()!;
  final spacing = Theme.of(context).extension<AppSpacing>()!;

  return showModalBottomSheet<ActivityLevel>(
    context: context,
    backgroundColor: colors.bg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(color: colors.glassBorder),
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: spacing.sm,
                      bottom: spacing.md,
                    ),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.inkSubtle.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'SELECT ACTIVITY LEVEL',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.ink,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: spacing.lg),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                    children: ActivityLevel.values.map((level) {
                      return ActivitySelectionCard(
                        title: _titleFor(level),
                        subtitle: _subtitleFor(level),
                        isSelected: current == level,
                        onTap: () => Navigator.pop(sheetContext, level),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

String _titleFor(ActivityLevel level) {
  switch (level) {
    case ActivityLevel.sedentary:
      return 'Sedentary';
    case ActivityLevel.lightlyActive:
      return 'Lightly Active';
    case ActivityLevel.moderatelyActive:
      return 'Moderately Active';
    case ActivityLevel.veryActive:
      return 'Very Active';
    case ActivityLevel.extremelyActive:
      return 'Extremely Active';
  }
}

String _subtitleFor(ActivityLevel level) {
  switch (level) {
    case ActivityLevel.sedentary:
      return 'Little or no exercise, desk job.';
    case ActivityLevel.lightlyActive:
      return 'Light exercise 1-3 days/week.';
    case ActivityLevel.moderatelyActive:
      return 'Moderate exercise 3-5 days/week.';
    case ActivityLevel.veryActive:
      return 'Hard exercise 6-7 days/week.';
    case ActivityLevel.extremelyActive:
      return 'Physical job or training twice per day.';
  }
}
