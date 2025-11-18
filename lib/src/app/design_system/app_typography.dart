import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Typography tokens. We generate styles from colors so they track light/dark.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  /// Constructs the typography set.
  const AppTypography({
    required this.display,
    required this.title,
    required this.body,
    required this.caption,
    required this.button,
  });

  /// Generates typography styles tied to the provided color tokens.
  factory AppTypography.from(AppColors c) {
    return AppTypography(
      display: TextStyle(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: c.ink,
      ),
      title: TextStyle(
        fontSize: 20,
        height: 1.20,
        fontWeight: FontWeight.w700,
        color: c.ink,
      ),
      body: TextStyle(
        fontSize: 16,
        height: 1.40,
        fontWeight: FontWeight.w400,
        color: c.ink,
      ),
      caption: TextStyle(
        fontSize: 13,
        height: 1.30,
        fontWeight: FontWeight.w600,
        color: c.inkSubtle,
      ),
      button: TextStyle(
        fontSize: 16,
        height: 1.20,
        fontWeight: FontWeight.w700,
        color: c.ink,
      ),
    );
  }

  /// Large hero/header style.
  final TextStyle display;

  /// Section/page title style.
  final TextStyle title;

  /// Primary body copy style.
  final TextStyle body;

  /// Caption/meta style.
  final TextStyle caption;

  /// Button label style.
  final TextStyle button;

  /// Returns a copy with selectively overridden text styles.
  @override
  AppTypography copyWith({
    TextStyle? display,
    TextStyle? title,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? button,
  }) => AppTypography(
    display: display ?? this.display,
    title: title ?? this.title,
    body: body ?? this.body,
    caption: caption ?? this.caption,
    button: button ?? this.button,
  );

  @override
  ThemeExtension<AppTypography> lerp(
    ThemeExtension<AppTypography>? other,
    double t,
  ) {
    if (other is! AppTypography) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppTypography(
      display: l(display, other.display),
      title: l(title, other.title),
      body: l(body, other.body),
      caption: l(caption, other.caption),
      button: l(button, other.button),
    );
  }
}
