import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starter_app/src/features/settings/domain/entities/user_preferences.dart';
import 'package:starter_app/src/features/settings/presentation/viewstate/settings_view_state.dart';

/// Manages state and business logic for the Settings screen.
class SettingsViewModel extends ChangeNotifier {
  /// Creates the ViewModel and starts initialization.
  SettingsViewModel() {
    unawaited(_init());
  }

  SettingsViewState _state = SettingsViewState.initial();

  /// The current view state.
  SettingsViewState get state => _state;

  Future<void> _init() async {
    _emit(_state.copyWith(isLoading: true));
    // Simulate loading data from local storage/repository
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _emit(_state.copyWith(isLoading: false));
  }

  /// Toggles the food reminder setting.
  void toggleFoodReminder({required bool isEnabled}) {
    _emit(_state.copyWith(foodReminderEnabled: isEnabled));
  }

  /// Toggles the weight reminder setting.
  void toggleWeightReminder({required bool isEnabled}) {
    _emit(_state.copyWith(weightReminderEnabled: isEnabled));
  }

  /// Toggles the training reminder setting.
  void toggleTrainingReminder({required bool isEnabled}) {
    _emit(_state.copyWith(trainingReminderEnabled: isEnabled));
  }

  /// Sets the weight unit preference.
  void setWeightUnit(WeightUnit unit) {
    _emit(_state.copyWith(weightUnit: unit));
  }

  /// Sets the height unit preference.
  void setHeightUnit(HeightUnit unit) {
    _emit(_state.copyWith(heightUnit: unit));
  }

  /// Sets the theme mode preference.
  void setThemeMode(AppThemeMode mode) {
    _emit(_state.copyWith(themeMode: mode));
  }

  /// Signs the user out.
  Future<void> signOut() async {
    _emit(_state.copyWith(isLoading: true));
    // Simulate network request for sign out
    await Future<void>.delayed(const Duration(seconds: 1));
    _emit(_state.copyWith(isLoading: false));
  }

  void _emit(SettingsViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
