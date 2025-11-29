/// Biological sex used for metabolic calculations.
enum Sex {
  /// Male.
  male,

  /// Female.
  female
  ;

  /// Human-readable label.
  String get label => switch (this) {
    Sex.male => 'Male',
    Sex.female => 'Female',
  };
}
