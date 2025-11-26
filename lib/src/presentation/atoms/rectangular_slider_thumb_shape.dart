import 'package:flutter/material.dart';

/// Rectangular slider thumb resembling a mixing-console fader.
class RectangularSliderThumbShape extends SliderComponentShape {
  /// Creates a rectangular slider thumb with configurable dimensions.
  const RectangularSliderThumbShape({
    this.width = 12.0,
    this.height = 24.0,
    this.borderRadius = 4.0,
  });

  /// Width of the thumb.
  final double width;

  /// Height of the thumb.
  final double height;

  /// Corner radius applied to the thumb body.
  final double borderRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      Radius.circular(borderRadius),
    );

    canvas
      ..drawRRect(rRect, fillPaint)
      ..drawRRect(rRect, borderPaint);
  }
}
