import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Scrollable ruler picker that provides tactile feedback on major ticks.
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
    super.key,
  });

  /// Minimum selectable value.
  final double min;

  /// Maximum selectable value.
  final double max;

  /// Initial value to snap the ruler to.
  final double initialValue;

  /// Callback invoked when the ruler scroll position changes.
  final ValueChanged<double> onChanged;

  /// Unit label displayed beneath the value.
  final String unitLabel;

  /// Increment between ticks.
  final double step;

  /// Number of minor ticks before a major tick is drawn.
  final int minorTicksPerMajor;

  /// Optional formatter for the displayed value.
  final String Function(double)? valueFormatter;

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
    _currentValue = widget.initialValue.clamp(
      widget.min,
      widget.max,
    );
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

      // HAPTIC FIX: Only vibrate on integer steps to avoid "buzzing"
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
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : null;
        const valueHeight = 72.0;
        const spacingHeight = 32.0;
        final rulerHeight = availableHeight != null
            ? (availableHeight - valueHeight - spacingHeight).clamp(60.0, 140.0)
            : 100.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  style: typography.hero.copyWith(
                    fontSize: 56,
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
            const SizedBox(height: spacingHeight),
            SizedBox(
              height: rulerHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final centerPadding = constraints.maxWidth / 2;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: centerPadding,
                        ),
                        itemCount: tickCount + 1,
                        itemBuilder: (context, index) {
                          final hasMinor = widget.minorTicksPerMajor > 0;
                          final isMajor =
                              hasMinor &&
                              index % widget.minorTicksPerMajor == 0;
                          final half = hasMinor
                              ? (widget.minorTicksPerMajor / 2).round().clamp(
                                  1,
                                  widget.minorTicksPerMajor,
                                )
                              : 1;
                          final isMedium =
                              hasMinor && !isMajor && index % half == 0;
                          final height = isMajor
                              ? 48.0
                              : isMedium
                              ? 32.0
                              : 16.0;
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
                      Container(
                        width: 4,
                        height: 64,
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
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors.surface,
                                  colors.surface.withValues(alpha: 0),
                                  colors.surface.withValues(alpha: 0),
                                  colors.surface,
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
              ),
            ),
          ],
        );
      },
    );
  }
}
