import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Root widget for the template application, wired with [GoRouter].
class App extends StatelessWidget {
  /// Creates the template app for the provided [envName].
  const App({required this.envName, super.key});

  /// Name of the environment currently running (e.g. dev/prod).
  final String envName;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: Text('Nutrition ($envName)')),
            body: const Center(child: Text('Hello from template')),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Nutrition',
      routerConfig: router,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
