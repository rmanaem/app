Here is the integration guide for the **"Obsidian & Steel"** design system.

This guide updates your foundational tokens (`AppColors`, `AppTypography`, `AppTheme`) and refactors the `WelcomePage` to match the locked-in aesthetic.

**Note on Existing Tokens:** The existing code relies on specific fields (e.g., `macroCarbs`, `heroPositive`). I have preserved these fields to prevent compilation errors but re-mapped their values to the new Monochrome/Steel palette so the rest of the app immediately inherits the premium dark mode look.

### **Step 1: Update Color Tokens (`app_colors.dart`)**

We add the new "Glass" and "Ring" tokens while re-skinning the legacy tokens to fit the "Industrial Luxury" theme.

**File:** `lib/src/app/design_system/app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// App design tokens (colors) exposed as a ThemeExtension.
/// Widgets MUST read from these tokens (no hard-coded hex in UI code).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates the token set with the provided colors.
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.inkSubtle,
    required this.accent,
    required this.accentMuted,
    required this.ringTrack,
    required this.ringActive,
    required this.ringActiveStart,
    required this.ringActiveEnd,
    required this.glassFill,
    required this.glassBorder,
    required this.success,
    required this.warning,
    required this.danger,
    required this.heroPositive,
    required this.heroNeutral,
    required this.heroChip,
    required this.gaugeAccent,
    required this.chartCalloutFill,
    required this.chartCalloutText,
    required this.macroCarbs,
    required this.macroProtein,
    required this.macroFat,
  });

  /// Page background (Deep Onyx).
  final Color bg;

  /// Primary surface used for cards and sheets (Matte Dark Grey).
  final Color surface;

  /// Secondary surface (inputs/chips).
  final Color surface2;

  /// Primary text/foreground color (Argent).
  final Color ink;

  /// Secondary text color (Cool Grey).
  final Color inkSubtle;

  /// Primary CTA fill color (Brushed Steel).
  final Color accent;

  /// Muted version of the CTA color for pressed states.
  final Color accentMuted;

  /// Divider/chart track color (Dark Steel).
  final Color ringTrack;

  /// Legacy active ring color (kept for compatibility).
  final Color ringActive;

  /// Start color for the "White Hot" ring gradient.
  final Color ringActiveStart;

  /// End color for the "White Hot" ring gradient.
  final Color ringActiveEnd;

  /// "Dense Smoke" fill for glass cards (~80% opacity dark grey).
  final Color glassFill;

  /// Crisp steel edge for glass cards.
  final Color glassBorder;

  /// Success color slot (Muted Green/Grey).
  final Color success;

  /// Warning color slot (Amber/Grey).
  final Color warning;

  /// Danger color slot (Muted Red).
  final Color danger;

  /// Hero/card background emphasizing positive stats.
  final Color heroPositive;

  /// Hero/card background for neutral stats.
  final Color heroNeutral;

  /// Chip background used for pace indicators.
  final Color heroChip;

  /// Accent line/fill color for gauges.
  final Color gaugeAccent;

  /// Background for highlighted chart callouts.
  final Color chartCalloutFill;

  /// Text color rendered on top of chart callouts.
  final Color chartCalloutText;

  /// Macro color representing carbohydrates.
  final Color macroCarbs;

  /// Macro color representing protein.
  final Color macroProtein;

  /// Macro color representing fat.
  final Color macroFat;

  // ---- LIGHT (Placeholder - Mapped to dark for consistency until light mode design is locked)
  /// Light palette.
  static const AppColors light = AppColors.dark;

  // ---- DARK (The "Obsidian & Steel" Palette)
  /// Dark palette (Deep Onyx & Steel).
  static const AppColors dark = AppColors(
    // Background: Deepest Onyx (Not pure black, prevents smearing on OLED)
    bg: Color(0xFF050505),

    // Surface: Matte Dark Grey (for non-glass elements)
    surface: Color(0xFF121212),
    surface2: Color(0xFF1C1C1E),

    // Text: "Argent" (Silver-White) to reduce eye strain
    ink: Color(0xFFE5E5EA),
    inkSubtle: Color(0xFF8E8E93), // Cool Grey

    // Accent: Brushed Steel
    accent: Color(0xFFD1D1D6),
    accentMuted: Color(0xFF636366),

    // Glass: Dense, Tinted Privacy Glass (High Opacity)
    glassFill: Color(0xCC151517), // ~80% Opacity
    glassBorder: Color(0xFF3A3A3C), // Crisp Steel Edge

    // Rings: Brushed Steel Gradient
    ringTrack: Color(0xFF1C1C1E),
    ringActive: Color(0xFFE5E5EA),
    ringActiveStart: Color(0xFFE5E5EA), // Bright Silver
    ringActiveEnd: Color(0xFF636366), // Fades to Steel

    // Functional (Muted to maintain monochrome feel)
    success: Color(0xFF30D158), // Muted Green
    warning: Color(0xFFFFD60A), // Muted Amber
    danger: Color(0xFFFF453A), // Muted Red

    // Legacy Fields (Remapped to Monochrome/Industrial)
    heroPositive: Color(0xFF1C1C1E),
    heroNeutral: Color(0xFF1C1C1E),
    heroChip: Color(0xFF2C2C2E),
    gaugeAccent: Color(0xFFD1D1D6),
    chartCalloutFill: Color(0xFFD1D1D6),
    chartCalloutText: Color(0xFF000000),

    // Macros (Desaturated/Earthy to fit Industrial Vibe)
    macroCarbs: Color(0xFFA8A8A8), // Silver
    macroProtein: Color(0xFFD4C4A8), // Champagne Gold (Subtle)
    macroFat: Color(0xFF5E5E5E), // Dark Steel
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? ink,
    Color? inkSubtle,
    Color? accent,
    Color? accentMuted,
    Color? ringTrack,
    Color? ringActive,
    Color? ringActiveStart,
    Color? ringActiveEnd,
    Color? glassFill,
    Color? glassBorder,
    Color? success,
    Color? warning,
    Color? danger,
    Color? heroPositive,
    Color? heroNeutral,
    Color? heroChip,
    Color? gaugeAccent,
    Color? chartCalloutFill,
    Color? chartCalloutText,
    Color? macroCarbs,
    Color? macroProtein,
    Color? macroFat,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      ink: ink ?? this.ink,
      inkSubtle: inkSubtle ?? this.inkSubtle,
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      ringTrack: ringTrack ?? this.ringTrack,
      ringActive: ringActive ?? this.ringActive,
      ringActiveStart: ringActiveStart ?? this.ringActiveStart,
      ringActiveEnd: ringActiveEnd ?? this.ringActiveEnd,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      heroPositive: heroPositive ?? this.heroPositive,
      heroNeutral: heroNeutral ?? this.heroNeutral,
      heroChip: heroChip ?? this.heroChip,
      gaugeAccent: gaugeAccent ?? this.gaugeAccent,
      chartCalloutFill: chartCalloutFill ?? this.chartCalloutFill,
      chartCalloutText: chartCalloutText ?? this.chartCalloutText,
      macroCarbs: macroCarbs ?? this.macroCarbs,
      macroProtein: macroProtein ?? this.macroProtein,
      macroFat: macroFat ?? this.macroFat,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    final o = other as AppColors; // Cast for easier access
    return AppColors(
      bg: Color.lerp(bg, o.bg, t)!,
      surface: Color.lerp(surface, o.surface, t)!,
      surface2: Color.lerp(surface2, o.surface2, t)!,
      ink: Color.lerp(ink, o.ink, t)!,
      inkSubtle: Color.lerp(inkSubtle, o.inkSubtle, t)!,
      accent: Color.lerp(accent, o.accent, t)!,
      accentMuted: Color.lerp(accentMuted, o.accentMuted, t)!,
      ringTrack: Color.lerp(ringTrack, o.ringTrack, t)!,
      ringActive: Color.lerp(ringActive, o.ringActive, t)!,
      ringActiveStart: Color.lerp(ringActiveStart, o.ringActiveStart, t)!,
      ringActiveEnd: Color.lerp(ringActiveEnd, o.ringActiveEnd, t)!,
      glassFill: Color.lerp(glassFill, o.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, o.glassBorder, t)!,
      success: Color.lerp(success, o.success, t)!,
      warning: Color.lerp(warning, o.warning, t)!,
      danger: Color.lerp(danger, o.danger, t)!,
      heroPositive: Color.lerp(heroPositive, o.heroPositive, t)!,
      heroNeutral: Color.lerp(heroNeutral, o.heroNeutral, t)!,
      heroChip: Color.lerp(heroChip, o.heroChip, t)!,
      gaugeAccent: Color.lerp(gaugeAccent, o.gaugeAccent, t)!,
      chartCalloutFill: Color.lerp(chartCalloutFill, o.chartCalloutFill, t)!,
      chartCalloutText: Color.lerp(chartCalloutText, o.chartCalloutText, t)!,
      macroCarbs: Color.lerp(macroCarbs, o.macroCarbs, t)!,
      macroProtein: Color.lerp(macroProtein, o.macroProtein, t)!,
      macroFat: Color.lerp(macroFat, o.macroFat, t)!,
    );
  }
}
```

