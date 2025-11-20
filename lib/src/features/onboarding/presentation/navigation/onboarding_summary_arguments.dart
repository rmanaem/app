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

  final Goal goal;
  final DateTime dob;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activity;
  final double targetWeightKg;
  final double weeklyRateKg;
  final int dailyCalories;
  final DateTime projectedEnd;
}
