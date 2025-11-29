/// The primary objective for the user's plan.
enum Goal {
  /// Indicates the member is focused on fat loss.
  lose,

  /// Indicates the member intends to maintain their current weight.
  maintain,

  /// Indicates the member is targeting lean mass gain.
  gain
  ;

  /// The short title used in headers.
  String get title => switch (this) {
    Goal.lose => 'LOSE WEIGHT',
    Goal.maintain => 'MAINTAIN WEIGHT',
    Goal.gain => 'GAIN WEIGHT',
  };

  /// The descriptive subtitle used in cards and summaries.
  String get description => switch (this) {
    Goal.lose => 'Lose fat with a sustainable caloric deficit.',
    Goal.maintain => 'Optimize performance at current weight.',
    Goal.gain => 'Build muscle with a controlled surplus.',
  };

  /// Secondary subtitle used in cards.
  String get subtitle => description;

  /// Analytics-safe identifier.
  String get analyticsName => switch (this) {
    Goal.lose => 'lose_weight',
    Goal.maintain => 'maintain_weight',
    Goal.gain => 'gain_weight',
  };
}
