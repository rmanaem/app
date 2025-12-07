import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/domain/entities/completed_workout.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/atoms/note_input_tile.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/app_text_field.dart';

/// A page that summarizes a completed session.
class SessionSummaryPage extends StatefulWidget {
  /// Creates a session summary page.
  const SessionSummaryPage({required this.workout, super.key});

  /// The completed workout to display.
  final CompletedWorkout workout;

  @override
  State<SessionSummaryPage> createState() => _SessionSummaryPageState();
}

class _SessionSummaryPageState extends State<SessionSummaryPage> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.workout.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _openNoteEditor() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: _noteController.text);
        return Dialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EDIT NOTE',
                      style: typography.title.copyWith(fontSize: 18),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, color: colors.inkSubtle),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.borderIdle),
                  ),
                  child: AppTextField(
                    controller: controller,
                    autofocus: true,
                    isGhost: true,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 5,
                    minLines: 3,
                    hintText: 'How did it feel? Any pain or PRs?',
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'SAVE NOTE',
                  isPrimary: true,
                  onTap: () => Navigator.pop(ctx, controller.text),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _noteController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final result = widget.workout;

    return Scaffold(
      backgroundColor: colors.bg,
      // Allow scrolling for keyboard avoidance
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
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
                        child: Icon(
                          Icons.check,
                          size: 48,
                          color: colors.accent,
                        ),
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
                            value: result.formattedDuration,
                            icon: Icons.timer_outlined,
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: _StatCard(
                            label: 'VOLUME',
                            value: result.formattedVolume,
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

                    SizedBox(height: spacing.xxl),

                    // 3. Session Note Input
                    Text(
                      'SESSION NOTE',
                      style: typography.caption.copyWith(
                        color: colors.inkSubtle,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    NoteInputTile(
                      value: _noteController.text,
                      onTap: _openNoteEditor,
                    ),

                    const Spacer(flex: 2),

                    // 4. Exit Button
                    AppButton(
                      label: 'RETURN TO DASHBOARD',
                      isPrimary: true,
                      onTap: () {
                        // TODO(User): Here is where you would call the
                        // repository to save.
                        // final finalWorkout = widget.workout.copyWith(
                        //   note: _noteController.text,
                        // );
                        // context.read<HistoryRepository>()
                        //     .saveWorkout(finalWorkout);

                        // For now, clear stack and go home
                        context.go('/training');
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
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
