import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';

import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/picker_sheet_scaffold.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/picker_wheel.dart';

/// Shows a wheel picker for height with inline unit toggle.
Future<({UnitSystem unit, Stature stature})?> showHeightPickerSheet({
  required BuildContext context,
  required UnitSystem unit,
  required Stature? current,
}) {
  var tempUnit = unit;
  var temp = current ?? Stature.fromCm(175);

  return showModalBottomSheet<({UnitSystem unit, Stature stature})>(
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
              ? _MetricHeightPicker(
                  stature: temp,
                  onChanged: (value) => temp = value,
                  onUnitChanged: (value) => setState(() => tempUnit = value),
                )
              : _ImperialHeightPicker(
                  stature: temp,
                  onChanged: (value) => temp = value,
                  onUnitChanged: (value) => setState(() => tempUnit = value),
                );

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PickerSheetHeader(title: 'Height'),
                SizedBox(height: 220, child: measurementWheels),
                PickerSheetActions(
                  onCancel: () => Navigator.of(sheetContext).pop(),
                  onDone: () => Navigator.of(sheetContext).pop(
                    (unit: tempUnit, stature: temp),
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

class _MetricHeightPicker extends StatelessWidget {
  const _MetricHeightPicker({
    required this.stature,
    required this.onChanged,
    required this.onUnitChanged,
  });

  final Stature stature;
  final ValueChanged<Stature> onChanged;
  final ValueChanged<UnitSystem> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final intValues = List<int>.generate(111, (index) => 120 + index);
    final decimalValues = List<int>.generate(10, (index) => index);
    var cmInt = stature.cm.floor().clamp(120, 230);
    final cmDecimal = ((stature.cm - cmInt) * 10).round().clamp(0, 9);
    if (!intValues.contains(cmInt)) {
      cmInt = 175;
    }

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
                values: intValues,
                initialIndex: intValues.indexOf(cmInt),
                onSelected: (value) =>
                    onChanged(Stature.fromCm(value + cmDecimal / 10)),
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
                values: decimalValues,
                initialIndex: cmDecimal,
                onSelected: (value) =>
                    onChanged(Stature.fromCm(cmInt + value / 10)),
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
                    value == UnitSystem.metric ? 'cm' : 'ft/in',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImperialHeightPicker extends StatelessWidget {
  const _ImperialHeightPicker({
    required this.stature,
    required this.onChanged,
    required this.onUnitChanged,
  });

  final Stature stature;
  final ValueChanged<Stature> onChanged;
  final ValueChanged<UnitSystem> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final feetValues = List<int>.generate(4, (index) => 4 + index);
    final inchValues = List<int>.generate(12, (index) => index);
    var footIndex = feetValues.indexOf(stature.feet);
    if (footIndex < 0) footIndex = 0;
    var inchIndex = inchValues.indexOf(
      stature.inchesRemainder.round().clamp(0, 11),
    );
    if (inchIndex < 0) inchIndex = 0;

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
                values: feetValues,
                initialIndex: footIndex,
                onSelected: (value) => onChanged(
                  Stature.fromImperial(
                    ft: value,
                    inch: stature.inchesRemainder,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                'ft',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: PickerWheel<int>(
                values: inchValues,
                initialIndex: inchIndex,
                onSelected: (value) => onChanged(
                  Stature.fromImperial(
                    ft: stature.feet,
                    inch: value.toDouble(),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                'in',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              width: 90,
              child: PickerWheel<UnitSystem>(
                values: const [UnitSystem.metric, UnitSystem.imperial],
                initialIndex: 1,
                onSelected: onUnitChanged,
                displayValue: (value) =>
                    value == UnitSystem.metric ? 'cm' : 'ft/in',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
