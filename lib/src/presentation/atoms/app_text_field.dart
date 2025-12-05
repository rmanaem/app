import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

/// A standardized text field atom for the application.
///
/// Supports a [isGhost] variant for transparent, borderless inputs
/// used in modals or special contexts.
class AppTextField extends StatelessWidget {
  /// Creates a new [AppTextField].
  const AppTextField({
    required this.controller,
    this.hintText,
    this.isGhost = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    super.key,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// Optional hint text to display when empty.
  final String? hintText;

  /// Whether to render as a "Ghost" input (transparent, borderless).
  /// Defaults to false.
  final bool isGhost;

  /// Whether to autofocus the text field.
  final bool autofocus;

  /// Text capitalization strategy.
  final TextCapitalization textCapitalization;

  /// Maximum lines for the text field.
  final int? maxLines;

  /// Minimum lines for the text field.
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: typography.body.copyWith(color: colors.ink, height: 1.5),
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: typography.body.copyWith(color: colors.inkSubtle),
        // Ghost Variant Logic
        filled: !isGhost,
        border: isGhost ? InputBorder.none : null,
        focusedBorder: isGhost ? InputBorder.none : null,
        enabledBorder: isGhost ? InputBorder.none : null,
        contentPadding: isGhost ? EdgeInsets.zero : null,
      ),
    );
  }
}
