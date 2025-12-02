import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// A container for grouping settings tiles.
/// Features rounded corners and inset dividers.
class SettingsCard extends StatelessWidget {
  /// Creates a card container for settings rows.
  const SettingsCard({required this.children, super.key});

  /// The list of settings tiles to display.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderIdle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildChildrenWithDividers(colors),
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers(AppColors colors) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(
          Divider(
            height: 1,
            thickness: 1,
            color: colors.borderIdle,
            indent: 16, // Inset left to match text alignment
            endIndent: 0,
          ),
        );
      }
    }
    return items;
  }
}