### **Step 2: Update Typography Tokens (`app_typography.dart`)**

We introduce the `hero` style for massive numbers and adjust the `display` style to be bold and condensed for that "Industrial" look.

**File:** `lib/src/app/design_system/app_typography.dart`

```dart
import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Typography tokens.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  /// Constructs the typography set.
  const AppTypography({
    required this.hero,
    required this.display,
    required this.title,
    required this.body,
    required this.caption,
    required this.button,
  });

  /// Generates typography styles tied to the provided color tokens.
  factory AppTypography.from(AppColors c) {
    // Note: In a real app, apply GoogleFonts or custom assets here.
    // e.g., SF Pro Rounded or JetBrains Mono.
    return AppTypography(
      // HERO: Massive, Tight Spacing (for "2,450" kcal)
      hero: TextStyle(
        fontSize: 48,
        height: 1.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: c.ink,
      ),
      // DISPLAY: For headlines "Log Fast. Train Smart."
      display: TextStyle(
        fontSize: 32,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: c.ink,
      ),
      // TITLE: Section headers
      title: TextStyle(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: c.ink,
      ),
      // BODY: Primary readable text
      body: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: c.ink,
      ),
      // CAPTION: Secondary meta data
      caption: TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: c.inkSubtle,
      ),
      // BUTTON: Action labels
      button: TextStyle(
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: c.ink, // Silver text on buttons
      ),
    );
  }

  /// Massive hero style for data.
  final TextStyle hero;

  /// Large header style.
  final TextStyle display;

  /// Section title style.
  final TextStyle title;

  /// Primary body copy style.
  final TextStyle body;

  /// Caption/meta style.
  final TextStyle caption;

  /// Button label style.
  final TextStyle button;

  @override
  AppTypography copyWith({
    TextStyle? hero,
    TextStyle? display,
    TextStyle? title,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? button,
  }) {
    return AppTypography(
      hero: hero ?? this.hero,
      display: display ?? this.display,
      title: title ?? this.title,
      body: body ?? this.body,
      caption: caption ?? this.caption,
      button: button ?? this.button,
    );
  }

  @override
  ThemeExtension<AppTypography> lerp(
    ThemeExtension<AppTypography>? other,
    double t,
  ) {
    if (other is! AppTypography) return this;
    final o = other as AppTypography;
    return AppTypography(
      hero: TextStyle.lerp(hero, o.hero, t)!,
      display: TextStyle.lerp(display, o.display, t)!,
      title: TextStyle.lerp(title, o.title, t)!,
      body: TextStyle.lerp(body, o.body, t)!,
      caption: TextStyle.lerp(caption, o.caption, t)!,
      button: TextStyle.lerp(button, o.button, t)!,
    );
  }
}
```

