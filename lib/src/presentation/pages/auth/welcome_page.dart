import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Welcome / Auth landing page.
/// - Minimal look inspired by black/white design.
/// - Placeholder Flutter logo used until brand asset is ready.
/// - Two primary actions: Get Started (onboarding) and Log In.
class WelcomePage extends StatelessWidget {
  /// Creates the welcome page with navigation callbacks.
  const WelcomePage({
    required this.onGetStarted,
    required this.onLogIn,
    this.appName = 'Your App',
    this.tagline = 'Log fast. Train smart. See progress.',
    this.showLegal = true,
    super.key,
  });

  /// Invoked when the user taps "Get Started".
  final VoidCallback onGetStarted;

  /// Invoked when the user taps "Log In".
  final VoidCallback onLogIn;

  /// Name of the product displayed in the headline.
  final String appName;

  /// Supporting copy below the headline.
  final String tagline;

  /// Whether to render the legal notice.
  final bool showLegal;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final s = Theme.of(context).extension<AppSpacing>()!;
    final t = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s.gutter),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Placeholder brand mark
                      const FlutterLogo(size: 96),

                      SizedBox(height: s.lg),

                      // Headline
                      Text(
                        'Welcome to $appName',
                        textAlign: TextAlign.center,
                        style: t.display,
                      ),

                      SizedBox(height: s.sm),

                      // Tagline
                      Text(
                        tagline,
                        textAlign: TextAlign.center,
                        style: t.body.copyWith(color: c.inkSubtle),
                      ),

                      SizedBox(height: s.xl),

                      // Primary CTA
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: onGetStarted,
                          child: const Text('Get Started'),
                        ),
                      ),
                      SizedBox(height: s.sm),

                      // Secondary CTA
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: onLogIn,
                          child: const Text('Log In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (showLegal) ...[
                SizedBox(height: s.md),
                _LegalNotice(),
              ],

              SizedBox(height: s.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final s = Theme.of(context).extension<AppSpacing>()!;
    final t = Theme.of(context).extension<AppTypography>()!;

    final link = t.caption.copyWith(
      decoration: TextDecoration.underline,
      color: c.ink,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: s.xs),
      child: Text.rich(
        TextSpan(
          text: 'By continuing, you agree to our ',
          style: t.caption,
          children: [
            TextSpan(text: 'Terms of Service', style: link),
            const TextSpan(text: ', '),
            TextSpan(text: 'Privacy Policy', style: link),
            const TextSpan(text: ' and '),
            TextSpan(text: 'Consumer Health Privacy Policy', style: link),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
