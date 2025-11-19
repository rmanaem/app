import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/core/analytics/analytics_service.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewstate/onboarding_stats_view_state.dart';

/// Onboarding · Stats & Units step.
class OnboardingStatsPage extends StatefulWidget {
  /// Creates the stats page with the selected [initialGoal].
  const OnboardingStatsPage({super.key, this.initialGoal});

  /// Goal selected on the previous step.
  final Goal? initialGoal;

  @override
  State<OnboardingStatsPage> createState() => _OnboardingStatsPageState();
}

class _OnboardingStatsPageState extends State<OnboardingStatsPage> {
  late final OnboardingVm _vm;

  final TextEditingController _heightCmCtrl = TextEditingController();
  final TextEditingController _heightFtCtrl = TextEditingController();
  final TextEditingController _heightInCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = OnboardingVm(
      context.read<AnalyticsService>(),
      initialGoal: widget.initialGoal,
    );
    unawaited(_vm.logStatsScreenViewed());
  }

  @override
  void dispose() {
    _heightCmCtrl.dispose();
    _heightFtCtrl.dispose();
    _heightInCtrl.dispose();
    _weightCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Your Details'),
        elevation: 0,
        backgroundColor: colors.bg,
      ),
      body: AnimatedBuilder(
        animation: _vm,
        builder: (context, _) {
          final state = _vm.statsState;
          final isMetric = state.unitSystem == UnitSystem.metric;

          _syncHeightControllers(state, isMetric);
          _syncWeightController(state, isMetric);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHeading(label: 'Units', colors: colors),
                  SegmentedButton<UnitSystem>(
                    segments: const [
                      ButtonSegment<UnitSystem>(
                        value: UnitSystem.metric,
                        label: Text('Metric'),
                      ),
                      ButtonSegment<UnitSystem>(
                        value: UnitSystem.imperial,
                        label: Text('Imperial'),
                      ),
                    ],
                    selected: <UnitSystem>{state.unitSystem},
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        _vm.setUnitSystem(selection.first);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  _SectionHeading(label: 'Date of Birth', colors: colors),
                  const SizedBox(height: 8),
                  _DobField(
                    value: state.dob,
                    onPick: _pickDob,
                  ),
                  const SizedBox(height: 20),
                  _SectionHeading(label: 'Height', colors: colors),
                  const SizedBox(height: 8),
                  if (isMetric)
                    _NumberField(
                      controller: _heightCmCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}$')),
                      ],
                      suffixText: 'cm',
                      onChanged: (value) {
                        final cm = double.tryParse(value);
                        if (cm != null) _vm.setHeightCm(cm);
                      },
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _NumberField(
                            controller: _heightFtCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,2}$'),
                              ),
                            ],
                            suffixText: 'ft',
                            onChanged: (_) => _applyImperialHeight(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NumberField(
                            controller: _heightInCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,2}(\.\d{0,1})?$'),
                              ),
                            ],
                            suffixText: 'in',
                            onChanged: (_) => _applyImperialHeight(),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  _SectionHeading(label: 'Weight', colors: colors),
                  const SizedBox(height: 8),
                  _NumberField(
                    controller: _weightCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,3}(\.\d{0,1})?$'),
                      ),
                    ],
                    suffixText: isMetric ? 'kg' : 'lb',
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed == null) return;
                      if (isMetric) {
                        _vm.setWeightKg(parsed);
                      } else {
                        _vm.setWeightLb(parsed);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  _SectionHeading(label: 'Activity Level', colors: colors),
                  const SizedBox(height: 8),
                  SegmentedButton<ActivityLevel>(
                    segments: const [
                      ButtonSegment<ActivityLevel>(
                        value: ActivityLevel.low,
                        label: Text('Low'),
                      ),
                      ButtonSegment<ActivityLevel>(
                        value: ActivityLevel.moderate,
                        label: Text('Moderate'),
                      ),
                      ButtonSegment<ActivityLevel>(
                        value: ActivityLevel.high,
                        label: Text('High'),
                      ),
                    ],
                    selected: state.activity == null
                        ? <ActivityLevel>{}
                        : <ActivityLevel>{state.activity!},
                    emptySelectionAllowed: true,
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        _vm.setActivityLevel(selection.first);
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: state.isValid
                        ? () async {
                            final router = GoRouter.of(context);
                            final payload = {
                              'goal': _vm.goalState.selected,
                              'dob': state.dob,
                              'heightCm': state.height?.cm,
                              'weightKg': state.weight?.kg,
                              'activity': state.activity,
                              'unitSystem': state.unitSystem,
                            };
                            await _vm.logStatsNext();
                            await router.push(
                              '/onboarding/preview',
                              extra: payload,
                            );
                          }
                        : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _syncHeightControllers(OnboardingStatsViewState state, bool isMetric) {
    final height = state.height;
    if (height == null) return;
    if (isMetric) {
      final cmText = height.cm.toStringAsFixed(0);
      if (_heightCmCtrl.text != cmText) {
        _heightCmCtrl.value = TextEditingValue(
          text: cmText,
          selection: TextSelection.collapsed(offset: cmText.length),
        );
      }
      return;
    }

    final ftText = height.feet.toString();
    if (_heightFtCtrl.text != ftText) {
      _heightFtCtrl.value = TextEditingValue(
        text: ftText,
        selection: TextSelection.collapsed(offset: ftText.length),
      );
    }

    final inText = height.inchesRemainder.toStringAsFixed(1);
    if (_heightInCtrl.text != inText) {
      _heightInCtrl.value = TextEditingValue(
        text: inText,
        selection: TextSelection.collapsed(offset: inText.length),
      );
    }
  }

  void _syncWeightController(OnboardingStatsViewState state, bool isMetric) {
    final weight = state.weight;
    if (weight == null) return;
    final text = (isMetric ? weight.kg : weight.lb).toStringAsFixed(1);
    if (_weightCtrl.text != text) {
      _weightCtrl.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial =
        _vm.statsState.dob ?? DateTime(now.year - 25, now.month, now.day);
    final firstDate = DateTime(now.year - 100);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (!mounted || picked == null) return;
    _vm.setDob(picked);
  }

  void _applyImperialHeight() {
    final ft = int.tryParse(_heightFtCtrl.text);
    final inch = double.tryParse(_heightInCtrl.text);
    if (ft == null || inch == null) return;
    _vm.setHeightImperial(ft: ft, inch: inch);
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label, required this.colors});

  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: colors.ink,
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.keyboardType,
    required this.inputFormatters,
    required this.suffixText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String suffixText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        suffixText: suffixText,
        suffixStyle: TextStyle(color: colors.inkSubtle),
        hintText: 'Enter value',
      ),
    );
  }
}

class _DobField extends StatelessWidget {
  const _DobField({required this.value, required this.onPick});

  final DateTime? value;
  final Future<void> Function() onPick;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final text = value == null
        ? 'Select date'
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}'
            '-${value!.day.toString().padLeft(2, '0')}';

    return OutlinedButton(
      onPressed: onPick,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        side: BorderSide(color: colors.ringTrack),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.ink),
            ),
          ),
          Icon(Icons.date_range, color: colors.inkSubtle),
        ],
      ),
    );
  }
}
