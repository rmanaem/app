/// Primary objectives a user can choose during onboarding.
enum Goal {
  /// Focus on losing weight.
  lose,

  /// Maintain the current weight.
  maintain,

  /// Gain weight.
  gain,
}

/// Convenience labels derived from a [Goal].
extension GoalLabel on Goal {
  /// Human-readable title used in UI copy.
  String get title => switch (this) {
    Goal.lose => 'Lose Weight',
    Goal.maintain => 'Maintain Weight',
    Goal.gain => 'Gain Weight',
  };

  /// Supporting copy clarifying what the [Goal] entails.
  String get subtitle => switch (this) {
    Goal.lose => 'Create a mild daily deficit.',
    Goal.maintain => 'Keep weight steady.',
    Goal.gain => 'Create a mild daily surplus.',
  };

  /// Analytics-friendly identifier for the [Goal].
  String get analyticsName => switch (this) {
    Goal.lose => 'lose',
    Goal.maintain => 'maintain',
    Goal.gain => 'gain',
  };
}
