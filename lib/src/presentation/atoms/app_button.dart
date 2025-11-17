import 'package:flutter/material.dart';

/// Template-level button atom to ensure consistent styling.
class AppButton extends StatelessWidget {
  /// Creates a primary button with the provided [label].
  const AppButton({required this.label, super.key, this.onPressed});

  /// Text shown on the button.
  final String label;

  /// Optional handler invoked when the button is tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
