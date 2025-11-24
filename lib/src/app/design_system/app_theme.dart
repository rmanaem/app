import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Produces a Material 3 ThemeData from AppColors tokens.
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
        borderSide: BorderSide(color: tokens.accent),
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
          side: BorderSide(color: tokens.glassBorder),
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
