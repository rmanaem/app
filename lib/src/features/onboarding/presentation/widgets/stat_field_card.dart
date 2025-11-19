import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Tappable row used for editable onboarding stats.
class StatFieldCard extends StatelessWidget {
  /// Creates a stat card displaying [label] and [valueText].
  const StatFieldCard({
    required this.label,
    required this.valueText,
    required this.onTap,
    super.key,
    this.placeholder = 'Tap to set',
  });

  /// Label describing the stat (e.g., "Height").
  final String label;

  /// Current value to display; when null, [placeholder] is shown.
  final String? valueText;

  /// Invoked when the card is tapped.
  final VoidCallback onTap;

  /// Placeholder text when [valueText] is null.
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final valueStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(color: colors.ink);
    final placeholderStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: colors.inkSubtle);

    return Material(
      color: colors.surface2,
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      valueText ?? placeholder,
                      style: valueText == null ? placeholderStyle : valueStyle,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.ink),
            ],
          ),
        ),
      ),
    );
  }
}
