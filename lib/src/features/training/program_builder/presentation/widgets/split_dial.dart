import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';

/// A horizontal carousel "Dial" for selecting the Program Split.
class SplitDial extends StatefulWidget {
  /// Creates a split dial.
  const SplitDial({
    required this.selectedSplit,
    required this.onChanged,
    super.key,
  });

  /// Currently selected split.
  final ProgramSplit selectedSplit;

  /// Callback when selection changes.
  final ValueChanged<ProgramSplit> onChanged;

  @override
  State<SplitDial> createState() => _SplitDialState();
}

class _SplitDialState extends State<SplitDial> {
  late final PageController _controller;
  static const double _viewportFraction = 0.85;

  @override
  void initState() {
    super.initState();
    final initialIndex = ProgramSplit.values.indexOf(widget.selectedSplit);
    _controller = PageController(
      initialPage: initialIndex,
      viewportFraction: _viewportFraction,
    );
  }

  @override
  void didUpdateWidget(SplitDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSplit != widget.selectedSplit) {
      final index = ProgramSplit.values.indexOf(widget.selectedSplit);
      if (_controller.hasClients && _controller.page?.round() != index) {
        unawaited(
          _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuint,
          ),
        );
      }
    }
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
      height: 220,
      child: PageView.builder(
        controller: _controller,
        itemCount: ProgramSplit.values.length,
        onPageChanged: (index) => widget.onChanged(ProgramSplit.values[index]),
        itemBuilder: (context, index) {
          final split = ProgramSplit.values[index];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              var value = 1.0;
              if (_controller.position.haveDimensions) {
                value = _controller.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              } else {
                value = split == widget.selectedSplit ? 1.0 : 0.7;
              }

              final isSelected = value > 0.9;

              return Center(
                child: Transform.scale(
                  scale: Curves.easeOut.transform(value),
                  child: Opacity(
                    opacity: isSelected ? 1.0 : 0.4,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? colors.borderActive
                              : colors.borderIdle,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colors.bg.withValues(alpha: 0.8),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: _SplitCardContent(split: split),
          );
        },
      ),
    );
  }
}

class _SplitCardContent extends StatelessWidget {
  const _SplitCardContent({required this.split});

  final ProgramSplit split;

  IconData _getIcon() {
    switch (split) {
      case ProgramSplit.ppl:
        return Icons.layers_outlined;
      case ProgramSplit.upperLower:
        return Icons.vertical_split_rounded;
      case ProgramSplit.fullBody:
        return Icons.accessibility_new_rounded;
      case ProgramSplit.broSplit:
        return Icons.fitness_center_rounded;
      case ProgramSplit.custom:
        return Icons.edit_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.ink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.ink.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _getIcon(),
              size: 28,
              color: colors.bg,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SPLIT TYPE',
            style: typography.caption.copyWith(
              color: colors.accent,
              letterSpacing: 2,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            split.label.toUpperCase(),
            style: typography.title.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              split.description,
              style: typography.body.copyWith(
                color: colors.inkSubtle,
                fontSize: 13,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
