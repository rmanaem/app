import 'package:flutter/material.dart';

/// Spacing tokens — used everywhere instead of magic numbers.
/// Scale (dp): 4, 8, 12, 16, 24, 32. Includes page gutters.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  /// Creates the spacing scale.
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.quad,
    required this.quint,
    required this.gutter,
  });

  /// Extra small spacing (4dp).
  final double xs;

  /// Small spacing (8dp).
  final double sm;

  /// Medium spacing (12dp).
  final double md;

  /// Large spacing (16dp).
  final double lg;

  /// Extra-large spacing (24dp).
  final double xl;

  /// Double extra-large spacing (32dp).
  final double xxl;

  /// Triple extra-large spacing (48dp).
  final double xxxl;

  /// Quadruple extra-large spacing (64dp).
  final double quad;

  /// Quintuple extra-large spacing (80dp).
  final double quint;

  /// Horizontal page gutter spacing.
  final double gutter;

  /// Default spacing scale used across the app.
  static const AppSpacing base = AppSpacing(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
    xxxl: 48,
    quad: 64,
    quint: 80,
    gutter: 24,
  );

  /// Convenience helper for all-side padding.
  EdgeInsets edgeAll(double v) => EdgeInsets.all(v);

  /// Convenience helper for horizontal padding.
  EdgeInsets edgeH(double v) => EdgeInsets.symmetric(horizontal: v);

  /// Convenience helper for vertical padding.
  EdgeInsets edgeV(double v) => EdgeInsets.symmetric(vertical: v);

  @override
  /// Returns a copy with selectively overridden values.
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? quad,
    double? quint,
    double? gutter,
  }) => AppSpacing(
    xs: xs ?? this.xs,
    sm: sm ?? this.sm,
    md: md ?? this.md,
    lg: lg ?? this.lg,
    xl: xl ?? this.xl,
    xxl: xxl ?? this.xxl,
    xxxl: xxxl ?? this.xxxl,
    quad: quad ?? this.quad,
    quint: quint ?? this.quint,
    gutter: gutter ?? this.gutter,
  );

  @override
  ThemeExtension<AppSpacing> lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    double l(double a, double b) => a + (b - a) * t;
    return AppSpacing(
      xs: l(xs, other.xs),
      sm: l(sm, other.sm),
      md: l(md, other.md),
      lg: l(lg, other.lg),
      xl: l(xl, other.xl),
      xxl: l(xxl, other.xxl),
      xxxl: l(xxxl, other.xxxl),
      quad: l(quad, other.quad),
      quint: l(quint, other.quint),
      gutter: l(gutter, other.gutter),
    );
  }
}
