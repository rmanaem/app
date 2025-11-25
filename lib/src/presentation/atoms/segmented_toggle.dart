import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// A tactile horizontal toggle switch.
///
/// Replaces `GlassToggle`.
/// Features a "grooved" track and a solid "steel" thumb.
class SegmentedToggle<T> extends StatelessWidget {
  /// Creates the toggle with the provided [options].
  const SegmentedToggle({
    required this.value,
    required this.options,
    required this.labels,
    required this.onChanged,
    super.key,
  });

  /// Currently selected option.
  final T value;

  /// Ordered options rendered in the toggle.
  final List<T> options;

  /// Display labels keyed by option.
  final Map<T, String> labels;

  /// Callback invoked when a segment is tapped.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surfaceHighlight, // "Groove" color (Lighter Ceramic)
        borderRadius: BorderRadius.circular(100),
        // No border on the track itself, creates a "sunken" feel
      ),
      child: Row(
        children: options.map((option) {
          final selected = value == option;
          final label = labels[option] ?? '';

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!selected) {
                  unawaited(HapticFeedback.lightImpact());
                  onChanged(option);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutQuint,
                decoration: BoxDecoration(
                  // ACTIVE: Polished Silver thumb
                  // INACTIVE: Transparent
                  color: selected ? c.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    // ACTIVE: Black text (on Silver)
                    // INACTIVE: Grey text (on Dark)
                    color: selected ? c.bg : c.inkSubtle,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
