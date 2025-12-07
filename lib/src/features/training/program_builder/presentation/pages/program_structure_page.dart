import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/viewmodels/program_structure_view_model.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/structure_day_card.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Page for reviewing the program structure and assigned workouts.
class ProgramStructurePage extends StatelessWidget {
  /// Creates the structure page.
  const ProgramStructurePage({super.key});

  static const List<String> _days = <String>[
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final vm = context.watch<ProgramStructureViewModel>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'STRUCTURE',
          style: typography.caption.copyWith(
            letterSpacing: 3,
            color: colors.inkSubtle,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: vm.isLoading || vm.draft == null
          ? Center(child: CircularProgressIndicator(color: colors.ink))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: spacing.edgeAll(spacing.gutter),
                    children: [
                      Text(
                        'Review and edit your weekly schedule.',
                        style: typography.body.copyWith(
                          color: colors.inkSubtle,
                        ),
                      ),
                      SizedBox(height: spacing.lg),
                      ...List.generate(7, (index) {
                        final dayActive = vm.draft!.schedule[index] ?? false;
                        final workout = vm.draft!.getWorkoutForDay(index);
                        return StructureDayCard(
                          dayName: _days[index],
                          isRestDay: !dayActive,
                          workout: workout,
                          onTap: workout != null
                              ? () async {
                                  await context.push(
                                    '/training/builder/editor/${workout.id}',
                                  );
                                  if (context.mounted) {
                                    unawaited(vm.refresh());
                                  }
                                }
                              : null,
                        );
                      }),
                      // Add padding at the bottom so the last card isn't hidden
                      // behind the floating button area if we used a Stack,
                      // but here in a Column it ensures scroll space.
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // THE MISSING PIECE: The Publish Button
                Container(
                  padding: EdgeInsets.fromLTRB(
                    spacing.gutter,
                    0,
                    spacing.gutter,
                    spacing.gutter + 20,
                  ),
                  decoration: BoxDecoration(
                    color: colors.bg,
                    border: Border(top: BorderSide(color: colors.borderIdle)),
                  ),
                  child: AppButton(
                    label: 'PUBLISH PROGRAM',
                    isPrimary: true,
                    onTap: () => vm.publishProgram(context),
                  ),
                ),
              ],
            ),
    );
  }
}
