we want to build a robust Notification System that leverages Flutter's native ScaffoldMessenger (the most stable standard) but abstracted behind a clean service layer.

Here is the comprehensive implementation plan.

1. The Architecture: "The Notification Pipeline"

We will move the logic out of the Widget (LogWeightSheet) and into a Service, managed by dependency injection.

    Layer: Core (Service Definition & Implementation)

    Layer: Presentation/Molecules (The UI Component)

    Mechanism: GlobalKey<ScaffoldMessengerState>

This approach allows your ViewModels to fire-and-forget notifications like _notificationService.showSuccess("Weight logged") without knowing what a BuildContext or SnackBar is.


2. Implementation Plan

Step 1: Define the Atomic Component (Molecule)

We need a standard UI container for notifications that matches your "Obsidian & Steel" aesthetic (High contrast, bordered, distinct).

File: lib/src/presentation/molecules/app_snackbar_content.dart

```Dart
import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';

enum SnackbarType { success, error, info }

class AppSnackbarContent extends StatelessWidget {
  const AppSnackbarContent({
    required this.message,
    this.type = SnackbarType.info,
    super.key,
  });

  final String message;
  final SnackbarType type;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final (icon, accentColor) = switch (type) {
      SnackbarType.success => (Icons.check_circle_outline, colors.success),
      SnackbarType.error => (Icons.error_outline, colors.danger),
      SnackbarType.info => (Icons.info_outline, colors.accent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderIdle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: typography.body.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

Step 2: Create the Global Key (The Bridge)

We need a way to access the ScaffoldMessenger without a context from the ViewModels.

File: lib/src/app/scaffold_messenger_key.dart

```Dart

import 'package:flutter/material.dart';

/// Global key to access the ScaffoldMessenger state from anywhere.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = 
    GlobalKey<ScaffoldMessengerState>();
```

Wiring in app.dart: You must assign this key to your MaterialApp.

```Dart
// lib/src/app/app.dart
MaterialApp.router(
  scaffoldMessengerKey: rootScaffoldMessengerKey, // <--- Add this line
  routerConfig: router,
  // ... other configs
);
```

Step 3: Define the Service Contract (Core)

This keeps your architecture clean. ViewModels talk to this interface, not Flutter.

File: lib/src/core/services/notification_service.dart

```Dart
abstract class NotificationService {
  void showSuccess(String message);
  void showError(String message);
  void showInfo(String message);
}
```

Step 4: Implement the Service (Data/Infrastructure)

This implementation uses the rootScaffoldMessengerKey to show the standard Flutter SnackBar, but wraps our custom AppSnackbarContent inside it.

File: lib/src/core/services/scaffold_notification_service.dart

```Dart
import 'package:flutter/material.dart';
import 'package:starter_app/src/app/scaffold_messenger_key.dart';
import 'package:starter_app/src/core/services/notification_service.dart';
import 'package:starter_app/src/presentation/molecules/app_snackbar_content.dart';

class ScaffoldNotificationService implements NotificationService {
  @override
  void showSuccess(String message) => _show(message, SnackbarType.success);

  @override
  void showError(String message) => _show(message, SnackbarType.error);

  @override
  void showInfo(String message) => _show(message, SnackbarType.info);

  void _show(String message, SnackbarType type) {
    final state = rootScaffoldMessengerKey.currentState;
    if (state == null) {
      debugPrint(
        'WARNING: Root ScaffoldMessenger state is null. '
        'Notification skipped: $message',
      );
      return;
    }

    final mediaQuery = MediaQuery.maybeOf(state.context);
    final size = mediaQuery?.size ?? Size.zero;
    final topPadding = mediaQuery?.padding.top ?? 0.0;

    final duration = type == SnackbarType.error
        ? const Duration(seconds: 4)
        : const Duration(milliseconds: 2000);

    // Compute a bottom margin to float near the top.
    final topOffset = topPadding + 200;
    final bottomMargin = size.height > 0 ? size.height - topOffset : 0.0;

    state
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.up,
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: bottomMargin,
          ),
          padding: EdgeInsets.zero,
          duration: duration,
          content: AppSnackbarContent(message: message, type: type),
        ),
      );
  }
}
```

3. Usage in "Log Weight" Logic

Now you can refactor your LogWeightSheet logic. Ideally, the saving logic should move to a ViewModel (as per MVVM), but if you are keeping it in the widget for now, you can still use the service pattern.

Dependency Injection (Provider Setup): Ensure ScaffoldNotificationService is provided at the top level in lib/src/app/app.dart.

```Dart
Provider<NotificationService>(
  create: (_) => ScaffoldNotificationService(),
),
```

Refactor LogweightSheet to use notification service to show notification:
```Dart
// Inside _handleSave
Future<void> _handleSave() async {
  setState(() => _isSaving = true);
  
  // ... await repository logic ...

  if (mounted) {
    Navigator.of(context).pop(_currentWeight);
  }
}

