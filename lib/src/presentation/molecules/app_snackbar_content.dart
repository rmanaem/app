// For FontFeature

import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Notification variants supported by the app snackbar.
enum SnackbarType {
  /// Successful outcome notification.
  success,

  /// Failure or validation notification.
  error,

  /// Informational notification.
  info,
}

/// Molecule for rendering consistent snackbar content.
class AppSnackbarContent extends StatelessWidget {
  /// Creates a snackbar content molecule.
  const AppSnackbarContent({
    required this.message,
    this.type = SnackbarType.info,
    super.key,
  });

  /// Message to display.
  final String message;

  /// Presentation style for the snackbar.
  final SnackbarType type;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final (icon, accentColor) = switch (type) {
      SnackbarType.success => (Icons.check_circle_outline, colors.success),
      SnackbarType.error => (Icons.error_outline, colors.danger),
      SnackbarType.info => (Icons.info_outline, colors.accent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderIdle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: typography.body.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w500,
                // Force numbers to align by width for a monospaced feel.
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
