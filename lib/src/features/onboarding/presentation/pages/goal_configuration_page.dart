import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/navigation/onboarding_summary_arguments.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/goal_configuration_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/bento_stat_tile.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/tactile_ruler_picker.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/safety_warning_banner.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/precision_slider.dart';

/// Onboarding step: "The Calibration Flight Deck".
/// Fine-tunes target weight and pace using premium instruments.
class GoalConfigurationPage extends StatefulWidget {
  /// Creates the goal configuration page.
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
        title: Text(
          'CALIBRATE PLAN',
          style: typography.caption.copyWith(
            letterSpacing: 2,
            color: colors.inkSubtle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: spacing.md),
                        if (_vm.showingSafetyWarning) ...[
                          SafetyWarningBanner(
                            minCalories: _vm.safeMinimumKcal!,
                            onAcknowledge: _vm.acknowledgeSafetyWarning,
                            onCancel: _vm.adjustToSafeRate,
                          ),
                          SizedBox(height: spacing.lg),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 120,
                                child: BentoStatTile(
                                  label: 'Daily Budget',
                                  value: _vm.dailyKcal.round().toString(),
                                  unit: 'KCAL',
                                  onTap: () {},
                                ),
                              ),
                            ),
                            SizedBox(width: spacing.md),
                            Expanded(
                              child: SizedBox(
                                height: 120,
                                child: BentoStatTile(
                                  label: 'Estimated Arrival',
                                  value: _formatDateMonth(_vm.endDate),
                                  unit: _formatDateYear(_vm.endDate),
                                  onTap: () {},
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing.xxl),
                        Text(
                          'TARGET WEIGHT',
                          style: typography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: colors.inkSubtle,
                          ),
                        ),
                        SizedBox(height: spacing.lg),
                        SizedBox(
                          height: 150,
                          child: TactileRulerPicker(
                            min: _vm.minTargetKg,
                            max: _vm.maxTargetKg,
                            initialValue: _vm.targetWeightKg,
                            unitLabel: unit == UnitSystem.metric ? 'KG' : 'LB',
                            step: 0.1,
                            valueFormatter: unit == UnitSystem.metric
                                ? null
                                : (val) => BodyWeight.fromKg(
                                    val,
                                  ).lb.toStringAsFixed(1),
                            onChanged: _vm.setTargetWeightKg,
                          ),
                        ),
                        SizedBox(height: spacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'WEEKLY RATE',
                              style: typography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: colors.inkSubtle,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceHighlight,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: colors.borderIdle),
                              ),
                              child: Text(
                                _paceLabel(),
                                style: typography.caption.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing.lg),
                        PrecisionSlider(
                          value: _vm.weeklyRateKg.clamp(
                            _vm.minRateKg,
                            _vm.maxRateKg,
                          ),
                          min: _vm.minRateKg,
                          max: _vm.maxRateKg,
                          divisions: ((_vm.maxRateKg - _vm.minRateKg) / 0.05)
                              .round(),
                          onChanged: _vm.setWeeklyRateKg,
                        ),
                        SizedBox(height: spacing.md),
                        Wrap(
                          spacing: spacing.md,
                          runSpacing: spacing.sm,
                          children: [
                            _DataChip(
                              label: _displayRate(_vm.weeklyDeltaAbs, unit),
                              sub: '/ WEEK',
                            ),
                            _DataChip(
                              label:
                                  '${_vm.weeklyPercentBw.toStringAsFixed(1)}%',
                              sub: 'BODYWEIGHT',
                            ),
                          ],
                        ),
                        SizedBox(height: spacing.xl),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(spacing.gutter),
                  child: AppButton(
                    label: 'CREATE PLAN',
                    isPrimary: true,
                    onTap: () async {
                      final args = _buildSummaryArguments();
                      if (args == null) return;
                      _flowVm.setGoalConfigurationChoice(
                        targetWeightKg: _vm.targetWeightKg,
                        weeklyRateKg: _vm.weeklyRateKg,
                        dailyBudgetKcal: _vm.dailyKcal,
                        projectedEndDate: args.projectedEnd,
                      );
                      await context.push('/onboarding/summary', extra: args);
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

  String _paceLabel() {
    final pct = _vm.weeklyPercentBw;
    if (pct <= 0.5) return 'GENTLE';
    if (pct <= 1.0) return 'STANDARD';
    return 'AGGRESSIVE';
  }

  String _displayRate(double kg, UnitSystem unit) {
    if (unit == UnitSystem.metric) {
      return '${kg.toStringAsFixed(2)} kg';
    }
    final lb = BodyWeight.fromKg(kg).lb;
    return '${lb.toStringAsFixed(2)} lb';
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

  OnboardingSummaryArguments? _buildSummaryArguments() {
    final goal = _flowVm.goalState.selected;
    final stats = _flowVm.statsState;
    final dob = stats.dob;
    final height = stats.height;
    final weight = stats.weight;
    final activity = stats.activity;
    final endDate = _vm.endDate;

    if (goal == null ||
        dob == null ||
        height == null ||
        weight == null ||
        activity == null ||
        endDate == null) {
      return null;
    }
    return OnboardingSummaryArguments(
      goal: goal,
      dob: dob,
      heightCm: height.cm,
      weightKg: weight.kg,
      activity: activity,
      targetWeightKg: _vm.targetWeightKg,
      weeklyRateKg: _vm.weeklyRateKg,
      dailyCalories: _vm.dailyKcal.round(),
      projectedEnd: endDate,
    );
  }
}

class _DataChip extends StatelessWidget {
  const _DataChip({required this.label, required this.sub});
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final t = Theme.of(context).extension<AppTypography>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.borderIdle),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: t.body.copyWith(
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            sub,
            style: t.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: c.inkSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
