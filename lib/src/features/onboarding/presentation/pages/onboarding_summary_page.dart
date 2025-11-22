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
    final existingVm = context.read<OnboardingSummaryVm?>();
    if (existingVm != null) {
      _vm = existingVm;
    } else {
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
                const SizedBox(height: 32),
                const _NutritionSectionHeader(),
                const SizedBox(height: 16),
                _NutritionCard(vm: _vm),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isSaving ? null : _onSave,
                  child: state.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Get started'),
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
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Summary of your plan',
              style: textTheme.titleLarge?.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          _WeightTrendGraph(points: vm.trendPoints),
          const SizedBox(height: 4),
          ...vm.highlightBullets.map((text) => _BulletRow(text: text)),
        ],
      ),
    );
  }
}

class _NutritionSectionHeader extends StatelessWidget {
  const _NutritionSectionHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          'Your nutritional recommendations',
          style: textTheme.titleLarge?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Adjust your nutritional goals anytime.',
          style: textTheme.bodyMedium?.copyWith(color: colors.inkSubtle),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NutritionCard extends StatelessWidget {
  const _NutritionCard({required this.vm});

  final OnboardingSummaryVm vm;

  @override
  Widget build(BuildContext context) {
    final state = vm.state;
    return _CardShell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _CalorieTile(kcal: state.dailyCalories),
          ),
          ...vm.macroBreakdown.map(
            (macro) => Expanded(
              child: _MacroTile(macro: macro),
            ),
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
  });

