import 'package:meta/meta.dart';
import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';

/// Immutable view state for the today dashboard page.
///
/// Represents all data needed to render the today view, including
/// the user's plan, loading status, and consumed nutrition data.
@immutable
class TodayViewState {
  /// Creates a today view state snapshot.
  const TodayViewState({
    this.plan,
    this.isLoading = false,
    this.errorMessage,
    this.consumedCalories = 0,
    this.consumedProtein = 0,
    this.consumedFat = 0,
    this.consumedCarbs = 0,
    this.planLabel,
    this.nextWorkoutTitle,
    this.nextWorkoutSubtitle,
    this.lastWorkoutTitle,
    this.lastWorkoutSubtitle,
    this.lastWeightKg,
    this.weightDeltaLabel,
    this.hasWeightTrend = false,
  });

  /// The user's active nutrition plan.
  final UserPlan? plan;

  /// Whether the plan is currently being loaded.
  final bool isLoading;

  /// Error message if plan loading failed.
  final String? errorMessage;

  /// Calories consumed today.
  final int consumedCalories;

  /// Protein consumed today in grams.
  final int consumedProtein;

  /// Fat consumed today in grams.
  final int consumedFat;

  /// Carbohydrates consumed today in grams.
  final int consumedCarbs;

  /// Short label for the plan chip (e.g. "Lose · Standard").
  final String? planLabel;

  /// Title for the next workout block.
  final String? nextWorkoutTitle;

  /// Subtitle for the next workout block (e.g. time/duration).
  final String? nextWorkoutSubtitle;

  /// Title for the last workout block.
  final String? lastWorkoutTitle;

  /// Subtitle for the last workout block.
  final String? lastWorkoutSubtitle;

  /// Last recorded weight in kg (MVP: placeholder).
  final double? lastWeightKg;

  /// Short trend label for weight compared to last week.
  final String? weightDeltaLabel;

  /// Whether there is enough data to show a trend visual.
  final bool hasWeightTrend;

  /// True when a non-null [errorMessage] is present.
  bool get hasError => errorMessage != null;

  /// Creates a copy with updated fields.
  TodayViewState copyWith({
    UserPlan? plan,
    bool? isLoading,
    String? errorMessage,
    int? consumedCalories,
    int? consumedProtein,
    int? consumedFat,
    int? consumedCarbs,
    String? planLabel,
    String? nextWorkoutTitle,
    String? nextWorkoutSubtitle,
    String? lastWorkoutTitle,
    String? lastWorkoutSubtitle,
    double? lastWeightKg,
    String? weightDeltaLabel,
    bool? hasWeightTrend,
  }) {
    return TodayViewState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      consumedProtein: consumedProtein ?? this.consumedProtein,
      consumedFat: consumedFat ?? this.consumedFat,
      consumedCarbs: consumedCarbs ?? this.consumedCarbs,
      planLabel: planLabel ?? this.planLabel,
      nextWorkoutTitle: nextWorkoutTitle ?? this.nextWorkoutTitle,
      nextWorkoutSubtitle: nextWorkoutSubtitle ?? this.nextWorkoutSubtitle,
      lastWorkoutTitle: lastWorkoutTitle ?? this.lastWorkoutTitle,
      lastWorkoutSubtitle: lastWorkoutSubtitle ?? this.lastWorkoutSubtitle,
      lastWeightKg: lastWeightKg ?? this.lastWeightKg,
      weightDeltaLabel: weightDeltaLabel ?? this.weightDeltaLabel,
      hasWeightTrend: hasWeightTrend ?? this.hasWeightTrend,
    );
  }
}
