import 'dart:async';
// For FontFeature

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// A modal bottom sheet for logging body weight.
///
/// Features a horizontal scrolling ruler for precise value selection
/// and a high-contrast digital display.
class LogWeightSheet extends StatefulWidget {
  /// Creates a log weight sheet.
  const LogWeightSheet({
    required this.initialWeight,
    super.key,
  });

  /// The initial weight value to display.
  final double initialWeight;

  @override
  State<LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends State<LogWeightSheet> {
  // Default to a reasonable starting weight (e.g., 75.0 kg).
  double _currentWeight = 75;
  bool _isSaving = false;

  void _handleWeightChanged(double newValue) {
    setState(() {
      _currentWeight = newValue;
    });
    // Haptic feedback for tactile feel
    unawaited(HapticFeedback.selectionClick());
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate network delay for the saving action
    // In a real app, this would call a Repository.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      // Close the sheet and return the logged weight to the caller.
      Navigator.of(context).pop(_currentWeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: colors.borderIdle)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.borderIdle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOG WEIGHT',
                style: typography.caption.copyWith(
                  color: colors.inkSubtle,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: colors.inkSubtle),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Digital Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _currentWeight.toStringAsFixed(1),
                style: typography.hero.copyWith(
                  color: colors.ink,
                  fontSize: 64,
                  height: 1,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'KG', // Hardcoded unit for MVP
                style: typography.title.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Horizontal Ruler
          SizedBox(
            height: 100,
            child: _WeightRulerPicker(
              initialValue: _currentWeight,
              minValue: 30,
              maxValue: 200,
              onValueChanged: _handleWeightChanged,
            ),
          ),
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'CONFIRM',
              isLoading: _isSaving,
              isPrimary: true,
              onTap: _handleSave,
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal scrollable ruler for selecting a double value.
class _WeightRulerPicker extends StatefulWidget {
  const _WeightRulerPicker({
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onValueChanged,
  });

  final double initialValue;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onValueChanged;

  @override
  State<_WeightRulerPicker> createState() => _WeightRulerPickerState();
}

class _WeightRulerPickerState extends State<_WeightRulerPicker> {
  late final ScrollController _scrollController;
  // Width of a single 0.1 kg tick.
  static const double _tickWidth = 10;

  @override
  void initState() {
    super.initState();
    // Scroll so the initial value sits under the needle.
    // (Value - Min) * 10 ticks per unit * width per tick.
    final initialOffset =
        ((widget.initialValue - widget.minValue) * 10) * _tickWidth;

    _scrollController = ScrollController(initialScrollOffset: initialOffset)
      ..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    // Convert scroll offset back to a weight:
    // offset / width = total ticks, ticks / 10 = weight units.
    final offset = _scrollController.offset;
    final valueToAdd = (offset / _tickWidth) / 10.0;
    final rawValue = widget.minValue + valueToAdd;

    final clampedValue = rawValue.clamp(widget.minValue, widget.maxValue);

    // Debounce/Round to nearest 0.1
    final roundedValue = (clampedValue * 10).round() / 10.0;

    widget.onValueChanged(roundedValue);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    // Total number of 0.1 increments.
    final totalTicks = ((widget.maxValue - widget.minValue) * 10).toInt();
    // Use the actual ruler width so the needle sits on tick centers.
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = _horizontalPaddingForCentering(constraints.maxWidth);

        return Stack(
          alignment: Alignment.center,
          children: [
            // The Center Indicator (The "Needle")
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),

            // The Scrollable Ruler
            ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: totalTicks + 1,
              padding: EdgeInsets.symmetric(horizontal: padding),
              itemBuilder: (context, index) {
                // Determine if this tick is major (whole) or minor
                final isMajor = index % 10 == 0;
                final isMedium = index % 5 == 0 && !isMajor;

                return SizedBox(
                  width: _tickWidth,
                  // Use Stack so text can overflow the 10px width constraint
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior:
                        Clip.none, // Allow text to draw outside bounds
                    children: [
                      // The Tick Line
                      Container(
                        width: isMajor ? 2 : 1,
                        height: isMajor ? 30 : (isMedium ? 20 : 12),
                        color: isMajor ? colors.ink : colors.borderIdle,
                      ),
                      // The Number Label
                      if (isMajor)
                        Positioned(
                          bottom: 36, // Positioned above the tick
                          child: Text(
                            (widget.minValue + (index / 10)).toInt().toString(),
                            softWrap: false, // Prevent wrapping
                            style: TextStyle(
                              color: colors.inkSubtle,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // Gradient Fade Edges
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.surface,
                      colors.surface.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.surface,
                      colors.surface.withValues(alpha: 0),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
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

/// Calculates horizontal padding so the needle aligns with tick centers.
double _horizontalPaddingForCentering(double parentWidth) {
  return (parentWidth / 2) - (_WeightRulerPickerState._tickWidth / 2);
}
