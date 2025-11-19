import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:starter_app/src/core/analytics/analytics_service.dart';

/// Firebase-backed implementation of [AnalyticsService].
class FirebaseAnalyticsService implements AnalyticsService {
  /// Creates the service with the provided [FirebaseAnalytics] instance.
  FirebaseAnalyticsService(this._analytics);

  /// Analytics client used to record events.
  final FirebaseAnalytics _analytics;

  @override
  Future<void> onboardingGoalImpression() {
    return _analytics.logEvent(name: 'onboarding_goal_impression');
  }

  @override
  Future<void> onboardingGoalNext(String goal) {
    return _analytics.logEvent(
      name: 'onboarding_goal_next',
      parameters: {'goal': goal},
    );
  }

  @override
  Future<void> onboardingGoalSelected(String goal) {
    return _analytics.logEvent(
      name: 'onboarding_goal_selected',
      parameters: {'goal': goal},
    );
  }
}
