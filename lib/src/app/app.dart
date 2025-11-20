import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/core/analytics/analytics_service.dart';
import 'package:starter_app/src/core/analytics/firebase_analytics_service.dart';
import 'package:starter_app/src/features/onboarding/domain/repositories/plan_repository.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/infrastructure/memory_plan_repository.dart';
import 'package:starter_app/src/features/onboarding/presentation/navigation/onboarding_summary_arguments.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/goal_configuration_page.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/onboarding_goal_page.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/onboarding_stats_page.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/onboarding_summary_page.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/presentation/pages/auth/welcome_page.dart';

/// Root widget for the template application, wired with [GoRouter].
class App extends StatelessWidget {
  /// Creates the template app for the provided [envName].
  const App({required this.envName, super.key});

  /// Name of the environment currently running (e.g. dev/prod).
  final String envName;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => WelcomePage(
            onGetStarted: () => context.push('/onboarding/goal'),
            onLogIn: () {},
          ),
        ),
        GoRoute(
          path: '/onboarding/goal',
          builder: (context, state) => const OnboardingGoalPage(),
        ),
        GoRoute(
          path: '/onboarding/stats',
          builder: (context, state) {
            final goal = state.extra is Goal ? state.extra! as Goal : null;
            return OnboardingStatsPage(initialGoal: goal);
          },
        ),
        GoRoute(
          path: '/onboarding/goal-configuration',
          builder: (context, state) => const GoalConfigurationPage(),
        ),
        GoRoute(
          path: '/onboarding/summary',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is! OnboardingSummaryArguments) {
              throw StateError(
                'OnboardingSummaryPage requires OnboardingSummaryArguments.',
              );
            }
            return OnboardingSummaryPage(args: extra);
          },
        ),
      ],
    );

    return MultiProvider(
      providers: [
        Provider<AnalyticsService>(
          create: (_) => FirebaseAnalyticsService(FirebaseAnalytics.instance),
        ),
        Provider<PlanRepository>(
          create: (_) => const MemoryPlanRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) => OnboardingVm(context.read<AnalyticsService>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'App',
        routerConfig: router,
        theme: makeTheme(AppColors.light, dark: false),
        darkTheme: makeTheme(AppColors.dark, dark: true),
        themeMode: ThemeMode.dark,
      ),
    );
  }
}
