/// Unit system for user-facing inputs.
enum UnitSystem {
  /// Metric measurements (cm, kg).
  metric,

  /// Imperial measurements (ft/in, lb).
  imperial,
}

/// Convenience labels derived from [UnitSystem].
extension UnitSystemLabel on UnitSystem {
  /// Human-readable label for segmented controls.
  String get label => switch (this) {
    UnitSystem.metric => 'Metric',
    UnitSystem.imperial => 'Imperial',
  };

  /// Analytics-friendly name.
  String get analyticsName => switch (this) {
    UnitSystem.metric => 'metric',
    UnitSystem.imperial => 'imperial',
  };
}
