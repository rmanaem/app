import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Dashboard page showing a fusion of diet and training.
class TodayPage extends StatelessWidget {
  /// Creates the Today page.
  const TodayPage({super.key});

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
          'Today',
          style: textTheme.titleLarge?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Today Dashboard Placeholder',
          style: textTheme.bodyMedium?.copyWith(color: colors.inkSubtle),
        ),
      ),
    );
  }
}
