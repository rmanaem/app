import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_layout.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewstate/nutrition_day_view_state.dart';
import 'package:starter_app/src/features/nutrition/presentation/widgets/quick_add_food_sheet.dart';
import 'package:starter_app/src/features/settings/presentation/pages/nutrition_target_page.dart';

/// The main logbook page for the "Nutrition" tab.
class NutritionPage extends StatefulWidget {
  /// Creates a [NutritionPage].
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

  Future<void> _showQuickAddSheet(
    NutritionDayViewModel vm, {
    String? initialSlot,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (sheetContext) {
        return ChangeNotifierProvider<NutritionDayViewModel>.value(
          value: vm,
          child: Consumer<NutritionDayViewModel>(
            builder: (context, notifier, _) {
              final sheetState = notifier.state;
              return QuickAddFoodSheet(
                initialSlot: initialSlot ?? 'Snacks',
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
            : _NutritionLogbook(
                state: state,
                onDateSelected: vm.onDateSelected,
                onAddMeal: (slotName) {
                  unawaited(
                    _showQuickAddSheet(vm, initialSlot: slotName),
                  );
                },
              ),
      ),
    );
  }
}

class _NutritionLogbook extends StatelessWidget {
  const _NutritionLogbook({
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
          // 1. Header
          _NutritionHeader(dateLabel: state.dateLabel),
          SizedBox(height: spacing.lg),

          // 2. Week Strip
          _WeekStrip(
            days: state.weekDays,
            selectedDate: state.selectedDate,
            onSelect: onDateSelected,
          ),
          SizedBox(height: spacing.xl),

          // 3. Equalizer Summary
          _NutritionEqualizerHeader(
            consumed: state.caloriesConsumed,
            target: state.caloriesTarget,
            p: state.proteinConsumed,
            pTarget: state.proteinTarget,
            c: state.carbsConsumed,
            cTarget: state.carbsTarget,
            f: state.fatConsumed,
            fTarget: state.fatTarget,
          ),
          SizedBox(height: spacing.xl),

          // 4. THE THREADED STREAM
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.meals.length,
            itemBuilder: (context, index) {
              final meal = state.meals[index];
              final isLast = index == state.meals.length - 1;
              return _ThreadedMealGroup(
                meal: meal,
                isLast: isLast,
                onAdd: () => onAddMeal(meal.title),
              );
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// UPDATED MEAL GROUP: BRIGHTER HEADER
// -----------------------------------------------------------------------------
class _ThreadedMealGroup extends StatelessWidget {
  const _ThreadedMealGroup({
    required this.meal,
    required this.isLast,
    required this.onAdd,
  });

  final MealSummaryVm meal;
  final bool isLast;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. The Rail (Left)
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.bg,
                  border: Border.all(
                    color: colors.ink,
                    width: 2,
                  ), // Brighter Dot
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : colors.ink.withValues(alpha: 0.15),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // 2. The Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Meal Title (UPDATED: White & Heavy)
                    Text(
                      meal.title.toUpperCase(),
                      style: typography.caption.copyWith(
                        color: colors.ink, // Was inkSubtle
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 12, // Slightly larger
                      ),
                    ),

                    // Right Side: Calorie Summary + Add Button
                    Row(
                      children: [
                        if (meal.entries.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text(
                              meal.subtitle
                                  .replaceAll('•', '')
                                  .trim(), // Extract just the kcal
                              style: typography.caption.copyWith(
                                color: colors.inkSubtle,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(
                              6,
                            ), // Smaller, tighter button
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.borderIdle),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add, size: 16, color: colors.ink),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Food List
                if (meal.entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      'No items logged',
                      style: typography.caption.copyWith(
                        color: colors.inkSubtle.withValues(alpha: 0.3),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...meal.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colors.inkSubtle,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.title,
                              style: typography.body.copyWith(
                                color: colors.ink,
                                fontSize: 15,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.calories}',
                            style: typography.caption.copyWith(
                              color: colors.inkSubtle, // Numbers recede
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ... (EqualizerHeader, EqualizerBar, Header, WeekStrip, DayKey...)
class _NutritionEqualizerHeader extends StatelessWidget {
  const _NutritionEqualizerHeader({
    required this.consumed,
    required this.target,
    required this.p,
    required this.pTarget,
    required this.c,
    required this.cTarget,
    required this.f,
    required this.fTarget,
  });
  final int consumed;
  final int target;
  final int p;
  final int pTarget;
  final int c;
  final int cTarget;
  final int f;
  final int fTarget;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY INTAKE',
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
                      '$consumed',
                      style: typography.display.copyWith(
                        color: colors.ink,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ $target kcal',
                      style: typography.body.copyWith(
                        color: colors.inkSubtle,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _EqualizerBar(
          label: 'PRO',
          val: p,
          target: pTarget,
          color: const Color(0xFF9E9E9E),
        ),
        const SizedBox(height: 12),
        _EqualizerBar(
          label: 'CARB',
          val: c,
          target: cTarget,
          color: const Color(0xFF616161),
        ),
        const SizedBox(height: 12),
        _EqualizerBar(
          label: 'FAT',
          val: f,
          target: fTarget,
          color: const Color(0xFF424242),
        ),
      ],
    );
  }
}

class _EqualizerBar extends StatelessWidget {
  const _EqualizerBar({
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
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: typography.caption.copyWith(
              color: colors.inkSubtle,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(color: colors.surface),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            '${val}g',
            textAlign: TextAlign.right,
            style: typography.caption.copyWith(
              color: colors.ink,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

class _NutritionHeader extends StatelessWidget {
  const _NutritionHeader({required this.dateLabel});
  final String dateLabel;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FOOD LOG',
              style: typography.caption.copyWith(
                color: colors.inkSubtle,
                letterSpacing: 2,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateLabel.toUpperCase(),
              style: typography.display.copyWith(
                fontSize: 24,
                color: colors.ink,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: IconButton(
            onPressed: () async {
              await Navigator.of(context, rootNavigator: true).push(
                PageRouteBuilder<void>(
                  fullscreenDialog: true,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const NutritionTargetPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0, 1);
                        const end = Offset.zero;
                        const curve = Curves.easeOutQuint;
                        final tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                ),
              );
              if (context.mounted) {
                final vm = context.read<NutritionDayViewModel>();
                unawaited(vm.onDateSelected(vm.state.selectedDate));
              }
            },
            icon: Icon(Icons.tune, color: colors.ink),
            tooltip: 'Adjust Targets',
          ),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.days,
    required this.selectedDate,
    required this.onSelect,
  });
  final List<DateTime> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;
  @override
  Widget build(BuildContext context) {
    const dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((date) {
        final isSelected =
            date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
        final label = dayLabels[date.weekday - 1];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _DayKey(
              label: label,
              date: date.day.toString(),
              isActive: isSelected,
              onTap: () => onSelect(date),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DayKey extends StatelessWidget {
  const _DayKey({
    required this.label,
    required this.date,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final String date;
  final bool isActive;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final layout = Theme.of(context).extension<AppLayout>()!;
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 64,
        decoration: BoxDecoration(
          color: isActive ? colors.surface : colors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? colors.borderActive : colors.borderIdle,
            width: isActive ? layout.strokeLg : layout.strokeMd,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.1),
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
              label,
              style: typography.caption.copyWith(
                fontSize: 9,
                color: isActive
                    ? colors.inkSubtle
                    : colors.inkSubtle.withValues(alpha: 0.5),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: typography.title.copyWith(
                fontSize: 16,
                color: isActive ? colors.ink : colors.inkSubtle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
