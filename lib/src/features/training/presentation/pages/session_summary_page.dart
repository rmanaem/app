import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Result of a completed session.
class SessionResult {
  /// Creates a session result.
  SessionResult({
    required this.durationSeconds,
    required this.totalVolume,
    required this.totalSets,
    this.prCount = 0,
  });

  /// The total duration of the session in seconds.
  final int durationSeconds;

  /// The total volume lifted in kg.
  final int totalVolume;

  /// The total number of sets completed.
  final int totalSets;

  /// The number of personal records broken.
  final int prCount;
}

/// Page displaying the summary of a completed session.
class SessionSummaryPage extends StatelessWidget {
  /// Creates a session summary page.
  const SessionSummaryPage({required this.result, super.key});

  /// The result of the session to display.
  final SessionResult result;

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: spacing.edgeAll(spacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // 1. Hero Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 48, color: colors.accent),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'SESSION COMPLETE',
                textAlign: TextAlign.center,
                style: typography.caption.copyWith(
                  letterSpacing: 2,
                  color: colors.inkSubtle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Great work.',
                textAlign: TextAlign.center,
                style: typography.display.copyWith(fontSize: 32),
              ),

              const Spacer(),

              // 2. Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'DURATION',
                      value: _formatDuration(result.durationSeconds),
                      icon: Icons.timer_outlined,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: _StatCard(
                      label: 'VOLUME',
                      value:
                          '${(result.totalVolume / 1000).toStringAsFixed(1)}k',
                      unit: 'kg',
                      icon: Icons.fitness_center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'SETS',
                      value: '${result.totalSets}',
                      icon: Icons.layers_outlined,
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: _StatCard(
                      label: 'RECORDS',
                      value: '${result.prCount}',
                      icon: Icons.emoji_events_outlined,
                      highlight: result.prCount > 0,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // 3. Exit Button
              AppButton(
                label: 'RETURN TO DASHBOARD',
                isPrimary: true,
                onTap: () {
                  // Clear stack and go home
                  context.go('/training');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.unit,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? colors.accent : colors.borderIdle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 20,
                color: highlight ? colors.accent : colors.inkSubtle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: typography.hero.copyWith(
                  fontSize: 28,
                  color: colors.ink,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: typography.caption.copyWith(
                    fontSize: 12,
                    color: colors.inkSubtle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: typography.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors.inkSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
