import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/nutrition/presentation/models/quick_food_entry_input.dart';

/// Bottom sheet for quickly logging nutrition entries.
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
  final _titleController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();
  String _mealType = _mealTypes.first;

  static const List<String> _mealTypes = <String>[
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Uncategorized',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quick add',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: colors.inkSubtle,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _mealType,
                    decoration: const InputDecoration(labelText: 'Meal type'),
                    items: _mealTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _mealType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Energy (kcal)',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter calories';
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MacroField(
                          label: 'Protein (g)',
                          controller: _proteinController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroField(
                          label: 'Carbs (g)',
                          controller: _carbController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroField(
                          label: 'Fat (g)',
                          controller: _fatController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.errorText != null)
                    _ErrorBanner(
                      message: widget.errorText!,
                      onClose: widget.onErrorDismissed,
                    ),
                  if (widget.errorText != null) const SizedBox(height: 8),
                  FilledButton(
                    onPressed: widget.isSubmitting ? null : _handleSubmit,
                    child: widget.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Log food'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: widget.isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
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
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      calories: int.parse(_caloriesController.text),
      proteinGrams: _parseOptionalInt(_proteinController.text),
      carbGrams: _parseOptionalInt(_carbController.text),
      fatGrams: _parseOptionalInt(_fatController.text),
      mealLabel: _mealType,
    );

    final success = await widget.onSubmit(input);
    if (!mounted) {
      return;
    }
    if (success) {
      Navigator.of(context).pop();
    }
  }

  int? _parseOptionalInt(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return int.tryParse(value.trim());
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onClose,
  });

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: colors.ringTrack),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(color: colors.ink),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: colors.inkSubtle,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
