import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:starter_app/src/features/nutrition/domain/entities/day_food_log.dart';
import 'package:starter_app/src/features/nutrition/domain/entities/food_entry.dart';
import 'package:starter_app/src/features/nutrition/domain/repositories/food_log_repository.dart';
import 'package:starter_app/src/features/nutrition/presentation/models/quick_food_entry_input.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewstate/nutrition_day_view_state.dart';
import 'package:starter_app/src/features/plan/domain/repositories/plan_repository.dart';

/// ViewModel for the Nutrition tab, focused on a single day's log.
class NutritionDayViewModel extends ChangeNotifier {
  /// Creates the ViewModel.
  NutritionDayViewModel({
    required FoodLogRepository foodLogRepository,
    required PlanRepository planRepository,
  }) : _foodLogRepository = foodLogRepository,
       _planRepository = planRepository {
    unawaited(_loadForDate(DateTime.now()));
  }

  final FoodLogRepository _foodLogRepository;
  final PlanRepository _planRepository;

  late NutritionDayViewState _state = NutritionDayViewState(
    selectedDate: _dateOnly(DateTime.now()),
    dateLabel: '',
    caloriesConsumed: 0,
    caloriesTarget: 0,
    proteinConsumed: 0,
    proteinTarget: 0,
    carbsConsumed: 0,
    carbsTarget: 0,
    fatConsumed: 0,
    fatTarget: 0,
    meals: const <MealSummaryVm>[],
    isLoading: true,
  );

  /// Current view state.
  NutritionDayViewState get state => _state;

  /// Loads the log for the selected [date].
  Future<void> onDateSelected(DateTime date) => _loadForDate(date);

  /// Adds a quick entry (calories only, optional macros) to the current day.
  Future<bool> addQuickEntry(QuickFoodEntryInput input) async {
    _updateState(
      _state.copyWith(
        isAddingEntry: true,
      ),
    );

    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: (input.title ?? '').isEmpty ? input.mealLabel : input.title!,
      calories: input.calories,
      proteinGrams: input.proteinGrams ?? 0,
      carbGrams: input.carbGrams ?? 0,
      fatGrams: input.fatGrams ?? 0,
      slot: input.mealLabel,
    );

    try {
      await _foodLogRepository.addQuickEntry(_selectedDate, entry);
      await _loadForDate(_selectedDate);
      _updateState(_state.copyWith(isAddingEntry: false));
      return true;
    } on Exception catch (_) {
      _updateState(
        _state.copyWith(
          isAddingEntry: false,
          addEntryErrorMessage: 'Could not log food entry. Try again.',
        ),
      );
      return false;
    }
  }

  /// Clears the quick-add error message once rendered.
  void clearQuickAddError() {
    if (!_state.hasQuickAddError) {
      return;
    }
    _updateState(_state.copyWith());
  }

  late DateTime _selectedDate = DateTime.now();

  Future<void> _loadForDate(DateTime date) async {
    _selectedDate = _dateOnly(date);
    _updateState(_state.copyWith(isLoading: true));

    try {
      final log = await _foodLogRepository.getLogForDate(_selectedDate);
      final plan = await _planRepository.getCurrentPlan();

      final meals = _generateMealSlots(log);
      final totals = _totals(log);

      _updateState(
        _state.copyWith(
          isLoading: false,
          selectedDate: _selectedDate,
          dateLabel: _formatDate(_selectedDate),
          caloriesConsumed: totals.calories,
          caloriesTarget: plan?.dailyCalories.round() ?? 0,
          proteinConsumed: totals.protein,
          proteinTarget: plan?.proteinGrams ?? 0,
          carbsConsumed: totals.carbs,
          carbsTarget: plan?.carbGrams ?? 0,
          fatConsumed: totals.fat,
          fatTarget: plan?.fatGrams ?? 0,
          meals: meals,
        ),
      );
    } on Exception catch (_) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load nutrition for this day.',
        ),
      );
    }
  }

  List<MealSummaryVm> _generateMealSlots(DayFoodLog log) {
    final slots = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
    final result = <MealSummaryVm>[];

    for (final slotName in slots) {
      final entriesInSlot = log.entries.where((e) {
        // Fallback to title matching for legacy data or if slot is null
        final effectiveSlot = e.slot ?? e.title;
        return effectiveSlot.toLowerCase() == slotName.toLowerCase();
      }).toList();

      if (entriesInSlot.isNotEmpty) {
        var totalCals = 0;
        for (final e in entriesInSlot) {
          totalCals += e.calories;
        }

        result.add(
          MealSummaryVm(
            title: slotName,
            subtitle: '${entriesInSlot.length} items · $totalCals kcal',
            entries: entriesInSlot,
          ),
        );
      } else {
        result.add(
          MealSummaryVm(
            title: slotName,
            subtitle: 'Ghost',
          ),
        );
      }
    }
    return result;
  }

  _LogTotals _totals(DayFoodLog log) {
    var calories = 0;
    var protein = 0;
    var carbs = 0;
    var fat = 0;
    for (final entry in log.entries) {
      calories += entry.calories;
      protein += entry.proteinGrams;
      carbs += entry.carbGrams;
      fat += entry.fatGrams;
    }
    return _LogTotals(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEEE, MMM d');
    return formatter.format(date).toUpperCase();
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  void _updateState(NutritionDayViewState newState) {
    _state = newState;
    notifyListeners();
  }
}

class _LogTotals {
  _LogTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final int calories;
  final int protein;
  final int carbs;
  final int fat;
}
