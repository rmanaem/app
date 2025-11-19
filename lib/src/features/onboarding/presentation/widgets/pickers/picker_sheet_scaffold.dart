import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Standard header used across onboarding picker sheets.
class PickerSheetHeader extends StatelessWidget {
  /// Creates a header with [title] and an optional [trailing] widget.
  const PickerSheetHeader({required this.title, super.key, this.trailing});

  /// Title describing the sheet.
  final String title;

  /// Optional widget placed at the end of the row (e.g., unit toggles).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colors.ink),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Shared cancel/done buttons for picker sheets.
class PickerSheetActions extends StatelessWidget {
  /// Creates the action row.
  const PickerSheetActions({
    required this.onCancel,
    required this.onDone,
    super.key,
  });

  /// Invoked when the user cancels the sheet.
  final VoidCallback onCancel;

  /// Invoked when the user confirms the selection.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.bg,
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
