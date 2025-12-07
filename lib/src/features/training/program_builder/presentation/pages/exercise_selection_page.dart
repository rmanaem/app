import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/viewmodels/exercise_selection_view_model.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/exercise_list_tile.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Modal for selecting exercises to add to a workout.
class ExerciseSelectionPage extends StatelessWidget {
  /// Creates the selection page.
  const ExerciseSelectionPage({
    super.key,
    this.isSingleSelect = false,
    this.submitButtonText,
  });

  /// Whether to allow only one exercise to be selected.
  final bool isSingleSelect;

  /// Optional text to override the submit button label.
  final String? submitButtonText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final vm = context.watch<ExerciseSelectionViewModel>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'EXERCISE LIBRARY', // CHANGED: Standard terminology
          style: typography.caption.copyWith(
            letterSpacing: 3,
            color: colors.inkSubtle,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _showCreateExerciseSheet(context, vm),
            child: Text(
              'CREATE',
              style: typography.button.copyWith(
                color: colors.accent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.ink))
          : Column(
              children: [
                // 1. Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: vm.updateSearch,
                    autofocus: true,
                    style: typography.body.copyWith(color: colors.ink),
                    cursorColor: colors.accent,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Search library...',
                      hintStyle: typography.body.copyWith(
                        color: colors.inkSubtle,
                      ),
                      filled: true,
                      fillColor: colors.surface,
                      prefixIcon: Icon(Icons.search, color: colors.inkSubtle),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),

                // 2. Filter Rail (Updated Style)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: 'All',
                        selectedCategory: vm.selectedCategory,
                        onSelect: vm.selectCategory,
                      ),
                      _FilterChip(
                        label: 'Chest',
                        selectedCategory: vm.selectedCategory,
                        onSelect: vm.selectCategory,
                      ),
                      _FilterChip(
                        label: 'Back',
                        selectedCategory: vm.selectedCategory,
                        onSelect: vm.selectCategory,
                      ),
                      _FilterChip(
                        label: 'Legs',
                        selectedCategory: vm.selectedCategory,
                        onSelect: vm.selectCategory,
                      ),
                      _FilterChip(
                        label: 'Shoulders',
                        selectedCategory: vm.selectedCategory,
                        onSelect: vm.selectCategory,
                      ),
                      _FilterChip(
                        label: 'Arms',
                        selectedCategory: vm.selectedCategory,
                        onSelect: vm.selectCategory,
                      ),
                      _FilterChip(
                        label: 'Cardio',
                        selectedCategory: vm.selectedCategory,
                        onSelect: vm.selectCategory,
                      ),
                      _FilterChip(
                        label: 'Abs',
                        selectedCategory: vm.selectedCategory,
                        onSelect: vm.selectCategory,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. The List or Empty State
                Expanded(
                  child: vm.filteredExercises.isEmpty
                      ? Center(
                          child: vm.searchQuery.isNotEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: colors.inkSubtle.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No exercises found for '
                                      '"${vm.searchQuery}"',
                                      style: typography.body.copyWith(
                                        color: colors.inkSubtle,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    AppButton(
                                      label:
                                          'CREATE '
                                          '"${vm.searchQuery.toUpperCase()}"',
                                      isPrimary: true,
                                      onTap: () => _showCreateExerciseSheet(
                                        context,
                                        vm,
                                        initialName: vm.searchQuery,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'No exercises in this category',
                                  style: typography.body.copyWith(
                                    color: colors.inkSubtle,
                                  ),
                                ),
                        )
                      : ListView.builder(
                          itemCount: vm.filteredExercises.length,
                          itemBuilder: (context, index) {
                            final ex = vm.filteredExercises[index];
                            return ExerciseListTile(
                              name: ex['name'] as String,
                              muscle: ex['muscle'] as String,
                              isSelected: vm.selectedIds.contains(ex['id']),
                              onTap: () =>
                                  vm.toggleSelection(ex['id'] as String),
                            );
                          },
                        ),
                ),

                // 4. Confirmation Button
                if (vm.selectedCount > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    // Removed Top Border for Infinite look
                    color: colors.bg,
                    child: SafeArea(
                      child: AppButton(
                        label:
                            submitButtonText ??
                            (isSingleSelect
                                ? 'SWAP WITH '
                                      '${vm.singleSelectedName?.toUpperCase()}'
                                : 'ADD (${vm.selectedCount})'),
                        isPrimary: true,
                        onTap: () {
                          final selected = vm.confirmSelection();
                          context.pop(selected);
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showCreateExerciseSheet(
    BuildContext context,
    ExerciseSelectionViewModel vm, {
    String? initialName,
  }) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _CreateExerciseSheet(
          initialName: initialName,
          onSubmit: (name, muscle) {
            unawaited(vm.createCustomExercise(name, muscle));
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }
}

class _CreateExerciseSheet extends StatefulWidget {
  const _CreateExerciseSheet({
    required this.onSubmit,
    this.initialName,
  });

  final void Function(String name, String muscle) onSubmit;
  final String? initialName;

  @override
  State<_CreateExerciseSheet> createState() => _CreateExerciseSheetState();
}

class _CreateExerciseSheetState extends State<_CreateExerciseSheet> {
  final _nameController = TextEditingController();
  String _selectedMuscle = 'Chest';

  final _muscles = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Cardio',
    'Abs',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'NEW EXERCISE',
            style: typography.title.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.xl),

          // Name Input
          Text(
            'NAME',
            style: typography.caption.copyWith(
              color: colors.inkSubtle,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: typography.body.copyWith(color: colors.ink),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. Plate Pinch Press',
              hintStyle: typography.body.copyWith(
                color: colors.inkSubtle.withValues(alpha: 0.5),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors.borderIdle),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors.accent),
              ),
            ),
          ),

          SizedBox(height: spacing.lg),

          // Muscle Dropdown (Simple wrap for now)
          Text(
            'TARGET MUSCLE',
            style: typography.caption.copyWith(
              color: colors.inkSubtle,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _muscles.map((muscle) {
              final isSelected = muscle == _selectedMuscle;
              return ChoiceChip(
                label: Text(muscle),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedMuscle = muscle),
                selectedColor: colors.accent,
                backgroundColor: colors.bg,
                labelStyle: typography.caption.copyWith(
                  color: isSelected ? colors.bg : colors.ink,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? colors.accent : colors.borderIdle,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: spacing.xxl),

          AppButton(
            label: 'CREATE EXERCISE',
            isPrimary: true,
            onTap: () {
              if (_nameController.text.isNotEmpty) {
                widget.onSubmit(_nameController.text, _selectedMuscle);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selectedCategory,
    required this.onSelect,
  });

  final String label;
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final isSelected = label == selectedCategory;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onSelect(label),
        borderRadius: BorderRadius.circular(
          10,
        ), // CHANGED: Tighter radius (Mechanical feel)
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            // Active: Pure White (Light Source). Inactive: Transparent/Dark.
            color: isSelected ? colors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(
              10,
            ), // Matches the InkWell radius
            border: Border.all(
              // Active: No border (the fill is enough).
              // Inactive: Dark Steel Edge.
              color: isSelected ? colors.ink : colors.borderIdle,
            ),
            // The "OLED Pop" Glow for the active state
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.ink.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: typography.caption.copyWith(
              // Active: Black Text. Inactive: Grey Text.
              color: isSelected ? colors.bg : colors.inkSubtle,
              fontWeight:
                  FontWeight.w700, // Always bold for technical readability
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
