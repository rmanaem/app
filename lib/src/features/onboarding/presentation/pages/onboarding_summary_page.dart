import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/domain/usecases/save_user_plan.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/navigation/onboarding_summary_arguments.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_summary_vm.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Displays the onboarding summary once the configuration flow is complete.
class OnboardingSummaryPage extends StatefulWidget {
  /// Creates the summary page with the provided onboarding [args].
  const OnboardingSummaryPage({required this.args, super.key});

  /// Arguments collected from the goal configuration flow.
  final OnboardingSummaryArguments args;

  @override
  State<OnboardingSummaryPage> createState() => _OnboardingSummaryPageState();
}

class _OnboardingSummaryPageState extends State<OnboardingSummaryPage> {
  late final OnboardingSummaryVm _vm;

  @override
  void initState() {
    super.initState();
    final existingVm = context.read<OnboardingSummaryVm?>();
    if (existingVm != null) {
      _vm = existingVm;
    } else {
      final saveUserPlan = context.read<SaveUserPlan?>();
      _vm = OnboardingSummaryVm(
        goal: widget.args.goal,
        dob: widget.args.dob,
        heightCm: widget.args.heightCm,
        currentWeightKg: widget.args.weightKg,
        activity: widget.args.activity,
        targetWeightKg: widget.args.targetWeightKg,
        weeklyRateKg: widget.args.weeklyRateKg,
        dailyCalories: widget.args.dailyCalories.toDouble(),
        projectedEndDate: widget.args.projectedEnd,
        createdAt: DateTime.now(),
        saveUserPlan: saveUserPlan,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.ink),
      ),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                    children: [
                      // 1. HEADER
                      Text(
                        'YOUR PLAN\nIS READY.',
                        style: typography.display.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          height: 1,
                          color: colors.ink,
                        ),
                      ),
                      // Visual separation between header and content
                      SizedBox(height: spacing.xxl),

                      // 2. PLAN OVERVIEW (Maintenance vs. Standard)
                      if (_vm.state.goal == Goal.maintain)
                        _MaintenanceOverviewSection(vm: _vm)
                      else
                        _PlanProjectionSection(vm: _vm),

                      // Visual separation between Plan and Nutrition
                      SizedBox(height: spacing.lg),

                      // 3. NUTRITION SUMMARY
                      _DailyNutritionSection(vm: _vm),

                      // Bottom padding to clear CTA
                      SizedBox(height: spacing.xxl),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(spacing.gutter),
                  color: colors.bg,
                  child: AppButton(
                    label: _vm.state.isSaving
                        ? 'INITIALIZING...'
                        : 'CONFIRM PLAN',
                    isPrimary: true,
                    onTap: _vm.state.isSaving ? null : _onSave,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onSave() async {
    try {
      final planId = await _vm.savePlan();
      if (!mounted) return;
      context.go('/today', extra: {'planId': planId});
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Launch sequence failed: $error')),
      );
    }
  }
}

// -----------------------------------------------------------------------------
// 1. PLAN PROJECTION SECTION (Standard Loss/Gain)
// -----------------------------------------------------------------------------
class _PlanProjectionSection extends StatelessWidget {
  const _PlanProjectionSection({required this.vm});
  final OnboardingSummaryVm vm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      children: [
        Text(
          vm.state.goal.title,
          style: typography.display.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: colors.ink,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            vm.state.goal.description,
            style: typography.body.copyWith(
              fontSize: 14,
              color: colors.inkSubtle,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          vm.projectionSummaryStats,
          style: typography.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.accent,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: vm.isMaintenance
              ? _buildMaintenanceProjection(colors)
              : _buildStandardProjection(colors),
        ),
      ],
    );
  }

