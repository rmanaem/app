import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';

import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/picker_sheet_scaffold.dart';

/// Shows a modal sheet to pick an [ActivityLevel].
Future<ActivityLevel?> showActivityLevelSheet({
  required BuildContext context,
  required ActivityLevel? current,
}) {
  final colors = Theme.of(context).extension<AppColors>()!;

  // Use all 5 activity levels dynamically
  final items = ActivityLevel.values.map((level) {
    return _ActivityRow(
      level: level,
      title: level.label,
      subtitle: level.description,
    );
  }).toList();

  return showModalBottomSheet<ActivityLevel>(
    context: context,
    backgroundColor: colors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PickerSheetHeader(title: 'Activity level'),
            ...items.map((row) {
              final selected = current == row.level;
              return ListTile(
                onTap: () => Navigator.of(sheetContext).pop(row.level),
                title: Text(
                  row.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: colors.ink),
                ),
                subtitle: Text(
                  row.subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
                ),
                trailing: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? colors.ink : colors.inkSubtle,
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

class _ActivityRow {
  const _ActivityRow({
    required this.level,
    required this.title,
    required this.subtitle,
  });

  final ActivityLevel level;
  final String title;
  final String subtitle;
}
