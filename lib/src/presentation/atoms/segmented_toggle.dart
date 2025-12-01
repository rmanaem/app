import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// A horizontal toggle switch with a sliding appearance.
class SegmentedToggle<T> extends StatelessWidget {
  /// Creates the toggle with the provided options.
  const SegmentedToggle({
    required this.value,
    required this.options,
    required this.labels,
    required this.onChanged,
    this.icons,
    super.key,
  });

  /// Currently selected option.
  final T value;

  /// Ordered list of options to render.
  final List<T> options;

  /// Display text labels keyed by option.
  final Map<T, String> labels;

  /// Optional icons keyed by option.
  final Map<T, IconData>? icons;

  /// Callback invoked when a segment is tapped.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceHighlight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: options.map((option) {
          final selected = value == option;
          final label = labels[option] ?? '';
          final icon = icons?[option];

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
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
                  color: selected ? colors.accent : Colors.transparent,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 16,
                        color: selected ? colors.bg : colors.inkSubtle,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? colors.bg : colors.inkSubtle,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
