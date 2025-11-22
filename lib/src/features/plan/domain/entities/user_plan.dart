import 'package:meta/meta.dart';
import 'package:starter_app/src/features/plan/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/plan/domain/value_objects/goal.dart';

/// Immutable plan captured at the end of onboarding.
@immutable
class UserPlan {
  /// Creates a user plan snapshot.
  const UserPlan({
    required this.goal,
    required this.targetWeightKg,
    required this.weeklyRateKg,
    required this.dailyCalories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbGrams,
    required this.projectedEndDate,
    required this.currentWeightKg,
    required this.heightCm,
    required this.dob,
    required this.activity,
    required this.createdAt,
  });

  /// Chosen goal (lose/maintain/gain).
  final Goal goal;

  /// Target weight expressed in kilograms.
  final double targetWeightKg;

  /// Signed kg/week (negative for loss, positive for gain).
  final double weeklyRateKg;

  /// Daily calorie budget.
  final double dailyCalories;

  /// Daily protein target in grams.
  final int proteinGrams;

  /// Daily fat target in grams.
  final int fatGrams;

  /// Daily carbohydrate target in grams.
  final int carbGrams;

  /// Estimated end date for completing the goal.
  final DateTime projectedEndDate;

  /// Current weight in kg.
  final double currentWeightKg;

  /// Height in centimeters.
  final double heightCm;

  /// Date of birth.
  final DateTime dob;

  /// Activity level.
  final ActivityLevel activity;

  /// When the plan was saved.
  final DateTime createdAt;
}
