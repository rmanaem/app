import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Minimal progress indicator used across onboarding steps.
class StepProgressBar extends StatelessWidget {
  /// Creates a segmented progress bar displaying the provided step info.
  const StepProgressBar({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  }) : assert(totalSteps >= 1, 'totalSteps must be >= 1'),
       assert(
         currentStep >= 1 && currentStep <= totalSteps,
         'currentStep must be in the range 1..totalSteps',
       );

  /// Current (1-based) step in the flow.
  final int currentStep;

  /// Total number of steps in the flow.
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: List.generate(totalSteps, (index) {
        final active = index + 1 <= currentStep;
        final isLast = index == totalSteps - 1;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsetsDirectional.only(end: isLast ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? colors.ink : colors.ringTrack,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ),
        );
      }),
    );
  }
}
