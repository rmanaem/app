import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/goal_selection_card.dart';
import 'package:starter_app/src/presentation/atoms/glass_button.dart';

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
    final c = Theme.of(context).extension<AppColors>()!;
    final s = Theme.of(context).extension<AppSpacing>()!;
    final t = Theme.of(context).extension<AppTypography>()!;
    final vm = context.watch<OnboardingVm>();
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: c.ink),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: s.gutter),
                children: [
                  Text(
                    'WHAT IS YOUR\nPRIMARY GOAL?',
                    style: t.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1,
                      color: c.ink,
                    ),
                  ),
                  SizedBox(height: s.sm),
                  Text(
                    'We’ll calibrate your nutrition plan\n'
                    'based on this choice.',
                    style: t.body.copyWith(
                      color: c.inkSubtle,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: s.xl),
                  GoalSelectionCard(
                    goal: Goal.lose,
                    title: 'Lose Weight',
                    subtitle: 'Create a sustainable caloric deficit.',
                    icon: Icons.arrow_downward_rounded,
                    isSelected: vm.goalState.selected == Goal.lose,
                    onTap: () => vm.selectGoal(Goal.lose),
                  ),
                  GoalSelectionCard(
                    goal: Goal.maintain,
                    title: 'Maintain Weight',
                    subtitle: 'Optimize performance at current weight.',
                    icon: Icons.balance_rounded,
                    isSelected: vm.goalState.selected == Goal.maintain,
                    onTap: () => vm.selectGoal(Goal.maintain),
                  ),
                  GoalSelectionCard(
                    goal: Goal.gain,
                    title: 'Gain Weight',
                    subtitle: 'Build muscle with a controlled surplus.',
                    icon: Icons.arrow_upward_rounded,
                    isSelected: vm.goalState.selected == Goal.gain,
                    onTap: () => vm.selectGoal(Goal.gain),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(s.gutter),
              child: GlassButton(
                label: 'NEXT STEP',
                isPrimary: true,
                isSelected: vm.goalState.canContinue,
                onTap: vm.goalState.canContinue
                    ? () async {
                        final router = GoRouter.of(context);
                        await vm.logGoalNext();
                        await router.push('/onboarding/stats');
                      }
                    : () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
