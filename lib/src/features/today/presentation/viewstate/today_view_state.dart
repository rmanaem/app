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

  /// Creates a copy with updated fields.
  TodayViewState copyWith({
    UserPlan? plan,
    bool? isLoading,
    String? errorMessage,
    int? consumedCalories,
    int? consumedProtein,
    int? consumedFat,
    int? consumedCarbs,
  }) {
    return TodayViewState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      consumedProtein: consumedProtein ?? this.consumedProtein,
      consumedFat: consumedFat ?? this.consumedFat,
      consumedCarbs: consumedCarbs ?? this.consumedCarbs,
    );
  }
}
