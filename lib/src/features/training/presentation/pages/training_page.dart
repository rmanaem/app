import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Training management page.
class TrainingPage extends StatelessWidget {
  /// Creates the Training page.
  const TrainingPage({super.key});

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
          'Training',
          style: textTheme.titleLarge?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Training Placeholder',
          style: textTheme.bodyMedium?.copyWith(color: colors.inkSubtle),
        ),
      ),
    );
  }
}
