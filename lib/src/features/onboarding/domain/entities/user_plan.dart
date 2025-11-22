import 'package:meta/meta.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// Immutable onboarding plan captured at the end of the flow.
@immutable
class UserPlan {
  /// Creates a user plan snapshot.
  const UserPlan({
    required this.goal,
    required this.targetWeightKg,
    required this.weeklyRateKg,
    required this.dailyCalories,
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

  /// Daily calorie allowance.
  final int dailyCalories;

  /// Estimated end date for completing the goal.
  final DateTime projectedEndDate;

  /// Recap context captured from previous steps.
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
