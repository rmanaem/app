import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/plan/domain/repositories/plan_repository.dart';
import 'package:starter_app/src/features/plan/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/plan/domain/value_objects/goal.dart';

/// Fake implementation of [PlanRepository] for testing and development.
///
/// Returns a hardcoded mock plan to enable UI development without
/// a real backend.
class PlanRepositoryFake implements PlanRepository {
  /// Creates the fake repository.
  const PlanRepositoryFake();

  // A static "Perfect Plan" for UI testing
  // CHANGED: Removed 'final' so we can update it at runtime
  static UserPlan _mockPlan = UserPlan(
    goal: Goal.lose,
    currentWeightKg: 90,
    targetWeightKg: 85,
    weeklyRateKg: -0.5,
    dailyCalories: 2250,
    proteinGrams: 180,
    fatGrams: 70,
    carbGrams: 225,
    projectedEndDate: DateTime.now().add(const Duration(days: 56)),
    heightCm: 180,
    dob: DateTime(1990),
    activity: ActivityLevel.moderatelyActive,
    createdAt: DateTime.now(),
  );

  @override
  Future<UserPlan?> getCurrentPlan() async {
    // Simulate network delay for testing loading states
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _mockPlan;
  }

  @override
  Future<String> save(UserPlan plan) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // CHANGED: Update the in-memory store
    _mockPlan = plan;

    return 'plan_fake_${DateTime.now().millisecondsSinceEpoch}';
  }
}
