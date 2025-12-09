import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/plan/domain/repositories/plan_repository.dart';
import 'package:starter_app/src/features/settings/presentation/viewmodels/nutrition_target_view_model.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/tactile_ruler_picker.dart';

enum _TunerMode { energy, protein, carbs, fat }

/// Page to tune nutrition targets (Energy, Macros).
class NutritionTargetPage extends StatefulWidget {
  /// Creates the nutrition target page.
  const NutritionTargetPage({super.key});

  @override
  State<NutritionTargetPage> createState() => _NutritionTargetPageState();
}

class _NutritionTargetPageState extends State<NutritionTargetPage> {
  _TunerMode _mode = _TunerMode.energy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return ChangeNotifierProvider(
      create: (context) => NutritionTargetViewModel(
        planRepository: context.read<PlanRepository>(),
      ),
      child: Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          backgroundColor: colors.bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.ink),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'STRATEGY',
            style: TextStyle(
              color: colors.ink,
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<NutritionTargetViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: colors.ink),
              );
            }
            return _buildContent(context, vm);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, NutritionTargetViewModel vm) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    // Determine current ruler values based on mode
    var currentValue = 0.0;
    var max = 5000.0;
    var unit = '';

    switch (_mode) {
      case _TunerMode.energy:
        currentValue = vm.calories;
        max = 6000;
        unit = 'kcal';
      case _TunerMode.protein:
        currentValue = vm.protein;
        max = 500;
        unit = 'g';
      case _TunerMode.carbs:
        currentValue = vm.carbs;
        max = 800;
        unit = 'g';
      case _TunerMode.fat:
        currentValue = vm.fat;
        max = 300;
        unit = 'g';
    }

    return Column(
      children: [
        const Spacer(),

        // 1. Hero Value Display
        Column(
          children: [
            Text(
              'DAILY TARGET',
              style: typography.caption.copyWith(
                color: colors.inkSubtle,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  currentValue.round().toString(),
                  style: typography.hero.copyWith(
                    fontSize: 80,
                    height: 1,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: typography.title.copyWith(
                    fontSize: 24,
                    color: colors.inkSubtle,
                  ),
                ),
              ],
            ),
            if (_mode != _TunerMode.energy)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Impacts Total: ${vm.calories.round()} kcal',
                  style: typography.caption.copyWith(
                    color: colors.accent,
                  ),
                ),
              ),
          ],
        ),

        const Spacer(),

        // 2. The Ruler
        SizedBox(
          height: 120,
          child: TactileRulerPicker(
            initialValue: currentValue,
            min: 0,
            max: max,
            onChanged: (val) {
              unawaited(HapticFeedback.selectionClick());
              switch (_mode) {
                case _TunerMode.energy:
                  vm.updateEnergy(val);
                case _TunerMode.protein:
                  vm.updateProtein(val);
                case _TunerMode.carbs:
                  vm.updateCarbs(val);
                case _TunerMode.fat:
                  vm.updateFat(val);
              }
            },
            key: ValueKey(_mode), // Forces ruler reset on mode switch
          ),
        ),

        const Spacer(),

        // 3. Mode Selectors (The Mixing Board)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _TunerTab(
                  label: 'ENERGY',
                  value: '${vm.calories.round()}',
                  isActive: _mode == _TunerMode.energy,
                  onTap: () => setState(() => _mode = _TunerMode.energy),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TunerTab(
                  label: 'PRO',
                  value: '${vm.protein.round()}g',
                  isActive: _mode == _TunerMode.protein,
                  onTap: () => setState(() => _mode = _TunerMode.protein),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TunerTab(
                  label: 'CARB',
                  value: '${vm.carbs.round()}g',
                  isActive: _mode == _TunerMode.carbs,
                  onTap: () => setState(() => _mode = _TunerMode.carbs),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TunerTab(
                  label: 'FAT',
                  value: '${vm.fat.round()}g',
                  isActive: _mode == _TunerMode.fat,
                  onTap: () => setState(() => _mode = _TunerMode.fat),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: spacing.xxl),

        // 4. Save Action
        Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            MediaQuery.of(context).viewPadding.bottom + 24,
          ),
          child: AppButton(
            label: 'SAVE CONFIGURATION',
            isPrimary: true,
            onTap: () => unawaited(vm.saveChanges(context)),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _TunerTab extends StatelessWidget {
  const _TunerTab({
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String value;
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? colors.surfaceHighlight : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? colors.ink : colors.borderIdle,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: typography.body.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isActive ? colors.ink : colors.inkSubtle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: typography.caption.copyWith(
                fontSize: 10,
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
