import 'package:flutter/material.dart';
import 'package:starter_app/firebase_options_dev.dart' as firebase_dev_options;
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/bootstrap/bootstrap.dart';
import 'package:starter_app/src/config/env.dart';
import 'package:starter_app/src/features/auth/presentation/pages/auth_preview_page.dart';

/// Standalone entrypoint to preview auth CTAs without touching onboarding/today.
Future<void> main() async {
  await bootstrap(
    () async => const _AuthPreviewApp(),
    env: Env.dev,
    firebaseOptions:
        firebase_dev_options.DefaultFirebaseOptions.currentPlatform,
  );
}

class _AuthPreviewApp extends StatelessWidget {
  const _AuthPreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Preview',
      theme: makeTheme(AppColors.light, dark: false),
      darkTheme: makeTheme(AppColors.dark, dark: true),
      themeMode: ThemeMode.dark,
      home: const AuthPreviewPage(),
    );
  }
}
