import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/activity_level_sheet.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/date_picker_sheet.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/height_picker_sheet.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/weight_picker_sheet.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/stat_field_card.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/step_progress_bar.dart';

/// Onboarding step for capturing personal stats via picker sheets.
class OnboardingStatsPage extends StatefulWidget {
  /// Creates the stats page with the [initialGoal].
  const OnboardingStatsPage({super.key, this.initialGoal});

  /// Goal selected on the previous screen.
  final Goal? initialGoal;

  @override
  State<OnboardingStatsPage> createState() => _OnboardingStatsPageState();
}

class _OnboardingStatsPageState extends State<OnboardingStatsPage> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<OnboardingVm>();
    if (widget.initialGoal != null) {
      vm.selectGoal(widget.initialGoal!);
    }
    unawaited(
      Future<void>.microtask(vm.logStatsScreenViewed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<OnboardingVm>();
    final state = vm.statsState;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('About you'),
        elevation: 0,
        backgroundColor: colors.bg,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(8),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: StepProgressBar(currentStep: 2, totalSteps: 4),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "We'll use this to tailor calorie targets and tips.",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
              ),
              const SizedBox(height: 16),
              StatFieldCard(
                label: 'Date of birth',
                valueText: _formatDob(state.dob),
                onTap: () async {
                  final picked = await showDobPickerSheet(
                    context: context,
                    initial: state.dob,
                  );
                  if (picked != null) {
                    vm.setDob(picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              StatFieldCard(
                label: 'Height',
                valueText: _formatHeight(state.height, state.unitSystem),
                onTap: () async {
                  final result = await showHeightPickerSheet(
                    context: context,
                    unit: state.unitSystem,
                    current: state.height,
                  );
                  if (result == null) return;
                  if (result.unit != state.unitSystem) {
                    vm.setUnitSystem(result.unit);
                  }
                  vm.setHeightCm(result.stature.cm);
                },
              ),
              const SizedBox(height: 12),
              StatFieldCard(
                label: 'Weight',
                valueText: _formatWeight(state.weight, state.unitSystem),
                onTap: () async {
                  final result = await showWeightPickerSheet(
                    context: context,
                    unit: state.unitSystem,
                    current: state.weight,
                  );
                  if (result == null) return;
                  if (result.unit != state.unitSystem) {
                    vm.setUnitSystem(result.unit);
                  }
                  if (result.unit == UnitSystem.metric) {
                    vm.setWeightKg(result.weight.kg);
                  } else {
                    vm.setWeightLb(result.weight.lb);
                  }
                },
              ),
              const SizedBox(height: 12),
              StatFieldCard(
                label: 'Activity level',
                valueText: _formatActivity(state.activity),
                onTap: () async {
                  final selection = await showActivityLevelSheet(
                    context: context,
                    current: state.activity,
                  );
                  if (selection != null) {
                    vm.setActivityLevel(selection);
                  }
                },
              ),
              const Spacer(),
              SafeArea(
                top: false,
                child: FilledButton(
                  onPressed: state.isValid
                      ? () async {
                          final router = GoRouter.of(context);
                          await vm.logStatsNext();
                          await router.push('/onboarding/goal-configuration');
                        }
                      : null,
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _formatDob(DateTime? dob) {
    if (dob == null) return null;
    final month = dob.month.toString().padLeft(2, '0');
    final day = dob.day.toString().padLeft(2, '0');
    return '${dob.year}-$month-$day';
  }

  String? _formatHeight(Stature? height, UnitSystem unit) {
    if (height == null) return null;
    if (unit == UnitSystem.metric) {
      return '${height.cm.toStringAsFixed(0)} cm';
    }
    final inches = height.inchesRemainder.round();
    return '${height.feet} ft $inches in';
  }

  String? _formatWeight(BodyWeight? weight, UnitSystem unit) {
    if (weight == null) return null;
    if (unit == UnitSystem.metric) {
      return '${weight.kg.toStringAsFixed(1)} kg';
    }
    return '${weight.lb.toStringAsFixed(1)} lb';
  }

  String? _formatActivity(ActivityLevel? level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Mostly sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately active';
      case ActivityLevel.veryActive:
        return 'Very active';
      case ActivityLevel.extremelyActive:
        return 'Extremely active';
      case null:
        return null;
    }
  }
}
