import 'package:starter_app/src/features/onboarding/domain/entities/user_plan.dart';

/// Persists onboarding plans.
abstract class PlanRepository {
  /// Persists [plan] and returns the generated identifier.
  Future<String> save(UserPlan plan);

  /// Retrieves all persisted plans.
  Future<List<UserPlan>> getAll();
}
