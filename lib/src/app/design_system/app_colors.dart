import 'package:flutter/material.dart';

/// App design tokens (colors) exposed as a ThemeExtension.
/// Widgets MUST read from these tokens (no hard-coded hex in UI code).
///
/// Adheres to the "Matte Monolith" aesthetic (Obsidian & Steel).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates the token set with the provided colors.
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceHighlight, // NEW: For inputs/nested elements
    required this.surface2,
    required this.borderIdle, // NEW: Milled Steel Edge
    required this.borderActive, // NEW: Polished Silver Edge
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

  /// Primary surface used for cards (Matte Ceramic).
  final Color surface;

  /// NEW: Lighter ceramic surface for inputs or nested containers.
  final Color surfaceHighlight;

  /// Secondary surface (Legacy support).
  final Color surface2;

  /// NEW: Dark steel edge for inactive elements.
  final Color borderIdle;

  /// NEW: Polished silver edge for active/selected elements.
  final Color borderActive;

  /// Primary text/foreground color (Pure White).
  final Color ink;

  /// Secondary text color (Cool Grey/Argent).
  final Color inkSubtle;

  /// Primary CTA fill color (Brushed Steel).
  final Color accent;

  /// Muted version of the CTA color for pressed states.
  final Color accentMuted;

  /// Divider/chart track color (Dark Steel).
  final Color ringTrack;

  /// Legacy active ring color.
  final Color ringActive;

  /// Start color for the "White Hot" ring gradient.
  final Color ringActiveStart;

  /// End color for the "White Hot" ring gradient.
  final Color ringActiveEnd;

  /// Legacy Glass Fill. Remapped to Solid Surface in Monolith theme.
  final Color glassFill;

  /// Legacy Glass Border. Remapped to BorderIdle in Monolith theme.
  final Color glassBorder;

  /// Success color slot (Muted Green).
  final Color success;

  /// Warning color slot (Muted Amber).
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

  // ---- LIGHT (Placeholder - Mapped to dark until roadmap updates)
  /// Light palette.
  static const AppColors light = AppColors.dark;

  // ---- DARK (The "Obsidian & Steel" Palette)
  /// Dark palette (Deep Onyx & Steel).
  static const AppColors dark = AppColors(
    // Background: Deepest Onyx
    bg: Color(0xFF050505),

    // Surface: Matte Ceramic (Solid, No Blur)
    surface: Color(0xFF1C1C1E),
    surfaceHighlight: Color(0xFF2C2C2E), // Slightly lighter for inputs
    surface2: Color(0xFF2C2C2E), // Mapping legacy surface2 to highlight
    // Borders: Milled Steel
    borderIdle: Color(0xFF3A3A3C), // Dark Steel
    borderActive: Color(0xFFE5E5EA), // Polished Silver
    // Text: Pure White vs Cool Grey
    ink: Color(0xFFFFFFFF),
    inkSubtle: Color(0xFF8E8E93),

    // Accent: Brushed Steel
    accent: Color(0xFFE5E5EA), // Silver
    accentMuted: Color(0xFF636366),

    // Legacy Glass Remapping -> Solid Monolith
    // This ensures old glass widgets become solid matte widgets automatically.
    glassFill: Color(0xFF1C1C1E),
    glassBorder: Color(0xFF3A3A3C),

    // Rings
    ringTrack: Color(0xFF1C1C1E), // Blends with surface
    ringActive: Color(0xFFE5E5EA),
    ringActiveStart: Color(0xFFE5E5EA),
    ringActiveEnd: Color(0xFF636366),

    // Functional (Muted/Industrial)
    success: Color(0xFF30D158),
    warning: Color(0xFFFFD60A),
    danger: Color(0xFFFF453A),

    // Legacy / Specifics (Desaturated for stealth look)
    heroPositive: Color(0xFF1C1C1E),
    heroNeutral: Color(0xFFF2F2F2),
    heroChip: Color(0xFF2C2C2E), // Dark chip
    gaugeAccent: Color(0xFFE5E5EA),
    chartCalloutFill: Color(0xFFE5E5EA),
    chartCalloutText: Color(0xFF050505), // Black text on silver
    // Macros (Earthy/Metallic tones)
    macroCarbs: Color(0xFFA8A8A8), // Silver
    macroProtein: Color(0xFFD4C4A8), // Champagne
    macroFat: Color(0xFF5E5E5E), // Iron
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceHighlight,
    Color? surface2,
    Color? borderIdle,
    Color? borderActive,
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
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      surface2: surface2 ?? this.surface2,
      borderIdle: borderIdle ?? this.borderIdle,
      borderActive: borderActive ?? this.borderActive,
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
    final o = other;
    return AppColors(
      bg: Color.lerp(bg, o.bg, t)!,
      surface: Color.lerp(surface, o.surface, t)!,
      surfaceHighlight: Color.lerp(surfaceHighlight, o.surfaceHighlight, t)!,
      surface2: Color.lerp(surface2, o.surface2, t)!,
      borderIdle: Color.lerp(borderIdle, o.borderIdle, t)!,
      borderActive: Color.lerp(borderActive, o.borderActive, t)!,
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