  final List<WeightTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(
          points: points,
          lineColor: colors.accent,
          fillColor: colors.accent.withValues(alpha: 0.08),
          markerColor: colors.accent,
          calloutFillColor: colors.accent,
          labelStyle:
              textTheme.bodySmall?.copyWith(
                color: colors.bg,
                fontWeight: FontWeight.w700,
              ) ??
              const TextStyle(fontSize: 12),
          captionStyle:
              textTheme.bodySmall?.copyWith(color: colors.inkSubtle) ??
              const TextStyle(fontSize: 12),
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
    required this.calloutFillColor,
    required this.labelStyle,
    required this.captionStyle,
  });

  final List<WeightTrendPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color markerColor;
  final Color calloutFillColor;
  final TextStyle labelStyle;
  final TextStyle captionStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final weights = points.map((p) => p.weightKg).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = (maxWeight - minWeight).abs();
    final safeRange = range == 0 ? 1 : range;
    final isFlat = range == 0;

    const horizontalPadding = 16.0;
    const topPadding = 40.0; // Increased for callouts
    const bottomPadding = 48.0;
    const chartLeft = horizontalPadding;
    final chartRight = size.width - horizontalPadding;
    final chartBottom = size.height - bottomPadding;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - topPadding;

    // Calculate offsets for all points
    final offsets = <Offset>[];
    // Add 10% padding to the range so points aren't on the edge
    final paddingRange = safeRange * 0.1;
    final adjustedMin = minWeight - paddingRange;
    final adjustedMax = maxWeight + paddingRange;
    final adjustedRange = adjustedMax - adjustedMin;

    for (var i = 0; i < points.length; i++) {
      final fraction = points.length == 1 ? 0.0 : i / (points.length - 1);
      final x = chartLeft + (chartWidth * fraction);

      final normalized = isFlat
          ? 0.5
          : (points[i].weightKg - adjustedMin) / adjustedRange;

      final y = topPadding + ((1 - normalized) * chartHeight);
      offsets.add(Offset(x, y));
    }

    final linePath = Path();

    if (offsets.isNotEmpty) {
      linePath.moveTo(offsets[0].dx, offsets[0].dy);

      // Draw curve from P0 to P1 (Weight Loss Phase)
      if (offsets.length > 1) {
        final p0 = offsets[0];
        final p1 = offsets[1];

        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p1.dx - (p1.dx - p0.dx) / 2, p1.dy);

        linePath.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p1.dx,
          p1.dy,
        );
      }

      // Draw flat line from P1 to P2 (Maintain Phase)
      if (offsets.length > 2) {
        final p2 = offsets[2];
        linePath.lineTo(p2.dx, p2.dy);
      }
    }

    final fillPath = Path.from(linePath)
      ..lineTo(offsets.last.dx, chartBottom)
      ..lineTo(offsets.first.dx, chartBottom)
      ..close();

    // Draw Fill (Main Curve)
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Draw Maintain Block
    if (offsets.length > 2) {
      final p1 = offsets[1];
      final p2 = offsets[2];
      final rect = Rect.fromLTRB(p1.dx, p1.dy, p2.dx, chartBottom);

      // Draw block background
      canvas.drawRect(
        rect,
        Paint()..color = lineColor.withValues(alpha: 0.2),
      );

      // Draw "Your next goal" text centered in block
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Your next goal',
          style: captionStyle.copyWith(
            color: lineColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - (textPainter.width / 2),
          rect.center.dy - (textPainter.height / 2),
        ),
      );
    }

    // Draw Line
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Draw Markers and Callouts
    for (var i = 0; i < offsets.length; i++) {
      // Skip marker/callout for the last point (maintain end)
      if (i == offsets.length - 1 && points.length > 2) continue;

      canvas.drawCircle(offsets[i], 6, Paint()..color = markerColor);

      if (points[i].label.isNotEmpty) {
        _paintCallout(canvas, size, offsets[i], points[i].label);
      }
    }

    // Date labels logic remains...

    // Draw Date Labels
    for (var i = 0; i < offsets.length; i++) {
      // Only draw date for start and goal (P0 and P1)
      if (i > 1) continue;

      final dateLabel = i == 0 ? 'Today' : _formatDate(points[i].date);
      _paintDateLabel(
        canvas,
        size,
        offsets[i],
        chartBottom,
        dateLabel,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.markerColor != markerColor ||
        oldDelegate.calloutFillColor != calloutFillColor ||
        oldDelegate.labelStyle != labelStyle ||
        oldDelegate.captionStyle != captionStyle;
  }

  void _paintCallout(
    Canvas canvas,
    Size size,
    Offset anchor,
    String text,
  ) {
    const horizontalPadding = 12.0;
    const verticalPadding = 8.0;
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 150);

    final calloutWidth = painter.width + (horizontalPadding * 2);
    final calloutHeight = painter.height + (verticalPadding * 2);

    var left = anchor.dx - (calloutWidth / 2);
    // Clamp to bounds
    if (left < 0) left = 0;
    if (left + calloutWidth > size.width) left = size.width - calloutWidth;

    var top = anchor.dy - calloutHeight - 12;
    if (top < 0) top = 0;

    final rect = Rect.fromLTWH(left, top, calloutWidth, calloutHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    // Draw bubble
    canvas.drawRRect(rrect, Paint()..color = calloutFillColor);

    // Draw small triangle pointer
    final path = Path()
      ..moveTo(anchor.dx, anchor.dy - 4)
      ..lineTo(anchor.dx - 6, anchor.dy - 12)
      ..lineTo(anchor.dx + 6, anchor.dy - 12)
      ..close();
    canvas.drawPath(path, Paint()..color = calloutFillColor);

    painter.paint(
      canvas,
      Offset(rect.left + horizontalPadding, rect.top + verticalPadding),
    );
  }

  void _paintDateLabel(
    Canvas canvas,
    Size size,
    Offset anchor,
    double chartBottom,
    String text,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: captionStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 100);
    var dx = anchor.dx - (painter.width / 2);
    if (dx < 0) {
      dx = 0;
    } else if (dx + painter.width > size.width) {
      dx = size.width - painter.width;
    }
    final dy = chartBottom + 8;
    painter.paint(canvas, Offset(dx, dy));
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
              color: colors.accent,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department, color: colors.accent, size: 36),
        const SizedBox(height: 8),
        Text(
          '$kcal',
          style: textTheme.headlineSmall?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'kcal',
          style: textTheme.bodySmall?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
    final ringColor = switch (macro.type) {
      NutritionMacroType.carbs => colors.macroCarbs,
      NutritionMacroType.protein => colors.macroProtein,
      NutritionMacroType.fat => colors.macroFat,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 72,
          width: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 72,
                width: 72,
                child: CircularProgressIndicator(
                  value: macro.percentage / 100,
                  backgroundColor: colors.ringTrack,
                  valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${macro.percentage}%',
                style: textTheme.labelLarge?.copyWith(
                  color: colors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          macro.label,
          style: textTheme.bodySmall?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