// In the caller (e.g., AppShellPage)
final weight = await showModalBottomSheet<double>(...);
if (context.mounted && weight != null) {
  context.read<NotificationService>().showSuccess(
        'Logged ${weight.toStringAsFixed(1)} kg',
      );
}
```

Answer to the questions:

Q: Where in lib/src/app/app.dart should we slot the NotificationService provider inside the existing MultiProvider, and are there any import/ordering preferences we should follow?

A: Provider Placement in app.dart

Location: The NotificationService is a Core Service (like Analytics). It has no dependencies, but other layers (Repositories, ViewModels) might depend on it. Therefore, it should be initialized first, right alongside AnalyticsService.

```Dart
// Imports
import 'package:starter_app/src/core/services/scaffold_notification_service.dart';
import 'package:starter_app/src/core/services/notification_service.dart';

// ... inside the build method
return MultiProvider(
  providers: [
    // 1. Core Services (Initialize these first)
    Provider<AnalyticsService>(create: (_) => FirebaseAnalyticsService()),
    Provider<NotificationService>(create: (_) => ScaffoldNotificationService()), // <--- Slot it here

    // 2. Repositories (Data Layer)
    Provider<PlanRepository>(...),
    
    // 3. ViewModels (Presentation Layer)
    // ...
  ],
  child: ...
);
```

Q: Do we want to keep state.clearSnackBars() (overwrite behavior) or allow queueing when multiple events fire quickly?

A: Queueing vs. Overwriting

Verdict: Keep clearSnackBars() (Overwrite).

Rationale: The "Log Fast" philosophy requires the interface to feel snappy and responsive.

    Scenario: A user logs Food, Weight, and Workout in rapid succession (within 3 seconds).

    If Queued: The user has to wait 6+ seconds to see the last confirmation. The UI feels "laggy" or behind.

    If Overwritten: The UI immediately confirms the current reality. The previous message is irrelevant the moment the new action is taken.

Q: For the floating SnackBar style, should we add bottom padding/safe-area spacing so it clears the bottom nav + FAB shell, and set a default horizontal margin?

A: Styling: Margins & Durations

Verdict: Yes, add explicit margins and duration logic.

To maintain the "Premium" feel, the SnackBar must not obscure the Bottom Navigation ("Control Panel") or the FAB. It should float strictly above them.

Updated ScaffoldNotificationService Logic:

```Dart
void _show(String message, SnackbarType type) {
    final state = rootScaffoldMessengerKey.currentState;
    if (state == null) {
      // Safety check (see point 4 below)
      debugPrint('WARNING: Root ScaffoldMessenger state is null. Notification skipped: $message');
      return;
    }

    state.clearSnackBars(); 

    // UX Timing: Errors need more reading time than success toasts
    final duration = type == SnackbarType.error 
        ? const Duration(seconds: 4) 
        : const Duration(milliseconds: 2000);

    state.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        // MARGINS: 16px horizontal, 100px bottom to clear Nav Bar + FAB
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        padding: EdgeInsets.zero, // Let the inner Molecule handle padding
        duration: duration,
        content: AppSnackbarContent(message: message, type: type),
      ),
    );
  }
```

Q: Is a silent no-op acceptable when rootScaffoldMessengerKey.currentState is null (e.g., early lifecycle/tests), or should we log/throw in debug?

A: Verdict: Silent in Production, Log in Debug.

Throwing an exception for a missing toast would crash the app for a trivial UI embellishment. However, developers need to know if the key isn't wired up.

Implementation: Use debugPrint (as shown in the snippet above) or your specific Logger utility if you have one in core.

Q: Do you want a widget test that verifies the service renders AppSnackbarContent via the global key, or skip tests for this layer?

A:Testing Strategy

Verdict: Yes, add a Widget Test.

Since this service relies on a GlobalKey and specific Widget tree structure, a Unit test won't catch integration issues. A simple Widget test ensures the service actually finds the key and renders the molecule.

File: test/core/services/scaffold_notification_service_test.dart

```Dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/app/scaffold_messenger_key.dart';
import 'package:starter_app/src/core/services/scaffold_notification_service.dart';
import 'package:starter_app/src/presentation/molecules/app_snackbar_content.dart';

void main() {
  testWidgets('Service renders AppSnackbarContent via global key', (tester) async {
    // 1. Pump the app shell with the specific key
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey, // The real key
        home: Scaffold(
          body: Container(),
        ),
      ),
    );

    // 2. Instantiate the service (no mocks needed for this integration test)
    final service = ScaffoldNotificationService();

    // 3. Trigger notification
    service.showSuccess('Test Message');
    await tester.pump(); // Start animation

    // 4. Verify custom Molecule is present
    expect(find.byType(AppSnackbarContent), findsOneWidget);
    expect(find.text('Test Message'), findsOneWidget);
    
    // 5. Verify duration/animation settles
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(AppSnackbarContent), findsNothing);
  });
}
```

Appendix: Current Implementation vs. Spec

- Delivery mechanism: Uses `ScaffoldMessenger.showSnackBar` with floating behavior and a large bottom margin to pin it near the top. Spec originally called for a bottom-floating SnackBar.
- Positioning: Current toasts are top-positioned via margin; spec positioned floating at the bottom with horizontal margins and a bottom offset.
- Infrastructure: Removed overlay usage; no `rootNavigatorKey` dependency remains (spec didn’t require it).
- Logging/fallbacks: Service logs when scaffold/overlay context is missing; spec only logged when `currentState` was null.
- Tests: Widget test still exists; no navigator key requirement now that overlay was removed.
