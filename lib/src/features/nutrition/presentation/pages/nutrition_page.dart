import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Nutrition tracking page.
class NutritionPage extends StatelessWidget {
  /// Creates the Nutrition page.
  const NutritionPage({super.key});

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
          'Nutrition',
          style: textTheme.titleLarge?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Nutrition Log Placeholder',
          style: textTheme.bodyMedium?.copyWith(color: colors.inkSubtle),
        ),
      ),
    );
  }
}
