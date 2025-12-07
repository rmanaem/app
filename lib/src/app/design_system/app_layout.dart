import 'package:flutter/material.dart';

/// Layout metrics and sizing tokens (borders, radii, etc).
/// Central source of truth for physical dimensions.
@immutable
class AppLayout extends ThemeExtension<AppLayout> {
  /// Create the layout values.
  const AppLayout({
    required this.strokeXs,
    required this.strokeSm,
    required this.strokeMd,
    required this.strokeLg,
  });

  /// 0.5 - Hairline
  final double strokeXs;

  /// 1.0 - Default/Thin
  final double strokeSm;

  /// 1.5 - Medium/Button
  final double strokeMd;

  /// 2.0 - Thick/Active
  final double strokeLg;

  /// Default base setup.
  static const AppLayout base = AppLayout(
    strokeXs: 0.5,
    strokeSm: 1,
    strokeMd: 1.5,
    strokeLg: 2,
  );

  @override
  AppLayout copyWith({
    double? strokeXs,
    double? strokeSm,
    double? strokeMd,
    double? strokeLg,
  }) {
    return AppLayout(
      strokeXs: strokeXs ?? this.strokeXs,
      strokeSm: strokeSm ?? this.strokeSm,
      strokeMd: strokeMd ?? this.strokeMd,
      strokeLg: strokeLg ?? this.strokeLg,
    );
  }

  @override
  ThemeExtension<AppLayout> lerp(ThemeExtension<AppLayout>? other, double t) {
    if (other is! AppLayout) return this;
    double l(double a, double b) => a + (b - a) * t;
    return AppLayout(
      strokeXs: l(strokeXs, other.strokeXs),
      strokeSm: l(strokeSm, other.strokeSm),
      strokeMd: l(strokeMd, other.strokeMd),
      strokeLg: l(strokeLg, other.strokeLg),
    );
  }
}
