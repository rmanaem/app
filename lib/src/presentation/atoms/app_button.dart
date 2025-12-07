import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Primary CTA pill used across the Matte Monolith experience.
class AppButton extends StatelessWidget {
  /// Creates a new [AppButton].
  const AppButton({
    required this.label,
    this.onTap,
    this.icon,
    this.leading,
    this.isPrimary = false,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    super.key,
  });

  /// Text rendered inside the button.
  final String label;

  /// Callback executed when tapped; when null the button is disabled.
  final VoidCallback? onTap;

  /// Optional leading icon rendered before the label.
  final IconData? icon;

  /// Optional custom leading widget (e.g., branded logos).
  final Widget? leading;

  /// Whether the primary styling should be applied.
  final bool isPrimary;

  /// Whether to display the loading spinner.
  final bool isLoading;

  /// Optional override for background color.
  final Color? backgroundColor;

  /// Optional override for content color (text/icon).
  final Color? foregroundColor;

  /// Optional override for border color.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final isDisabled = onTap == null;

    final effectiveBackgroundColor =
        backgroundColor ??
        (isDisabled ? c.surface : (isPrimary ? c.accent : c.surface));
    final effectiveBorderColor =
        borderColor ??
        (isDisabled ? c.borderIdle : (isPrimary ? c.accent : c.borderIdle));
    final effectiveForegroundColor =
        foregroundColor ??
        (isDisabled ? c.inkSubtle : (isPrimary ? c.bg : c.ink));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading || isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(100),
        splashColor: isPrimary
            ? Colors.white.withValues(alpha: 0.3)
            : c.accent.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: effectiveBorderColor),
            boxShadow: (isPrimary && !isDisabled)
                ? [
                    BoxShadow(
                      color: (backgroundColor ?? c.accent).withValues(
                        alpha: 0.1,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: effectiveForegroundColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 8),
                    ] else if (icon != null) ...[
                      Icon(
                        icon,
                        color: effectiveForegroundColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: effectiveForegroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
