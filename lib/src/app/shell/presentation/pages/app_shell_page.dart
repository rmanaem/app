import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// Root shell for the main application, managing bottom navigation.
class AppShellPage extends StatelessWidget {
  /// Creates the app shell with the provided [navigationShell].
  const AppShellPage({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell managing the nested routes.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: colors.surface,
        indicatorColor: colors.accent.withValues(alpha: 0.2),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Training',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO(user): Implement quick action sheet.
        },
        backgroundColor: colors.accent,
        foregroundColor: colors.bg,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
