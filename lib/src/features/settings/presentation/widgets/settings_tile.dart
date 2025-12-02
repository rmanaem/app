import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// A standard interactive row for the settings screen.
/// Supports navigation, toggles, and value display.
class SettingsTile extends StatelessWidget {
  /// Creates a settings tile.
  const SettingsTile({
    required this.label,
    this.valueLabel,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
    super.key,
  });

  /// The main label text.
  final String label;

  /// Optional secondary value text (e.g., "KG").
  final String? valueLabel;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Widget to display at the end (e.g., Switch).
  final Widget? trailing;

  /// If true, renders the label in a danger color.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: typography.body.copyWith(
                    color: isDestructive ? colors.danger : colors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (valueLabel != null) ...[
                Text(
                  valueLabel!,
                  style: typography.body.copyWith(
                    color: colors.inkSubtle,
                  ),
                ),
                if (onTap != null && trailing == null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colors.inkSubtle,
                  ),
                ],
              ],
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
