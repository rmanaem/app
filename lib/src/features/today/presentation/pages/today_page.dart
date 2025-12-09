import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/nutrition/presentation/navigation/nutrition_page_arguments.dart';
import 'package:starter_app/src/features/today/presentation/viewmodels/today_viewmodel.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/tactile_ruler_picker.dart';

/// Daily dashboard showing nutrition, actions, and progress.
class TodayPage extends StatelessWidget {
  /// Builds the today dashboard page.
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<TodayViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.hasError
            ? _ErrorState(message: state.errorMessage ?? 'System Error')
            : _buildContent(context, vm),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TodayViewModel vm) {
    final state = vm.state;
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMM d').format(now).toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. HEADER
          _Header(
            dateLabel: formattedDate,
            statusLabel: state.planLabel?.toUpperCase() ?? 'CALIBRATING...',
          ),

          const SizedBox(height: 32),

          // 2. CALORIE & MACRO DISPLAY
          _DailyCaloriesSection(vm: vm, onTap: () => _onLogFoodTap(context)),

          const SizedBox(height: 40),

          // 3. QUICK ACTIONS
          _QuickActions(
            onLogFood: () => _onLogFoodTap(context),
            onLogWeight: () => _onLogWeightTap(context, vm),
          ),

          const SizedBox(height: 32),

          // 4. WORKOUT CARD
          _WorkoutCard(
            title: state.nextWorkoutTitle ?? 'REST DAY',
            subtitle: state.nextWorkoutSubtitle ?? 'Recovery & Mobility',
            onTap: () => context.go('/training'),
          ),

          const SizedBox(height: 24),

          // 5. WEIGHT CARD
          _WeightTrendCard(
            currentWeight: state.lastWeightKg,
            deltaLabel: state.weightDeltaLabel,
            onTap: () => _onLogWeightTap(context, vm),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _onLogFoodTap(BuildContext context) {
    context.go(
      '/nutrition',
      extra: const NutritionPageArguments(showQuickAddSheet: true),
    );
  }

  Future<void> _onLogWeightTap(BuildContext context, TodayViewModel vm) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    // Use last logged weight or default to 75
    var currentVal = vm.state.lastWeightKg ?? 75.0;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.bg,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'LOG WEIGHT',
              style: TextStyle(
                color: colors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 150,
              child: TactileRulerPicker(
                min: 30,
                max: 200,
                initialValue: currentVal,
                unitLabel: 'KG',
                step: 0.1,
                onChanged: (val) => currentVal = val,
              ),
            ),
            const Spacer(),
            AppButton(
              label: 'CONFIRM LOG',
              isPrimary: true,
              onTap: () {
                // TODO(arman): Wire up save logic in VM
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. HEADER
// -----------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({required this.dateLabel, required this.statusLabel});
  final String dateLabel;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODAY',
              style: textTheme.labelSmall?.copyWith(
                color: colors.inkSubtle,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: textTheme.titleLarge?.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. DAILY CALORIES & MACROS
// -----------------------------------------------------------------------------
class _DailyCaloriesSection extends StatelessWidget {
  const _DailyCaloriesSection({required this.vm, required this.onTap});
  final TodayViewModel vm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final state = vm.state;

    var gaugeColor = colors.accent;
    if (vm.isOverBudget) gaugeColor = colors.danger;
    if (vm.isTargetHit) gaugeColor = colors.ink;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // 1. GAUGE
          SizedBox(
            height: 150,
            width: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 150),
                  painter: _GaugePainter(
                    color: gaugeColor,
                    trackColor: colors.surface,
                    percent: vm.gaugePercent,
                    strokeWidth: 10,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      vm.heroValue,
                      style: textTheme.displayLarge?.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        fontSize: 56,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vm.heroLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.inkSubtle,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vm.gaugeSubtitle,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.inkSubtle.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 2. MACROS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MacroRing(
                label: 'Protein',
                current: state.consumedProtein,
                target: state.plan?.proteinGrams ?? 0,
                color: colors.macroProtein,
              ),
              const SizedBox(width: 24),
              _MacroRing(
                label: 'Carbs',
                current: state.consumedCarbs,
                target: state.plan?.carbGrams ?? 0,
                color: colors.macroCarbs,
              ),
              const SizedBox(width: 24),
              _MacroRing(
                label: 'Fat',
                current: state.consumedFat,
                target: state.plan?.fatGrams ?? 0,
                color: colors.macroFat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  const _MacroRing({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  final String label;
  final int current;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final progress = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          height: 44,
          width: 44,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: colors.surface,
            color: color,
            strokeWidth: 4,
            strokeCap: StrokeCap.round,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$current/$target',
          style: TextStyle(
            color: colors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: colors.inkSubtle,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.color,
    required this.trackColor,
    required this.percent,
    this.strokeWidth = 12,
  });
  final Color color;
  final Color trackColor;
  final double percent;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    final radius = size.width * 0.45;
    const startAngle = 135 * (math.pi / 180);
    const sweepAngle = 270 * (math.pi / 180);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.solid,
        2,
      );

    final progressSweep = sweepAngle * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// 3. QUICK ACTIONS
// -----------------------------------------------------------------------------
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onLogFood,
    required this.onLogWeight,
  });
  final VoidCallback onLogFood;
  final VoidCallback onLogWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.add,
            label: 'LOG FOOD',
            onTap: onLogFood,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionTile(
            icon: Icons.monitor_weight_outlined,
            label: 'WEIGH IN',
            onTap: onLogWeight,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: colors.borderIdle),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: colors.accent),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. WORKOUT CARD
// -----------------------------------------------------------------------------
class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Left Strip
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT SESSION',
                    style: TextStyle(
                      color: colors.inkSubtle,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.inkSubtle,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.accent),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. WEIGHT CARD
// -----------------------------------------------------------------------------
class _WeightTrendCard extends StatelessWidget {
  const _WeightTrendCard({
    required this.currentWeight,
    required this.deltaLabel,
    required this.onTap,
  });

  final double? currentWeight;
  final String? deltaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Left Strip
            Container(width: 4, height: 48, color: colors.accent),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LATEST WEIGHT',
                    style: TextStyle(
                      color: colors.inkSubtle,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        currentWeight != null
                            ? currentWeight!.toStringAsFixed(1)
                            : '--',
                        style: TextStyle(
                          color: colors.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'kg',
                        style: TextStyle(
                          color: colors.inkSubtle,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (deltaLabel != null)
                    Text(
                      deltaLabel!,
                      style: TextStyle(color: colors.inkSubtle, fontSize: 12),
                    ),
                ],
              ),
            ),
            Icon(Icons.show_chart_rounded, color: colors.accent, size: 32),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
