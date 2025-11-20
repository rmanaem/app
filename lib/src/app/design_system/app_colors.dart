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
    required this.success,
    required this.warning,
    required this.danger,
    required this.heroPositive,
    required this.heroNeutral,
    required this.heroChip,
    required this.gaugeAccent,
  });

  /// Page background.
  final Color bg;

  /// Primary surface used for cards and sheets.
  final Color surface;

  /// Secondary surface (inputs/chips).
  final Color surface2;

  /// Primary text/foreground color.
  final Color ink;

  /// Secondary text color.
  final Color inkSubtle;

  /// Primary CTA fill color.
  final Color accent;

  /// Muted version of the CTA color for pressed states.
  final Color accentMuted;

  /// Divider/chart track color.
  final Color ringTrack;

  /// Active chart stroke/highlight color.
  final Color ringActive;

  /// Success color slot (neutral by default).
  final Color success;

  /// Warning color slot (neutral by default).
  final Color warning;

  /// Danger color slot (neutral by default).
  final Color danger;

  /// Hero/card background emphasizing positive stats.
  final Color heroPositive;

  /// Hero/card background for neutral stats.
  final Color heroNeutral;

  /// Chip background used for pace indicators.
  final Color heroChip;

  /// Accent line/fill color for gauges.
  final Color gaugeAccent;

  // ---- LIGHT (strict black/white UI)
  /// Light palette (black on white).
  static const AppColors light = AppColors(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF2F2F2),
    ink: Color(0xFF000000),
    inkSubtle: Color(0xFF6B7280),
    accent: Color(0xFF000000), // CTAs = black on light
    accentMuted: Color(0xFF111111),
    ringTrack: Color(0xFFE5E7EB),
    ringActive: Color(0xFF000000), // charts draw in black
    success: Color(0xFF000000), // reserved (kept neutral)
    warning: Color(0xFF000000),
    danger: Color(0xFF000000),
    heroPositive: Color(0xFFE3F2FF),
    heroNeutral: Color(0xFFF2F2F2),
    heroChip: Color(0xFFE3F2FF),
    gaugeAccent: Color(0xFF3B82F6),
  );

  // ---- DARK (strict black/white UI)
  /// Dark palette (white on black).
  static const AppColors dark = AppColors(
    bg: Color(0xFF111315), // charcoal
    surface: Color(0xFF16181B),
    surface2: Color(0xFF1F2124),
    ink: Color(0xFFFFFFFF),
    inkSubtle: Color(0xFFA1A1AA),
    accent: Color(0xFFFFFFFF), // CTAs = white on dark
    accentMuted: Color(0xFFE5E5E5),
    ringTrack: Color(0xFF2B2D30),
    ringActive: Color(0xFFFFFFFF), // charts draw in white
    success: Color(0xFFFFFFFF),
    warning: Color(0xFFFFFFFF),
    danger: Color(0xFFFFFFFF),
    heroPositive: Color(0xFF103654),
    heroNeutral: Color(0xFF1F2023),
    heroChip: Color(0xFF103654),
    gaugeAccent: Color(0xFF3B82F6),
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
    Color? success,
    Color? warning,
    Color? danger,
    Color? heroPositive,
    Color? heroNeutral,
    Color? heroChip,
    Color? gaugeAccent,
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
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      heroPositive: heroPositive ?? this.heroPositive,
      heroNeutral: heroNeutral ?? this.heroNeutral,
      heroChip: heroChip ?? this.heroChip,
      gaugeAccent: gaugeAccent ?? this.gaugeAccent,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: lerpColor(bg, other.bg),
      surface: lerpColor(surface, other.surface),
      surface2: lerpColor(surface2, other.surface2),
      ink: lerpColor(ink, other.ink),
      inkSubtle: lerpColor(inkSubtle, other.inkSubtle),
      accent: lerpColor(accent, other.accent),
      accentMuted: lerpColor(accentMuted, other.accentMuted),
      ringTrack: lerpColor(ringTrack, other.ringTrack),
      ringActive: lerpColor(ringActive, other.ringActive),
      success: lerpColor(success, other.success),
      warning: lerpColor(warning, other.warning),
      danger: lerpColor(danger, other.danger),
      heroPositive: lerpColor(heroPositive, other.heroPositive),
      heroNeutral: lerpColor(heroNeutral, other.heroNeutral),
      heroChip: lerpColor(heroChip, other.heroChip),
      gaugeAccent: lerpColor(gaugeAccent, other.gaugeAccent),
    );
  }
}
