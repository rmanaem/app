import 'dart:math';

import 'package:starter_app/src/features/onboarding/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/onboarding/domain/repositories/plan_repository.dart';

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
  Future<List<UserPlan>> getAll() async {
    return [];
  }
}
