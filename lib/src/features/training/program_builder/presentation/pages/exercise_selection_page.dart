import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/viewmodels/exercise_selection_view_model.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/exercise_list_tile.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Modal for selecting exercises to add to a workout.
class ExerciseSelectionPage extends StatelessWidget {
  /// Creates the selection page.
  const ExerciseSelectionPage({super.key});

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
      ),
      body: Column(
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
                hintStyle: typography.body.copyWith(color: colors.inkSubtle),
                filled: true,
                fillColor: colors.surface,
                prefixIcon: Icon(Icons.search, color: colors.inkSubtle),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. The List
          Expanded(
            child: ListView.builder(
              itemCount: vm.filteredExercises.length,
              itemBuilder: (context, index) {
                final ex = vm.filteredExercises[index];
                return ExerciseListTile(
                  name: ex['name'] as String,
                  muscle: ex['muscle'] as String,
                  isSelected: vm.selectedIds.contains(ex['id']),
                  onTap: () => vm.toggleSelection(ex['id'] as String),
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
                  label: 'ADD (${vm.selectedCount})',
                  isPrimary: true,
                  onTap: () {
                    vm.confirmSelection();
                    context.pop();
                  },
                ),
              ),
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
