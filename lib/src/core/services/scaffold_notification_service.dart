import 'package:flutter/material.dart';
import 'package:starter_app/src/app/scaffold_messenger_key.dart';
import 'package:starter_app/src/core/services/notification_service.dart';
import 'package:starter_app/src/presentation/molecules/app_snackbar_content.dart';

/// Notification service that renders toasts via [ScaffoldMessenger].
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

    // Position Calculation:
    // Calculate a bottom margin that pushes the SnackBar toward the top.
    // Increasing the offset moves the SnackBar down; decreasing moves it up.
    // 200.0 clears status bar/notch while keeping the toast visible.
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
