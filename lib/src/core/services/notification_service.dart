/// Contract for displaying user-facing notifications.
abstract class NotificationService {
  /// Show a success notification with the given [message].
  void showSuccess(String message);

  /// Show an error notification with the given [message].
  void showError(String message);

  /// Show an informational notification with the given [message].
  void showInfo(String message);
}
