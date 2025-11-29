import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/sex.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/bento_stat_tile.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/activity_mode_dial.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/date_picker_sheet.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/tactile_ruler_picker.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';
import 'package:starter_app/src/presentation/atoms/segmented_toggle.dart';

/// Onboarding step for capturing personal stats via picker sheets.
class OnboardingStatsPage extends StatefulWidget {
  /// Creates the stats page with the [initialGoal].
  const OnboardingStatsPage({super.key, this.initialGoal});

  /// Goal selected on the previous screen.
  final Goal? initialGoal;

  @override
  State<OnboardingStatsPage> createState() => _OnboardingStatsPageState();
}

class _OnboardingStatsPageState extends State<OnboardingStatsPage> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<OnboardingVm>();
    if (widget.initialGoal != null) {
      vm.selectGoal(widget.initialGoal!);
    }
    unawaited(
      Future<void>.microtask(vm.logStatsScreenViewed),
    );
  }

  Future<void> _showHeightSheet() {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final vm = context.read<OnboardingVm>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.bg,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, _) {
            final state = context.watch<OnboardingVm>().statsState;
            final isMetric = state.unitSystem == UnitSystem.metric;
            final imperialValue = state.height == null
                ? 70.0
                : (state.height!.feet * 12) + state.height!.inchesRemainder;
            final currentValue = isMetric
                ? (state.height?.cm ?? 175)
                : imperialValue;
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    'Height',
                    style: typography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: colors.ink,
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  SizedBox(
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: spacing.lg),
                          child: SizedBox(
                            width: 160,
                            child: SegmentedToggle<UnitSystem>(
                              value: state.unitSystem,
                              options: const [
                                UnitSystem.metric,
                                UnitSystem.imperial,
                              ],
                              labels: const {
                                UnitSystem.metric: 'CM',
                                UnitSystem.imperial: 'FT',
                              },
                              onChanged: vm.setUnitSystem,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: TactileRulerPicker(
                              key: ValueKey(state.unitSystem),
                              min: isMetric ? 100 : 48,
                              max: isMetric ? 250 : 96,
                              initialValue: currentValue,
                              unitLabel: isMetric ? 'CM' : '',
                              valueFormatter: isMetric
                                  ? null
                                  : (val) {
                                      final feet = val ~/ 12;
                                      final inches = (val % 12).toInt();
                                      return "$feet' $inches\"";
                                    },
                              onChanged: (val) {
                                if (isMetric) {
                                  vm.setHeightCm(val);
                                } else {
                                  final feet = val ~/ 12;
                                  final inches = val % 12;
                                  vm.setHeightImperial(
                                    ft: feet,
                                    inch: inches,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                    child: AppButton(
                      label: 'CONFIRM',
                      isPrimary: true,
                      onTap: () {
                        final latestState = context
                            .read<OnboardingVm>()
                            .statsState;
                        if (latestState.height == null) {
                          if (isMetric) {
                            vm.setHeightCm(currentValue);
                          } else {
                            final feet = currentValue ~/ 12;
                            final inches = currentValue % 12;
                            vm.setHeightImperial(ft: feet, inch: inches);
                          }
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showActivitySheet() {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final vm = context.read<OnboardingVm>();
    final typography = Theme.of(context).extension<AppTypography>()!;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.bg,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Activity Level',
                style: typography.display.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: colors.ink,
                ),
              ),
              SizedBox(height: spacing.lg),
              SizedBox(
                height: 400,
                child: ActivityModeDial(
                  initialLevel: vm.statsState.activity,
                  onChanged: vm.setActivityLevel,
                ),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                child: AppButton(
                  label: 'CONFIRM',
                  isPrimary: true,
                  onTap: () {
                    final latestState = context.read<OnboardingVm>().statsState;
                    if (latestState.activity == null) {
                      vm.setActivityLevel(ActivityLevel.moderatelyActive);
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showWeightSheet() {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final vm = context.read<OnboardingVm>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.bg,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, _) {
            final state = context.watch<OnboardingVm>().statsState;
            final isMetric = state.unitSystem == UnitSystem.metric;
            final currentValue = isMetric
                ? (state.weight?.kg ?? 75)
                : (state.weight?.lb ?? 165);
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    'Weight',
                    style: typography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: colors.ink,
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  SizedBox(
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: spacing.lg),
                          child: SizedBox(
                            width: 160,
                            child: SegmentedToggle<UnitSystem>(
                              value: state.unitSystem,
                              options: const [
                                UnitSystem.metric,
                                UnitSystem.imperial,
                              ],
                              labels: const {
                                UnitSystem.metric: 'KG',
                                UnitSystem.imperial: 'LB',
                              },
                              onChanged: vm.setUnitSystem,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: TactileRulerPicker(
                              key: ValueKey(state.unitSystem),
                              min: isMetric ? 30 : 70,
                              max: isMetric ? 200 : 450,
                              initialValue: currentValue,
                              unitLabel: isMetric ? 'KG' : 'LB',
                              step: 0.1,
                              onChanged: (val) {
                                if (isMetric) {
                                  vm.setWeightKg(val);
                                } else {
                                  vm.setWeightLb(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                    child: AppButton(
                      label: 'CONFIRM',
                      isPrimary: true,
                      onTap: () {
                        final latestState = context
                            .read<OnboardingVm>()
                            .statsState;
                        if (latestState.weight == null) {
                          if (isMetric) {
                            vm.setWeightKg(currentValue);
                          } else {
                            vm.setWeightLb(currentValue);
                          }
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSexSelector(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final vm = context.read<OnboardingVm>();

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.bg,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            final selected = sheetContext.watch<OnboardingVm>().statsState.sex;
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    'BIOLOGICAL SEX',
                    style: typography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: colors.ink,
                    ),
                  ),
                  SizedBox(height: spacing.xxl),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                    child: Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 0.75,
                            child: _SexSelectionCard(
                              label: 'MALE',
                              icon: Icons.male_rounded,
                              isSelected: selected == Sex.male,
                              onTap: () {
                                vm.setSex(Sex.male);
                                setModalState(() {});
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 0.75,
                            child: _SexSelectionCard(
                              label: 'FEMALE',
                              icon: Icons.female_rounded,
                              isSelected: selected == Sex.female,
                              onTap: () {
                                vm.setSex(Sex.female);
                                setModalState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                    child: AppButton(
                      label: 'CONFIRM',
                      isPrimary: true,
                      onTap: () {
                        if (selected == null) {
                          vm.setSex(Sex.male);
                        }
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final vm = context.read<OnboardingVm>();
    final state = context.watch<OnboardingVm>().statsState;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: colors.ink),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                children: [
                  Text(
                    'CALIBRATE\nYOUR PLAN.',
                    style: typography.display.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1,
                      color: colors.ink,
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    'We use this to calibrate your initial targets.',
                    style: typography.body.copyWith(
                      color: colors.inkSubtle,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: BentoStatTile(
                          label: 'SEX',
                          value: state.sex?.label.toUpperCase(),
                          icon: _getSexIcon(state.sex) ?? Icons.wc_rounded,
                          onTap: () => _showSexSelector(context),
                          placeholder: '--',
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: BentoStatTile(
                          label: 'AGE',
                          value: state.dob != null
                              ? '${_calculateAge(state.dob!)}'
                              : null,
                          icon: Icons.cake_outlined,
                          onTap: () async {
                            final picked = await showDobPickerSheet(
                              context: context,
                              initial: state.dob,
                            );
                            if (picked != null) {
                              vm.setDob(picked);
                            }
                          },
                          placeholder: '--',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: BentoStatTile(
                          label: 'HEIGHT',
                          value: _getHeightValue(
                            state.height,
                            state.unitSystem,
                          ),
                          unit: _getHeightUnit(state.unitSystem),
                          icon: Icons.height,
                          onTap: _showHeightSheet,
                          placeholder: '--',
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: BentoStatTile(
                          label: 'WEIGHT',
                          value: _getWeightValue(
                            state.weight,
                            state.unitSystem,
                          ),
                          unit: _getWeightUnit(state.unitSystem),
                          icon: Icons.monitor_weight_outlined,
                          onTap: _showWeightSheet,
                          placeholder: '--',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.md),
                  BentoStatTile(
                    label: 'ACTIVITY LEVEL',
                    value: _formatActivityForTile(state.activity),
                    isWide: true,
                    icon: _activityIcon(state.activity),
                    placeholder: '--',
                    onTap: _showActivitySheet,
                  ),
                  SizedBox(height: spacing.xxl),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(spacing.gutter),
              child: AppButton(
                label: 'NEXT',
                isPrimary: true,
                onTap: state.isValid
                    ? () async {
                        final router = GoRouter.of(context);
                        await vm.logStatsNext();
                        await router.push('/onboarding/goal-configuration');
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String? _getHeightValue(Stature? height, UnitSystem unit) {
    if (height == null) return null;
    if (unit == UnitSystem.metric) {
      return height.cm.toStringAsFixed(0);
    }
    final inches = height.inchesRemainder.round();
    return "${height.feet}' $inches\"";
  }

  String _getHeightUnit(UnitSystem unit) {
    return unit == UnitSystem.metric ? 'CM' : '';
  }

  String? _getWeightValue(BodyWeight? weight, UnitSystem unit) {
    if (weight == null) return null;
    if (unit == UnitSystem.metric) {
      return weight.kg.toStringAsFixed(1);
    }
    return weight.lb.toStringAsFixed(1);
  }

  String _getWeightUnit(UnitSystem unit) {
    return unit == UnitSystem.metric ? 'KG' : 'LB';
  }

  /// Shortened activity labels to fit the 32px hero size.
  String? _formatActivityForTile(ActivityLevel? level) {
    if (level == null) return null;
    return switch (level) {
      ActivityLevel.sedentary => 'SEDENTARY',
      ActivityLevel.lightlyActive => 'LIGHT',
      ActivityLevel.moderatelyActive => 'MODERATE',
      ActivityLevel.veryActive => 'HIGH',
      ActivityLevel.extremelyActive => 'EXTREME',
    };
  }

  IconData? _getSexIcon(Sex? sex) {
    return switch (sex) {
      Sex.male => Icons.male_rounded,
      Sex.female => Icons.female_rounded,
      null => null,
    };
  }

  IconData _activityIcon(ActivityLevel? level) {
    return switch (level) {
      ActivityLevel.sedentary => Icons.weekend_outlined,
      ActivityLevel.lightlyActive => Icons.directions_walk,
      ActivityLevel.moderatelyActive => Icons.fitness_center,
      ActivityLevel.veryActive => Icons.sports_mma,
      ActivityLevel.extremelyActive => Icons.flash_on,
      null => Icons.fitness_center_rounded,
    };
  }
}

class _SexSelectionCard extends StatelessWidget {
  const _SexSelectionCard({
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
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final borderColor = isSelected ? colors.accent : colors.borderIdle;
    final fillColor = isSelected ? colors.surfaceHighlight : colors.surface2;
    final contentColor = isSelected ? colors.ink : colors.inkSubtle;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(spacing.lg),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: contentColor,
            ),
            SizedBox(height: spacing.md),
            Text(
              label,
              style: typography.display.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: contentColor,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
