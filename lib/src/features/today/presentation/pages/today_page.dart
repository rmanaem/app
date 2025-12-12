import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

import 'package:starter_app/src/features/today/presentation/viewmodels/today_viewmodel.dart';
import 'package:starter_app/src/features/today/presentation/widgets/log_weight_sheet.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// The main dashboard page for the app "Today" tab.
class TodayPage extends StatelessWidget {
  /// Creates a [TodayPage].
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
            ? Center(child: CircularProgressIndicator(color: colors.ink))
            : _DailyVoidHUD(vm: vm),
      ),
    );
  }
}

class _DailyVoidHUD extends StatelessWidget {
  const _DailyVoidHUD({required this.vm});

  final TodayViewModel vm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final state = vm.state;

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: SingleChildScrollView(
        padding: spacing.edgeAll(spacing.gutter),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header
            _FadeInSlide(
              delay: 0,
              child: _HUDHeader(onSettings: () => context.push('/settings')),
            ),

            SizedBox(height: spacing.xl),

            // 2. THE REACTOR (Hero)
            _FadeInSlide(
              delay: 100,
              child: _ReactorHero(
                vm: vm,
                onTap: () => context.go('/nutrition'),
              ),
            ),

            SizedBox(height: spacing.xxl),

            // VISUAL DIVIDER (Subtle separation)
            _FadeInSlide(
              delay: 150,
              child: Divider(color: colors.borderIdle.withValues(alpha: 0.3)),
            ),

            SizedBox(height: spacing.xl),

            // 3. TRAINING (Void Integration)
            _FadeInSlide(
              delay: 200,
              child: _TrainingVoidSection(
                title: state.nextWorkoutTitle ?? 'REST DAY',
                subtitle: state.nextWorkoutSubtitle ?? 'Active Recovery',
                onTap: () => context.go('/training'),
              ),
            ),

            SizedBox(height: spacing.xl),

            // VISUAL DIVIDER
            _FadeInSlide(
              delay: 250,
              child: Divider(color: colors.borderIdle.withValues(alpha: 0.3)),
            ),

            SizedBox(height: spacing.lg),

            // 4. WEIGHT (Void Integration)
            _FadeInSlide(
              delay: 300,
              child: _WeightVoidSection(
                weight: state.lastWeightKg,
                delta: state.weightDeltaLabel,
                onLog: () async {
                  final initial = state.lastWeightKg ?? 75.0;
                  await showModalBottomSheet<double>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    builder: (ctx) => LogWeightSheet(initialWeight: initial),
                  );
                },
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ... (FadeInSlide, HUDHeader, ReactorHero, MacroGauge - Same as before)
// ... Copying them here for completeness

class _FadeInSlide extends StatelessWidget {
  const _FadeInSlide({required this.child, required this.delay});
  final Widget child;
  final int delay;
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: FutureBuilder(
        future: Future<void>.delayed(Duration(milliseconds: delay)),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? child
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HUDHeader extends StatelessWidget {
  const _HUDHeader({required this.onSettings});
  final VoidCallback onSettings;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, MMM d').format(now).toUpperCase();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COMMAND CENTER',
              style: typography.caption.copyWith(
                color: colors.inkSubtle,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateString,
              style: typography.display.copyWith(
                color: colors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: onSettings,
          icon: Icon(Icons.settings, color: colors.ink),
        ),
      ],
    );
  }
}

class _ReactorHero extends StatelessWidget {
  const _ReactorHero({required this.vm, required this.onTap});
  final TodayViewModel vm;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final state = vm.state;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CircularProgressIndicator(
                  value: 1,
                  color: Color(0xFF222222),
                  strokeWidth: 14,
                ),
                CircularProgressIndicator(
                  value: vm.gaugePercent,
                  color: colors.ink,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vm.heroValue,
                        style: typography.display.copyWith(
                          fontSize: 56,
                          color: colors.ink,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KCAL LEFT',
                        style: typography.caption.copyWith(
                          color: colors.inkSubtle,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _MacroGauge(
                    label: 'PROTEIN',
                    val: state.consumedProtein,
                    target: state.plan?.proteinGrams ?? 0,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MacroGauge(
                    label: 'CARBS',
                    val: state.consumedCarbs,
                    target: state.plan?.carbGrams ?? 0,
                    color: const Color(0xFF616161),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MacroGauge(
                    label: 'FAT',
                    val: state.consumedFat,
                    target: state.plan?.fatGrams ?? 0,
                    color: const Color(0xFF424242),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroGauge extends StatelessWidget {
  const _MacroGauge({
    required this.label,
    required this.val,
    required this.target,
    required this.color,
  });
  final String label;
  final int val;
  final int target;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final progress = target > 0 ? (val / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF222222),
            color: color,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$val/$target',
          style: typography.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: colors.ink,
          ),
        ),
        Text(
          label,
          style: typography.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: colors.inkSubtle,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 3. TRAINING VOID SECTION (No Card - "Total Integration")
// -----------------------------------------------------------------------------
class _TrainingVoidSection extends StatelessWidget {
  const _TrainingVoidSection({
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
    final typography = Theme.of(context).extension<AppTypography>()!;

    // Mock Data for "Weekly Consistency"
    const completed = 3;
    const target = 4;
    const progress = completed / target;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Row(
            children: [
              // Left: Weekly Volume Ring (The Anchor)
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const CircularProgressIndicator(
                      value: 1,
                      color: Color(0xFF222222),
                      strokeWidth: 5,
                    ),
                    CircularProgressIndicator(
                      value: progress,
                      color: colors
                          .accent, // Use accent to distinguish from Nutrition
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$completed/$target',
                            style: typography.title.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.ink,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Right: Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT SESSION',
                      style: typography.caption.copyWith(
                        color: colors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: typography.display.copyWith(
                        fontSize: 32, // Huge text
                        color: colors.ink,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: typography.body.copyWith(
                        color: colors.inkSubtle,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Button (The ONLY solid object)
          AppButton(
            label: 'START SESSION',
            icon: Icons.play_arrow_rounded,
            isPrimary: true,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. WEIGHT VOID SECTION (Ticker Style)
// -----------------------------------------------------------------------------
class _WeightVoidSection extends StatelessWidget {
  const _WeightVoidSection({
    required this.weight,
    required this.delta,
    required this.onLog,
  });

  final double? weight;
  final String? delta;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return InkWell(
      onTap: onLog,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Left: Value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BODY WEIGHT',
                    style: typography.caption.copyWith(
                      color: colors.inkSubtle,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        weight?.toStringAsFixed(1) ?? '--',
                        style: typography.display.copyWith(
                          fontSize: 32,
                          color: colors.ink,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'KG',
                        style: typography.caption.copyWith(
                          fontSize: 12,
                          color: colors.inkSubtle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Middle: Sparkline (Visual only for now)
            SizedBox(
              width: 80,
              height: 30,
              child: CustomPaint(
                painter: _SimpleSparklinePainter(color: colors.accent),
              ),
            ),

            const SizedBox(width: 24),

            // Right: Log Button (Small Outline)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.borderIdle),
              ),
              child: Icon(Icons.add, size: 16, color: colors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleSparklinePainter extends CustomPainter {
  _SimpleSparklinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.25, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.7)
      ..lineTo(size.width * 0.75, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
