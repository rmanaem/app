import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Hero marketing page presented before onboarding.
/// Design: "The Monolith Launchpad"
class WelcomePage extends StatelessWidget {
  /// Creates the welcome page.
  const WelcomePage({
    required this.onGetStarted,
    required this.onLogIn,
    this.appName = 'OBSIDIAN',
    this.tagline = 'The premium tracker for\nserious progress.',
    this.showLegal = true,
    super.key,
  });

  /// Callback executed when the user taps the primary CTA.
  final VoidCallback onGetStarted;

  /// Callback executed when the user taps "Log In".
  final VoidCallback onLogIn;

  /// Display name for branding.
  final String appName;

  /// Supporting marketing copy below the headline.
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
      body: Stack(
        children: [
          Positioned(
            top: -200,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    c.accent.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  _BrandSymbol(appName: appName),
                  SizedBox(height: s.xl),
                  Text(
                    'LOG FAST.\nTRAIN SMART.',
                    style: t.display.copyWith(
                      fontSize: 56,
                      height: 0.9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      color: c.ink,
                    ),
                  ),
                  SizedBox(height: s.lg),
                  Text(
                    tagline,
                    style: t.body.copyWith(
                      fontSize: 18,
                      color: c.inkSubtle,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(flex: 2),
                  AppButton(
                    label: 'GET STARTED',
                    onTap: onGetStarted,
                    isPrimary: true,
                  ),
                  SizedBox(height: s.md),
                  AppButton(
                    label: 'LOG IN',
                    onTap: onLogIn,
                  ),
                  SizedBox(height: s.xl),
                  if (showLegal) const _LegalNotice(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandSymbol extends StatelessWidget {
  const _BrandSymbol({required this.appName});

  final String appName;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Semantics(
      label: appName,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.borderIdle),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.bolt_rounded,
          size: 40,
          color: c.accent,
        ),
      ),
    );
  }
}

class _LegalNotice extends StatelessWidget {
  const _LegalNotice();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final t = Theme.of(context).extension<AppTypography>()!;
    final linkStyle = t.caption.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: c.accent,
      color: c.accent,
      fontWeight: FontWeight.w600,
    );

    final textStyle = t.caption.copyWith(
      color: c.inkSubtle.withValues(alpha: 0.8),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: Text.rich(
          TextSpan(
            text: 'By continuing, you agree to our ',
            style: textStyle,
            children: [
              TextSpan(text: 'Terms of Service', style: linkStyle),
              TextSpan(text: ', ', style: textStyle),
              TextSpan(text: 'Privacy Policy', style: linkStyle),
              TextSpan(text: ' and ', style: textStyle),
              TextSpan(
                text: 'Consumer Health Privacy Policy',
                style: linkStyle,
              ),
              TextSpan(text: '.', style: textStyle),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
