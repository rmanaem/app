import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Cupertino-styled wheel used for numeric and unit selection.
class PickerWheel<T> extends StatefulWidget {
  /// Creates a wheel with the provided [values] and [initialIndex].
  const PickerWheel({
    required this.values,
    required this.initialIndex,
    required this.onSelected,
    super.key,
    this.displayValue,
    this.width = 80,
  });

  /// Values rendered by the wheel.
  final List<T> values;

  /// Initial selection index.
  final int initialIndex;

  /// Called when the selection changes.
  final ValueChanged<T> onSelected;

  /// Optional formatter for displaying each [values] entry.
  final String Function(T value)? displayValue;

  /// Width of the picker widget.
  final double width;

  @override
  State<PickerWheel<T>> createState() => _PickerWheelState<T>();
}

class _PickerWheelState<T> extends State<PickerWheel<T>> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialIndex.clamp(0, widget.values.length - 1);
    _controller = FixedExtentScrollController(initialItem: initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      width: widget.width,
      child: CupertinoPicker(
        scrollController: _controller,
        itemExtent: 44,
        magnification: 1.05,
        useMagnifier: true,
        squeeze: 1.1,
        backgroundColor: colors.surface,
        onSelectedItemChanged: (index) {
          widget.onSelected(widget.values[index]);
        },
        children: widget.values
            .map(
              (value) => Center(
                child: Text(
                  widget.displayValue?.call(value) ?? '$value',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: colors.ink),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
