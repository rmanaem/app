/// Supported runtime environments for the template.
enum Env {
  /// Local or internal development environment.
  dev('dev', 'rc_public_sdk_key_dev'),

  /// Production environment used for shipping builds.
  prod('prod', 'rc_public_sdk_key_prod')
  ;

  const Env(this.displayName, this.revenuecatPublicSdkKey);

  /// Human-readable name for the environment.
  final String displayName;

  /// RevenueCat public SDK key associated with the environment.
  final String revenuecatPublicSdkKey;
}
