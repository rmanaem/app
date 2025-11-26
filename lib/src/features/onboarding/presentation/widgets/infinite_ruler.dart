import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// A precision scrolling ruler with "Industrial Luxury" physics.
///
/// Provides native scroll inertia and custom painted ticks that glow as they
/// pass the center indicator.
class InfiniteRuler extends StatefulWidget {
  /// Creates an infinite tactile ruler.
  const InfiniteRuler({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
    this.step = 0.1,
    this.height = 100,
    this.integerHapticsOnly = true,
  });

  /// Currently selected value shown on the ruler.
  final double value;

  /// Minimum value the ruler can represent.
  final double min;

  /// Maximum value the ruler can represent.
  final double max;

  /// Distance between ticks.
  final double step;

  /// Callback for delivering the new value.
  final ValueChanged<double> onChanged;

  /// Fixed overall height of the widget.
  final double height;

  /// Whether haptics fire only on integer changes.
  final bool integerHapticsOnly;

  @override
  State<InfiniteRuler> createState() => _InfiniteRulerState();
}

class _InfiniteRulerState extends State<InfiniteRuler> {
  late final ScrollController _scrollController;
  static const double _tickSpacing = 12;
  bool _isProgrammaticScroll = false;
  double _lastHapticValue = 0;

  @override
  void initState() {
    super.initState();
    final initialOffset =
        ((widget.value - widget.min) / widget.step) * _tickSpacing;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _lastHapticValue = widget.value;
  }

  @override
  void didUpdateWidget(InfiniteRuler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isProgrammaticScroll) {
      final targetOffset =
          ((widget.value - widget.min) / widget.step) * _tickSpacing;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(targetOffset);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScrollUpdate() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final rawValue = (offset / _tickSpacing) * widget.step + widget.min;
    final clampedValue = rawValue.clamp(widget.min, widget.max);

    if (widget.integerHapticsOnly) {
      if (clampedValue.floor() != _lastHapticValue.floor()) {
        unawaited(HapticFeedback.selectionClick());
        _lastHapticValue = clampedValue;
      }
    } else if ((clampedValue - _lastHapticValue).abs() >= widget.step) {
      unawaited(HapticFeedback.selectionClick());
      _lastHapticValue = clampedValue;
    }

    _isProgrammaticScroll = true;
    widget.onChanged(clampedValue);
    _isProgrammaticScroll = false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final totalSteps = ((widget.max - widget.min) / widget.step).ceil();
    final screenPadding = MediaQuery.of(context).size.width / 2;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                _handleScrollUpdate();
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: screenPadding),
              itemCount: totalSteps + 1,
              itemBuilder: (_, index) {
                return SizedBox(
                  key: ValueKey<int>(index),
                  width: _tickSpacing,
                  height: double.infinity,
                );
              },
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RulerPainter(
                    scrollOffset: _scrollController.hasClients
                        ? _scrollController.offset
                        : 0,
                    min: widget.min,
                    max: widget.max,
                    step: widget.step,
                    tickSpacing: _tickSpacing,
                    colors: colors,
                    viewportWidth: MediaQuery.of(context).size.width,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.bg,
                    colors.bg.withValues(alpha: 0),
                    colors.bg.withValues(alpha: 0),
                    colors.bg,
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 2,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.bg.withValues(alpha: 0),
                    colors.accent.withValues(alpha: 0.1),
                    colors.bg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({
    required this.scrollOffset,
    required this.min,
    required this.max,
    required this.step,
    required this.tickSpacing,
    required this.colors,
    required this.viewportWidth,
  });

  final double scrollOffset;
  final double min;
  final double max;
  final double step;
  final double tickSpacing;
  final AppColors colors;
  final double viewportWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = viewportWidth / 2;
    final idlePaint = Paint()
      ..color = colors.borderIdle
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final totalTicks = ((max - min) / step).ceil();

    final firstVisible = ((scrollOffset - center - 50) / tickSpacing)
        .floor()
        .clamp(0, totalTicks);
    final lastVisible = ((scrollOffset + center + 50) / tickSpacing)
        .ceil()
        .clamp(0, totalTicks);

    for (var i = firstVisible; i <= lastVisible; i++) {
      final tickPosition = (i * tickSpacing) - scrollOffset + center;
      final value = min + (i * step);
      final isMajor =
          (value % 1.0).abs() < 0.001 || (value % 1.0).abs() > 0.999;
      final distanceFromCenter = (tickPosition - center).abs();
      const activationThreshold = 20.0;

      var paintToUse = idlePaint;
      var height = isMajor ? 32.0 : 16.0;

      if (distanceFromCenter < activationThreshold) {
        final t = 1.0 - (distanceFromCenter / activationThreshold);
        final color = Color.lerp(colors.borderIdle, colors.accent, t)!;
        final width = ui.lerpDouble(1.0, 2.5, t)!;
        paintToUse = Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round;
        height = ui.lerpDouble(height, height + 6.0, t)!;
      }

      final y = size.height / 2;
      canvas.drawLine(
        Offset(tickPosition, y - (height / 2)),
        Offset(tickPosition, y + (height / 2)),
        paintToUse,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.colors != colors;
  }
}
