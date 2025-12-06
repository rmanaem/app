import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/tactile_ruler_picker.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/app_text_field.dart';
import 'package:starter_app/src/presentation/atoms/segmented_toggle.dart';

/// Tabs available in the exercise context sheet.
enum ContextTab {
  /// Edit exercise settings (rest, remove, swap).
  edit,

  /// View exercise history.
  history,

  /// View and edit notes.
  note,
}

/// Bottom sheet for exercise options (edit settings, history, notes).
class ExerciseContextSheet extends StatefulWidget {
  /// Creates an exercise context sheet.
  const ExerciseContextSheet({
    required this.exerciseName,
    required this.onRemove,
    required this.onSwap,
    required this.onSaveNote,
    required this.onUpdateRest,
    this.initialNote,
    this.initialRestSeconds = 90,
    this.initialTab = ContextTab.edit,
    super.key,
  });

  /// The name of the exercise.
  final String exerciseName;

  /// The initial note content.
  final String? initialNote;

  /// The initial rest time in seconds.
  final int initialRestSeconds;

  /// The tab to show initially.
  final ContextTab initialTab;

  /// Callback to remove the exercise.
  final VoidCallback onRemove;

  /// Callback to swap the exercise.
  final VoidCallback onSwap;

  /// Callback when note is saved.
  final ValueChanged<String> onSaveNote;

  /// Callback when rest time is updated.
  final ValueChanged<int> onUpdateRest;

  @override
  State<ExerciseContextSheet> createState() => _ExerciseContextSheetState();
}

class _ExerciseContextSheetState extends State<ExerciseContextSheet> {
  late ContextTab _currentTab;
  late TextEditingController _noteController;
  late double _restSeconds;

  Timer? _debounceTimer;
  String? _saveStatus;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _restSeconds = widget.initialRestSeconds.toDouble();
    _noteController = TextEditingController(text: widget.initialNote)
      ..addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // If the debounce is in-flight, persist the latest text before closing.
    if (_debounceTimer?.isActive ?? false) {
      widget.onSaveNote(_noteController.text);
    }
    _debounceTimer?.cancel();
    _noteController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() => _saveStatus = 'Saving...');

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      widget.onSaveNote(_noteController.text);
      setState(() => _saveStatus = 'All changes saved');
    });
  }

  String _formatRestTime(double seconds) {
    final s = seconds.round();
    final m = s ~/ 60;
    final rem = s % 60;
    return '$m:${rem.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: colors.borderIdle)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderIdle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: spacing.edgeH(spacing.gutter),
              child: Text(
                widget.exerciseName,
                style: typography.title.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: spacing.lg),
            Padding(
              padding: spacing.edgeH(spacing.gutter),
              child: SegmentedToggle<ContextTab>(
                value: _currentTab,
                options: ContextTab.values,
                labels: const {
                  ContextTab.edit: 'Edit',
                  ContextTab.history: 'History',
                  ContextTab.note: 'Notes',
                },
                icons: const {
                  ContextTab.edit: Icons.tune,
                  ContextTab.history: Icons.history,
                  ContextTab.note: Icons.edit_note,
                },
                onChanged: (val) => setState(() => _currentTab = val),
              ),
            ),
            SizedBox(height: spacing.lg),
            SizedBox(
              height: 380, // Increased height for swap button
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previous,
                    // ignore: use_null_aware_elements - Stack children cannot contain nulls
                    if (current != null) current,
                  ],
                ),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_currentTab) {
      case ContextTab.edit:
        return _EditTab(
          restSeconds: _restSeconds,
          onRestChanged: (val) {
            setState(() => _restSeconds = val);
            widget.onUpdateRest(val.round());
          },
          onRemove: widget.onRemove,
          onSwap: widget.onSwap,
          restFormatter: _formatRestTime,
        );
      case ContextTab.history:
        return const _HistoryTab();
      case ContextTab.note:
        return _NoteTab(
          controller: _noteController,
          statusText: _saveStatus,
          onSave: () => widget.onSaveNote(_noteController.text),
        );
    }
  }
}

class _EditTab extends StatelessWidget {
  const _EditTab({
    required this.restSeconds,
    required this.onRestChanged,
    required this.onRemove,
    required this.onSwap,
    required this.restFormatter,
  });

  final double restSeconds;
  final ValueChanged<double> onRestChanged;
  final VoidCallback onRemove;
  final VoidCallback onSwap;
  final String Function(double) restFormatter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Padding(
      padding: spacing.edgeAll(spacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GLOBAL REST TIMER',
            style: typography.caption.copyWith(
              color: colors.inkSubtle,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Integrated Ruler for Rest Time
          SizedBox(
            height: 120,
            child: TactileRulerPicker(
              min: 0,
              max: 300,
              initialValue: restSeconds,
              step: 15,
              valueFormatter: restFormatter,
              onChanged: onRestChanged,
            ),
          ),
          const Spacer(),
          AppButton(
            label: 'SWAP EXERCISE',
            isPrimary: true,
            icon: Icons.swap_horiz,
            onTap: onSwap,
          ),
          SizedBox(height: spacing.md),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: colors.danger.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, color: colors.danger),
                  const SizedBox(width: 8),
                  Text(
                    'REMOVE EXERCISE',
                    style: typography.button.copyWith(color: colors.danger),
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

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return ListView(
      padding: spacing.edgeAll(spacing.gutter),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceHighlight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_events, color: colors.accent),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PERSONAL RECORD', style: typography.caption),
                  Text('120kg x 1', style: typography.title),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        const _HistoryRow(date: 'Dec 12', log: '100x5, 100x5, 100x5'),
        const _HistoryRow(date: 'Dec 09', log: '95x5, 95x5, 95x5'),
        const _HistoryRow(date: 'Dec 05', log: '90x5, 90x5, 90x5'),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.date, required this.log});
  final String date;
  final String log;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: typography.body.copyWith(color: colors.inkSubtle)),
          Text(log, style: typography.body.copyWith(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _NoteTab extends StatelessWidget {
  const _NoteTab({
    required this.controller,
    required this.statusText,
    required this.onSave,
  });

  final TextEditingController controller;
  final String? statusText;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return ListView(
      shrinkWrap: true,
      padding: spacing.edgeAll(spacing.gutter),
      children: [
        Text(
          'CURRENT SESSION',
          style: typography.caption.copyWith(
            color: colors.inkSubtle,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: controller,
          minLines: 1,
          maxLines: null,
          hintText: 'Write your cues here...',
        ),
        SizedBox(height: spacing.sm),
        if (statusText != null)
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  statusText!,
                  style: typography.caption.copyWith(
                    color: colors.ink, // use primary ink for visibility
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: spacing.md),
        Text(
          'PREVIOUS NOTES',
          style: typography.caption.copyWith(
            color: colors.inkSubtle,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Dec 12: Grip felt slippery. Try chalk.',
            style: typography.body.copyWith(
              color: colors.inkSubtle,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
