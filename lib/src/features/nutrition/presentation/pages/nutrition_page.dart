import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_layout.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewstate/nutrition_day_view_state.dart';
import 'package:starter_app/src/features/nutrition/presentation/widgets/quick_add_food_sheet.dart';

/// Primary page for the Nutrition feature.
class NutritionPage extends StatefulWidget {
  /// Creates the nutrition page.
  const NutritionPage({super.key, this.showQuickAddSheet = false});

  /// Whether to automatically show the quick add sheet.
  final bool showQuickAddSheet;

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  bool _shouldOpenQuickAdd = false;

  @override
  void initState() {
    super.initState();
    _shouldOpenQuickAdd = widget.showQuickAddSheet;
  }

  @override
  void didUpdateWidget(covariant NutritionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showQuickAddSheet && !oldWidget.showQuickAddSheet) {
      _shouldOpenQuickAdd = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shouldOpenQuickAdd) {
      _shouldOpenQuickAdd = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final notifier = context.read<NutritionDayViewModel>();
        unawaited(_showQuickAddSheet(notifier));
      });
    }
  }

  Future<void> _showQuickAddSheet(NutritionDayViewModel vm) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ChangeNotifierProvider<NutritionDayViewModel>.value(
          value: vm,
          child: Consumer<NutritionDayViewModel>(
            builder: (context, notifier, _) {
              final sheetState = notifier.state;
              return QuickAddFoodSheet(
                isSubmitting: sheetState.isAddingEntry,
                errorText: sheetState.addEntryErrorMessage,
                onErrorDismissed: notifier.clearQuickAddError,
                onSubmit: notifier.addQuickEntry,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<NutritionDayViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: state.isLoading
            ? Center(child: CircularProgressIndicator(color: colors.ink))
            : state.hasError
            ? Center(child: Text(state.errorMessage ?? 'Error'))
            : _NutritionDashboard(
                state: state,
                onDateSelected: vm.onDateSelected,
                onAddMeal: (slotName) {
                  // Trigger Quick Add with pre-filled slot?
                  // For now, just open the sheet.
                  unawaited(_showQuickAddSheet(vm));
                },
              ),
      ),
    );
  }
}

class _NutritionDashboard extends StatelessWidget {
  const _NutritionDashboard({
    required this.state,
    required this.onDateSelected,
    required this.onAddMeal,
  });

