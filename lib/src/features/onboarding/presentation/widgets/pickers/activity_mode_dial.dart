import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';

/// A horizontal "Mode Dial" for selecting activity level.
///
/// Features a "snappy" physics-based carousel with the "Matte Monolith"
/// aesthetic (Solid Ceramic cards, Milled Steel borders).
class ActivityModeDial extends StatefulWidget {
  /// Creates the activity mode dial.
  const ActivityModeDial({
    required this.initialLevel,
    required this.onChanged,
    super.key,
  });

  /// The initially selected activity level (defaults to moderately active).
  final ActivityLevel? initialLevel;

  /// Callback firing whenever the user snaps to a new level.
  final ValueChanged<ActivityLevel> onChanged;

  @override
  State<ActivityModeDial> createState() => _ActivityModeDialState();
}

class _ActivityModeDialState extends State<ActivityModeDial> {
  late PageController _controller;
  late int _selectedIndex;

  // Ordered list of levels to display
  static const List<ActivityLevel> _levels = ActivityLevel.values;

  @override
  void initState() {
    super.initState();
    // Default to moderately active when nothing is selected yet,
    // or map the provided initial level to its index.
    _selectedIndex = widget.initialLevel == null
        ? 2 // moderatelyActive
        : _levels.indexOf(widget.initialLevel!);

    _controller = PageController(
      viewportFraction: 0.75, // Show part of the next/prev cards
      initialPage: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Maps activity levels to icons.
  IconData _getIconForLevel(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => Icons.weekend_outlined, // Desk job
      ActivityLevel.lightlyActive => Icons.directions_walk,
      ActivityLevel.moderatelyActive => Icons.fitness_center,
      ActivityLevel.veryActive => Icons.sports_mma, // Intense
      ActivityLevel.extremelyActive => Icons.flash_on, // "Athlete" / Bolt
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return PageView.builder(
      controller: _controller,
      itemCount: _levels.length,
      onPageChanged: (index) {
        setState(() => _selectedIndex = index);
        unawaited(HapticFeedback.mediumImpact()); // The "Thud" of the dial
        widget.onChanged(_levels[index]);
      },
      itemBuilder: (context, index) {
        final level = _levels[index];
        final isActive = index == _selectedIndex;

        // Animated transition properties
        final scale = isActive ? 1.0 : 0.9;
        final opacity = isActive ? 1.0 : 0.4;
        final borderColor = isActive ? colors.borderActive : colors.borderIdle;
        final iconBg = isActive ? colors.accent : colors.surfaceHighlight;
        final iconColor = isActive ? colors.bg : colors.inkSubtle;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: scale, end: scale),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuint,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    // Push inactive cards down slightly for depth
                    vertical: isActive ? 0 : spacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface, // Solid Ceramic
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: borderColor,
                      width: isActive ? 2 : 1, // Thicker active border
                    ),
                    // Subtle "OLED" glow behind active card only
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: colors.accent.withValues(alpha: 0.05),
                              blurRadius: 32,
                              spreadRadius: -8,
                              offset: const Offset(0, 16),
                            ),
                          ]
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(spacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconBg,
                          ),
                          child: Icon(
                            _getIconForLevel(level),
                            size: 40,
                            color: iconColor,
                          ),
                        ),
                        SizedBox(height: spacing.xl),

                        // Title
                        Text(
                          level.label.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: typography.display.copyWith(
                            fontSize: 24,
                            color: colors.ink,
                          ),
                        ),
                        SizedBox(height: spacing.md),

                        // Description
                        Text(
                          level.description,
                          textAlign: TextAlign.center,
                          style: typography.body.copyWith(
                            color: colors.inkSubtle,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
