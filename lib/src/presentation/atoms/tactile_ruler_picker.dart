import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Scrollable ruler picker that provides tactile feedback on major ticks.
/// Updated to be responsive and fit within compact vertical constraints.
class TactileRulerPicker extends StatefulWidget {
  /// Creates a tactile ruler.
  const TactileRulerPicker({
    required this.min,
    required this.max,
    required this.initialValue,
    required this.onChanged,
    this.unitLabel = '',
    this.step = 1,
    this.minorTicksPerMajor = 10,
    this.valueFormatter,
    this.showValueDisplay = true,
    this.fadeColor,
    super.key,
  });

  /// Minimum selectable value on the ruler.
  final double min;

  /// Maximum selectable value on the ruler.
  final double max;

  /// Initial value the ruler positions itself at.
  final double initialValue;

  /// Callback fired when the value changes.
  final ValueChanged<double> onChanged;

  /// Optional unit label displayed next to the value.
  final String unitLabel;

  /// Step size between ticks.
  final double step;

  /// Number of minor ticks to render between each major tick.
  final int minorTicksPerMajor;

  /// Optional formatter for customizing the displayed number.
  final String Function(double)? valueFormatter;

  /// Whether to render the large value display above the ruler.
  final bool showValueDisplay;

  /// Custom color for the edge fades (defaults to colors.bg).
  final Color? fadeColor;

  @override
  State<TactileRulerPicker> createState() => _TactileRulerPickerState();
}

class _TactileRulerPickerState extends State<TactileRulerPicker> {
  static const double _tickSpacing = 14;

  late final ScrollController _scrollController;
  late double _currentValue;
  double _lastFeedbackValue = -1;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.min, widget.max);
    final initialTickIndex = (_currentValue - widget.min) / widget.step;
    final initialOffset = initialTickIndex * _tickSpacing;
    _scrollController = ScrollController(initialScrollOffset: initialOffset)
      ..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    final tickIndex = offset / _tickSpacing;
    var newValue = widget.min + (tickIndex * widget.step);
    newValue = newValue.clamp(widget.min, widget.max);

    // Snap logic for display
    final snapped = (newValue / widget.step).round() * widget.step;

    if ((snapped - _currentValue).abs() > 0.001) {
      setState(() => _currentValue = snapped);
      widget.onChanged(snapped);

      if (snapped % 1 == 0 && snapped != _lastFeedbackValue) {
        unawaited(HapticFeedback.selectionClick());
        _lastFeedbackValue = snapped;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final tickCount = ((widget.max - widget.min) / widget.step).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        // If height is constrained, let the ruler fill the remainder.
        // Otherwise default to a compact fixed height.
        final isConstrained = constraints.maxHeight.isFinite;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showValueDisplay) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.valueFormatter != null
                        ? widget.valueFormatter!(_currentValue)
                        : _currentValue.toStringAsFixed(
                            widget.step < 1 ? 1 : 0,
                          ),
                    // Reduce font size slightly to fit compact layouts
                    style: typography.hero.copyWith(
                      fontSize: 48,
                      color: colors.ink,
                      letterSpacing: -2,
                      height: 1,
                    ),
                  ),
                  if (widget.unitLabel.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.unitLabel.toUpperCase(),
                      style: typography.button.copyWith(
                        color: colors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),

              // 2. Responsive Spacer
              // If constrained, use a smaller gap.
              SizedBox(height: isConstrained ? 12 : 32),
            ],

            // 3. The Ruler
            if (isConstrained)
              Expanded(
                child: _buildRuler(tickCount, colors),
              )
            else
              SizedBox(
                height: 100,
                child: _buildRuler(tickCount, colors),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRuler(int tickCount, AppColors colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Align tick centers under the center indicator.
        final centerPadding = (constraints.maxWidth / 2) - (_tickSpacing / 2);
        return Stack(
          alignment: Alignment.center,
          children: [
            ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: centerPadding),
              itemCount: tickCount + 1,
              itemBuilder: (context, index) {
                final hasMinor = widget.minorTicksPerMajor > 0;
                final isMajor =
                    hasMinor && index % widget.minorTicksPerMajor == 0;
                final half = hasMinor
                    ? (widget.minorTicksPerMajor / 2).round().clamp(
                        1,
                        widget.minorTicksPerMajor,
                      )
                    : 1;
                final isMedium = hasMinor && !isMajor && index % half == 0;

                // Adaptive tick heights based on available height
                final maxH = constraints.maxHeight;
                final height = isMajor
                    ? maxH * 0.6
                    : isMedium
                    ? maxH * 0.4
                    : maxH * 0.25;

                final width = isMajor ? 2.0 : 1.5;
                final color = isMajor
                    ? colors.ink
                    : colors.ink.withValues(alpha: 0.2);

                return Container(
                  width: _tickSpacing,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
            // Center Indicator
            Container(
              width: 4,
              height: constraints.maxHeight * 0.8,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            // Edge Fades
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.fadeColor ?? colors.bg,
                        (widget.fadeColor ?? colors.bg).withValues(alpha: 0),
                        (widget.fadeColor ?? colors.bg).withValues(alpha: 0),
                        widget.fadeColor ?? colors.bg,
                      ],
                      stops: const [0, 0.2, 0.8, 1],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
