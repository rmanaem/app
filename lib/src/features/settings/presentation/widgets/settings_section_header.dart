import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// A technical, all-caps header for settings sections.
class SettingsSectionHeader extends StatelessWidget {
  /// Creates a section header.
  const SettingsSectionHeader({required this.title, super.key});

  /// The title text to display.
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: typography.caption.copyWith(
          color: colors.inkSubtle,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
