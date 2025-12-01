import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewstate/nutrition_day_view_state.dart';
import 'package:starter_app/src/features/nutrition/presentation/widgets/quick_add_food_sheet.dart';

/// Main Nutrition tab page.
///
/// Displays a daily summary of calories and macros, a list of meals,
/// and a date selector.
class NutritionPage extends StatefulWidget {
  /// Creates the Nutrition page.
  const NutritionPage({
    this.showQuickAddSheet = false,
    super.key,
  });

  /// Whether to trigger the quick-add sheet once the page is built.
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<NutritionDayViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: state.isLoading
              ? Center(child: CircularProgressIndicator(color: colors.ink))
              : state.hasError
              ? _ErrorState(message: state.errorMessage!)
              : _NutritionContent(
                  state: state,
                  onDateSelected: vm.onDateSelected,
                ),
        ),
      ),
    );
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
}

class _NutritionContent extends StatelessWidget {
  const _NutritionContent({
    required this.state,
    required this.onDateSelected,
  });

  final NutritionDayViewState state;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DaySelector(
          selectedDate: state.selectedDate,
          selectedDateLabel: state.dateLabel,
          onDateSelected: onDateSelected,
        ),
        const SizedBox(height: 24),
        _DailySummaryCard(
          caloriesConsumed: state.caloriesConsumed,
          caloriesTarget: state.caloriesTarget,
          proteinConsumed: state.proteinConsumed,
          proteinTarget: state.proteinTarget,
          carbsConsumed: state.carbsConsumed,
          carbsTarget: state.carbsTarget,
          fatConsumed: state.fatConsumed,
          fatTarget: state.fatTarget,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _MealListSection(meals: state.meals),
        ),
      ],
    );
  }
}

/// Horizontal day selector using standard buttons.
class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selectedDate,
    required this.selectedDateLabel,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final String selectedDateLabel;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final today = DateTime.now();
    // Generate 7 days centered on today
    final days = List<DateTime>.generate(
      7,
      (index) => DateTime(
        today.year,
        today.month,
        today.day - 3 + index,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FOOD LOG',
          style: typography.caption.copyWith(
            color: colors.inkSubtle,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          selectedDateLabel,
          style: typography.display.copyWith(color: colors.ink),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (context, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = _isSameDay(date, selectedDate);

              final backgroundColor = isSelected ? colors.ink : colors.surface;
              final borderColor = isSelected ? colors.ink : colors.borderIdle;
              final textColor = isSelected ? colors.bg : colors.ink;
              final subtitleColor = isSelected
                  ? colors.bg.withValues(alpha: 0.7)
                  : colors.inkSubtle;

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 50,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekdayLetter(date),
                        style: typography.caption.copyWith(
                          color: subtitleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: typography.title.copyWith(
                          color: textColor,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _weekdayLetter(DateTime date) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return letters[date.weekday - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Summary card displaying remaining calories and macro progress bars.
/// Uses a solid background color to differentiate from the list.
class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbsConsumed,
    required this.carbsTarget,
    required this.fatConsumed,
    required this.fatTarget,
  });

  final int caloriesConsumed;
  final int caloriesTarget;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbsConsumed;
  final int carbsTarget;
  final int fatConsumed;
  final int fatTarget;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final remainingCalories = (caloriesTarget - caloriesConsumed).clamp(
      0,
      caloriesTarget,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.borderIdle),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ENERGY',
                style: typography.caption.copyWith(
                  color: colors.inkSubtle,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$caloriesConsumed / $caloriesTarget KCAL',
                style: typography.caption.copyWith(color: colors.inkSubtle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            remainingCalories.toString(),
            style: typography.hero.copyWith(
              color: colors.ink,
              fontSize: 56,
              height: 1,
            ),
          ),
          Text(
            'KCAL REMAINING',
            style: typography.caption.copyWith(
              color: colors.inkSubtle,
              letterSpacing: 2,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _MacroProgressBar(
                  label: 'PROTEIN',
                  consumed: proteinConsumed,
                  target: proteinTarget,
                  color: colors.macroProtein,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MacroProgressBar(
                  label: 'CARBS',
                  consumed: carbsConsumed,
                  target: carbsTarget,
                  color: colors.macroCarbs,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MacroProgressBar(
                  label: 'FAT',
                  consumed: fatConsumed,
                  target: fatTarget,
                  color: colors.macroFat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  const _MacroProgressBar({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
  });

  final String label;
  final int consumed;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: typography.caption.copyWith(
                fontSize: 10,
                color: colors.inkSubtle,
              ),
            ),
            Text(
              '${consumed}g',
              style: typography.caption.copyWith(
                fontSize: 10,
                color: colors.ink,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.surfaceHighlight,
            color: color,
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

/// A vertical list of meals.
/// Uses a transparent background with a border to reduce visual weight.
class _MealListSection extends StatelessWidget {
  const _MealListSection({
    required this.meals,
  });

  final List<MealSummaryVm> meals;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    if (meals.isEmpty) {
      return const _EmptyMealState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIMELINE',
          style: typography.caption.copyWith(
            color: colors.inkSubtle,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: meals.length,
            separatorBuilder: (context, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final meal = meals[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border.all(color: colors.borderIdle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.title.toUpperCase(),
                          style: typography.title.copyWith(
                            color: colors.ink,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal.subtitle,
                          style: typography.caption.copyWith(
                            color: colors.inkSubtle,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colors.borderIdle,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyMealState extends StatelessWidget {
  const _EmptyMealState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.grid_3x3,
            color: colors.borderIdle,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'NO DATA LOGGED',
            style: typography.title.copyWith(
              color: colors.ink,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the add button to log a meal.',
            textAlign: TextAlign.center,
            style: typography.body.copyWith(
              color: colors.inkSubtle,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Center(
      child: Text(
        message,
        style: typography.body.copyWith(color: colors.ink),
        textAlign: TextAlign.center,
      ),
    );
  }
}
