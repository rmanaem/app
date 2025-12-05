import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/tactile_ruler_picker.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/atoms/note_input_tile.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/app_text_field.dart';

/// The "Calibration Station" modal for tuning an exercise configuration.
class ExerciseTunerSheet extends StatefulWidget {
  /// Creates a tuning sheet for a single exercise.
  const ExerciseTunerSheet({
    required this.exerciseName,
    required this.muscleGroup,
    this.initialSets = 3,
    this.initialWeight = 25.0, // Starts on a major tick
    this.initialReps = 10,
    this.initialRestSeconds = 150, // 2:30 default rest
    this.initialRpe = 8.0,
    this.initialNotes,
    super.key,
  });

  /// Display name of the exercise to tune.
  final String exerciseName;

  /// Primary muscle group for the exercise.
  final String muscleGroup;

  /// Starting sets count.
  final int initialSets;

  /// Starting weight value.
  final double initialWeight;

  /// Starting reps target.
  final int initialReps;

  /// Starting rest time in seconds.
  final int initialRestSeconds;

  /// Starting RPE value.
  final double initialRpe;

  /// Existing notes for the exercise, if any.
  final String? initialNotes;

  @override
  State<ExerciseTunerSheet> createState() => _ExerciseTunerSheetState();
}

class _ExerciseTunerSheetState extends State<ExerciseTunerSheet> {
  late int _sets;
  late double _weight;
  late double _reps;
  late double _rest;
  late double _rpe;
  String? _currentNote;

  @override
  void initState() {
    super.initState();
    _sets = widget.initialSets;
    _weight = widget.initialWeight;
    _reps = widget.initialReps.toDouble();
    _rest = widget.initialRestSeconds.toDouble();
    _rpe = widget.initialRpe;
    _currentNote = widget.initialNotes;
  }

  void _updateSets(int delta) {
    setState(() {
      _sets = (_sets + delta).clamp(1, 10);
    });
    unawaited(HapticFeedback.lightImpact());
  }

  String _formatRestTime(double seconds) {
    final s = seconds.round();
    final m = s ~/ 60;
    final rem = s % 60;
    return '$m:${rem.toString().padLeft(2, '0')}';
  }

  Future<void> _showInfoModal(
    BuildContext context,
    String title,
    String value,
  ) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title.toUpperCase(),
                style: typography.caption.copyWith(
                  color: colors.accent,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: typography.hero.copyWith(fontSize: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNoteEditor() async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: _currentNote);
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
                    hintText: 'Enter technical cues or reminders...',
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
      setState(() => _currentNote = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'CALIBRATION',
          style: typography.caption.copyWith(
            fontSize: 10,
            letterSpacing: 2,
            color: colors.inkSubtle,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: spacing.edgeV(spacing.md),
                children: [
                  // 1. HEADER & METADATA ACTIONS
                  Padding(
                    padding: spacing.edgeH(spacing.gutter),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.muscleGroup.toUpperCase(),
                                style: typography.caption.copyWith(
                                  color: colors.accent,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.exerciseName,
                                style: typography.title.copyWith(
                                  fontSize: 24, // Matches image_73a70c scale
                                  height: 1.1,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              _HeaderActionButton(
                                icon: Icons.history,
                                onTap: () async => _showInfoModal(
                                  context,
                                  'Last Session',
                                  '100kg x 5',
                                ),
                              ),
                              const SizedBox(width: 12),
                              _HeaderActionButton(
                                icon: Icons.emoji_events_outlined,
                                onTap: () async => _showInfoModal(
                                  context,
                                  'Personal Record',
                                  '120kg x 1',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing.xxl),

                  // 2. TARGET SETS
                  const _SectionLabel(label: 'TARGET SETS'),
                  Padding(
                    padding: spacing.edgeH(spacing.gutter),
                    child: Center(
                      child: Container(
                        width: 160,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: colors.borderIdle),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CompactStepButton(
                              icon: Icons.remove,
                              onTap: () => _updateSets(-1),
                            ),
                            Text(
                              '$_sets',
                              style: typography.hero.copyWith(fontSize: 28),
                            ),
                            _CompactStepButton(
                              icon: Icons.add,
                              onTap: () => _updateSets(1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: spacing.xxl),

                  // 3. TARGET LOAD
                  const _SectionLabel(label: 'TARGET LOAD'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: TactileRulerPicker(
                      min: 0,
                      max: 300,
                      initialValue: _weight,
                      unitLabel: 'kg',
                      step: 2.5,
                      valueFormatter: (val) =>
                          val.toStringAsFixed(1).replaceAll('.0', ''),
                      onChanged: (val) => _weight = val,
                    ),
                  ),

                  SizedBox(height: spacing.xl),

                  // 4. TARGET REPS
                  const _SectionLabel(label: 'TARGET REPS'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: TactileRulerPicker(
                      min: 0,
                      max: 50,
                      initialValue: _reps,
                      onChanged: (val) => _reps = val,
                    ),
                  ),

                  SizedBox(height: spacing.xl),

                  // 5. REST TIMER
                  const _SectionLabel(label: 'REST TIMER'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: TactileRulerPicker(
                      min: 0,
                      max: 600,
                      initialValue: _rest,
                      step: 15,
                      valueFormatter: _formatRestTime,
                      onChanged: (val) => _rest = val,
                    ),
                  ),

                  SizedBox(height: spacing.xl),

                  // 6. TARGET RPE (Now Ruler for Consistency)
                  const _SectionLabel(label: 'TARGET RPE'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: TactileRulerPicker(
                      min: 1,
                      max: 10,
                      initialValue: _rpe,
                      valueFormatter: (val) => val.toStringAsFixed(0),
                      onChanged: (val) => _rpe = val,
                    ),
                  ),

                  SizedBox(height: spacing.xxl),

                  // 7. NOTE (New Atom)
                  const _SectionLabel(label: 'NOTE'),
                  Padding(
                    padding: spacing.edgeH(spacing.gutter),
                    child: NoteInputTile(
                      value: _currentNote,
                      onTap: _openNoteEditor,
                    ),
                  ),

                  SizedBox(height: spacing.gutter),
                ],
              ),
            ),

            // Bottom Save Button
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.gutter,
                spacing.sm,
                spacing.gutter,
                spacing.gutter + 20,
              ),
              child: AppButton(
                label: 'SAVE CONFIGURATION',
                isPrimary: true,
                onTap: () {
                  Navigator.pop(context, {
                    'sets': _sets,
                    'weight': _weight,
                    'reps': _reps.round(),
                    'rest': _formatRestTime(_rest),
                    'rpe': _rpe,
                    'notes': _currentNote,
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
      child: Text(
        label,
        style: typography.caption.copyWith(
          color: colors.inkSubtle,
          fontSize: 10,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CompactStepButton extends StatelessWidget {
  const _CompactStepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        child: Icon(icon, color: colors.ink),
      ),
    );
  }
}

/// Updated: Prominent style (accent icon + border).
class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.borderIdle),
        ),
        child: Icon(icon, color: colors.accent, size: 20),
      ),
    );
  }
}