### **Step 3: Update Theme Configuration (`app_theme.dart`)**

Wire the new tokens into the Material `ThemeData`. This ensures `Scaffold`, `Input`, and `Button` widgets use our new "Onyx & Steel" values by default.

**File:** `lib/src/app/design_system/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Produces a Material 3 ThemeData from AppColors tokens.
ThemeData makeTheme(AppColors tokens, {required bool dark}) {
  final base = dark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);

  // Force the industrial color scheme
  final colorScheme =
      (dark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
    primary: tokens.accent,
    onPrimary: tokens.bg, // Black text on Silver button
    secondary: tokens.accent,
    surface: tokens.surface,
    onSurface: tokens.ink,
    outline: tokens.glassBorder,
    error: tokens.danger,
  );

  final type = AppTypography.from(tokens);
  const spacing = AppSpacing.base;

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tokens.bg,
    textTheme: base.textTheme.apply(
      bodyColor: tokens.ink,
      displayColor: tokens.ink,
    ),

    // AppBar: Blend into background
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.bg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: tokens.ink),
      titleTextStyle: type.title,
    ),

    // Card: Use Surface color by default (GlassCard used explicitly elsewhere)
    cardTheme: CardThemeData(
      color: tokens.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: tokens.glassBorder, width: 0.5),
      ),
    ),

    // Input: Industrial Field
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surface2,
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: tokens.glassBorder, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: tokens.accent, width: 1),
      ),
      labelStyle: type.caption,
      hintStyle: type.caption.copyWith(color: tokens.inkSubtle),
    ),

    // Filled Button: Brushed Steel Pill
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.glassFill, // Dense Smoke
        foregroundColor: tokens.ink, // Silver Text
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: spacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100), // Stadium
          side: BorderSide(color: tokens.glassBorder, width: 1),
        ),
        minimumSize: const Size.fromHeight(56), // Tall tap target
        textStyle: type.button,
      ),
    ),

    // Outlined Button: Faint Steel Border
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tokens.inkSubtle,
        side: BorderSide(color: tokens.glassBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        minimumSize: const Size.fromHeight(56),
        textStyle: type.button,
      ),
    ),

    // Extensions
    extensions: <ThemeExtension<dynamic>>[
      tokens,
      spacing,
      type,
    ],
  );
}
```

