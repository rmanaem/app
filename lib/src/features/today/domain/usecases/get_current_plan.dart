import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/plan/domain/repositories/plan_repository.dart';

/// Use case for retrieving the user's active nutrition plan.
///
/// Fetches the current plan to display on the today dashboard.
class GetCurrentPlan {
  /// Creates the use case with the required repository.
  const GetCurrentPlan(this._repository);

  final PlanRepository _repository;

  /// Retrieves the active plan, or null if none exists.
  Future<UserPlan?> call() => _repository.getCurrentPlan();
}
