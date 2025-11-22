import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/onboarding/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/onboarding/domain/repositories/plan_repository.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// Immutable snapshot rendered on the summary page.
@immutable
class OnboardingSummaryState {
  /// Creates an immutable summary snapshot.
  const OnboardingSummaryState({
    required this.goal,
    required this.dob,
    required this.heightCm,
    required this.currentWeightKg,
    required this.activity,
    required this.targetWeightKg,
    required this.weeklyRateKg,
    required this.dailyCalories,
    required this.projectedEndDate,
    this.planId,
    this.isSaving = false,
  });

  /// Selected goal (lose, maintain, gain).
  final Goal goal;

  /// Date of birth.
  final DateTime dob;

  /// Height in cm.
  final double heightCm;

  /// Current weight in kg.
  final double currentWeightKg;

  /// Activity level.
  final ActivityLevel activity;

  /// Target weight in kg.
  final double targetWeightKg;

  /// Weekly weight change rate in kg.
  final double weeklyRateKg;

  /// Daily calorie budget.
  final int dailyCalories;

  /// Projected end date.
  final DateTime projectedEndDate;

  /// Whether the plan is currently being saved.
  final bool isSaving;

  /// ID of the saved plan.
  final String? planId;

  /// Returns a copy with updated flags.
  OnboardingSummaryState copyWith({
    bool? isSaving,
    String? planId,
  }) {
    return OnboardingSummaryState(
      goal: goal,
      dob: dob,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      activity: activity,
      targetWeightKg: targetWeightKg,
      weeklyRateKg: weeklyRateKg,
      dailyCalories: dailyCalories,
      projectedEndDate: projectedEndDate,
      isSaving: isSaving ?? this.isSaving,
      planId: planId ?? this.planId,
    );
  }
}

/// Lightweight point describing the trend between milestones.
class WeightTrendPoint {
  /// Creates a trend point.
  const WeightTrendPoint({
    required this.weightKg,
    required this.date,
    required this.label,
  });

  /// Weight represented by the point.
  final double weightKg;

  /// Date for the point.
  final DateTime date;

  /// Label rendered inside the callout.
  final String label;
}

/// Macro types rendered in the nutrition summary rings.
enum NutritionMacroType {
  /// Carbohydrates.
  carbs,

  /// Protein.
  protein,

  /// Fat.
  fat,
}

/// Represents a macro recommendation rendered on the summary screen.
class NutritionMacroVm {
  /// Creates a macro breakdown element.
  const NutritionMacroVm({
    required this.label,
    required this.percentage,
    required this.type,
  });

  /// Label (e.g. "Carbs").
  final String label;

  /// Percentage value (0-100).
  final int percentage;

  /// Type of macro.
  final NutritionMacroType type;
}

/// Exposes labels and persistence commands for the summary page.
class OnboardingSummaryVm extends ChangeNotifier {
  /// Creates the ViewModel bound to the provided snapshot.
  OnboardingSummaryVm({
    required Goal goal,
    required DateTime dob,
    required double heightCm,
    required double currentWeightKg,
    required ActivityLevel activity,
    required double targetWeightKg,
    required double weeklyRateKg,
    required int dailyCalories,
    required DateTime projectedEndDate,
    required DateTime createdAt,
    PlanRepository? repository,
  }) : _repo = repository,
       _createdAt = createdAt {
    _state = OnboardingSummaryState(
      goal: goal,
      dob: dob,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      activity: activity,
      targetWeightKg: targetWeightKg,
      weeklyRateKg: weeklyRateKg,
      dailyCalories: dailyCalories,
      projectedEndDate: projectedEndDate,
    );
  }

  final PlanRepository? _repo;
  final DateTime _createdAt;

  late OnboardingSummaryState _state;

  /// Latest snapshot for the UI.
  OnboardingSummaryState get state => _state;

  /// Weight trend graph points (start → goal).
  List<WeightTrendPoint> get trendPoints => [
    WeightTrendPoint(
      weightKg: state.currentWeightKg,
      date: DateTime.now(),
      label: '${state.currentWeightKg.toStringAsFixed(1)} kg',
    ),
    WeightTrendPoint(
      weightKg: state.targetWeightKg,
      date: state.projectedEndDate,
      label: '${state.targetWeightKg.toStringAsFixed(1)} kg',
    ),
    WeightTrendPoint(
      weightKg: state.targetWeightKg,
      date: state.projectedEndDate.add(const Duration(days: 90)),
      label: '',
    ),
  ];

  /// Highlights rendered as bullet text.
  List<String> get highlightBullets {
    final weight = state.targetWeightKg.toStringAsFixed(1);
    final date = _formatDate(state.projectedEndDate);
    return [
      'Reach $weight kg by $date.',
      'Daily budget of ${state.dailyCalories} kcal keeps you on pace.',
      'Tailored to your ${_formatActivityLabel(state.activity)} lifestyle.',
    ];
  }

  /// Nutrition macro split percentages.
  List<NutritionMacroVm> get macroBreakdown => const [
    NutritionMacroVm(
      label: 'Carbs',
      percentage: 50,
      type: NutritionMacroType.carbs,
    ),
    NutritionMacroVm(
      label: 'Protein',
      percentage: 25,
      type: NutritionMacroType.protein,
    ),
    NutritionMacroVm(
      label: 'Fat',
      percentage: 25,
      type: NutritionMacroType.fat,
    ),
  ];

  /// Computed label describing how aggressive the selected rate is.
  String get paceLabel {
    final pct = (state.weeklyRateKg.abs() / state.currentWeightKg) * 100;
    if (pct < 0.35) return 'Gentle';
    if (pct < 0.8) return 'Standard';
    return 'Aggressive';
  }

  /// Human readable goal label.
  String get goalLabel => switch (state.goal) {
    Goal.lose => 'Lose weight',
    Goal.maintain => 'Maintain weight',
    Goal.gain => 'Gain weight',
  };

  /// Persists the plan using the injected repository.
  Future<String> savePlan() async {
    if (_repo == null) {
      return 'plan_local_preview';
    }
    if (_state.isSaving) {
      return _state.planId ?? 'plan_pending';
    }
    _updateState(_state.copyWith(isSaving: true));
    try {
      final id = await _repo.save(
        UserPlan(
          goal: state.goal,
          targetWeightKg: state.targetWeightKg,
          weeklyRateKg: state.weeklyRateKg,
          dailyCalories: state.dailyCalories,
          projectedEndDate: state.projectedEndDate,
          currentWeightKg: state.currentWeightKg,
          heightCm: state.heightCm,
          dob: state.dob,
          activity: state.activity,
          createdAt: _createdAt,
        ),
      );
      _updateState(_state.copyWith(isSaving: false, planId: id));
      return id;
    } catch (error) {
      _updateState(_state.copyWith(isSaving: false));
      rethrow;
    }
  }

  void _updateState(OnboardingSummaryState value) {
    _state = value;
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  String _formatActivityLabel(ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => 'mostly sedentary',
    ActivityLevel.lightlyActive => 'lightly active',
    ActivityLevel.moderatelyActive => 'moderately active',
    ActivityLevel.veryActive => 'very active',
    ActivityLevel.extremelyActive => 'extremely active',
  };
}
