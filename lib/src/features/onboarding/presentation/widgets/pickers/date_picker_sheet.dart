import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:starter_app/src/app/design_system/app_colors.dart';

import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/picker_sheet_scaffold.dart';

/// Shows a modal wheel picker for selecting a date of birth.
Future<DateTime?> showDobPickerSheet({
  required BuildContext context,
  required DateTime? initial,
}) async {
  final colors = Theme.of(context).extension<AppColors>()!;
  var temp = initial ?? DateTime(DateTime.now().year - 25);
  final now = DateTime.now();

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: colors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PickerSheetHeader(title: 'Date of birth'),
            SizedBox(
              height: 220,
              child: CupertinoDatePicker(
                backgroundColor: colors.surface,
                mode: CupertinoDatePickerMode.date,
                initialDateTime: temp,
                maximumDate: now,
                minimumDate: DateTime(now.year - 100),
                onDateTimeChanged: (value) => temp = value,
              ),
            ),
            PickerSheetActions(
              onCancel: () => Navigator.of(sheetContext).pop(),
              onDone: () => Navigator.of(sheetContext).pop(
                DateTime(temp.year, temp.month, temp.day),
              ),
            ),
          ],
        ),
      );
    },
  );
}
