import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/plan/domain/repositories/plan_repository.dart';

/// Use case for persisting a user's nutrition plan.
///
/// Encapsulates the business logic for saving a plan created during
/// the onboarding flow.
class SaveUserPlan {
  /// Creates the use case with the required repository.
  const SaveUserPlan(this._repository);

  final PlanRepository _repository;

  /// Saves the provided [plan] and returns its unique identifier.
  Future<String> call(UserPlan plan) => _repository.save(plan);
}
