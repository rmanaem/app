import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Slide potentiometer inspired slider for premium control surfaces.
class FaderSlider extends StatelessWidget {
  /// Creates the fader slider.
  const FaderSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
    this.divisions,
  });

  /// Current slider value.
  final double value;

  /// Minimum slider value.
  final double min;

  /// Maximum slider value.
  final double max;

  /// Number of discrete steps, if provided.
  final int? divisions;

  /// Callback fired when the slider value changes.
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SliderTheme(
      data: SliderThemeData(
        // The Rail: Thin and subtle (2px)
        trackHeight: 2,
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.borderIdle,
        // The Thumb: Custom "Milled Fader" shape
        thumbShape: _FaderThumbShape(color: colors.ink),
        // Interaction Effects
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        overlayColor: colors.accent.withValues(alpha: 0.1),
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
        trackShape: _FaderTrackShape(),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

class _FaderThumbShape extends SliderComponentShape {
  const _FaderThumbShape({required this.color});

  final Color color;

  // Reduced width (24 -> 12) for a sleek, non-chunky look.
  // Kept height (32) for touch target accessibility.
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(12, 32);

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

    // Shadow for depth
    final shadowPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + const Offset(0, 2),
            width: 12,
            height: 32,
          ),
          const Radius.circular(2),
        ),
      );
    canvas.drawShadow(shadowPath, Colors.black, 3, true);

    // Main handle body
    final handle = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 12, height: 32),
      const Radius.circular(2),
    );

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(handle, fillPaint);

    // Grip line for a milled slot detail
    final linePaint = Paint()
      ..color = const Color(0xFF050505)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      center - const Offset(0, 4),
      center + const Offset(0, 4),
      linePaint,
    );
  }
}

class _FaderTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset offset = Offset.zero,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 2;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
