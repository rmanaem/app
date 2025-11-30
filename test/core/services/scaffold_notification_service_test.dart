import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/app/root_navigator_key.dart';
import 'package:starter_app/src/app/scaffold_messenger_key.dart';
import 'package:starter_app/src/core/services/scaffold_notification_service.dart';
import 'package:starter_app/src/presentation/molecules/app_snackbar_content.dart';

void main() {
  testWidgets(
    'ScaffoldNotificationService renders AppSnackbarContent via global key',
    (tester) async {
      const colors = AppColors.dark;
      final typography = AppTypography.from(colors);

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootNavigatorKey,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          theme: ThemeData(extensions: [colors, typography]),
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );

      // Ensure the scaffold messenger is mounted before triggering a toast.
      await tester.pump();

      ScaffoldNotificationService().showSuccess('Test Message');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppSnackbarContent), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(AppSnackbarContent), findsNothing);
    },
  );
}
