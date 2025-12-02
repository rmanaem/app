import 'package:flutter/foundation.dart';
import 'package:starter_app/src/features/settings/domain/entities/user_preferences.dart';

/// Immutable state for the Settings screen.
@immutable
class SettingsViewState {
  /// Creates a view state snapshot.
  const SettingsViewState({
    required this.isLoading,
    required this.email,
    required this.weightUnit,
    required this.heightUnit,
    required this.themeMode,
    required this.foodReminderEnabled,
    required this.weightReminderEnabled,
    required this.trainingReminderEnabled,
    required this.appVersion,
  });

  /// Creates the initial state with default values.
  factory SettingsViewState.initial() {
    return const SettingsViewState(
      isLoading: true,
      email: 'user@example.com',
      weightUnit: WeightUnit.kg,
      heightUnit: HeightUnit.cm,
      themeMode: AppThemeMode.dark,
      foodReminderEnabled: true,
      weightReminderEnabled: false,
      trainingReminderEnabled: false,
      appVersion: '1.0.0 (100)',
    );
  }

  /// Whether the settings are currently loading.
  final bool isLoading;

  /// The user's email address.
  final String email;

  /// Selected unit for weight.
  final WeightUnit weightUnit;

  /// Selected unit for height.
  final HeightUnit heightUnit;

  /// Selected app theme mode.
  final AppThemeMode themeMode;

  /// Whether food logging reminders are enabled.
  final bool foodReminderEnabled;

  /// Whether weight logging reminders are enabled.
  final bool weightReminderEnabled;

  /// Whether training reminders are enabled.
  final bool trainingReminderEnabled;

  /// The current app version string.
  final String appVersion;

  /// Creates a copy with updated fields.
  SettingsViewState copyWith({
    bool? isLoading,
    String? email,
    WeightUnit? weightUnit,
    HeightUnit? heightUnit,
    AppThemeMode? themeMode,
    bool? foodReminderEnabled,
    bool? weightReminderEnabled,
    bool? trainingReminderEnabled,
    String? appVersion,
  }) {
    return SettingsViewState(
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      themeMode: themeMode ?? this.themeMode,
      foodReminderEnabled: foodReminderEnabled ?? this.foodReminderEnabled,
      weightReminderEnabled:
          weightReminderEnabled ?? this.weightReminderEnabled,
      trainingReminderEnabled:
          trainingReminderEnabled ?? this.trainingReminderEnabled,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
