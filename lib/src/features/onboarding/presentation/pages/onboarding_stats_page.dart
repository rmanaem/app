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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final vm = context.watch<OnboardingVm>();
    final state = vm.statsState;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: colors.ink),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TELL US\nABOUT YOU.',
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
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.xl),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: BentoStatTile(
                        label: 'Birthday',
                        value: _formatDob(state.dob),
                        unit: '',
                        icon: Icons.cake_outlined,
                        isWide: true,
                        placeholder: 'Select Date',
                        onTap: () async {
                          final picked = await showDobPickerSheet(
                            context: context,
                            initial: state.dob,
                          );
                          if (picked != null) {
                            vm.setDob(picked);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: spacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 160,
                            child: BentoStatTile(
                              label: 'Height',
                              value: _getHeightValue(
                                state.height,
                                state.unitSystem,
                              ),
                              unit: _getHeightUnit(state.unitSystem),
                              onTap: _showHeightSheet,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: SizedBox(
                            height: 160,
                            child: BentoStatTile(
                              label: 'Weight',
                              value: _getWeightValue(
                                state.weight,
                                state.unitSystem,
                              ),
                              unit: _getWeightUnit(state.unitSystem),
                              onTap: _showWeightSheet,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.md),
                    SizedBox(
                      height: 80,
                      child: BentoStatTile(
                        label: 'Activity Level',
                        value: _formatActivity(state.activity),
                        unit: '',
                        icon: Icons.fitness_center,
                        isWide: true,
                        placeholder: 'Select Level',
                        onTap: _showActivitySheet,
                      ),
                    ),
                  ],
                ),
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

  String? _formatDob(DateTime? dob) {
    if (dob == null) return null;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dob.month - 1]} ${dob.day}, ${dob.year}';
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

  String? _formatActivity(ActivityLevel? level) {
    return level?.label;
  }
}
