import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// App settings page.
class SettingsPage extends StatelessWidget {
  /// Creates the Settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        title: Text(
          'Settings',
          style: textTheme.titleLarge?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Settings Placeholder',
          style: textTheme.bodyMedium?.copyWith(color: colors.inkSubtle),
        ),
      ),
    );
  }
}
