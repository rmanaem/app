import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/nutrition/presentation/models/quick_food_entry_input.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/segmented_toggle.dart';

/// Bottom sheet for logging nutrition entries with mode switching.
class QuickAddFoodSheet extends StatefulWidget {
  /// Creates the quick add sheet.
  const QuickAddFoodSheet({
    required this.onSubmit,
    required this.isSubmitting,
    required this.onErrorDismissed,
    this.errorText,
    super.key,
  });

  /// Called when the user submits the form.
  final Future<bool> Function(QuickFoodEntryInput input) onSubmit;

  /// Whether the ViewModel is currently persisting the entry.
  final bool isSubmitting;

  /// Optional error surfaced from the ViewModel.
  final String? errorText;

  /// Clears the surfaced error once rendered.
  final VoidCallback onErrorDismissed;

  @override
  State<QuickAddFoodSheet> createState() => _QuickAddFoodSheetState();
}

class _QuickAddFoodSheetState extends State<QuickAddFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();

  String _selectedMealType = 'Breakfast';
  int _inputModeIndex = 0;
  bool _isFormValid = false;

  static const List<({String label, IconData icon})> _mealOptions = [
    (label: 'Breakfast', icon: Icons.wb_sunny_outlined),
    (label: 'Lunch', icon: Icons.wb_cloudy_outlined),
    (label: 'Dinner', icon: Icons.nights_stay_outlined),
    (label: 'Snack', icon: Icons.cookie_outlined),
    (label: 'Other', icon: Icons.more_horiz),
  ];

  static const List<({String label, IconData icon})> _inputModes = [
    (label: 'Quick', icon: Icons.bolt),
    (label: 'Servings', icon: Icons.calculate_outlined),
    (label: 'Scan', icon: Icons.qr_code_scanner),
  ];

  @override
  void initState() {
    super.initState();
    _caloriesController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _caloriesController.removeListener(_validateForm);
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _caloriesController.text.isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: colors.borderIdle)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LOG FOOD',
                      style: typography.caption.copyWith(
                        color: colors.inkSubtle,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: colors.inkSubtle),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SegmentedToggle<String>(
                  value: _inputModes[_inputModeIndex].label,
                  options: _inputModes.map((m) => m.label).toList(),
                  labels: {
                    for (final mode in _inputModes) mode.label: mode.label,
                  },
                  icons: {
                    for (final mode in _inputModes) mode.label: mode.icon,
                  },
                  onChanged: (val) {
                    setState(
                      () => _inputModeIndex = _inputModes.indexWhere(
                        (m) => m.label == val,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mealOptions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final option = _mealOptions[index];
                      final isSelected = option.label == _selectedMealType;
                      return _SelectionChip(
                        label: option.label,
                        icon: option.icon,
                        isSelected: isSelected,
                        onTap: () => setState(
                          () => _selectedMealType = option.label,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                if (_inputModeIndex == 0) ...[
                  _StandardFieldBlock(
                    label: 'Description',
                    controller: _descriptionController,
                    hintText: 'e.g. Oatmeal',
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 20),
                  _EnergyFieldBlock(controller: _caloriesController),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _MacroBlock(
                          label: 'Protein',
                          controller: _proteinController,
                          color: colors.macroProtein,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MacroBlock(
                          label: 'Carbs',
                          controller: _carbController,
                          color: colors.macroCarbs,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MacroBlock(
                          label: 'Fat',
                          controller: _fatController,
                          color: colors.macroFat,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        '${_inputModes[_inputModeIndex]} mode coming soon',
                        style: typography.body.copyWith(
                          color: colors.inkSubtle,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                if (widget.errorText != null) ...[
                  _ErrorDisplay(
                    message: widget.errorText!,
                    onClose: widget.onErrorDismissed,
                  ),
                  const SizedBox(height: 16),
                ],
                AppButton(
                  label: 'CONFIRM',
                  onTap: (_isFormValid && !widget.isSubmitting)
                      ? _handleSubmit
                      : null,
                  isLoading: widget.isSubmitting,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || widget.isSubmitting) {
      return;
    }
    final input = QuickFoodEntryInput(
      title: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      calories: int.tryParse(_caloriesController.text) ?? 0,
      proteinGrams: _parseOptionalInt(_proteinController.text),
      carbGrams: _parseOptionalInt(_carbController.text),
      fatGrams: _parseOptionalInt(_fatController.text),
      mealLabel: _selectedMealType,
    );

    await widget.onSubmit(input);
  }

  int? _parseOptionalInt(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }
}

class _SelectionChip extends StatelessWidget {
  const _SelectionChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.ink : Colors.transparent,
          border: Border.all(
            color: isSelected ? colors.ink : colors.borderIdle,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colors.bg : colors.inkSubtle,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: typography.caption.copyWith(
                color: isSelected ? colors.bg : colors.inkSubtle,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusableInputShell extends StatefulWidget {
  const _FocusableInputShell({
    required this.child,
    this.height,
    this.padding,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  State<_FocusableInputShell> createState() => _FocusableInputShellState();
}

class _FocusableInputShellState extends State<_FocusableInputShell> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: colors.surfaceHighlight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused ? colors.accent : colors.borderIdle,
            width: _isFocused ? 1.5 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.centerLeft,
        child: widget.child,
      ),
    );
  }
}

/// A robust, full-width input block for standard text.
class _StandardFieldBlock extends StatelessWidget {
  const _StandardFieldBlock({
    required this.label,
    required this.controller,
    required this.hintText,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: typography.caption.copyWith(
              color: colors.inkSubtle,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _FocusableInputShell(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: controller,
            textCapitalization: textCapitalization,
            style: typography.body.copyWith(color: colors.ink),
            decoration: InputDecoration(
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: hintText,
              hintStyle: typography.body.copyWith(color: colors.inkSubtle),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

/// The Hero Block. Taller, bolder text, dedicated right-side unit.
class _EnergyFieldBlock extends StatelessWidget {
  const _EnergyFieldBlock({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Energy',
            style: typography.caption.copyWith(
              color: colors.inkSubtle,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _FocusableInputShell(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: typography.display.copyWith(
                    color: colors.ink,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -1,
                  ),
                  cursorColor: colors.accent,
                  cursorHeight: 40,
                  decoration: const InputDecoration(
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    hintText: '0',
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'kcal',
                  style: typography.body.copyWith(
                    color: colors.inkSubtle,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact macro blocks.
class _MacroBlock extends StatelessWidget {
  const _MacroBlock({
    required this.label,
    required this.controller,
    required this.color,
  });

  final String label;
  final TextEditingController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: typography.caption.copyWith(
                  color: colors.inkSubtle,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _FocusableInputShell(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  style: typography.title.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.bold,
                  ),
                  cursorColor: colors.ink,
                  decoration: const InputDecoration(
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: '0',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                ),
              ),
              Text(
                'g',
                style: typography.body.copyWith(color: colors.inkSubtle),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  const _ErrorDisplay({
    required this.message,
    required this.onClose,
  });

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20, color: colors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: typography.caption.copyWith(color: colors.danger),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20, color: colors.danger),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
