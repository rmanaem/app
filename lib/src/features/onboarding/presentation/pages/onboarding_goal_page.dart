import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/goal_card.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/step_progress_bar.dart';

/// Page that lets the user choose their primary goal during onboarding.
class OnboardingGoalPage extends StatefulWidget {
  /// Creates the onboarding goal page.
  const OnboardingGoalPage({super.key});

  @override
  State<OnboardingGoalPage> createState() => _OnboardingGoalPageState();
}

/// Internal state that owns the [OnboardingVm].
class _OnboardingGoalPageState extends State<OnboardingGoalPage> {
  @override
  void initState() {
    super.initState();
    final onboardingVm = context.read<OnboardingVm>();
    unawaited(
      Future<void>.microtask(
        onboardingVm.logGoalScreenViewed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<OnboardingVm>();
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Set Your Goal'),
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.bg,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(8),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: StepProgressBar(currentStep: 1, totalSteps: 4),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "What's your primary goal?",
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: colors.ink),
              ),
              const SizedBox(height: 8),
              Text(
                'You can fine-tune details later.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.inkSubtle),
              ),
              const SizedBox(height: 16),
              GoalCard(
                goal: Goal.lose,
                selected: vm.goalState.selected == Goal.lose,
                onTap: () => vm.selectGoal(Goal.lose),
              ),
              const SizedBox(height: 12),
              GoalCard(
                goal: Goal.maintain,
                selected: vm.goalState.selected == Goal.maintain,
                onTap: () => vm.selectGoal(Goal.maintain),
              ),
              const SizedBox(height: 12),
              GoalCard(
                goal: Goal.gain,
                selected: vm.goalState.selected == Goal.gain,
                onTap: () => vm.selectGoal(Goal.gain),
              ),
              const Spacer(),
              FilledButton(
                onPressed: vm.goalState.canContinue
                    ? () async {
                        final router = GoRouter.of(context);
                        await vm.logGoalNext();
                        await router.push('/onboarding/stats');
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.bg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