  Widget _buildStandardProjection(AppColors colors) {
    return CustomPaint(
      painter: _ProjectionPainter(
        accentColor: colors.accent,
        idleColor: colors.borderIdle,
        bg: colors.bg,
        inkColor: colors.ink,
      ),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(-0.95, 0),
            child: _ProjectionLabel(
              weight: '${vm.state.currentWeightKg.toStringAsFixed(1)} kg',
              date: 'TODAY',
              alignLeft: true,
              isHighlight: false,
            ),
          ),
          Align(
            alignment: const Alignment(0.95, 0),
            child: _ProjectionLabel(
              weight: '${vm.state.targetWeightKg.toStringAsFixed(1)} kg',
              date: vm.endDateFormatted,
              alignLeft: false,
              isHighlight: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceProjection(AppColors colors) {
    return CustomPaint(
      painter: _MaintenanceProjectionPainter(
        accentColor: colors.accent,
        idleColor: colors.borderIdle,
        bg: colors.bg,
        inkColor: colors.ink,
      ),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(-0.95, 0),
            child: _ProjectionLabel(
              weight: '${vm.state.currentWeightKg.toStringAsFixed(1)} kg',
              date: 'NOW',
              alignLeft: true,
              isHighlight: false,
            ),
          ),
          Align(
            alignment: const Alignment(0.95, 0),
            child: _ProjectionLabel(
              weight: '${vm.state.targetWeightKg.toStringAsFixed(1)} kg',
              date: 'ONGOING',
              alignLeft: false,
              isHighlight: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceOverviewSection extends StatelessWidget {
  const _MaintenanceOverviewSection({required this.vm});
  final OnboardingSummaryVm vm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      children: [
        Text(
          vm.state.goal.title,
          style: typography.display.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: colors.ink,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            vm.state.goal.description,
            style: typography.body.copyWith(
              fontSize: 14,
              color: colors.inkSubtle,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 48),
        Column(
          children: [
            Text(
              'MAINTENANCE TARGET',
              style: typography.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: colors.inkSubtle,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  vm.targetWeightFormatted,
                  style: typography.hero.copyWith(
                    fontSize: 56,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'KG',
                  style: typography.caption.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectionLabel extends StatelessWidget {
  const _ProjectionLabel({
    required this.weight,
    required this.date,
    required this.alignLeft,
    required this.isHighlight,
  });

  final String weight;
  final String? date;
  final bool alignLeft;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final crossAlign = alignLeft
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          weight,
          style: typography.display.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isHighlight ? colors.accent : colors.ink,
          ),
        ),
        const SizedBox(height: 32),
        if (date != null)
          Text(
            date!,
            style: typography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.inkSubtle,
              letterSpacing: 0.5,
            ),
          ),
      ],
    );
  }
}

class _ProjectionPainter extends CustomPainter {
  _ProjectionPainter({
    required this.accentColor,
    required this.idleColor,
    required this.bg,
    required this.inkColor,
  });

  final Color accentColor;
  final Color idleColor;
  final Color bg;
  final Color inkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    final padSide = w * 0.05 + 20;

    final pStart = Offset(padSide, cy);
    final pEnd = Offset(w - padSide, cy);

    final linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawLine(pStart, pEnd, linePaint)
      ..drawCircle(pStart, 5, Paint()..color = idleColor)
      ..drawCircle(pStart, 3, Paint()..color = bg)
      ..drawCircle(
        pEnd,
        10,
        Paint()..color = accentColor.withValues(alpha: 0.2),
      )
      ..drawCircle(pEnd, 5, Paint()..color = accentColor)
      ..drawCircle(pEnd, 2, Paint()..color = inkColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MaintenanceProjectionPainter extends CustomPainter {
  _MaintenanceProjectionPainter({
    required this.accentColor,
    required this.idleColor,
    required this.bg,
    required this.inkColor,
  });

  final Color accentColor;
  final Color idleColor;
  final Color bg;
  final Color inkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;
    final padSide = w * 0.05 + 20;

    final pStart = Offset(padSide, cy);
    final pEnd = Offset(w - padSide, cy);

    final zonePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final zoneRect = Rect.fromLTRB(padSide, cy - 20, w - padSide, cy + 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(zoneRect, const Radius.circular(4)),
      zonePaint,
    );

    final linePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pStart, pEnd, linePaint);

    for (final point in [pStart, pEnd]) {
      canvas
        ..drawCircle(point, 4, Paint()..color = accentColor)
        ..drawCircle(point, 2, Paint()..color = bg);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DailyNutritionSection extends StatelessWidget {
  const _DailyNutritionSection({required this.vm});
  final OnboardingSummaryVm vm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final macrosByType = {
      for (final macro in vm.macroBreakdown) macro.type: macro,
    };
    final orderedMacros = <NutritionMacroVm>[
      if (macrosByType[NutritionMacroType.protein] != null)
        macrosByType[NutritionMacroType.protein]!,
      if (macrosByType[NutritionMacroType.carbs] != null)
        macrosByType[NutritionMacroType.carbs]!,
      if (macrosByType[NutritionMacroType.fat] != null)
        macrosByType[NutritionMacroType.fat]!,
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, color: colors.warning, size: 20),
            const SizedBox(width: 8),
            Text(
              'DAILY NUTRITION',
              style: typography.caption.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: colors.inkSubtle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Hero Calories
        Column(
          children: [
            Text(
              '${vm.state.dailyCalories.round()}',
              style: typography.hero.copyWith(
                fontSize: 64,
                letterSpacing: -2,
                height: 1,
              ),
            ),
            Text(
              'KCAL',
              style: typography.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.inkSubtle,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: orderedMacros
              .map(
                (macro) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _MacroRing(macro: macro),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MacroRing extends StatelessWidget {
  const _MacroRing({required this.macro});
  final NutritionMacroVm macro;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final color = switch (macro.type) {
      NutritionMacroType.protein => colors.macroProtein,
      NutritionMacroType.carbs => colors.macroCarbs,
      NutritionMacroType.fat => colors.macroFat,
    };

    final fullLabel = switch (macro.type) {
      NutritionMacroType.protein => 'Protein',
      NutritionMacroType.carbs => 'Carbs',
      NutritionMacroType.fat => 'Fat',
    };

    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: macro.percentage / 100,
                backgroundColor: colors.borderIdle,
                color: color,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Text(
                  '${macro.percentage}%',
                  style: typography.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: colors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          fullLabel.toUpperCase(),
          style: typography.caption.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: colors.inkSubtle,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