  final NutritionDayViewState state;
  final ValueChanged<DateTime> onDateSelected;
  final void Function(String slot) onAddMeal;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return SingleChildScrollView(
      padding: spacing.edgeAll(spacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header (Day Strip)
          _DaySelectorStrip(
            selectedDate: state.selectedDate,
            onDateSelected: onDateSelected,
          ),
          SizedBox(height: spacing.xl),

          // 2. Hero (Reactor)
          _CalorieReactorCard(
            consumed: state.caloriesConsumed,
            target: state.caloriesTarget,
            protein: state.proteinConsumed,
            proteinTarget: state.proteinTarget,
            carbs: state.carbsConsumed,
            carbsTarget: state.carbsTarget,
            fat: state.fatConsumed,
            fatTarget: state.fatTarget,
          ),
          SizedBox(height: spacing.xxl),

          // 3. Meals List (Ghost Slots)
          ...state.meals.map((meal) {
            final isGhost = meal.subtitle == 'Ghost';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: isGhost
                  ? _GhostMealSlot(
                      label: meal.title,
                      onTap: () => onAddMeal(meal.title),
                    )
                  : _MealLogTile(meal: meal),
            );
          }),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. DAY SELECTOR STRIP (Match Training Tab)
// -----------------------------------------------------------------------------
class _DaySelectorStrip extends StatelessWidget {
  const _DaySelectorStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final layout = Theme.of(context).extension<AppLayout>()!;

    // Generate 7 days centered on today
    final today = DateTime.now();
    final days = List<DateTime>.generate(
      7,
      (index) => DateTime(today.year, today.month, today.day - 3 + index),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FOOD LOG',
          style: typography.caption.copyWith(
            color: colors.inkSubtle,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatHeaderDate(selectedDate),
          style: typography.display.copyWith(fontSize: 24, color: colors.ink),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((date) {
            final isSelected =
                date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 64,
                    decoration: BoxDecoration(
                      color: isSelected ? colors.surface : colors.bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? colors.ink : colors.borderIdle,
                        width: isSelected ? layout.strokeMd : layout.strokeSm,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colors.ink.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekdayLetter(date),
                          style: typography.caption.copyWith(
                            fontSize: 10,
                            color: isSelected
                                ? colors.inkSubtle
                                : colors.inkSubtle.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: typography.title.copyWith(
                            fontSize: 16,
                            color: isSelected ? colors.ink : colors.inkSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatHeaderDate(DateTime date) {
    // Simple formatter "Sun, Dec 7"
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
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _weekdayLetter(DateTime date) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return letters[date.weekday - 1];
  }
}

// -----------------------------------------------------------------------------
// 2. HERO: CALORIE REACTOR CARD
// -----------------------------------------------------------------------------
class _CalorieReactorCard extends StatelessWidget {
  const _CalorieReactorCard({
    required this.consumed,
    required this.target,
    required this.protein,
    required this.proteinTarget,
    required this.carbs,
    required this.carbsTarget,
    required this.fat,
    required this.fatTarget,
  });

  final int consumed;
  final int target;
  final int protein;
  final int proteinTarget;
  final int carbs;
  final int carbsTarget;
  final int fat;
  final int fatTarget;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final remaining = (target - consumed).clamp(0, 9999);
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      // No decoration here to keep it integrated with the background
      child: Column(
        children: [
          // The Reactor Ring
          SizedBox(
            width: 220, // Slightly larger for impact
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Track: Visible Structure (Dark Steel)
                const CircularProgressIndicator(
                  value: 1,
                  color: Color(
                    0xFF333333,
                  ), // Explicit Dark Grey (Visible)
                  strokeWidth: 16,
                  strokeCap: StrokeCap.butt, // Mechanical cut
                ),
                // Fill Track: The Fuel (Pure White)
                CircularProgressIndicator(
                  value: progress,
                  color: colors.ink,
                  strokeWidth: 16,
                  strokeCap: StrokeCap.round,
                ),
                // Center Data
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$remaining',
                        style: typography.display.copyWith(
                          fontSize: 56, // Larger
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KCAL LEFT',
                        style: typography.caption.copyWith(
                          color: colors.inkSubtle,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$consumed / $target',
                        style: typography.caption.copyWith(
                          color: colors.inkSubtle.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Macro Gauges
          Row(
            children: [
              // Using colors directly for pop
              Expanded(
                child: _MacroGauge(
                  label: 'PROTEIN',
                  val: protein,
                  target: proteinTarget,
                  color: const Color(0xFF9E9E9E),
                ),
              ), // Silver
              const SizedBox(width: 12),
              Expanded(
                child: _MacroGauge(
                  label: 'CARBS',
                  val: carbs,
                  target: carbsTarget,
                  color: const Color(0xFF616161),
                ),
              ), // Dark Grey
              const SizedBox(width: 12),
              Expanded(
                child: _MacroGauge(
                  label: 'FAT',
                  val: fat,
                  target: fatTarget,
                  color: const Color(0xFF424242),
                ),
              ), // Charcoal
            ],
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
        SizedBox(
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.surfaceHighlight,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$val/$target',
          style: typography.caption.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: typography.caption.copyWith(
            color: colors.inkSubtle,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 3. MEAL TILES (Ghost vs Filled)
// -----------------------------------------------------------------------------
class _GhostMealSlot extends StatelessWidget {
  const _GhostMealSlot({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final layout = Theme.of(context).extension<AppLayout>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.borderIdle,
            width: layout.strokeSm,

            // Dashed is hard in Flutter without package.
            // Solid thin is fine for "Ghost" if dim.
          ),
        ),
        child: Center(
          child: Text(
            '+ LOG ${label.toUpperCase()}',
            style: typography.caption.copyWith(
              color: colors.inkSubtle,
              letterSpacing: 1.5,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MealLogTile extends StatefulWidget {
  const _MealLogTile({required this.meal});

  final MealSummaryVm meal;

  @override
  State<_MealLogTile> createState() => _MealLogTileState();
}

class _MealLogTileState extends State<_MealLogTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: colors.surface, // Solid Matte Grey
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // THE FIX: High Contrast White Border for Filled Items
          color: colors.ink.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          // Subtle drop shadow for lift
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header is brighter now
                      Text(
                        widget.meal.title.toUpperCase(),
                        style: typography.caption.copyWith(
                          color: colors.ink.withValues(alpha: 0.8), // Brighter
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.meal.subtitle,
                        style: typography.body.copyWith(
                          color: colors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Chevron indicates interaction
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colors.ink,
                  ),
                ],
              ),
            ),
          ),

          // ... (AnimatedCrossFade content remains the same)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Column(
              children: [
                Divider(
                  height: 1,
                  color: colors.borderIdle.withValues(alpha: 0.3),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: widget.meal.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, // Match header padding
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colors.ink, // White bullet
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                entry.title,
                                style: typography.body.copyWith(
                                  fontSize: 15,
                                  color: colors.ink, // Bright text
                                ),
                              ),
                            ),
                            Text(
                              '${entry.calories}',
                              style: typography.caption.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: colors.ink,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              ' kcal',
                              style: typography.caption.copyWith(
                                fontSize: 10,
                                color: colors.inkSubtle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
