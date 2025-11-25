import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// A premium slider with a thick track and polished thumb.
class PrecisionSlider extends StatelessWidget {
  /// Creates a new precision slider.
  const PrecisionSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    super.key,
  });

  /// Current slider value.
  final double value;

  /// Minimum value allowed.
  final double min;

  /// Maximum value allowed.
  final double max;

  /// Optional number of divisions for snapping.
  final int? divisions;

  /// Callback invoked whenever the slider changes.
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final theme = SliderTheme.of(context);
    return SliderTheme(
      data: theme.copyWith(
        trackHeight: 6,
        inactiveTrackColor: c.surfaceHighlight,
        activeTrackColor: c.accent,
        thumbColor: c.ink,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 14,
          elevation: 6,
          pressedElevation: 10,
        ),
        overlayColor: c.accent.withValues(alpha: 0.1),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 26),
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
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
