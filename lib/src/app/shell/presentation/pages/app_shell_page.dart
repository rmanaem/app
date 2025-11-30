import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/nutrition/presentation/navigation/nutrition_page_arguments.dart';
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
          backgroundColor: colors.surface,
          foregroundColor: colors.ink,
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
      onLogFood: () => _navigateToNutrition(context),
      onLogWeight: () => _navigateToToday(context),
      onStartWorkout: () => _navigateToTraining(context),
    );
  }

  void _navigateToNutrition(BuildContext context) {
    context.go(
      '/nutrition',
      extra: const NutritionPageArguments(showQuickAddSheet: true),
    );
  }

  void _navigateToToday(BuildContext context) {
    context.go('/today');
  }

  void _navigateToTraining(BuildContext context) {
    context.go('/training');
  }
}
