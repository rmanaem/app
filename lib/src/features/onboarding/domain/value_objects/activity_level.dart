/// Baseline physical activity level for TDEE calculation.
/// Based on Mifflin-St Jeor activity multipliers.
enum ActivityLevel {
  /// Little or no exercise, desk job.
  /// TDEE Multiplier: 1.2
  sedentary,

  /// Light exercise 1-3 days per week.
  /// TDEE Multiplier: 1.375
  lightlyActive,

  /// Moderate exercise 3-5 days per week.
  /// TDEE Multiplier: 1.55
  moderatelyActive,

  /// Hard exercise 6-7 days per week.
  /// TDEE Multiplier: 1.725
  veryActive,

  /// Very hard exercise twice per day, or physical job + training.
  /// TDEE Multiplier: 1.9
  extremelyActive,
}

/// Convenience labels and properties derived from [ActivityLevel].
extension ActivityLevelLabel on ActivityLevel {
  /// UI label for the activity level.
  String get label => switch (this) {
    ActivityLevel.sedentary => 'Sedentary',
    ActivityLevel.lightlyActive => 'Lightly Active',
    ActivityLevel.moderatelyActive => 'Moderately Active',
    ActivityLevel.veryActive => 'Very Active',
    ActivityLevel.extremelyActive => 'Extremely Active',
  };

  /// Detailed description for picker UI.
  String get description => switch (this) {
    ActivityLevel.sedentary =>
      'Little or no exercise, desk job\n<5,000 steps/day',
    ActivityLevel.lightlyActive =>
      'Light exercise 1-3 days/week\n5,000-7,500 steps/day',
    ActivityLevel.moderatelyActive =>
      'Moderate exercise 3-5 days/week\n7,500-10,000 steps/day',
    ActivityLevel.veryActive =>
      'Hard exercise 6-7 days/week\n10,000-12,500 steps/day',
    ActivityLevel.extremelyActive =>
      'Very hard exercise daily + physical job\n>12,500 steps/day',
  };

  /// TDEE multiplier for this activity level (Mifflin-St Jeor standard).
  double get tdeeMultiplier => switch (this) {
    ActivityLevel.sedentary => 1.2,
    ActivityLevel.lightlyActive => 1.375,
    ActivityLevel.moderatelyActive => 1.55,
    ActivityLevel.veryActive => 1.725,
    ActivityLevel.extremelyActive => 1.9,
  };

  /// Analytics-friendly identifier for the activity level.
  String get analyticsName => switch (this) {
    ActivityLevel.sedentary => 'sedentary',
    ActivityLevel.lightlyActive => 'lightly_active',
    ActivityLevel.moderatelyActive => 'moderately_active',
    ActivityLevel.veryActive => 'very_active',
    ActivityLevel.extremelyActive => 'extremely_active',
  };
}