### **Step 4: Create the Glass Button Atom (`glass_button.dart`)**

This reusable widget implements the "Dense Smoke" physics we defined.

**File:** `lib/src/presentation/atoms/glass_button.dart`

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// A button with the "Dense Smoke" industrial aesthetic.
/// Features a backdrop blur, semi-transparent fill, and crisp steel border.
class GlassButton extends StatelessWidget {
  /// Creates a GlassButton.
  const GlassButton({
    required this.label,
    required this.onTap,
    super.key,
  });

  /// The text displayed on the button.
  final String label;

  /// Callback when tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(100), // Stadium Shape
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Heavy Blur
        child: Container(
          height: 64, // Tall, touchable target
          decoration: BoxDecoration(
            color: colors.glassFill, // Dense Smoke
            border: Border.all(
              color: colors.glassBorder,
              width: 1,
            ), // Steel Edge
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              // Subtle Steel Highlight
              splashColor: colors.accent.withOpacity(0.1),
              highlightColor: colors.accent.withOpacity(0.05),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.ink, // Silver Text
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### **Step 5: Update the Welcome Page (`welcome_page.dart`)**

Apply the "Cinematic" layout using the new typography and the `GlassButton`.

**File:** `lib/src/features/onboarding/presentation/pages/welcome_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/presentation/atoms/glass_button.dart';

/// Welcome / Auth landing page.
/// Updated to "Obsidian & Steel" aesthetic.
class WelcomePage extends StatelessWidget {
  /// Creates the welcome page with navigation callbacks.
  const WelcomePage({
    required this.onGetStarted,
    required this.onLogIn,
    this.appName = 'Your App', // Kept for compatibility
    this.tagline = 'The premium tracker for\nserious progress.',
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
      body: Stack(
        children: [
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

                  // Brand Mark Placeholder
                  // Ideally replace with a white/silver SVG logo
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: FlutterLogo(size: 48),
                  ),

                  SizedBox(height: s.lg),

                  // Industrial Typography Headline
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

                  // Tagline
                  Text(
                    tagline,
                    textAlign: TextAlign.left,
                    style: t.body.copyWith(
                      fontSize: 18,
                      color: c.inkSubtle,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Primary CTA (Glass Button)
                  GlassButton(
                    label: 'GET STARTED',
                    onTap: onGetStarted,
                  ),

                  SizedBox(height: s.md),

                  // Secondary CTA
                  TextButton(
                    onPressed: onLogIn,
                    child: Text(
                      'Log In',
                      style: t.button.copyWith(
                        color: c.inkSubtle,
                      ),
                    ),
                  ),

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
```