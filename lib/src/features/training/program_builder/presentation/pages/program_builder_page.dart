import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/program_builder/domain/repositories/program_builder_repository.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/viewmodels/program_builder_view_model.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/sequence_toggle.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/split_dial.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Page for configuring a training program blueprint.
class ProgramBuilderPage extends StatelessWidget {
  /// Creates the program builder page.
  const ProgramBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return ChangeNotifierProvider(
      create: (context) => ProgramBuilderViewModel(
        context.read<ProgramBuilderRepository>(),
      ),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ProgramBuilderViewModel>();
          final typography = Theme.of(context).extension<AppTypography>()!;

          return Scaffold(
            backgroundColor: colors.bg,
            appBar: AppBar(
              backgroundColor: colors.bg,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.close, color: colors.inkSubtle),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'NEW PROGRAM',
                style: typography.caption.copyWith(
                  letterSpacing: 3,
                  color: colors.inkSubtle,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: spacing.edgeAll(spacing.gutter),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(label: '01 // NAME'),
                          SizedBox(height: spacing.md),
                          _NameInput(
                            initialValue: vm.programName,
                            onChanged: vm.setName,
                          ),
                          SizedBox(height: spacing.xl),
                          const _SectionHeader(label: '02 // SPLIT'),
                          SizedBox(height: spacing.sm),
                          Text(
                            'Swipe to select base template.',
                            style: typography.caption.copyWith(
                              color: colors.inkSubtle,
                            ),
                          ),
                          SizedBox(height: spacing.md),
                          SplitDial(
                            selectedSplit: vm.selectedSplit,
                            onChanged: vm.setSplit,
                          ),
                          SizedBox(height: spacing.xl),
                          const _SectionHeader(label: '03 // SCHEDULE'),
                          SizedBox(height: spacing.md),
                          Text(
                            'Tap keys to toggle active training days.',
                            style: typography.body.copyWith(
                              color: colors.inkSubtle,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: spacing.lg),
                          SequenceToggle(
                            schedule: vm.schedule,
                            onToggle: vm.toggleDay,
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.gutter,
                      0,
                      spacing.gutter,
                      spacing.gutter + 20,
                    ),
                    child: AppButton(
                      label: 'CONFIRM & BUILD WORKOUTS',
                      isPrimary: true,
                      onTap: vm.isValid
                          ? () async {
                              await vm.saveProgram();
                              if (context.mounted) {
                                await context.push(
                                  '/training/builder/structure',
                                );
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Text(
      label,
      style: typography.caption.copyWith(
        color: colors.accent,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      style: typography.display.copyWith(color: colors.ink, fontSize: 24),
      cursorColor: colors.accent,
      decoration: InputDecoration(
        hintText: 'Winter Bulk',
        hintStyle: typography.display.copyWith(
          color: colors.borderIdle,
          fontSize: 24,
        ),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderIdle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderActive),
        ),
      ),
    );
  }
}
