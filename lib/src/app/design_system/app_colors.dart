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

  // ---- LIGHT (Placeholder - Mapped to dark for consistency until
  // light mode design is locked)
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
    heroNeutral: Color(0xFFF2F2F2),
    heroChip: Color(0xFFE3F2FF),
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
    final o = other; // Cast for easier access
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
