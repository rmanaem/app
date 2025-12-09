import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/plan/domain/repositories/plan_repository.dart';

/// ViewModel for the Nutrition Target Tuner.
class NutritionTargetViewModel extends ChangeNotifier {
  /// Creates the view model and loads the current plan.
  NutritionTargetViewModel({required PlanRepository planRepository})
    : _repository = planRepository {
    unawaited(_loadCurrentPlan());
  }

  final PlanRepository _repository;

  bool _isLoading = true;
  UserPlan? _originalPlan;

  // Editable State
  double _calories = 2000;
  double _protein = 150;
  double _carbs = 200;
  double _fat = 65;

  /// Whether the initial plan is loading.
  bool get isLoading => _isLoading;

  /// Daily calorie target.
  double get calories => _calories;

  /// Daily protein target (g).
  double get protein => _protein;

  /// Daily carbs target (g).
  double get carbs => _carbs;

  /// Daily fat target (g).
  double get fat => _fat;

  Future<void> _loadCurrentPlan() async {
    _isLoading = true;
    notifyListeners();

    final plan = await _repository.getCurrentPlan();
    if (plan != null) {
      _originalPlan = plan;
      _calories = plan.dailyCalories;
      _protein = plan.proteinGrams.toDouble();
      _carbs = plan.carbGrams.toDouble();
      _fat = plan.fatGrams.toDouble();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Updates energy target and scales macros proportionally.
  void updateEnergy(double newCalories) {
    if (_calories <= 0) return;

    // Scale macros proportionally
    final ratio = newCalories / _calories;
    _protein = (_protein * ratio).roundToDouble();
    _carbs = (_carbs * ratio).roundToDouble();
    _fat = (_fat * ratio).roundToDouble();
    _calories = newCalories;
    notifyListeners();
  }

  /// Updates protein target and recalculates total calories.
  void updateProtein(double grams) {
    _protein = grams;
    _recalculateCalories();
  }

  /// Updates carb target and recalculates total calories.
  void updateCarbs(double grams) {
    _carbs = grams;
    _recalculateCalories();
  }

  /// Updates fat target and recalculates total calories.
  void updateFat(double grams) {
    _fat = grams;
    _recalculateCalories();
  }

  void _recalculateCalories() {
    // 4 cal/g for Protein/Carbs, 9 cal/g for Fat
    _calories = (_protein * 4) + (_carbs * 4) + (_fat * 9);
    notifyListeners();
  }

  /// Saves the updated plan to the repository.
  Future<void> saveChanges(BuildContext context) async {
    if (_originalPlan == null) return;

    _isLoading = true;
    notifyListeners();

    final updatedPlan = _originalPlan!.copyWith(
      dailyCalories: _calories,
      proteinGrams: _protein.round(),
      carbGrams: _carbs.round(),
      fatGrams: _fat.round(),
    );

    await _repository.save(updatedPlan);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
