import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/nutrition/presentation/models/quick_food_entry_input.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/app_text_field.dart';
import 'package:starter_app/src/presentation/atoms/tactile_ruler_picker.dart';

enum _EditMode { energy, protein, carbs, fat }

/// Sheet for quickly adding food entries.
class QuickAddFoodSheet extends StatefulWidget {
  /// Creates the sheet.
  const QuickAddFoodSheet({
    required this.onSubmit,
    this.initialSlot = 'Snacks',
    this.isSubmitting = false,
    this.errorText,
    this.onErrorDismissed,
    super.key,
  });

  /// Callback to submit the entry.
  final Future<bool> Function(QuickFoodEntryInput input) onSubmit;

  /// Initial slot name.
  final String initialSlot;

  /// Whether submission is in progress.
  final bool isSubmitting;

  /// Error text to display.
  final String? errorText;

  /// Callback when error is dismissed.
  final VoidCallback? onErrorDismissed;

  @override
  State<QuickAddFoodSheet> createState() => _QuickAddFoodSheetState();
}

class _QuickAddFoodSheetState extends State<QuickAddFoodSheet> {
  final _titleController = TextEditingController();

  // State
  late String _selectedSlot;
  _EditMode _mode = _EditMode.energy;

  // Independent Values
  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fat = 0;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.initialSlot;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // --- Logic Helpers ---

  void _onRulerChanged(double value) {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      switch (_mode) {
        case _EditMode.energy:
          _calories = value;
        case _EditMode.protein:
          _protein = value;
        case _EditMode.carbs:
          _carbs = value;
        case _EditMode.fat:
          _fat = value;
      }
    });
  }

  double get _currentValue {
    switch (_mode) {
      case _EditMode.energy:
        return _calories;
      case _EditMode.protein:
        return _protein;
      case _EditMode.carbs:
        return _carbs;
      case _EditMode.fat:
        return _fat;
    }
  }

  double get _currentMax {
    switch (_mode) {
      case _EditMode.energy:
        return 1500;
      case _EditMode.protein:
        return 100;
      case _EditMode.carbs:
        return 150;
      case _EditMode.fat:
        return 80;
    }
  }

  String get _currentUnit {
    return _mode == _EditMode.energy ? 'kcal' : 'g';
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.borderIdle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: spacing.lg),

              // 2. Header (Slot Chip + Name Input)
              Row(
                children: [
                  // Interactive Slot Chip
                  GestureDetector(
                    onTap: _showSlotSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.inkSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: colors.accent),
                          const SizedBox(width: 8),
                          Text(
                            _selectedSlot.toUpperCase(),
                            style: typography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: colors.inkSubtle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name Input (Replaced with AppTextField)
                  Expanded(
                    child: AppTextField(
                      controller: _titleController,
                      hintText: 'Enter food name...',
                      isGhost: true, // Transparent look
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.xxl),

              // 3. The "Big Number" (Value Display)
              Column(
                children: [
                  Text(
                    _mode.name.toUpperCase(),
                    style: typography.caption.copyWith(
                      letterSpacing: 2,
                      color: colors.inkSubtle,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _currentValue.round().toString(),
                        style: typography.display.copyWith(
                          fontSize: 64,
                          height: 1,
                          color: colors.ink,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentUnit,
                        style: typography.title.copyWith(
                          color: colors.inkSubtle,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: spacing.md),

              // 4. The Tactile Ruler
              SizedBox(
                height: 80,
                child: TactileRulerPicker(
                  initialValue: _currentValue,
                  min: 0,
                  max: _currentMax,
                  showValueDisplay: false, // We have our own big display
                  fadeColor: colors.surface,
                  onChanged: _onRulerChanged,
                  key: ValueKey(_mode),
                ),
              ),
              SizedBox(height: spacing.xl),

              // 5. Macro Selectors
              Row(
                children: [
                  Expanded(
                    child: _MacroSelector(
                      label: 'ENERGY',
                      value: '${_calories.round()}',
                      unit: 'kcal',
                      isActive: _mode == _EditMode.energy,
                      onTap: () => setState(() => _mode = _EditMode.energy),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroSelector(
                      label: 'PROTEIN',
                      value: '${_protein.round()}',
                      unit: 'g',
                      isActive: _mode == _EditMode.protein,
                      onTap: () => setState(() => _mode = _EditMode.protein),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroSelector(
                      label: 'CARBS',
                      value: '${_carbs.round()}',
                      unit: 'g',
                      isActive: _mode == _EditMode.carbs,
                      onTap: () => setState(() => _mode = _EditMode.carbs),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroSelector(
                      label: 'FAT',
                      value: '${_fat.round()}',
                      unit: 'g',
                      isActive: _mode == _EditMode.fat,
                      onTap: () => setState(() => _mode = _EditMode.fat),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.xxl),

              // 6. Submit Button
              if (widget.errorText != null) ...[
                Text(
                  widget.errorText!,
                  style: typography.caption.copyWith(color: colors.danger),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              AppButton(
                label: 'LOG ENTRY',
                isPrimary: true,
                isLoading: widget.isSubmitting,
                onTap: () async {
                  if (widget.isSubmitting) return;

                  final input = QuickFoodEntryInput(
                    title: _titleController.text,
                    mealLabel: _selectedSlot,
                    calories: _calories.round(),
                    proteinGrams: _protein.round(),
                    carbGrams: _carbs.round(),
                    fatGrams: _fat.round(),
                  );

                  final success = await widget.onSubmit(input);
                  if (!context.mounted) return;
                  if (success) {
                    Navigator.pop(context);
                  }
                },
              ),

              // 7. Spacer for FAB
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSlotSelector() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final colors = Theme.of(context).extension<AppColors>()!;
          final typography = Theme.of(context).extension<AppTypography>()!;
          final slots = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SELECT MEAL',
                  style: typography.caption.copyWith(
                    letterSpacing: 2,
                    color: colors.inkSubtle,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...slots.map(
                  (slot) => ListTile(
                    title: Text(
                      slot,
                      style: typography.body.copyWith(color: colors.ink),
                    ),
                    trailing: _selectedSlot == slot
                        ? Icon(Icons.check, color: colors.accent)
                        : null,
                    onTap: () {
                      setState(() => _selectedSlot = slot);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MacroSelector extends StatelessWidget {
  const _MacroSelector({
    required this.label,
    required this.value,
    required this.unit,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String value;
  final String unit;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? colors.surfaceHighlight : colors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? colors.ink : colors.borderIdle,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: typography.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isActive ? colors.ink : colors.inkSubtle,
                  ),
                ),
                const SizedBox(width: 1),
                Text(
                  unit,
                  style: typography.caption.copyWith(
                    fontSize: 10,
                    color: isActive
                        ? colors.ink
                        : colors.inkSubtle.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label.substring(0, 3),
              style: typography.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? colors.ink
                    : colors.inkSubtle.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
