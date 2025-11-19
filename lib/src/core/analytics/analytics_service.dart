/// Contract for capturing analytics events emitted from the presentation layer.
abstract class AnalyticsService {
  /// Logs an impression for the onboarding goal screen.
  Future<void> onboardingGoalImpression();

  /// Logs the specific goal the user selected while onboarding.
  Future<void> onboardingGoalSelected(String goal);

  /// Logs that the user tapped the next CTA from the goal step.
  Future<void> onboardingGoalNext(String goal);
}
