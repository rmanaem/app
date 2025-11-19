import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/core/analytics/analytics_service.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/goal_card.dart';

/// Page that lets the user choose their primary goal during onboarding.
class OnboardingGoalPage extends StatefulWidget {
  /// Creates the onboarding goal page.
  const OnboardingGoalPage({super.key});

  @override
  State<OnboardingGoalPage> createState() => _OnboardingGoalPageState();
}

/// Internal state that owns the [OnboardingVm].
class _OnboardingGoalPageState extends State<OnboardingGoalPage> {
  late final OnboardingVm _vm;

  @override
  void initState() {
    super.initState();
    _vm = OnboardingVm(context.read<AnalyticsService>());
    unawaited(_vm.logGoalScreenViewed());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Set Your Goal'),
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.bg,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          final state = _vm.goalState;
          return SafeArea(
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
                    selected: state.selected == Goal.lose,
                    onTap: () => _vm.selectGoal(Goal.lose),
                  ),
                  const SizedBox(height: 12),
                  GoalCard(
                    goal: Goal.maintain,
                    selected: state.selected == Goal.maintain,
                    onTap: () => _vm.selectGoal(Goal.maintain),
                  ),
                  const SizedBox(height: 12),
                  GoalCard(
                    goal: Goal.gain,
                    selected: state.selected == Goal.gain,
                    onTap: () => _vm.selectGoal(Goal.gain),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: state.canContinue
                        ? () async {
                            final selectedGoal = state.selected;
                            if (selectedGoal == null) return;
                            final router = GoRouter.of(context);
                            await _vm.logGoalNext();
                            await router.push(
                              '/onboarding/stats',
                              extra: selectedGoal,
                            );
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }
}
