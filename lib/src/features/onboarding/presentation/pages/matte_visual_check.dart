import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Visual reference page showcasing the Matte Monolith activity cards.
class MatteVisualCheckPage extends StatefulWidget {
  /// Creates the visual check page.
  const MatteVisualCheckPage({super.key});

  @override
  State<MatteVisualCheckPage> createState() => _MatteVisualCheckPageState();
}

class _MatteVisualCheckPageState extends State<MatteVisualCheckPage> {
  int _selectedIndex = 2;

  final List<_ActivityOption> _activities = const [
    _ActivityOption(
      title: 'SEDENTARY',
      description: 'Little or no exercise',
      icon: Icons.weekend,
    ),
    _ActivityOption(
      title: 'LIGHT',
      description: 'Exercise 1-3 days/week',
      icon: Icons.directions_walk,
    ),
    _ActivityOption(
      title: 'MODERATE',
      description: 'Exercise 3-5 days/week',
      icon: Icons.fitness_center,
    ),
    _ActivityOption(
      title: 'HEAVY',
      description: 'Hard exercise 6-7 days',
      icon: Icons.sports_mma,
    ),
    _ActivityOption(
      title: 'ATHLETE',
      description: 'Physical job / 2x daily',
      icon: Icons.flash_on,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Center(
              child: Text(
                'ACTIVITY LEVEL',
                style: typography.caption.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: colors.inkSubtle,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: PageController(
                  viewportFraction: 0.75,
                  initialPage: _selectedIndex,
                ),
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                  unawaited(HapticFeedback.mediumImpact());
                },
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final isActive = index == _selectedIndex;
                  final option = _activities[index];
                  return _ActivityCard(
                    data: option,
                    isActive: isActive,
                    colors: colors,
                    spacing: spacing,
                    typography: typography,
                  );
                },
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  'CONFIRM',
                  style: typography.button.copyWith(
                    color: colors.bg,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.lg),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.data,
    required this.isActive,
    required this.colors,
    required this.spacing,
    required this.typography,
  });

  final _ActivityOption data;
  final bool isActive;
  final AppColors colors;
  final AppSpacing spacing;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive ? colors.borderActive : colors.borderIdle;
    final iconBackground = isActive ? colors.accent : colors.surfaceHighlight;
    final iconColor = isActive ? colors.bg : colors.inkSubtle;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: isActive ? 0 : spacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isActive ? 2 : 1),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.1),
                  blurRadius: 20,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBackground,
            ),
            child: Icon(
              data.icon,
              size: 40,
              color: iconColor,
            ),
          ),
          SizedBox(height: spacing.xl),
          Text(
            data.title,
            style: typography.display.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isActive ? colors.ink : colors.inkSubtle,
            ),
          ),
          SizedBox(height: spacing.md),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: typography.body.copyWith(
              fontSize: 16,
              color: isActive ? colors.inkSubtle : colors.borderIdle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityOption {
  const _ActivityOption({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
