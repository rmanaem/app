/// Baseline physical activity (outside explicit exercise).
enum ActivityLevel {
  /// Mostly sedentary.
  low,

  /// Lightly active day-to-day.
  moderate,

  /// Very active lifestyle.
  high,
}

/// Convenience labels derived from [ActivityLevel].
extension ActivityLevelLabel on ActivityLevel {
  /// UI label for the activity level.
  String get label => switch (this) {
    ActivityLevel.low => 'Low',
    ActivityLevel.moderate => 'Moderate',
    ActivityLevel.high => 'High',
  };

  /// Analytics-friendly identifier for the activity level.
  String get analyticsName => switch (this) {
    ActivityLevel.low => 'low',
    ActivityLevel.moderate => 'moderate',
    ActivityLevel.high => 'high',
  };
}
