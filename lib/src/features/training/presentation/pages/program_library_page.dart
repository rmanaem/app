import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/domain/entities/program.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/program_library_view_model.dart';
import 'package:starter_app/src/presentation/atoms/segmented_toggle.dart';

/// A page displaying the user's program library (user-created and templates).
class ProgramLibraryPage extends StatelessWidget {
  /// Creates the [ProgramLibraryPage].
  const ProgramLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final vm = context.watch<ProgramLibraryViewModel>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'PROGRAM LIBRARY',
          style: typography.caption.copyWith(
            letterSpacing: 2,
            color: colors.inkSubtle,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      // FAB for creating new programs (Only visible on 'Mine' tab)
      floatingActionButton: vm.selectedTabIndex == 0
          ? FloatingActionButton(
              backgroundColor: colors.accent,
              foregroundColor: colors.bg,
              onPressed: () => context.push('/training/builder'),
              child: const Icon(Icons.add),
            )
          : null,
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.ink))
          : Column(
              children: [
                Padding(
                  padding: spacing.edgeAll(spacing.gutter),
                  child: SegmentedToggle<int>(
                    value: vm.selectedTabIndex,
                    options: const [0, 1],
                    labels: const {0: 'Mine', 1: 'Templates'},
                    onChanged: vm.setTab,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      spacing.gutter,
                      0,
                      spacing.gutter,
                      80, // Pad for FAB
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75, // Taller cards for tags
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                    itemCount: vm.filteredPrograms.length,
                    itemBuilder: (context, index) {
                      return _ProgramCard(
                        program: vm.filteredPrograms[index],
                        onTap: () async {
                          // Wait for the detail page to close and check result
                          final result = await context.push(
                            '/training/program/${vm.filteredPrograms[index].id}',
                          );

                          if (context.mounted && result == true) {
                            // If a new program was cloned or program was edited/activated/deleted
                            // switch to 'Mine' tab (safe default) and refresh
                            vm.setTab(0);
                            unawaited(vm.refresh());
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program, required this.onTap});

  final Program program;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // Active = Accent, Inactive = Idle
            color: program.isActive ? colors.accent : colors.borderIdle,
            width: program.isActive ? 2 : 1,
          ),
          boxShadow: program.isActive
              ? [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            if (program.isActive)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ACTIVE',
                  style: typography.caption.copyWith(
                    color: colors.bg,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

            const Spacer(),

            // Split Label
            Text(
              program.split.toString().split('.').last.toUpperCase(),
              style: typography.caption.copyWith(
                color: colors.inkSubtle,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Name
            Text(
              program.name,
              style: typography.title.copyWith(fontSize: 18),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              program.description,
              style: typography.body.copyWith(
                fontSize: 12,
                color: colors.inkSubtle,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Template Tags (if any)
            if (program.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: program.tags.map((tag) => _Tag(label: tag)).toList(),
              ),
            ],
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: typography.caption.copyWith(
          fontSize: 9,
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
