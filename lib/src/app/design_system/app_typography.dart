import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Typography tokens for the "Obsidian & Steel" design language.
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
      // HERO: Massive, Tight Spacing (e.g., "2,450")
      // Pure White for maximum punch.
      hero: TextStyle(
        fontSize: 48,
        height: 1,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: c.ink,
      ),
      // DISPLAY: Headlines (e.g., "Log Fast.")
      display: TextStyle(
        fontSize: 32,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: c.ink,
      ),
      // TITLE: Section headers (e.g., "Activity Level")
      title: TextStyle(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: c.ink,
      ),
      // BODY: Readable content
      body: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: c.ink,
      ),
      // CAPTION: Metadata / Labels
      // Cool Grey to recede.
      caption: TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: c.inkSubtle,
      ),
      // BUTTON: Action labels
      // High contrast: Black text on Silver buttons (Monolith style)
      button: TextStyle(
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: c.bg,
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
    final o = other;
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
