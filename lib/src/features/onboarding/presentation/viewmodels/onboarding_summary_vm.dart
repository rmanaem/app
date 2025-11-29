import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/onboarding/domain/usecases/save_user_plan.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';

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
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbGrams,
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
  final double dailyCalories;

  /// Daily protein target in grams.
  final int proteinGrams;

  /// Daily fat target in grams.
  final int fatGrams;

  /// Daily carbohydrate target in grams.
  final int carbGrams;

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
    double? dailyCalories,
    int? proteinGrams,
    int? fatGrams,
    int? carbGrams,
    Goal? goal,
    DateTime? dob,
    double? heightCm,
    double? currentWeightKg,
    ActivityLevel? activity,
    double? targetWeightKg,
    double? weeklyRateKg,
    DateTime? projectedEndDate,
  }) {
    return OnboardingSummaryState(
      goal: goal ?? this.goal,
      dob: dob ?? this.dob,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      activity: activity ?? this.activity,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      weeklyRateKg: weeklyRateKg ?? this.weeklyRateKg,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      carbGrams: carbGrams ?? this.carbGrams,
      projectedEndDate: projectedEndDate ?? this.projectedEndDate,
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
    required DateTime createdAt,
    double? weeklyRateKg,
    double? dailyCalories,
    int? proteinGrams,
    int? fatGrams,
    int? carbGrams,
    DateTime? projectedEndDate,
    SaveUserPlan? saveUserPlan,
  }) : _saveUserPlan = saveUserPlan,
       _createdAt = createdAt {
    _state = OnboardingSummaryState(
      goal: goal,
      dob: dob,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      activity: activity,
      targetWeightKg: targetWeightKg,
      weeklyRateKg: weeklyRateKg ?? 0,
      dailyCalories: dailyCalories ?? 0,
      proteinGrams: proteinGrams ?? 0,
      fatGrams: fatGrams ?? 0,
      carbGrams: carbGrams ?? 0,
      projectedEndDate: projectedEndDate ?? DateTime.now(),
    );
  }

  final SaveUserPlan? _saveUserPlan;
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
    return [];
  }

  /// Formatted mission start date (today).
  String get startDateFormatted => _formatDate(DateTime.now());

  /// Formatted projected end date.
  String get endDateFormatted => _formatDate(state.projectedEndDate);

  /// Starting weight shown in the mission grid.
  String get startWeightFormatted => state.currentWeightKg.toStringAsFixed(1);

  /// Target weight shown in the mission grid.
  String get targetWeightFormatted => state.targetWeightKg.toStringAsFixed(1);

  /// Weekly rate copy for the mission grid.
  String get weeklyRateFormatted =>
      '${state.weeklyRateKg.abs().toStringAsFixed(2)} kg/wk';

  /// Returns true if the selected goal is maintenance.
  bool get isMaintenance => state.goal == Goal.maintain;

  /// Returns the combined summary string for the vector footer.
  /// Handles maintenance vs loss/gain states.
  String get vectorFooterStats {
    if (isMaintenance) {
      return 'DURATION: ONGOING  •  ZONE: ±1.5 KG  •  FOCUS: RECOMP';
    }
    final days = state.projectedEndDate.difference(DateTime.now()).inDays;
    final weeks = (days / 7).ceil().clamp(1, 999);
    final delta = state.targetWeightKg - state.currentWeightKg;
    final sign = delta > 0 ? '+' : '';
    final pace = state.weeklyRateKg.abs().toStringAsFixed(2);

    return '$weeks WEEKS  •  $sign${delta.toStringAsFixed(1)} KG  •  $pace KG/WK';
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

  /// Persists the plan using the injected use case.
  Future<String> savePlan() async {
    if (_saveUserPlan == null) {
      return 'plan_local_preview';
    }
    if (_state.isSaving) {
      return _state.planId ?? 'plan_pending';
    }
    _updateState(_state.copyWith(isSaving: true));
    try {
      final id = await _saveUserPlan(
        UserPlan(
          goal: state.goal,
          targetWeightKg: state.targetWeightKg,
          weeklyRateKg: state.weeklyRateKg,
          dailyCalories: state.dailyCalories,
          proteinGrams: state.proteinGrams,
          fatGrams: state.fatGrams,
          carbGrams: state.carbGrams,
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
    } on Exception catch (_) {
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
}
