import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/presentation/widgets/set_log_row.dart';

/// Card showing an active exercise with its set rows.
class ActiveExerciseCard extends StatelessWidget {
  /// Creates an active exercise card.
  const ActiveExerciseCard({
    required this.exerciseName,
    required this.sets,
    this.onAddSet,
    this.activeTimerSetIndex,
    this.timerDuration,
    this.timerTotal,
    this.onTimerAdd,
    this.onTimerSkip,
    this.onMoreOptions,
    this.onEditNote,
    super.key,
  });

  /// The name of the exercise.
  final String exerciseName;

  /// The list of set rows to display.
  final List<SetLogRow> sets;

  /// Callback to add a new set.
  final VoidCallback? onAddSet;

  /// The index of the set currently showing the timer.
  final int? activeTimerSetIndex;

  /// The current timer duration.
  final int? timerDuration;

  /// The total timer duration.
  final int? timerTotal;

  /// Callback to add time to the timer.
  final VoidCallback? onTimerAdd;

  /// Callback to skip the timer.
  final VoidCallback? onTimerSkip;

  /// Callback for the "more" menu.
  final VoidCallback? onMoreOptions;

  /// Callback for the "edit note" button.
  final VoidCallback? onEditNote;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exerciseName,
                  style: typography.title.copyWith(fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onEditNote != null)
                InkWell(
                  onTap: onEditNote,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.edit_note, color: colors.inkSubtle),
                  ),
                ),
              InkWell(
                onTap: onMoreOptions,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.more_horiz, color: colors.inkSubtle),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              SizedBox(width: 40, child: Center(child: _HeaderLabel('SET'))),
              Expanded(flex: 3, child: Center(child: _HeaderLabel('KG'))),
              Expanded(flex: 2, child: Center(child: _HeaderLabel('REPS'))),
              Expanded(flex: 2, child: Center(child: _HeaderLabel('RPE'))),
              SizedBox(width: 56),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...sets.asMap().entries.expand((entry) {
          final index = entry.key;
          final row = entry.value;
          final isTimerHere = activeTimerSetIndex == index;
          return [
            row,
            if (isTimerHere && timerDuration != null)
              _InlineTimer(
                duration: timerDuration!,
                total: timerTotal ?? 90,
                onAdd: onTimerAdd,
                onSkip: onTimerSkip,
              ),
          ];
        }),
        InkWell(
          onTap: onAddSet,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+ ADD SET',
              style: typography.button.copyWith(
                color: colors.accent,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Divider(color: colors.borderIdle.withValues(alpha: 0.3)),
      ],
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return Text(
      text,
      style: typography.caption.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: colors.inkSubtle.withValues(alpha: 0.5),
      ),
    );
  }
}

class _InlineTimer extends StatelessWidget {
  const _InlineTimer({
    required this.duration,
    required this.total,
    required this.onAdd,
    required this.onSkip,
  });

  final int duration;
  final int total;
  final VoidCallback? onAdd;
  final VoidCallback? onSkip;

  String get _formattedTime {
    final m = duration ~/ 60;
    final s = duration % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final progress = (duration / total).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              color: colors.accent.withValues(alpha: 0.1),
              minHeight: 48,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer, size: 16, color: colors.accent),
                  const SizedBox(width: 12),
                  Text(
                    _formattedTime,
                    style: typography.title.copyWith(
                      color: colors.ink,
                      fontFamily: 'monospace',
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (onAdd != null)
                    TextButton(
                      onPressed: onAdd,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.ink,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.center,
                      ),
                      child: const Text('+30s'),
                    ),
                  if (onSkip != null)
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.ink,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.center,
                      ),
                      child: const Text('SKIP'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
