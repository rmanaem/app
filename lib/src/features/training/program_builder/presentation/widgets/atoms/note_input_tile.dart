import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// A tile that displays a note summary and opens an editor on tap.
class NoteInputTile extends StatelessWidget {
  /// Creates a new [NoteInputTile].
  const NoteInputTile({
    required this.value,
    required this.onTap,
    super.key,
  });

  /// The current note text to display.
  final String? value;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  String _formatNoteForPreview(String text) {
    final lines = text.split('\n');
    if (lines.length > 3) {
      return '${lines.take(3).join('\n')}...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? colors.accent.withValues(alpha: 0.5)
                : colors.borderIdle,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasValue ? Icons.comment : Icons.add_comment_rounded,
              size: 20,
              color: hasValue ? colors.accent : colors.inkSubtle,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                hasValue
                    ? _formatNoteForPreview(value!)
                    : 'Add technical note...',
                style: typography.body.copyWith(
                  color: hasValue ? colors.ink : colors.inkSubtle,
                  fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasValue)
              Icon(
                Icons.edit_rounded,
                size: 16,
                color: colors.inkSubtle,
              ),
          ],
        ),
      ),
    );
  }
}
