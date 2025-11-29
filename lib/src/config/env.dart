/// Supported runtime environments for the template.
enum Env {
  /// Local or internal development environment.
  dev('dev', 'test_IOZA0PfyiFLiqipCLJypWnCMPw'),

  /// Production environment used for shipping builds.
  prod('prod', 'test_IOZA0PfyiFLiqipCLJypWnCMPw')
  ;

  const Env(this.displayName, this.revenuecatPublicSdkKey);

  /// Human-readable name for the environment.
  final String displayName;

  /// RevenueCat public SDK key associated with the environment.
  final String revenuecatPublicSdkKey;
}
