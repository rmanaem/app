import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';

/// Repository interface for managing user nutrition plans.
///
/// Provides methods to persist and retrieve the user's active plan.
abstract class PlanRepository {
  /// Fetches the active plan for the dashboard.
  ///
  /// Returns null if no plan exists or if the plan could not be loaded.
  Future<UserPlan?> getCurrentPlan();

  /// Saves a new plan created at the end of onboarding.
  ///
  /// Returns the unique identifier for the saved plan.
  Future<String> save(UserPlan plan);
}
