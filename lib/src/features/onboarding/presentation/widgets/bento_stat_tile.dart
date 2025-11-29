import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Stateless bento-style tile for stats entry.
///
/// Follows the "Biometric Dashboard" aesthetic:
/// - Top-Left: Micro-Label (Caption)
/// - Top-Right: Category Anchor (Icon)
/// - Bottom-Left: Hero Value (Display)
class BentoStatTile extends StatelessWidget {
  /// Creates a bento stat tile.
  const BentoStatTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.unit = '',
    this.icon,
    this.placeholder,
    this.isWide = false,
    super.key,
  });

  /// Label rendered above the value (Micro-label).
  final String label;

  /// Primary value shown in the tile body.
  final String? value;

  /// Optional unit shown next to the value.
  final String unit;

  /// Optional anchor icon shown in the top-right.
  final IconData? icon;

  /// Tap handler.
  final VoidCallback onTap;

  /// Optional placeholder text.
  final String? placeholder;

  /// Whether to render the wider variant.
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final showPlaceholder = value == null;
    final displayValue = showPlaceholder ? (placeholder ?? '--') : value!;
    // VISUAL STATE LOGIC:
    // Filled = Active Border (Silver) & White Text
    // Empty = Idle Border (Dark Steel) & Grey Text
    final borderColor = showPlaceholder
        ? colors.borderIdle
        : colors.borderActive;
    final textColor = showPlaceholder ? colors.inkSubtle : colors.ink;
    final iconColor = showPlaceholder
        ? colors.inkSubtle.withValues(alpha: 0.5)
        : colors.inkSubtle;

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: borderColor,
          width: showPlaceholder ? 1 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: colors.accent.withValues(alpha: 0.1),
        highlightColor: colors.surfaceHighlight,
        child: Container(
          padding: EdgeInsets.all(spacing.lg),
          height: isWide
              ? 100
              : 120, // Wide tiles can be slightly shorter if needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TOP ROW: Label + Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: typography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontSize: 10,
                      color: colors.inkSubtle,
                    ),
                  ),
                  if (icon != null)
                    Icon(
                      icon,
                      // Dim icon if empty, brighter if filled
                      color: iconColor,
                      size: 24, // BUMPED UP from 20
                    ),
                ],
              ),

              // BOTTOM ROW: Value + Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      displayValue,
                      style: typography.display.copyWith(
                        fontSize: 32, // Consistent Hero Size
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1,
                        letterSpacing: -1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (unit.isNotEmpty && !showPlaceholder) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: typography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: colors.inkSubtle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
