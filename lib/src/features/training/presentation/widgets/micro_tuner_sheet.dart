import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/onboarding/presentation/widgets/pickers/tactile_ruler_picker.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// A focused modal for adjusting a single metric (Weight, Reps, or RPE).
class MicroTunerSheet extends StatefulWidget {
  /// Creates a micro tuner sheet.
  const MicroTunerSheet({
    required this.title,
    required this.initialValue,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    this.isInteger = false,
    super.key,
  });

  /// The title of the sheet.
  final String title;

  /// The initial value to display.
  final double initialValue;

  /// The unit label (e.g., 'kg', 'reps').
  final String unit;

  /// The minimum value.
  final double min;

  /// The maximum value.
  final double max;

  /// The step value for the ruler.
  final double step;

  /// Whether the value should be treated as an integer.
  final bool isInteger;

  @override
  State<MicroTunerSheet> createState() => _MicroTunerSheetState();
}

class _MicroTunerSheetState extends State<MicroTunerSheet> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: colors.borderIdle)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderIdle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Text(
              widget.title.toUpperCase(),
              style: typography.caption.copyWith(
                color: colors.inkSubtle,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: spacing.xl),

            // The Ruler
            SizedBox(
              height: 140,
              child: TactileRulerPicker(
                min: widget.min,
                max: widget.max,
                step: widget.step,
                initialValue: _currentValue,
                unitLabel: widget.unit,
                valueFormatter: (val) => widget.isInteger
                    ? val.toStringAsFixed(0)
                    : val.toStringAsFixed(1).replaceAll('.0', ''),
                onChanged: (val) {
                  setState(() => _currentValue = val);
                },
              ),
            ),

            SizedBox(height: spacing.xl),

            // Confirm Button
            Padding(
              padding: spacing.edgeAll(spacing.gutter),
              child: AppButton(
                label: 'CONFIRM',
                isPrimary: true,
                onTap: () {
                  // Simply return the value. No complex map needed.
                  Navigator.pop(context, _currentValue);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
