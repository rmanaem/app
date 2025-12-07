import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_layout.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Produces a Material 3 ThemeData from AppColors tokens.
/// Enforces the "Matte Monolith" aesthetic (Obsidian & Steel).
ThemeData makeTheme(AppColors tokens, {required bool dark}) {
  final base = dark ? ThemeData.dark() : ThemeData.light();

  // Force the industrial color scheme
  final colorScheme =
      (dark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
        primary: tokens.accent,
        onPrimary: tokens.bg, // Black text on Silver button
        secondary: tokens.accent,
        surface: tokens.surface,
        onSurface: tokens.ink,
        outline: tokens.borderIdle,
        error: tokens.danger,
      );

  final type = AppTypography.from(tokens);
  const spacing = AppSpacing.base;
  const layout = AppLayout.base;

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tokens.bg,
    textTheme: base.textTheme.apply(
      bodyColor: tokens.ink,
      displayColor: tokens.ink,
    ),

    // AppBar: Blend into background (Seamless)
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.bg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: tokens.ink),
      titleTextStyle: type.title,
    ),

    // Card: "Matte Ceramic"
    // Solid fill, milled steel border.
    cardTheme: CardThemeData(
      color: tokens.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: tokens.borderIdle),
      ),
    ),

    // Input: "Stealth Field"
    // Uses lighter ceramic highlight to recede into surface.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surfaceHighlight,
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
        borderSide: BorderSide(color: tokens.borderIdle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: tokens.borderActive),
      ),
      labelStyle: type.caption,
      hintStyle: type.caption.copyWith(color: tokens.inkSubtle),
    ),

    // Filled Button: "Polished Steel Pill"
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.accent, // Polished Silver
        foregroundColor: tokens.bg, // Black Text
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: spacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        minimumSize: const Size.fromHeight(56),
        textStyle: type.button,
      ),
    ),

    // Outlined Button: "Milled Edge"
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tokens.ink, // White text
        side: BorderSide(color: tokens.borderIdle), // Steel border
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
      layout,
    ],
  );
}
