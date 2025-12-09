import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/features/settings/domain/entities/user_preferences.dart';
import 'package:starter_app/src/features/settings/presentation/pages/nutrition_target_page.dart';
import 'package:starter_app/src/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:starter_app/src/features/settings/presentation/widgets/settings_card.dart';
import 'package:starter_app/src/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:starter_app/src/features/settings/presentation/widgets/settings_tile.dart';
import 'package:starter_app/src/presentation/atoms/segmented_toggle.dart';

/// The Settings screen.
class SettingsPage extends StatelessWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Consumer<SettingsViewModel>(
            builder: (context, vm, _) {
              final state = vm.state;

              if (state.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: colors.ink),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SettingsSectionHeader(title: 'Account'),
                    SettingsCard(
                      children: [
                        SettingsTile(
                          label: 'Profile',
                          onTap: () {
                            // TODO(app-team): Navigate to profile edit
                          },
                        ),
                        SettingsTile(
                          label: 'Email',
                          valueLabel: state.email,
                        ),
                        SettingsTile(
                          label: 'Sign Out',
                          onTap: () => unawaited(vm.signOut()),
                        ),
                        SettingsTile(
                          label: 'Delete Account',
                          isDestructive: true,
                          onTap: () {
                            // TODO(app-team): Show delete account confirmation
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    const SettingsSectionHeader(title: 'Preferences'),
                    SettingsCard(
                      children: [
                        SettingsTile(
                          label: 'Nutrition Strategy',
                          valueLabel: 'Targets & Macros',
                          onTap: () {
                            unawaited(
                              Navigator.of(context, rootNavigator: true).push(
                                PageRouteBuilder<void>(
                                  fullscreenDialog: true,
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const NutritionTargetPage(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        const begin = Offset(0, 1);
                                        const end = Offset.zero;
                                        const curve = Curves.easeOutQuint;
                                        final tween = Tween(
                                          begin: begin,
                                          end: end,
                                        ).chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                ),
                              ),
                            );
                          },
                        ),
                        _SettingsSegmentedRow<WeightUnit>(
                          label: 'Weight Unit',
                          value: state.weightUnit,
                          options: const [WeightUnit.kg, WeightUnit.lb],
                          labels: const {
                            WeightUnit.kg: 'KG',
                            WeightUnit.lb: 'LB',
                          },
                          onChanged: vm.setWeightUnit,
                        ),
                        _SettingsSegmentedRow<HeightUnit>(
                          label: 'Height Unit',
                          value: state.heightUnit,
                          options: const [HeightUnit.cm, HeightUnit.ftIn],
                          labels: const {
                            HeightUnit.cm: 'CM',
                            HeightUnit.ftIn: 'FT',
                          },
                          onChanged: vm.setHeightUnit,
                        ),
                        _SettingsSegmentedRow<AppThemeMode>(
                          label: 'Theme',
                          value: state.themeMode,
                          options: const [
                            AppThemeMode.dark,
                            AppThemeMode.light,
                            AppThemeMode.system,
                          ],
                          labels: const {
                            AppThemeMode.dark: 'Dark',
                            AppThemeMode.light: 'Light',
                            AppThemeMode.system: 'Auto',
                          },
                          onChanged: vm.setThemeMode,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    const SettingsSectionHeader(title: 'Notifications'),
                    SettingsCard(
                      children: [
                        SettingsTile(
                          label: 'Food Logging',
                          onTap: () => vm.toggleFoodReminder(
                            isEnabled: !state.foodReminderEnabled,
                          ),
                          trailing: Switch.adaptive(
                            value: state.foodReminderEnabled,
                            thumbColor: WidgetStateProperty.resolveWith(
                              (states) {
                                return states.contains(WidgetState.selected)
                                    ? colors.ink
                                    : colors.inkSubtle;
                              },
                            ),
                            trackColor: WidgetStateProperty.resolveWith(
                              (states) {
                                return states.contains(WidgetState.selected)
                                    ? colors.accent
                                    : colors.bg;
                              },
                            ),
                            onChanged: (isEnabled) => vm.toggleFoodReminder(
                              isEnabled: isEnabled,
                            ),
                          ),
                        ),
                        SettingsTile(
                          label: 'Weigh-In',
                          onTap: () => vm.toggleWeightReminder(
                            isEnabled: !state.weightReminderEnabled,
                          ),
                          trailing: Switch.adaptive(
                            value: state.weightReminderEnabled,
                            thumbColor: WidgetStateProperty.resolveWith(
                              (states) {
                                return states.contains(WidgetState.selected)
                                    ? colors.ink
                                    : colors.inkSubtle;
                              },
                            ),
                            trackColor: WidgetStateProperty.resolveWith(
                              (states) {
                                return states.contains(WidgetState.selected)
                                    ? colors.accent
                                    : colors.bg;
                              },
                            ),
                            onChanged: (isEnabled) => vm.toggleWeightReminder(
                              isEnabled: isEnabled,
                            ),
                          ),
                        ),
                        SettingsTile(
                          label: 'Training',
                          onTap: () => vm.toggleTrainingReminder(
                            isEnabled: !state.trainingReminderEnabled,
                          ),
                          trailing: Switch.adaptive(
                            value: state.trainingReminderEnabled,
                            thumbColor: WidgetStateProperty.resolveWith(
                              (states) {
                                return states.contains(WidgetState.selected)
                                    ? colors.ink
                                    : colors.inkSubtle;
                              },
                            ),
                            trackColor: WidgetStateProperty.resolveWith(
                              (states) {
                                return states.contains(WidgetState.selected)
                                    ? colors.accent
                                    : colors.bg;
                              },
                            ),
                            onChanged: (isEnabled) => vm.toggleTrainingReminder(
                              isEnabled: isEnabled,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    const SettingsSectionHeader(title: 'Legal & Privacy'),
                    SettingsCard(
                      children: [
                        SettingsTile(
                          label: 'Terms of Service',
                          onTap: () {}, // TODO(app-team): Open URL
                        ),
                        SettingsTile(
                          label: 'Privacy Policy',
                          onTap: () {}, // TODO(app-team): Open URL
                        ),
                        SettingsTile(
                          label: 'Health Disclaimer',
                          onTap: () {}, // TODO(app-team): Open URL
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'v${state.appVersion}',
                        style: TextStyle(
                          color: colors.inkSubtle,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 64),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettingsSegmentedRow<T> extends StatelessWidget {
  const _SettingsSegmentedRow({
    required this.label,
    required this.value,
    required this.options,
    required this.labels,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> options;
  final Map<T, String> labels;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: colors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: SegmentedToggle<T>(
              value: value,
              options: options,
              labels: labels,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
