import 'dart:math';

import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/plan/domain/repositories/plan_repository.dart';

/// Temporary in-memory repository to keep onboarding unblocked.
class MemoryPlanRepository implements PlanRepository {
  /// Creates an in-memory repository.
  const MemoryPlanRepository();

  static final Random _random = Random();

  @override
  Future<String> save(UserPlan plan) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return 'plan_${_random.nextInt(1 << 31)}';
  }

  @override
  Future<UserPlan?> getCurrentPlan() async {
    // No plan stored in memory
    return null;
  }
}
