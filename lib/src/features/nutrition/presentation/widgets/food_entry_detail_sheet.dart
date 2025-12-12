import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/nutrition/domain/entities/food_entry.dart';

/// A bottom sheet that displays details for a logged food entry.
class FoodEntryDetailSheet extends StatelessWidget {
  /// Creates a [FoodEntryDetailSheet].
  const FoodEntryDetailSheet({
    required this.entry,
    required this.mealName,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  /// The food entry to display.
  final FoodEntry entry;

  /// Name of the meal slot (e.g. "Breakfast").
  final String mealName;

  /// Callback to delete the entry.
  final VoidCallback onDelete;

  /// Callback to edit the entry.
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderIdle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: spacing.lg),

          // Header Row (Title + Edit)
          Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Text(
                    entry.title,
                    style: typography.title.copyWith(
                      color: colors.ink,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Logged in ${mealName.toUpperCase()}',
                    style: typography.caption.copyWith(
                      color: colors.inkSubtle,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              // Delete Button (Top Left)
              Positioned(
                left: 0,
                top: 0,
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: colors.danger),
                  tooltip: 'Delete Entry',
                ),
              ),
              // Edit Button (Top Right)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context); // Close detail first
                    onEdit(); // Trigger edit flow
                  },
                  icon: Icon(Icons.edit, color: colors.ink),
                  tooltip: 'Edit Entry',
                ),
              ),
            ],
          ),

          SizedBox(height: spacing.xl),

          // Big Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${entry.calories}',
                style: typography.display.copyWith(
                  color: colors.ink,
                  fontSize: 64,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'kcal',
                style: typography.title.copyWith(
                  color: colors.inkSubtle,
                  fontSize: 24,
                ),
              ),
            ],
          ),

          SizedBox(height: spacing.lg),

          // Macro Grid
          Row(
            children: [
              _DetailMacro(label: 'PROTEIN', value: '${entry.proteinGrams}g'),
              _DetailMacro(label: 'CARBS', value: '${entry.carbGrams}g'),
              _DetailMacro(label: 'FAT', value: '${entry.fatGrams}g'),
            ],
          ),

          SizedBox(height: spacing.xxl),
        ],
      ),
    );
  }
}

class _DetailMacro extends StatelessWidget {
  const _DetailMacro({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: typography.title.copyWith(color: colors.ink, fontSize: 20),
          ),
          Text(
            label,
            style: typography.caption.copyWith(
              color: colors.inkSubtle,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
