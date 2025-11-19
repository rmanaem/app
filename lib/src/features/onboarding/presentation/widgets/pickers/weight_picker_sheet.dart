import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';

import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/picker_sheet_scaffold.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/picker_wheel.dart';

/// Shows a wheel picker for weight with inline unit toggle.
Future<({UnitSystem unit, BodyWeight weight})?> showWeightPickerSheet({
  required BuildContext context,
  required UnitSystem unit,
  required BodyWeight? current,
}) {
  var tempUnit = unit;
  var temp = current ?? BodyWeight.fromKg(75);

  return showModalBottomSheet<({UnitSystem unit, BodyWeight weight})>(
    context: context,
    backgroundColor: Theme.of(context).extension<AppColors>()!.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final measurementWheels = tempUnit == UnitSystem.metric
              ? _MetricWeightPicker(
                  weight: temp,
                  onChanged: (value) => temp = value,
                  onUnitChanged: (value) => setState(() => tempUnit = value),
                )
              : _ImperialWeightPicker(
                  weight: temp,
                  onChanged: (value) => temp = value,
                  onUnitChanged: (value) => setState(() => tempUnit = value),
                );

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PickerSheetHeader(title: 'Weight'),
                SizedBox(height: 220, child: measurementWheels),
                PickerSheetActions(
                  onCancel: () => Navigator.of(sheetContext).pop(),
                  onDone: () => Navigator.of(sheetContext).pop(
                    (unit: tempUnit, weight: temp),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _MetricWeightPicker extends StatelessWidget {
  const _MetricWeightPicker({
    required this.weight,
    required this.onChanged,
    required this.onUnitChanged,
  });

  final BodyWeight weight;
  final ValueChanged<BodyWeight> onChanged;
  final ValueChanged<UnitSystem> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final ints = List<int>.generate(221, (index) => 30 + index);
    final decs = List<int>.generate(10, (index) => index);
    final intPart = weight.kg.floor().clamp(30, 250);
    final decimalPart = ((weight.kg - intPart) * 10).round().clamp(0, 9);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()!.surface2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PickerWheel<int>(
                values: ints,
                initialIndex: ints.indexOf(intPart),
                onSelected: (value) => onChanged(
                  BodyWeight.fromKg(value + decimalPart / 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: PickerWheel<int>(
                values: decs,
                initialIndex: decimalPart,
                onSelected: (value) => onChanged(
                  BodyWeight.fromKg(intPart + value / 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: PickerWheel<UnitSystem>(
                values: const [UnitSystem.metric, UnitSystem.imperial],
                initialIndex: 0,
                onSelected: onUnitChanged,
                displayValue: (value) =>
                    value == UnitSystem.metric ? 'kg' : 'lb',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImperialWeightPicker extends StatelessWidget {
  const _ImperialWeightPicker({
    required this.weight,
    required this.onChanged,
    required this.onUnitChanged,
  });

  final BodyWeight weight;
  final ValueChanged<BodyWeight> onChanged;
  final ValueChanged<UnitSystem> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final ints = List<int>.generate(331, (index) => 80 + index);
    final decs = List<int>.generate(10, (index) => index);
    final intPart = weight.lb.floor().clamp(80, 410);
    final decimalPart = ((weight.lb - intPart) * 10).round().clamp(0, 9);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()!.surface2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PickerWheel<int>(
                values: ints,
                initialIndex: ints.indexOf(intPart),
                onSelected: (value) => onChanged(
                  BodyWeight.fromLb(value + decimalPart / 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: PickerWheel<int>(
                values: decs,
                initialIndex: decimalPart,
                onSelected: (value) => onChanged(
                  BodyWeight.fromLb(intPart + value / 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: PickerWheel<UnitSystem>(
                values: const [UnitSystem.metric, UnitSystem.imperial],
                initialIndex: 1,
                onSelected: onUnitChanged,
                displayValue: (value) =>
                    value == UnitSystem.metric ? 'kg' : 'lb',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
