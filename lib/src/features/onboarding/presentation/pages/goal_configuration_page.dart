import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/navigation/onboarding_summary_arguments.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/goal_configuration_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/safety_warning_banner.dart';

/// Onboarding step that fine-tunes target weight and pace before summary.
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final stats = _flowVm.statsState;
    final unit = stats.unitSystem;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Set New Goal'),
        backgroundColor: colors.bg,
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    children: [
                      const OnboardingProgressBar(
                        currentStep: 3,
                        totalSteps: 4,
                      ),
                      const SizedBox(height: 20),
                      // NEW: Safety warning banner
                      if (_vm.showingSafetyWarning)
                        SafetyWarningBanner(
                          minCalories: _vm.safeMinimumKcal!,
                          onAcknowledge: _vm.acknowledgeSafetyWarning,
                          onCancel: _vm.adjustToSafeRate,
                        ),
                      if (_vm.showingSafetyWarning) const SizedBox(height: 20),
                      _StatsRow(vm: _vm),
                      const SizedBox(height: 24),
                      _WeightSection(vm: _vm, unitSystem: unit),
                      const SizedBox(height: 32),
                      _RateSection(vm: _vm, unitSystem: unit),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: FilledButton(
                      onPressed: () {
                        final args = _buildSummaryArguments();
                        if (args == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Complete your details before continuing.',
                              ),
                            ),
                          );
                          return;
                        }
                        _flowVm.setGoalConfigurationChoice(
                          targetWeightKg: _vm.targetWeightKg,
                          weeklyRateKg: _vm.weeklyRateKg,
                          dailyBudgetKcal: _vm.dailyKcal,
                          projectedEndDate: args.projectedEnd,
                        );
                        unawaited(
                          context.push(
                            '/onboarding/summary',
                            extra: args,
                          ),
                        );
                      },
                      child: const Text('Next'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _ageFromDob(DateTime? dob) {
    if (dob == null) return 30;
    final now = DateTime.now();
    var age = now.year - dob.year;
    final passedBirthday =
        now.month > dob.month || (now.month == dob.month && now.day >= dob.day);
    if (!passedBirthday) age -= 1;
    return age.clamp(14, 90);
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.vm});
  final GoalConfigurationVm vm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'initial daily budget',
            value: '${vm.dailyKcal.round()} kcal',
            background: colors.heroPositive,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'projected end date',
            value: vm.endDate == null ? '—' : _formatDate(vm.endDate!),
            background: colors.heroNeutral,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.background,
  });

  final String label;
  final String value;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.inkSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightSection extends StatelessWidget {
  const _WeightSection({required this.vm, required this.unitSystem});

  final GoalConfigurationVm vm;
  final UnitSystem unitSystem;

  String _displayWeight(double kg) {
    if (unitSystem == UnitSystem.metric) {
      return '${kg.toStringAsFixed(1)} kg';
    }
    return '${BodyWeight.fromKg(kg).lb.toStringAsFixed(1)} lb';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your target weight?',
          style: textTheme.titleLarge?.copyWith(color: colors.ink),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            _displayWeight(vm.targetWeightKg),
            style: textTheme.headlineMedium?.copyWith(color: colors.ink),
          ),
        ),
        const SizedBox(height: 12),
        _WeightGauge(vm: vm, unitSystem: unitSystem),
      ],
    );
  }
}

class _WeightGauge extends StatelessWidget {
  const _WeightGauge({required this.vm, required this.unitSystem});

  final GoalConfigurationVm vm;
  final UnitSystem unitSystem;

