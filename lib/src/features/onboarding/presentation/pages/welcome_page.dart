import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/presentation/atoms/glass_button.dart';

/// Hero marketing page presented before onboarding.
class WelcomePage extends StatelessWidget {
  /// Creates the welcome page.
  const WelcomePage({
    required this.onGetStarted,
    required this.onLogIn,
    this.appName = 'Your App',
    this.tagline = 'The premium tracker for\nserious progress.',
    this.showLegal = true,
    super.key,
  });

  /// Callback for the “Enter” CTA.
  final VoidCallback onGetStarted;

  /// Callback for the “Log In” button.
  final VoidCallback onLogIn;

  /// Display name of the product/brand.
  final String appName;

  /// Supporting marketing copy.
  final String tagline;

  /// Whether to show the legal disclaimer row.
  final bool showLegal;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final s = Theme.of(context).extension<AppSpacing>()!;
    final t = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // 1. TOP ATMOSPHERE
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // 2. BOTTOM STAGE LIGHT (THE FIX)
          // This subtle glow gives the glass buttons something to refract.
          Positioned(
            bottom: -200,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 600,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.ink.withValues(alpha: 0.08), // Faint silver glow
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: s.gutter,
                vertical: s.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // Brand Mark
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Semantics(
                      label: appName,
                      child: const FlutterLogo(size: 48),
                    ),
                  ),

                  SizedBox(height: s.lg),

                  // Massive Headline
                  Text(
                    'LOG FAST.\nTRAIN SMART.',
                    style: t.display.copyWith(
                      fontSize: 56,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),

                  SizedBox(height: s.md),

                  // Subheadline
                  Text(
                    tagline,
                    textAlign: TextAlign.left,
                    style: t.body.copyWith(
                      fontSize: 18,
                      color: c.inkSubtle,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Primary Action (Brushed Steel Look)
                  GlassButton(
                    label: 'ENTER',
                    onTap: onGetStarted,
                    isPrimary: true, // Triggers the brighter style
                  ),

                  SizedBox(height: s.md),

                  // Secondary Action
                  TextButton(
                    onPressed: onLogIn,
                    child: Text(
                      'Log In',
                      style: t.button.copyWith(
                        color: c.inkSubtle,
                      ),
                    ),
                  ),

                  SizedBox(height: s.xl),

                  if (showLegal) ...[
                    const Spacer(),
                    _LegalNotice(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final t = Theme.of(context).extension<AppTypography>()!;
    final link = t.caption.copyWith(
      decoration: TextDecoration.underline,
      color: c.ink,
    );
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: t.caption,
        children: [
          TextSpan(text: 'Terms', style: link),
          const TextSpan(text: ' & '),
          TextSpan(text: 'Privacy Policy', style: link),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
