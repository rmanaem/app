import 'package:meta/meta.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// Arguments passed from the configuration step to the summary route.
@immutable
class OnboardingSummaryArguments {
  /// Creates a strongly typed summary argument bundle.
  const OnboardingSummaryArguments({
    required this.goal,
    required this.dob,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.targetWeightKg,
    required this.weeklyRateKg,
    required this.dailyCalories,
    required this.projectedEnd,
  });

  /// Selected goal.
  final Goal goal;

  /// Date of birth.
  final DateTime dob;

  /// Height in cm.
  final double heightCm;

  /// Weight in kg.
  final double weightKg;

  /// Activity level.
  final ActivityLevel activity;

  /// Target weight in kg.
  final double targetWeightKg;

  /// Weekly weight change rate in kg.
  final double weeklyRateKg;

  /// Daily calorie budget.
  final int dailyCalories;

  /// Projected end date.
  final DateTime projectedEnd;
}
