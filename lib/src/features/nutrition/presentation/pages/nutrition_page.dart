import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewstate/nutrition_day_view_state.dart';
import 'package:starter_app/src/features/nutrition/presentation/widgets/quick_add_food_sheet.dart';

/// Main Nutrition tab page.
///
/// Wires the [NutritionDayViewModel] state into presentational widgets.
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
              ? const Center(child: CircularProgressIndicator())
              : state.hasError
              ? _ErrorState(message: state.errorMessage!)
              : NutritionContent(
                  state: state,
                  onDateSelected: vm.onDateSelected,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.isAddingEntry
            ? null
            : () => unawaited(_showQuickAddSheet(vm)),
        backgroundColor: colors.accent,
        foregroundColor: colors.bg,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showQuickAddSheet(NutritionDayViewModel vm) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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

/// Layout for the Nutrition page content.
class NutritionContent extends StatelessWidget {
  /// Creates the Nutrition content section.
  const NutritionContent({
    required this.state,
    required this.onDateSelected,
    super.key,
  });

  /// Current nutrition view state.
  final NutritionDayViewState state;

  /// Invoked when the user selects a different date.
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
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        Expanded(
          child: _MealListSection(meals: state.meals),
        ),
      ],
    );
  }
}

/// Top horizontal day selector (for now, a simple 7-day strip).
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
    final textTheme = Theme.of(context).textTheme;

    final today = DateTime.now();
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
          'Food log',
          style: textTheme.labelSmall?.copyWith(color: colors.inkSubtle),
        ),
        const SizedBox(height: 4),
        Text(
          selectedDateLabel,
          style: textTheme.headlineSmall?.copyWith(color: colors.ink),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (context, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = _isSameDay(date, selectedDate);

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  width: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.ink : colors.surface2,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(
                      color: isSelected ? colors.ink : colors.ringTrack,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekdayLetter(date),
                        style: textTheme.labelSmall?.copyWith(
                          color: isSelected ? colors.bg : colors.inkSubtle,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date.day.toString(),
                        style: textTheme.titleMedium?.copyWith(
                          color: isSelected ? colors.bg : colors.ink,
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

/// Daily calories + macros summary, matching the Today card language.
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
    final textTheme = Theme.of(context).textTheme;

    final remainingCalories = (caloriesTarget - caloriesConsumed).clamp(
      0,
      caloriesTarget,
    );

    final card = Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.ringTrack),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today’s nutrition',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Calories and macros based on your plan.',
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remainingCalories.toString(),
                      style: textTheme.headlineLarge?.copyWith(
                        color: colors.ink,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'kcal remaining',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.inkSubtle,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Calories',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.inkSubtle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$caloriesConsumed / $caloriesTarget kcal',
                    style: textTheme.titleMedium?.copyWith(color: colors.ink),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MacroChip(
                  label: 'Protein',
                  consumed: proteinConsumed,
                  target: proteinTarget,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroChip(
                  label: 'Carbs',
                  consumed: carbsConsumed,
                  target: carbsTarget,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroChip(
                  label: 'Fat',
                  consumed: fatConsumed,
                  target: fatTarget,
                  unit: 'g',
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return card;
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
  });

  final String label;
  final int consumed;
  final int target;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: colors.ringTrack),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 4),
          Text(
            '$consumed / $target $unit',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
        ],
      ),
    );
  }
}

/// Section that shows meals for the selected day.
class _MealListSection extends StatelessWidget {
  const _MealListSection({
    required this.meals,
  });

  final List<MealSummaryVm> meals;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    if (meals.isEmpty) {
      return const _EmptyMealState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meals',
          style: textTheme.titleMedium?.copyWith(color: colors.ink),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: meals.length,
            separatorBuilder: (context, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final meal = meals[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border.all(color: colors.ringTrack),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.title,
                          style: textTheme.titleMedium?.copyWith(
                            color: colors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meal.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.inkSubtle,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right, size: 20),
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
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_outlined,
            color: colors.inkSubtle,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'No meals logged yet',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the + button to log your first meal today.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colors.inkSubtle,
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
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(color: colors.ink),
        textAlign: TextAlign.center,
      ),
    );
  }
}
