/// Contract for capturing analytics events emitted from the presentation layer.
abstract class AnalyticsService {
  /// Logs an impression for the onboarding goal screen.
  Future<void> onboardingGoalImpression();

  /// Logs the specific goal the user selected while onboarding.
  Future<void> onboardingGoalSelected(String goal);

  /// Logs that the user tapped the next CTA from the goal step.
  Future<void> onboardingGoalNext(String goal);

  /// Logs an impression for the onboarding stats screen.
  Future<void> onboardingStatsImpression();

  /// Logs when the user switches unit systems on the stats screen.
  Future<void> onboardingStatsUnitChanged(String unitSystem);

  /// Logs when the user proceeds from the stats screen.
  Future<void> onboardingStatsNext({
    required String unitSystem,
    required String activity,
  });
}
