import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/core/services/notification_service.dart';
import 'package:starter_app/src/features/nutrition/domain/repositories/food_log_repository.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel.dart';
import 'package:starter_app/src/features/nutrition/presentation/widgets/quick_add_food_sheet.dart';
import 'package:starter_app/src/features/plan/domain/repositories/plan_repository.dart';
import 'package:starter_app/src/features/today/presentation/widgets/log_weight_sheet.dart';
import 'package:starter_app/src/features/today/presentation/widgets/quick_actions_sheet.dart';

/// Top-level shell that hosts the tab navigation and floating action button.
class AppShellPage extends StatelessWidget {
  /// Creates the shell with the provided nested navigation container.
  const AppShellPage({
    required this.navigationShell,
    super.key,
  });

  /// Nested navigation controller injected by `go_router`.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    // Adjust nav index to account for the center FAB spacer (at nav index 2).
    final navIndex = navigationShell.currentIndex >= 2
        ? navigationShell.currentIndex + 1
        : navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: colors.bg,
      body: navigationShell,
      // FLOAT THE FAB: Docked in the "Steel Beam" bottom bar
      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderIdle, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => unawaited(_showQuickActions(context)),
          backgroundColor: colors.accent,
          foregroundColor: colors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // THE CONTROL PANEL (Bottom Nav)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.borderIdle)),
        ),
        child: NavigationBar(
          backgroundColor: colors.bg, // Matches void, but separated by border
          indicatorColor:
              Colors.transparent, // No pill indicator, just icon color change
          selectedIndex: navIndex,
          height: 70, // Slightly taller for "Panel" feel
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (index) {
            if (index == 2) return; // Spacer under the FAB
            final branchIndex = index >= 2 ? index - 1 : index;
            navigationShell.goBranch(
              branchIndex,
              initialLocation: branchIndex == navigationShell.currentIndex,
            );
          },
          destinations: [
            _buildNavDest(
              context,
              Icons.dashboard_outlined,
              Icons.dashboard,
              'Today',
              0,
            ),
            _buildNavDest(
              context,
              Icons.restaurant_outlined,
              Icons.restaurant,
              'Nutrition',
              1,
            ),
            // Middle gap for FAB
            const NavigationDestination(
              icon: SizedBox(width: 48),
              label: '',
            ),
            _buildNavDest(
              context,
              Icons.fitness_center_outlined,
              Icons.fitness_center,
              'Training',
              2,
            ),
            _buildNavDest(
              context,
              Icons.settings_outlined,
              Icons.settings,
              'Settings',
              3,
            ),
          ],
        ),
      ),
    );
  }

  // Custom Destination Builder for "Active/Idle" states
  NavigationDestination _buildNavDest(
    BuildContext context,
    IconData icon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return NavigationDestination(
      icon: Icon(icon, color: colors.inkSubtle),
      selectedIcon: Icon(selectedIcon, color: colors.accent),
      label: label,
    );
  }

  Future<void> _showQuickActions(BuildContext context) {
    return QuickActionsSheet.show(
      context,
      onLogFood: () => unawaited(_openFoodModal(context)),
      onLogWeight: () => unawaited(_openWeightModal(context)),
      onStartWorkout: () => _navigateToTraining(context),
    );
  }

  Future<void> _openFoodModal(BuildContext context) async {
    final foodRepo = context.read<FoodLogRepository>();
    final planRepo = context.read<PlanRepository>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ChangeNotifierProvider(
          create: (_) => NutritionDayViewModel(
            foodLogRepository: foodRepo,
            planRepository: planRepo,
          ),
          child: Consumer<NutritionDayViewModel>(
            builder: (context, notifier, _) {
              return QuickAddFoodSheet(
                isSubmitting: notifier.state.isAddingEntry,
                errorText: notifier.state.addEntryErrorMessage,
                onErrorDismissed: notifier.clearQuickAddError,
                onSubmit: notifier.addQuickEntry,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openWeightModal(BuildContext context) async {
    final weight = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return const LogWeightSheet(initialWeight: 75);
      },
    );
    if (!context.mounted || weight == null) return;
    context.read<NotificationService>().showSuccess(
      'Logged ${weight.toStringAsFixed(1)} kg',
    );
  }

  void _navigateToTraining(BuildContext context) {
    context.go('/training');
  }
}
