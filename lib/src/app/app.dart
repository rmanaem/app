import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/presentation/pages/auth/welcome_page.dart';

/// Root widget for the template application, wired with [GoRouter].
class App extends StatelessWidget {
  /// Creates the template app for the provided [envName].
  const App({required this.envName, super.key});

  /// Name of the environment currently running (e.g. dev/prod).
  final String envName;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App',
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => WelcomePage(
              onGetStarted: () {},
              onLogIn: () {},
            ),
          ),
        ],
      ),
      theme: makeTheme(AppColors.light, dark: false),
      darkTheme: makeTheme(AppColors.dark, dark: true),
    );
  }
}
