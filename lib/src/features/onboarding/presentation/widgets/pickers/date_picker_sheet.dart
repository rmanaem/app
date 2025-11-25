import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Displays a "Ceramic" date picker sheet.
Future<DateTime?> showDobPickerSheet({
  required BuildContext context,
  required DateTime? initial,
}) {
  final colors = Theme.of(context).extension<AppColors>()!;
  final spacing = Theme.of(context).extension<AppSpacing>()!;
  final typography = Theme.of(context).extension<AppTypography>()!;
  var tempDate = initial ?? DateTime(2000);

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: colors.bg, // Deep Onyx
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
              'Birthday',
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
              width: double.infinity,
              child: Center(
                child: SizedBox(
                  height: 250,
                  child: CupertinoTheme(
                    data:
                        const CupertinoThemeData(
                          brightness: Brightness.dark,
                        ).copyWith(
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                              color: colors.ink,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Rounded',
                            ),
                          ),
                        ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: tempDate,
                      maximumDate: DateTime.now(),
                      minimumYear: 1900,
                      backgroundColor: Colors.transparent,
                      onDateTimeChanged: (value) => tempDate = value,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
              child: AppButton(
                label: 'CONFIRM',
                isPrimary: true,
                onTap: () => Navigator.of(sheetContext).pop(tempDate),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    },
  );
}
