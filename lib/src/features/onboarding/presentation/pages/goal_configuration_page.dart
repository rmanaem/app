import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/sex.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/navigation/onboarding_summary_arguments.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/goal_configuration_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/tactile_ruler_picker.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/safety_warning_banner.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/fader_slider.dart';

/// Screen that lets members configure their target weight and pacing.
class GoalConfigurationPage extends StatefulWidget {
  /// Creates the goal configuration flow page.
  const GoalConfigurationPage({super.key});

  @override
  State<GoalConfigurationPage> createState() => _GoalConfigurationPageState();
}

class _GoalConfigurationPageState extends State<GoalConfigurationPage> {
  late final OnboardingVm _flowVm;
  late final GoalConfigurationVm _vm;

  @override
  void initState() {
    super.initState();
    _flowVm = context.read<OnboardingVm>();
    final stats = _flowVm.statsState;
    final goal = _flowVm.goalState.selected ?? Goal.maintain;
    final weight = stats.weight ?? BodyWeight.fromKg(75);
    final sex = stats.sex ?? Sex.male;

    final initialTarget = switch (goal) {
      Goal.lose => weight.kg * 0.95,
      Goal.maintain => weight.kg,
      Goal.gain => weight.kg * 1.03,
    };
    final initialRate = switch (goal) {
      Goal.lose => -0.5,
      Goal.maintain => 0.0,
      Goal.gain => 0.25,
    };

    _vm = GoalConfigurationVm(
      goal: goal,
      sex: sex,
      height: stats.height ?? Stature.fromCm(175),
      currentWeight: weight,
      ageYears: _ageFromDob(stats.dob),
      activity: stats.activity ?? ActivityLevel.moderatelyActive,
      initialTargetWeightKg: initialTarget,
      initialWeeklyRateKg: initialRate,
    );
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  int _ageFromDob(DateTime? dob) {
    if (dob == null) return 30;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age.clamp(14, 90);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final stats = _flowVm.statsState;
    final unit = stats.unitSystem;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: colors.ink),
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                  child: Text(
                    'CALIBRATE\nYOUR PLAN.',
                    style: typography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1,
                      color: colors.ink,
                    ),
                  ),
                ),
                Expanded(
                  child: _vm.isMaintenance
                      ? _MaintenanceLayout(
                          colors: colors,
                          spacing: spacing,
                          typography: typography,
                          unit: unit,
                          vm: _vm,
                        )
                      : _StandardGoalLayout(
                          colors: colors,
                          spacing: spacing,
                          typography: typography,
                          unit: unit,
                          vm: _vm,
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(spacing.gutter),
                  child: AppButton(
                    label: 'CREATE PLAN',
                    isPrimary: true,
                    onTap: () {
                      final args = _buildSummaryArguments();
                      if (args == null) return;
                      _flowVm.setGoalConfigurationChoice(
                        targetWeightKg: _vm.targetWeightKg,
                        weeklyRateKg: _vm.weeklyRateKg,
                        dailyBudgetKcal: _vm.dailyKcal,
                        projectedEndDate: args.projectedEnd,
                      );
                      unawaited(
                        context.push('/onboarding/summary', extra: args),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  OnboardingSummaryArguments? _buildSummaryArguments() {
    final goal = _flowVm.goalState.selected;
    final stats = _flowVm.statsState;
    if (goal == null ||
        stats.dob == null ||
        stats.height == null ||
        stats.weight == null ||
        stats.activity == null ||
        _vm.endDate == null) {
      return null;
    }
    return OnboardingSummaryArguments(
      goal: goal,
      dob: stats.dob!,
      heightCm: stats.height!.cm,
      weightKg: stats.weight!.kg,
      activity: stats.activity!,
      targetWeightKg: _vm.targetWeightKg,
      weeklyRateKg: _vm.weeklyRateKg,
      dailyCalories: _vm.dailyKcal.round(),
      projectedEnd: _vm.endDate!,
    );
  }
}

class _MaintenanceLayout extends StatelessWidget {
  const _MaintenanceLayout({
    required this.colors,
    required this.spacing,
    required this.typography,
    required this.unit,
    required this.vm,
  });

  final AppColors colors;
  final AppSpacing spacing;
  final AppTypography typography;
  final UnitSystem unit;
  final GoalConfigurationVm vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        Column(
          children: [
            Text(
              'DAILY MAINTENANCE TARGET',
              style: typography.caption.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: colors.inkSubtle,
                fontSize: 10,
              ),
            ),
            SizedBox(height: spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  vm.dailyKcal.round().toString(),
                  style: typography.hero.copyWith(
                    fontSize: 64,
                    color: colors.ink,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Text(
                  'KCAL',
                  style: typography.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: colors.inkSubtle,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Column(
          children: [
            Text(
              'TARGET WEIGHT',
              style: typography.caption.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: colors.inkSubtle,
              ),
            ),
            SizedBox(height: spacing.sm),
            SizedBox(
              height: 120,
              child: TactileRulerPicker(
                min: vm.minTargetKg,
                max: vm.maxTargetKg,
                initialValue: vm.targetWeightKg,
                unitLabel: unit == UnitSystem.metric ? 'KG' : 'LB',
                step: 0.1,
                valueFormatter: unit == UnitSystem.metric
                    ? null
                    : (val) => BodyWeight.fromKg(val).lb.toStringAsFixed(1),
                onChanged: vm.setTargetWeightKg,
              ),
            ),
          ],
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _StandardGoalLayout extends StatelessWidget {
  const _StandardGoalLayout({
    required this.colors,
    required this.spacing,
    required this.typography,
    required this.unit,
    required this.vm,
  });

  final AppColors colors;
  final AppSpacing spacing;
  final AppTypography typography;
  final UnitSystem unit;
  final GoalConfigurationVm vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: spacing.xl),
          if (vm.showingSafetyWarning) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
              child: SafetyWarningBanner(
                minCalories: vm.safeMinimumKcal!,
                onAcknowledge: vm.acknowledgeSafetyWarning,
                onCancel: vm.adjustToSafeRate,
              ),
            ),
            SizedBox(height: spacing.lg),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PlanTargetTile(
                    label: 'DAILY TARGET',
                    value: vm.dailyKcal.round().toString(),
                    unit: 'KCAL',
                    alignLeft: true,
                  ),
                ),
                Container(height: 40, width: 1, color: colors.borderIdle),
                Expanded(
                  child: _PlanTargetTile(
                    label: 'COMPLETION',
                    value: _formatDateMonth(vm.endDate),
                    unit: _formatDateYear(vm.endDate),
                    alignLeft: false,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.quad),
          Center(
            child: Text(
              'TARGET WEIGHT',
              style: typography.caption.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: colors.inkSubtle,
              ),
            ),
          ),
          SizedBox(height: spacing.sm),
          SizedBox(
            height: 120,
            child: TactileRulerPicker(
              min: vm.minTargetKg,
              max: vm.maxTargetKg,
              initialValue: vm.targetWeightKg,
              unitLabel: unit == UnitSystem.metric ? 'KG' : 'LB',
              step: 0.1,
              valueFormatter: unit == UnitSystem.metric
                  ? null
                  : (val) => BodyWeight.fromKg(val).lb.toStringAsFixed(1),
              onChanged: vm.setTargetWeightKg,
            ),
          ),
          SizedBox(height: spacing.xxxl),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
            child: _WeeklyRateSelector(vm: vm, unit: unit),
          ),
          SizedBox(height: spacing.xxl),
        ],
      ),
    );
  }

  String _formatDateMonth(DateTime? date) {
    if (date == null) return '--';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDateYear(DateTime? date) {
    if (date == null) return '';
    return '${date.year}';
  }
}

class _PlanTargetTile extends StatelessWidget {
  const _PlanTargetTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.alignLeft,
  });

  final String label;
  final String value;
  final String unit;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: alignLeft
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: typography.caption.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: colors.inkSubtle,
            fontSize: 10,
          ),
        ),
        SizedBox(height: spacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: typography.display.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            if (unit.isNotEmpty) ...[
              SizedBox(width: spacing.xs),
              Text(
                unit,
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: colors.inkSubtle,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _WeeklyRateSelector extends StatelessWidget {
  const _WeeklyRateSelector({
    required this.vm,
    required this.unit,
  });

  final GoalConfigurationVm vm;
  final UnitSystem unit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      children: [
        Text(
          'TARGET PACE',
          style: typography.caption.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: colors.inkSubtle,
          ),
        ),
        SizedBox(height: spacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: colors.ink, width: 1.5),
          ),
          child: Text(
            _paceLabel(vm.weeklyPercentBw).toUpperCase(),
            style: typography.caption.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.ink,
              fontSize: 11,
              letterSpacing: 0.5,
              height: 1,
            ),
          ),
        ),
        SizedBox(height: spacing.lg),
        FaderSlider(
          value: vm.weeklyRateKg.clamp(vm.minRateKg, vm.maxRateKg),
          min: vm.minRateKg,
          max: vm.maxRateKg,
          divisions: ((vm.maxRateKg - vm.minRateKg) / 0.05).round(),
          onChanged: vm.setWeeklyRateKg,
        ),
        SizedBox(height: spacing.md),
        Text(
          _displayRateLine(vm.weeklyDeltaAbs, unit),
          textAlign: TextAlign.center,
          style: typography.display.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: colors.ink,
            height: 1,
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          '${vm.weeklyPercentBw.toStringAsFixed(1)}% bodyweight',
          textAlign: TextAlign.center,
          style: typography.caption.copyWith(
            fontSize: 13,
            color: colors.inkSubtle,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _paceLabel(double pct) {
    if (pct <= 0.5) return 'Gentle';
    if (pct <= 1.0) return 'Standard';
    return 'Aggressive';
  }

  String _displayRateLine(double kg, UnitSystem unit) {
    if (unit == UnitSystem.metric) {
      return '${kg.toStringAsFixed(1)} kg / week';
    }
    final lb = BodyWeight.fromKg(kg).lb;
    return '${lb.toStringAsFixed(1)} lb / week';
  }
}
