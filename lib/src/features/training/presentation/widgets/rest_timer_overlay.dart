import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// Floating rest timer with skip/add controls.
class RestTimerOverlay extends StatefulWidget {
  /// Creates the rest timer overlay.
  const RestTimerOverlay({
    required this.duration,
    required this.onAdd30,
    required this.onSkip,
    super.key,
  });

  /// Current duration in seconds.
  final int duration;

  /// Callback when adding 30 seconds.
  final VoidCallback onAdd30;

  /// Callback when skipping the timer.
  final VoidCallback onSkip;

  @override
  State<RestTimerOverlay> createState() => _RestTimerOverlayState();
}

class _RestTimerOverlayState extends State<RestTimerOverlay> {
  String get _formattedTime {
    final m = widget.duration ~/ 60;
    final s = widget.duration % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: colors.borderActive),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, color: colors.accent, size: 24),
              const SizedBox(width: 16),
              Text(
                _formattedTime,
                style: typography.hero.copyWith(
                  fontSize: 28,
                  fontFamily: 'monospace',
                  color: colors.ink,
                ),
              ),
              const SizedBox(width: 24),
              Container(
                height: 32,
                width: 1,
                color: colors.borderIdle,
              ),
              const SizedBox(width: 16),
              _MiniControl(
                label: '+30',
                onTap: widget.onAdd30,
              ),
              const SizedBox(width: 12),
              _MiniControl(
                label: 'SKIP',
                onTap: widget.onSkip,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniControl extends StatelessWidget {
  const _MiniControl({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDestructive
              ? colors.danger.withValues(alpha: 0.1)
              : colors.surfaceHighlight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: isDestructive ? colors.danger : colors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