  void _handleGesture(double dx, double width) {
    final ratio = (dx / width).clamp(0.0, 1.0);
    final value = vm.minTargetKg + (vm.maxTargetKg - vm.minTargetKg) * ratio;
    vm.setTargetWeightKg(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanDown: (details) =>
              _handleGesture(details.localPosition.dx, width),
          onPanUpdate: (details) =>
              _handleGesture(details.localPosition.dx, width),
          child: SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GaugePainter(
                      min: vm.minTargetKg,
                      max: vm.maxTargetKg,
                      value: vm.targetWeightKg,
                      lineColor: colors.ringTrack,
                      accent: colors.gaugeAccent,
                      labelColor: colors.inkSubtle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 28,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                      thumbShape: SliderComponentShape.noThumb,
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: vm.targetWeightKg.clamp(
                        vm.minTargetKg,
                        vm.maxTargetKg,
                      ),
                      min: vm.minTargetKg,
                      max: vm.maxTargetKg,
                      divisions: math.max(
                        1,
                        ((vm.maxTargetKg - vm.minTargetKg) / 0.1).round(),
                      ),
                      onChanged: vm.setTargetWeightKg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.min,
    required this.max,
    required this.value,
    required this.lineColor,
    required this.accent,
    required this.labelColor,
  });

  final double min;
  final double max;
  final double value;
  final Color lineColor;
  final Color accent;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final diff = (max - min).clamp(0.1, double.infinity);
    final tickPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    final accentPaint = Paint()
      ..color = accent
      ..strokeWidth = 2;

    const tickCount = 40;
    for (var i = 0; i <= tickCount; i++) {
      final x = (i / tickCount) * size.width;
      final tall = i % 5 == 0;
      final height = tall ? size.height * 0.45 : size.height * 0.3;
      canvas.drawLine(
        Offset(x, size.height - height),
        Offset(x, size.height - 10),
        tickPaint,
      );
    }

    final fillWidth = size.width * ((value - min) / diff).clamp(0.0, 1.0);
    final fillRect = Rect.fromLTWH(
      size.width / 2,
      size.height - 25,
      fillWidth - size.width / 2,
      15,
    );
    if (fillRect.width > 0) {
      canvas.drawRect(fillRect, Paint()..color = accent.withValues(alpha: 0.4));
    }

    final targetX = size.width * ((value - min) / diff).clamp(0.0, 1.0);
    canvas.drawLine(
      Offset(targetX, 10),
      Offset(targetX, size.height - 10),
      accentPaint,
    );

    final minLabel = min.toStringAsFixed(0);
    final maxLabel = max.toStringAsFixed(0);
    final painter = TextPainter(textDirection: TextDirection.ltr);
    painter
      ..text = TextSpan(
        text: minLabel,
        style: TextStyle(color: labelColor, fontSize: 12),
      )
      ..layout()
      ..paint(canvas, Offset(0, size.height - 16))
      ..text = TextSpan(
        text: maxLabel,
        style: TextStyle(color: labelColor, fontSize: 12),
      )
      ..layout()
      ..paint(
        canvas,
        Offset(size.width - painter.width, size.height - 16),
      );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      min != oldDelegate.min ||
      max != oldDelegate.max ||
      value != oldDelegate.value;
}

class _RateSection extends StatelessWidget {
  const _RateSection({required this.vm, required this.unitSystem});
  final GoalConfigurationVm vm;
  final UnitSystem unitSystem;

  String _paceLabel() {
    final pct = vm.weeklyPercentBw;
    if (pct <= 0.5) return 'Gentle';
    if (pct <= 1) return 'Standard';
    return 'Aggressive';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your target goal rate?',
          style: textTheme.titleLarge?.copyWith(color: colors.ink),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: colors.heroChip,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _paceLabel(),
              style: textTheme.bodyMedium?.copyWith(color: colors.ink),
            ),
          ),
        ),
        const SizedBox(height: 18),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            activeTrackColor: colors.accent,
            inactiveTrackColor: colors.ringTrack,
            thumbColor: colors.ink,
            overlayColor: colors.ink.withValues(alpha: 0.24),
          ),
          child: Slider(
            value: vm.weeklyRateKg.clamp(vm.minRateKg, vm.maxRateKg),
            min: vm.minRateKg,
            max: vm.maxRateKg,
            divisions: math.max(
              1,
              ((vm.maxRateKg - vm.minRateKg) / 0.05).round(),
            ),
            onChanged: vm.setWeeklyRateKg,
          ),
        ),
        const SizedBox(height: 16),
        _RateBreakdown(vm: vm, unitSystem: unitSystem),
      ],
    );
  }
}

class _RateBreakdown extends StatelessWidget {
  const _RateBreakdown({required this.vm, required this.unitSystem});
  final GoalConfigurationVm vm;
  final UnitSystem unitSystem;

  String _fmt(double kg) {
    if (unitSystem == UnitSystem.metric) {
      return '${kg.toStringAsFixed(2)} kg';
    }
    return '${BodyWeight.fromKg(kg).lb.toStringAsFixed(2)} lb';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    Widget card(String title, double kg, double pct) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.ringTrack),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 10),
          Text(
            _fmt(kg),
            style: textTheme.titleLarge?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 6),
          Text(
            '${pct.toStringAsFixed(2)}% BW',
            style: textTheme.bodyMedium?.copyWith(color: colors.inkSubtle),
          ),
        ],
      ),
    );

    return Row(
      children: [
        Expanded(
          child: card('Per Week', vm.weeklyDeltaAbs, vm.weeklyPercentBw),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: card('Per Month', vm.monthlyDeltaAbs, vm.monthlyPercentBw),
        ),
      ],
    );
  }
}
