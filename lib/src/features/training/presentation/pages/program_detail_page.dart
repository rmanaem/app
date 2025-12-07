import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/domain/repositories/program_repository.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/program_detail_view_model.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// A full-screen page displaying detailed information about a program.
class ProgramDetailPage extends StatelessWidget {
  /// Creates a [ProgramDetailPage].
  const ProgramDetailPage({required this.programId, super.key});

  /// The ID of the program to display.
  final String programId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProgramDetailViewModel(
        programId: programId,
        repository: context.read<ProgramRepository>(),
      ),
      child: const _ProgramDetailContentView(),
    );
  }
}

class _ProgramDetailContentView extends StatefulWidget {
  const _ProgramDetailContentView();

  @override
  State<_ProgramDetailContentView> createState() =>
      _ProgramDetailContentViewState();
}

class _ProgramDetailContentViewState extends State<_ProgramDetailContentView> {
  bool _shouldRefreshParent = false;

  void _markDirty() {
    setState(() {
      _shouldRefreshParent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<ProgramDetailViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.pop(_shouldRefreshParent);
      },
      child: Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          backgroundColor: colors.bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.ink),
            onPressed: () => context.pop(_shouldRefreshParent),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    switch (vm.state) {
                      case ProgramDetailViewState.loading:
                        return Center(
                          child: CircularProgressIndicator(color: colors.ink),
                        );
                      case ProgramDetailViewState.error:
                        return Center(child: Text(vm.errorMessage ?? 'Error'));
                      case ProgramDetailViewState.loaded:
                        return _ProgramDetailBody(
                          vm: vm,
                          onProgramChanged: _markDirty,
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramDetailBody extends StatelessWidget {
  const _ProgramDetailBody({required this.vm, required this.onProgramChanged});

  final ProgramDetailViewModel vm;
  final VoidCallback onProgramChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final details = vm.programDetails!;
    final metadata = vm.programMetadata!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: spacing.edgeAll(spacing.gutter),
            children: [
              // Header
              Row(
                children: [
                  Text(
                    details.split.toString().split('.').last.toUpperCase(),
                    style: typography.caption.copyWith(
                      color: colors.accent,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (metadata.isActive) ...[
                    const SizedBox(width: 8),
                    _ActiveBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                details.name,
                style: typography.display.copyWith(fontSize: 32, height: 1.1),
              ),
              const SizedBox(height: 12),
              if (metadata.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: metadata.tags
                      .map((tag) => _Tag(label: tag))
                      .toList(),
                ),
              const SizedBox(height: 16),
              Text(
                details.description,
                style: typography.body.copyWith(color: colors.inkSubtle),
              ),

              SizedBox(height: spacing.xxl),

              // Weekly Schedule Label
              Text(
                'WEEKLY SCHEDULE',
                style: typography.caption.copyWith(
                  color: colors.inkSubtle,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: spacing.md),

              // Schedule Cards
              ...List.generate(7, (index) {
                final workout = details.getWorkoutForDay(index);
                return _DayPreviewRow(dayIndex: index, workout: workout);
              }),
            ],
          ),
        ),

        _ActionButtons(vm: vm, onProgramChanged: onProgramChanged),
      ],
    );
  }
}

class _DayPreviewRow extends StatelessWidget {
  const _DayPreviewRow({required this.dayIndex, required this.workout});

  final int dayIndex;
  final DraftWorkout? workout;
  static const _days = [
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
    final typography = Theme.of(context).extension<AppTypography>()!;
    final isRest = workout == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isRest ? colors.bg : colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRest ? colors.borderIdle : colors.borderActive,
        ),
        boxShadow: !isRest
            ? [
                BoxShadow(
                  color: colors.bg.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // 1. Vertical Status Bar
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isRest ? colors.borderIdle : colors.accent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: !isRest
                  ? [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 20),

          // 2. Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _days[dayIndex],
                  style: typography.caption.copyWith(
                    color: isRest ? colors.inkSubtle : colors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRest ? 'REST DAY' : (workout?.name ?? 'Untitled'),
                  style: typography.title.copyWith(
                    fontSize: 18,
                    color: isRest ? colors.inkSubtle : colors.ink,
                  ),
                ),
                if (!isRest && workout?.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    workout!.description,
                    style: typography.body.copyWith(
                      fontSize: 13,
                      color: colors.inkSubtle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.vm, required this.onProgramChanged});
  final ProgramDetailViewModel vm;
  final VoidCallback onProgramChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final isTemplate = vm.isTemplate;
    final isActive = vm.isActive;

    return Container(
      padding: spacing.edgeAll(spacing.gutter),
      decoration: BoxDecoration(color: colors.bg),
      child: Column(
        children: [
          // Primary Action (Activate / Clone)
          if (!isActive)
            AppButton(
              label: isTemplate ? 'CLONE & START' : 'ACTIVATE PROGRAM',
              isPrimary: true,
              onTap: () async {
                try {
                  if (isTemplate) {
                    await vm.cloneAndStartProgram();
                    if (context.mounted) {
                      // Return true to signal that a new program was created
                      context.pop(true);
                    }
                  } else {
                    await vm.activateProgram();
                    if (context.mounted) context.pop(true);
                  }
                } on Exception catch (e, stack) {
                  debugPrint('Error in CLONE & START: $e\n$stack');
                }
              },
            ),

          // Secondary Actions (Edit / Delete)
          if (!isTemplate) ...[
            if (!isActive) SizedBox(height: spacing.md),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'EDIT',
                    icon: Icons.edit,
                    isPrimary: true,
                    onTap: () async {
                      // Navigate to Builder with the specific ID
                      final result = await context.push(
                        '/training/builder/structure/${vm.programId}',
                      );
                      if (result == true && context.mounted) {
                        onProgramChanged();
                        unawaited(vm.refresh());
                      }
                    },
                  ),
                ),
                // Delete Button (only if not active)
                if (!isActive) ...[
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        unawaited(
                          _showDeleteConfirmation(context, () async {
                            await vm.deleteProgram();
                            if (context.mounted) context.pop(true);
                          }),
                        );
                      },
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 56, // Match standard button height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: colors.danger.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, color: colors.danger),
                            const SizedBox(width: 8),
                            Text(
                              'DELETE',
                              style: typography.button.copyWith(
                                color: colors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    VoidCallback onConfirm,
  ) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'DELETE PROGRAM?',
          style: typography.title.copyWith(fontSize: 18, color: colors.ink),
        ),
        content: Text(
          'This action cannot be undone. '
          'The program schedule will be permanently removed.',
          style: typography.body.copyWith(color: colors.inkSubtle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Cancel
            child: Text(
              'CANCEL',
              style: typography.button.copyWith(color: colors.inkSubtle),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              onConfirm(); // Proceed with delete
            },
            child: Text(
              'DELETE',
              style: typography.button.copyWith(color: colors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'ACTIVE',
        style: typography.caption.copyWith(
          color: colors.bg,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceHighlight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: typography.caption.copyWith(
          fontSize: 10,
          color: colors.inkSubtle,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
