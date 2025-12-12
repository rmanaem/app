import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Notification variants supported by the app snackbar.
enum SnackbarType {
  /// Success state.
  success,

  /// Error state.
  error,

  /// Information state.
  info,
}

/// Molecule for rendering consistent snackbar content.
class AppSnackbarContent extends StatefulWidget {
  /// Creates a snackbar content molecule.
  const AppSnackbarContent({
    required this.message,
    this.type = SnackbarType.info,
    this.onUndo,
    super.key,
  });

  /// The message to display.
  final String message;

  /// The type of snackbar (success, error, info).
  final SnackbarType type;

  /// Optional callback for the Undo action.
  final VoidCallback? onUndo;

  @override
  State<AppSnackbarContent> createState() => _AppSnackbarContentState();
}

class _AppSnackbarContentState extends State<AppSnackbarContent> {
  bool _isUndoing = false;

  void _handleUndo() {
    if (_isUndoing) return;
    setState(() => _isUndoing = true);

    // 1. Hide the snackbar immediately
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 2. Trigger the undo action
    widget.onUndo?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    // CORRECTED: Using Design Tokens
    final backgroundColor = colors.surfaceNotification;
    final contentColor = colors.inkNotification;

    final icon = switch (widget.type) {
      SnackbarType.success => Icons.check_circle,
      SnackbarType.error => Icons.error,
      SnackbarType.info => Icons.info,
    };

    // Error still uses Danger token, but others use Onyx for the "System" feel
    final iconColor = widget.type == SnackbarType.error
        ? colors.danger
        : contentColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        // Ensure the row takes up space relative to the snackbar constraints
        // Ensure the row takes up space relative to the snackbar constraints
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.message,
              style: typography.body.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.onUndo != null) ...[
            const SizedBox(width: 12),
            // Divider REMOVED
            GestureDetector(
              onTap: _handleUndo,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'UNDO',
                  style: typography.caption.copyWith(
                    color: contentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
