import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Toggle grid for selecting active training days.
class SequenceToggle extends StatelessWidget {
  /// Creates the toggle grid.
  const SequenceToggle({
    required this.schedule,
    required this.onToggle,
    super.key,
  });

  /// Active day map keyed by weekday index (0 = Monday).
  final Map<int, bool> schedule;

  /// Invoked when a day is toggled.
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isActive = schedule[index] ?? false;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _DayKey(
              dayIndex: index,
              isActive: isActive,
              onTap: () => onToggle(index),
            ),
          ),
        );
      }),
    );
  }
}

class _DayKey extends StatelessWidget {
  const _DayKey({
    required this.dayIndex,
    required this.isActive,
    required this.onTap,
  });

  final int dayIndex;
  final bool isActive;
  final VoidCallback onTap;

  static const List<String> _days = <String>[
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? colors.surfaceHighlight : colors.bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? colors.borderActive : colors.borderIdle,
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? <BoxShadow>[
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _days[dayIndex],
              style: typography.caption.copyWith(
                color: isActive ? colors.ink : colors.inkSubtle,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 4),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
