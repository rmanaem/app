import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// A "Biometric Dashboard" tile with tactile border feedback.
///
/// Idle: Dark steel border.
/// Pressed: bright silver border plus subtle glow.
class BentoStatTile extends StatefulWidget {
  /// Creates a new bento stat tile.
  const BentoStatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.onTap,
    this.icon,
    this.isWide = false,
    this.placeholder = 'SET',
    super.key,
  });

  /// Small label displayed above the primary value.
  final String label;

  /// Primary value shown in the tile body.
  final String? value;

  /// Unit rendered beneath or beside the value.
  final String unit;

  /// Callback triggered when the tile is tapped.
  final VoidCallback onTap;

  /// Optional icon used on the wide layout.
  final IconData? icon;

  /// Whether to render the wide variant.
  final bool isWide;

  /// Placeholder text when no value is provided.
  final String placeholder;

  @override
  State<BentoStatTile> createState() => _BentoStatTileState();
}

class _BentoStatTileState extends State<BentoStatTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final hasValue = widget.value != null;

    final borderColor = _isPressed ? colors.accent : colors.borderIdle;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: _isPressed ? 2 : 1,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Container(
          padding: EdgeInsets.all(spacing.lg),
          alignment: widget.isWide ? Alignment.centerLeft : Alignment.center,
          child: widget.isWide
              ? _buildWideLayout(colors, typography, spacing, hasValue)
              : _buildSquareLayout(colors, typography, spacing, hasValue),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
    AppColors c,
    AppTypography t,
    AppSpacing s,
    bool hasValue,
  ) {
    return Row(
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: c.inkSubtle, size: 24),
          SizedBox(width: s.md),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label.toUpperCase(),
              style: t.caption.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: c.inkSubtle,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasValue ? widget.value! : widget.placeholder,
              style: t.title.copyWith(
                color: hasValue ? c.ink : c.inkSubtle.withValues(alpha: 0.5),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (widget.unit.isNotEmpty && hasValue)
          Text(
            widget.unit.toUpperCase(),
            style: t.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: c.accent,
            ),
          )
        else
          Icon(
            Icons.add,
            color: c.inkSubtle.withValues(alpha: 0.3),
            size: 20,
          ),
      ],
    );
  }

  Widget _buildSquareLayout(
    AppColors c,
    AppTypography t,
    AppSpacing s,
    bool hasValue,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: t.caption.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: c.inkSubtle,
            fontSize: 11,
          ),
        ),
        SizedBox(height: s.sm),
        Text(
          hasValue ? widget.value! : '--',
          style: t.display.copyWith(
            color: hasValue ? c.ink : c.inkSubtle.withValues(alpha: 0.3),
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        if (widget.unit.isNotEmpty) ...[
          SizedBox(height: s.xs),
          Text(
            widget.unit.toUpperCase(),
            style: t.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: c.accent,
            ),
          ),
        ] else if (!hasValue) ...[
          SizedBox(height: s.xs),
          Text(
            widget.placeholder,
            style: t.caption.copyWith(
              color: c.inkSubtle.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }
}
