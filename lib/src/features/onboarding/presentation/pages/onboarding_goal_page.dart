import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/goal_tile.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Onboarding screen where users select their primary goal.
class OnboardingGoalPage extends StatelessWidget {
  /// Creates the goal selection page.
  const OnboardingGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final vm = context.watch<OnboardingVm>();
    final selectedGoal = vm.goalState.selected;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: colors.ink),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHAT IS YOUR\nPRIMARY GOAL?',
                    style: typography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1,
                      color: colors.ink,
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    'We’ll calibrate your nutrition plan based on this choice.',
                    style: typography.body.copyWith(
                      color: colors.inkSubtle,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.xl),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                child: Column(
                  children: [
                    GoalTile(
                      title: 'Lose Weight',
                      subtitle: 'Lose fat with a sustainable caloric deficit.',
                      icon: Icons.arrow_downward_rounded,
                      isSelected: selectedGoal == Goal.lose,
                      onTap: () => vm.selectGoal(Goal.lose),
                    ),
                    SizedBox(height: spacing.md),
                    GoalTile(
                      title: 'Maintain Weight',
                      subtitle: 'Optimize performance at current weight.',
                      icon: Icons.balance_rounded,
                      isSelected: selectedGoal == Goal.maintain,
                      onTap: () => vm.selectGoal(Goal.maintain),
                    ),
                    SizedBox(height: spacing.md),
                    GoalTile(
                      title: 'Gain Weight',
                      subtitle: 'Build muscle with a controlled surplus.',
                      icon: Icons.arrow_upward_rounded,
                      isSelected: selectedGoal == Goal.gain,
                      onTap: () => vm.selectGoal(Goal.gain),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(spacing.gutter),
              child: AppButton(
                label: 'NEXT',
                isPrimary: true,
                onTap: selectedGoal != null
                    ? () async {
                        final router = GoRouter.of(context);
                        await vm.logGoalNext();
                        await router.push('/onboarding/stats');
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
