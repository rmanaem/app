/// Defines the structural templates for a training program.
enum ProgramSplit {
  /// Push / Pull / Legs rotation.
  ppl,

  /// Upper / Lower rotation.
  upperLower,

  /// Full-body sessions.
  fullBody,

  /// Body part split.
  broSplit,

  /// Custom or empty template.
  custom
  ;

  /// Human-friendly label for the split.
  String get label {
    switch (this) {
      case ProgramSplit.ppl:
        return 'Push / Pull / Legs';
      case ProgramSplit.upperLower:
        return 'Upper / Lower';
      case ProgramSplit.fullBody:
        return 'Full Body';
      case ProgramSplit.broSplit:
        return 'Body Part Split';
      case ProgramSplit.custom:
        return 'Custom / Empty';
    }
  }

  /// Short description of the split intent.
  String get description {
    switch (this) {
      case ProgramSplit.ppl:
        return 'Classic 3 or 6 day rotation focusing on movement patterns.';
      case ProgramSplit.upperLower:
        return 'Balanced frequency separating upper and lower body sessions.';
      case ProgramSplit.fullBody:
        return 'High frequency, hitting every muscle group each session.';
      case ProgramSplit.broSplit:
        return 'Focus on one major muscle group per day.';
      case ProgramSplit.custom:
        return 'Start from scratch. No preset structure.';
    }
  }
}
