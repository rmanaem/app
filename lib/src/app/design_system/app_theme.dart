import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Produces a Material 3 ThemeData from AppColors tokens.
/// Ensures filled buttons have correct contrast:
///   • light: primary=black, onPrimary=white
///   • dark:  primary=white, onPrimary=black
ThemeData makeTheme(AppColors tokens, {required bool dark}) {
  final base = dark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);

  final colorScheme =
      (dark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
        primary: tokens.accent,
        onPrimary: dark ? Colors.black : Colors.white,
        secondary: tokens.accent,
        onSecondary: dark ? Colors.black : Colors.white,
        secondaryContainer: tokens.accent,
        onSecondaryContainer: dark ? Colors.black : Colors.white,
        surface: tokens.surface,
        surfaceTint: Colors.transparent,
        onSurface: tokens.ink,
        outline: tokens.ringTrack,
        error: tokens.danger,
        onError: dark ? Colors.black : Colors.white,
      );

  final textTheme = base.textTheme.apply(
    bodyColor: tokens.ink,
    displayColor: tokens.ink,
  );

  final type = AppTypography.from(tokens);
  const spacing = AppSpacing.base;

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tokens.bg,
    textTheme: textTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: tokens.bg,
      elevation: 0,
      iconTheme: IconThemeData(color: tokens.ink),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: tokens.ink,
        fontWeight: FontWeight.w700,
      ),
    ),

    cardTheme: CardThemeData(
      color: tokens.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    dividerTheme: DividerThemeData(
      color: tokens.ringTrack,
      thickness: 1,
      space: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: tokens.surface2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: tokens.surface2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: tokens.ink),
      ),
      labelStyle: TextStyle(color: tokens.inkSubtle),
      hintStyle: TextStyle(color: tokens.inkSubtle),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.accent,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(64, 52),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tokens.ink,
        side: BorderSide(color: tokens.ringTrack),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(64, 52),
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tokens.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Attach active tokens so widgets can read Theme.of(context).
    extensions: <ThemeExtension<dynamic>>[
      tokens,
      spacing,
      type,
    ],
  );
}
