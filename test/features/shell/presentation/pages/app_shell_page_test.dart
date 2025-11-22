import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/app/shell/presentation/pages/app_shell_page.dart';

void main() {
  group('AppShellPage', () {
    testWidgets('renders bottom navigation with 4 items', (tester) async {
      // Create a simple GoRouter with StatefulShellRoute for testing
      final router = GoRouter(
        initialLocation: '/today',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return AppShellPage(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/today',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Today')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/nutrition',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Nutrition')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/training',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Training')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/settings',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Settings')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: makeTheme(AppColors.light, dark: false),
          routerConfig: router,
        ),
      );

      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.text('Today'), findsAtLeastNWidgets(1));
      expect(find.text('Nutrition'), findsOneWidget);
      expect(find.text('Training'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders FAB', (tester) async {
      final router = GoRouter(
        initialLocation: '/today',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return AppShellPage(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/today',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Today')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/nutrition',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Nutrition')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/training',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Training')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/settings',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Settings')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: makeTheme(AppColors.light, dark: false),
          routerConfig: router,
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('tapping tab switches view', (tester) async {
      final router = GoRouter(
        initialLocation: '/today',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return AppShellPage(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/today',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Today Page')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/nutrition',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Nutrition Page')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/training',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Training Page')),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/settings',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Settings Page')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: makeTheme(AppColors.light, dark: false),
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Today tab
      expect(find.text('Today Page'), findsOneWidget);

      // Tap Nutrition tab
      await tester.tap(find.text('Nutrition'));
      await tester.pumpAndSettle();

      // Verify we're now on Nutrition tab
      expect(find.text('Nutrition Page'), findsOneWidget);
    });
  });
}
