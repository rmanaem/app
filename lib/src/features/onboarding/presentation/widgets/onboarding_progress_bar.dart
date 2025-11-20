import 'package:flutter/material.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/step_progress_bar.dart';

/// Compact wrapper around [StepProgressBar] used in onboarding pages.
class OnboardingProgressBar extends StatelessWidget {
  /// Creates a progress bar for onboarding steps.
  const OnboardingProgressBar({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  /// Current 1-based onboarding step.
  final int currentStep;

  /// Total number of onboarding steps.
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: StepProgressBar(currentStep: currentStep, totalSteps: totalSteps),
    );
  }
}
