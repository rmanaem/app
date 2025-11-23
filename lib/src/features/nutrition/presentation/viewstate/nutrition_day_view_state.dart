import 'package:meta/meta.dart';

/// UI-ready view state for a single day's nutrition log.
@immutable
class NutritionDayViewState {
  /// Creates a view state snapshot.
  const NutritionDayViewState({
    required this.selectedDate,
    required this.dateLabel,
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbsConsumed,
    required this.carbsTarget,
    required this.fatConsumed,
    required this.fatTarget,
    required this.meals,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Formatted date label (e.g. "Sat, Nov 22").
  final String dateLabel;

  /// The selected calendar date.
  final DateTime selectedDate;

  /// Calories consumed for the selected day.
  final int caloriesConsumed;

  /// Daily calorie target.
  final int caloriesTarget;

  /// Protein consumed.
  final int proteinConsumed;

  /// Protein target.
  final int proteinTarget;

  /// Carbs consumed.
  final int carbsConsumed;

  /// Carbs target.
  final int carbsTarget;

  /// Fat consumed.
  final int fatConsumed;

  /// Fat target.
  final int fatTarget;

  /// Meals list, ready for display.
  final List<MealSummaryVm> meals;

  /// Whether the view is currently loading.
  final bool isLoading;

  /// Optional error message if loading fails.
  final String? errorMessage;

  /// True when [errorMessage] is non-null.
  bool get hasError => errorMessage != null;

  /// Creates a copy with updated fields.
  NutritionDayViewState copyWith({
    String? dateLabel,
    DateTime? selectedDate,
    int? caloriesConsumed,
    int? caloriesTarget,
    int? proteinConsumed,
    int? proteinTarget,
    int? carbsConsumed,
    int? carbsTarget,
    int? fatConsumed,
    int? fatTarget,
    List<MealSummaryVm>? meals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NutritionDayViewState(
      dateLabel: dateLabel ?? this.dateLabel,
      selectedDate: selectedDate ?? this.selectedDate,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      caloriesTarget: caloriesTarget ?? this.caloriesTarget,
      proteinConsumed: proteinConsumed ?? this.proteinConsumed,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsConsumed: carbsConsumed ?? this.carbsConsumed,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatConsumed: fatConsumed ?? this.fatConsumed,
      fatTarget: fatTarget ?? this.fatTarget,
      meals: meals ?? this.meals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Lightweight meal summary for list display.
@immutable
class MealSummaryVm {
  /// Creates a meal summary.
  const MealSummaryVm({
    required this.title,
    required this.subtitle,
  });

  /// Meal title (e.g. "Breakfast").
  final String title;

  /// Short subtitle (e.g. "2 items · 430 kcal").
  final String subtitle;
}
