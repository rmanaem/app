import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/onboarding/domain/repositories/plan_repository.dart';
import 'package:starter_app/src/features/onboarding/presentation/navigation/onboarding_summary_arguments.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_summary_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';

/// Final onboarding step summarizing the generated plan.
class OnboardingSummaryPage extends StatefulWidget {
  /// Creates the summary page for the provided [args].
  const OnboardingSummaryPage({required this.args, super.key});

  /// Inputs collected from the previous steps.
  final OnboardingSummaryArguments args;

  @override
  State<OnboardingSummaryPage> createState() => _OnboardingSummaryPageState();
}

class _OnboardingSummaryPageState extends State<OnboardingSummaryPage> {
  late final OnboardingSummaryVm _vm;

  @override
  void initState() {
    super.initState();
    final repo = context.read<PlanRepository?>();
    _vm = OnboardingSummaryVm(
      goal: widget.args.goal,
      dob: widget.args.dob,
      heightCm: widget.args.heightCm,
      currentWeightKg: widget.args.weightKg,
      activity: widget.args.activity,
      targetWeightKg: widget.args.targetWeightKg,
      weeklyRateKg: widget.args.weeklyRateKg,
      dailyCalories: widget.args.dailyCalories,
      projectedEndDate: widget.args.projectedEnd,
      createdAt: DateTime.now(),
      repository: repo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        title: const Text('Review your plan'),
      ),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          final state = _vm.state;
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const OnboardingProgressBar(currentStep: 4, totalSteps: 4),
                const SizedBox(height: 16),
                _HeroSummaryCard(vm: _vm),
                const SizedBox(height: 16),
                _NutritionCard(vm: _vm),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isSaving ? null : () => _onSave(context),
                  child: state.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Get started'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back to adjust'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onSave(BuildContext context) async {
    try {
      final planId = await _vm.savePlan();
      if (!mounted) return;
      context.go('/', extra: {'planId': planId});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save plan: $error')),
      );
    }
  }
}

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({required this.vm});

  final OnboardingSummaryVm vm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final state = vm.state;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Highlights of your plan',
            style: textTheme.titleLarge?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 12),
          _WeightTrendGraph(
            points: vm.trendPoints,
            startLabel: '${state.currentWeightKg.toStringAsFixed(1)} kg',
            endLabel: '${state.targetWeightKg.toStringAsFixed(1)} kg',
            projectedDate: state.projectedEndDate,
          ),
          const SizedBox(height: 16),
          ...vm.highlightBullets.map((text) => _BulletRow(text: text)),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.vm});

  final OnboardingSummaryVm vm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final state = vm.state;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your nutritional recommendations',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Adjust your nutritional goals anytime.',
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 16),
          _CalorieTile(kcal: state.dailyCalories),
          const SizedBox(height: 16),
          Row(
            children: vm.macroBreakdown
                .map(
                  (macro) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _MacroTile(macro: macro),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: colors.ringTrack),
      ),
      child: child,
    );
  }
}

class _WeightTrendGraph extends StatelessWidget {
  const _WeightTrendGraph({
    required this.points,
    required this.startLabel,
    required this.endLabel,
    required this.projectedDate,
  });

  final List<WeightTrendPoint> points;
  final String startLabel;
  final String endLabel;
  final DateTime projectedDate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(
          points: points,
          lineColor: colors.accent,
          fillColor: colors.accent.withValues(alpha: 0.12),
          markerColor: colors.heroPositive,
          labelStyle: textTheme.bodyMedium?.copyWith(color: colors.ink) ??
              const TextStyle(),
          captionStyle: textTheme.bodySmall?.copyWith(color: colors.inkSubtle) ??
              const TextStyle(fontSize: 12),
          startLabel: startLabel,
          endLabel: endLabel,
          projectedDate: projectedDate,
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.markerColor,
    required this.labelStyle,
    required this.captionStyle,
    required this.startLabel,
    required this.endLabel,
    required this.projectedDate,
  });

  final List<WeightTrendPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color markerColor;
  final TextStyle labelStyle;
  final TextStyle captionStyle;
  final String startLabel;
  final String endLabel;
  final DateTime projectedDate;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final weights = points.map((p) => p.weightKg).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = (maxWeight - minWeight).abs().clamp(0.1, double.infinity);

    final linePath = Path();
    final fillPath = Path()..moveTo(0, size.height);
    for (var i = 0; i < points.length; i++) {
      final fraction = i / (points.length - 1);
      final x = size.width * fraction;
      final normalized = (points[i].weightKg - minWeight) / range;
      final y = size.height - (normalized * (size.height * 0.6)) - 24;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()..color = markerColor,
      );
      final label = i == 0 ? startLabel : endLabel;
      _paintText(
        canvas,
        label,
        Offset(x - 24, y - 28),
        labelStyle,
      );
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas
      ..drawPath(fillPath, Paint()..color = fillColor)
      ..drawPath(
        linePath,
        Paint()
          ..color = lineColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );

    _paintText(canvas, 'Today', const Offset(0, 150), captionStyle);
    _paintText(
      canvas,
      _formatDate(projectedDate),
      Offset(size.width - 90, 150),
      captionStyle,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 120);
    painter.paint(canvas, offset);
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: colors.heroPositive,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieTile extends StatelessWidget {
  const _CalorieTile({required this.kcal});

  final int kcal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.ringTrack),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: colors.heroPositive),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$kcal kcal',
                style: textTheme.headlineSmall?.copyWith(color: colors.ink),
              ),
              Text(
                'Daily target',
                style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({required this.macro});

  final NutritionMacroVm macro;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.ringTrack),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            width: 48,
            child: CircularProgressIndicator(
              value: macro.percentage / 100,
              backgroundColor: colors.ringTrack,
              valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
              strokeWidth: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${macro.percentage}%',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
          Text(
            macro.label,
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
        ],
      ),
    );
  }
}
