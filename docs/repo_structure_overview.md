# Repo Structure Overview

This reflects the current codebase layout (Clean Architecture + MVVM with Atomic Design). It lists what exists **and what each file does** so you can jump in quickly. See `docs/ARCHITECTURE.md` for the import/layering rules that back this map.

---

## High-level map

```
lib/
├─ main.dart (+ per-flavor entrypoints)
├─ firebase_options_*.dart   # Generated configs
└─ src/
   ├─ app/           # Composition: router, providers, design tokens, shell
   ├─ bootstrap/     # SDK + env initialization
   ├─ config/        # Env definitions (no secrets)
   ├─ core/          # Cross-cutting services (no Flutter UI imports)
   ├─ presentation/  # Shared Atomic UI (atoms/molecules)
   └─ features/      # Feature modules (domain → data → presentation)
```

---

## Composition & platform wiring (`lib/src/app`)

- `app.dart` – Builds the `GoRouter`: onboarding routes (`/`, `/onboarding/*`) plus a `StatefulShellRoute` with tabs for Today (`/today`), Nutrition (`/nutrition`), Training (`/training`), and Settings (`/settings`). Wraps the tree in `MultiProvider` wiring:
  - `AnalyticsService` → `FirebaseAnalyticsService`
  - `NotificationService` → `ScaffoldNotificationService`
  - `PlanRepository` → `MemoryPlanRepository` (onboarding writes)
  - `FoodLogRepository` → `FoodLogRepositoryFake`
  - `GetCurrentPlan` → `PlanRepositoryFake` (Today data seed)
  - `TrainingOverviewRepository` → `TrainingOverviewRepositoryFake`
  - `OnboardingVm` global state holder with analytics injection
  Configures `MaterialApp.router` with `makeTheme` using `AppColors.light/dark` (currently forced to dark via `themeMode: ThemeMode.dark`).
- `design_system/`
  - `app_colors.dart` – ThemeExtension tokens (bg/surface/ink/accent/etc.).
  - `app_typography.dart` – ThemeExtension typography tokens derived from colors.
  - `app_spacing.dart` – Spacing constants.
  - `app_theme.dart` – Builds `ThemeData` using tokens.
- `root_navigator_key.dart` / `scaffold_messenger_key.dart` – Global keys consumed by the router and scaffold messenger.
- `shell/presentation/pages/app_shell_page.dart` – Bottom-nav scaffold hosting the tab branches, forwards taps to `StatefulNavigationShell`, and exposes the center “+” action that opens Today’s quick actions sheet.

---

## Boot & configuration

- `lib/src/bootstrap/bootstrap.dart` – Ensures bindings are initialized, sets up Firebase and RevenueCat, then runs the app with the provided env.
- `lib/src/config/env.dart` – `Env` enum describing flavor labels and RevenueCat public API keys.
- Entrypoints:
  - `lib/main.dart` – Delegates to `main_dev.dart`.
  - `lib/main_dev.dart` / `lib/main_prod.dart` – Call `bootstrap` with the flavor’s Firebase options/env.
  - `lib/main_auth_preview.dart` – Launches the standalone auth CTA preview app.

---

## Cross-cutting core (`lib/src/core`)

- `analytics/analytics_service.dart` – Abstract analytics contract.
- `analytics/firebase_analytics_service.dart` – Firebase-backed implementation.
- `services/notification_service.dart` – Interface for in-app/OS notifications.
- `services/scaffold_notification_service.dart` – Simple snackbar-based notification implementation.

---

## Shared Atomic UI (`lib/src/presentation`)

Atoms and molecules are feature-agnostic and consume only design tokens:

- `atoms/app_button.dart` – Primary/secondary CTA with loading and disabled states.
- `atoms/precision_slider.dart` – Fine-grained slider for numeric inputs.
- `atoms/fader_slider.dart` + `atoms/rectangular_slider_thumb_shape.dart` – Custom slider visuals used in onboarding configurators.
- `atoms/segmented_toggle.dart` – Two/three-way toggle control.
- `molecules/app_snackbar_content.dart` – Styled snackbar content block for `ScaffoldMessenger`.

---

## Feature modules (`lib/src/features`)

All features follow domain → data → presentation layering per `docs/ARCHITECTURE.md`.

### Onboarding (`features/onboarding`)
- **Domain**: Value objects (`activity_level.dart`, `goal.dart`, `measurements.dart`, `unit_system.dart`, `sex.dart`), `entities/user_plan.dart`, repository contract `plan_repository.dart`, `preview_estimator.dart`, use case `save_user_plan.dart`.
- **Infrastructure**: `memory_plan_repository.dart` (temp in-memory repository) and `standard_preview_estimator.dart` (Mifflin-St Jeor-based estimator with safety bounds).
- **Presentation**:
  - View models: `onboarding_vm.dart`, `goal_configuration_vm.dart`, `onboarding_summary_vm.dart`.
  - View state DTOs: `onboarding_goal_view_state.dart`, `onboarding_stats_view_state.dart`.
  - Navigation DTOs: `navigation/navigation.dart`, `navigation/onboarding_summary_arguments.dart`.
  - Pages: `welcome_page.dart`, `onboarding_goal_page.dart`, `onboarding_stats_page.dart`, `goal_configuration_page.dart`, `onboarding_summary_page.dart`, `matte_visual_check.dart`.
  - Widgets: ruler pickers, goal/stat tiles, progress bars, banners (`activity_selection_card.dart`, `bento_stat_tile.dart`, `dual_monitor_panel.dart`, `goal_card.dart`, `goal_tile.dart`, `infinite_ruler.dart`, `onboarding_progress_bar.dart`, `safety_warning_banner.dart`, `stat_field_card.dart`, `step_progress_bar.dart`).
Routes are registered in `app/app.dart` under `/` and `/onboarding/*`.

### Today (`features/today`)
- **Domain**: `usecases/get_current_plan.dart` (pulls plan via `PlanRepository`).
- **Data**: `data/repositories_impl/plan_repository_fake.dart` (seed plan).
- **Presentation**: `today_page.dart`, `TodayViewModel`, `TodayViewState`, plus widgets `nutrition_summary_card.dart`, `training_summary_card.dart`, `weight_summary_card.dart`, `today_quick_actions_row.dart`, `quick_actions_sheet.dart`, `log_weight_sheet.dart`. Routed via shell branch `/today` with provider wiring in `app/app.dart`.

### Nutrition (`features/nutrition`)
- **Domain**: `entities/day_food_log.dart`, `entities/food_entry.dart`, and `FoodLogRepository` contract.
- **Data**: `data/repositories_impl/food_log_repository_fake.dart` (fake log data).
- **Presentation**: `NutritionDayViewModel`, `NutritionDayViewState`, page `nutrition_page.dart`, navigation DTO `nutrition_page_arguments.dart`, quick-add sheet `quick_add_food_sheet.dart`, and input model `quick_food_entry_input.dart`. Barrel export `nutrition.dart` for easier imports. Routed under `/nutrition`.

### Training (`features/training`)
- **Domain**: Entities `training_overview.dart`, `training_day_overview.dart`, `workout_summary.dart`; repository contract `training_overview_repository.dart`. Program builder adds `program_builder/domain/entities/program_split.dart` for split templates.
- **Data**: `data/repositories_impl/training_overview_repository_fake.dart` seeds overview data.
- **Presentation**:
  - Dashboard: `TrainingOverviewViewModel`, `TrainingOverviewViewState`, page `training_page.dart` (routed under `/training`).
  - Program Builder (modal route `/training/builder` on root navigator): view model `program_builder_view_model.dart`, page `program_builder_page.dart`, widgets `split_dial.dart` (carousel split selector) and `sequence_toggle.dart` (weekday toggle grid).

### Plan (`features/plan`)
- Shared domain primitives: `entities/user_plan.dart`, value objects (`activity_level.dart`, `goal.dart`), repository contract `plan_repository.dart`. Consumed by onboarding (writes) and Today/Nutrition (reads).

### Settings (`features/settings`)
- **Domain**: `entities/user_preferences.dart` (theme/units enums).
- **Presentation**: `SettingsViewModel` + `SettingsViewState`, page `settings_page.dart` (accounts, preferences for units/theme, notification toggles, legal/about, sign-out), and UI widgets `settings_card.dart`, `settings_tile.dart`, `settings_section_header.dart`. Currently local state only; theme mode and prefs are not yet persisted or connected to the app-level theme controller. Routed via shell branch `/settings`.

### Auth preview (`features/auth`)
- `presentation/pages/auth_preview_page.dart` – Standalone CTA preview. Launched by `lib/main_auth_preview.dart` (not on the main router).

### Sample counter (`features/sample_counter`)
- Reference architecture sample: data stub `counter_repository.dart`, use case `increment_counter.dart`, view model `sample_counter_view_model.dart`, and UI page `sample_counter_page.dart` (uses `AppButton`). Not routed by default; use `SampleCounterPage.sample()` in experiments/tests.

### Core feature placeholder (`features/core`)
- Placeholder module reserved for future shared feature logic (distinct from `lib/src/core` services).

---

## Documentation to keep nearby

- Architecture/process: `docs/ARCHITECTURE.md`, `docs/VERY_GOOD_ANALYSIS.md`, `docs/CONTRIBUTING.md`.
- Design direction: `docs/Design.md`, `docs/DNA.md`, `docs/redesign-step1.md`.
- Feature notes: `docs/nutrition.md`, `docs/today.md`, `docs/training.md`, `docs/trainingv2.md`, `docs/settings.md`.
- Setup/how-tos: `docs/auth_setup.md`, `docs/revenuecat_setup.md`, `docs/firebase_cli_setup.md`, `docs/android_emulator.md`, `docs/mainshell.md`, `docs/testing_plan.md`.
- Prompting/context: `docs/AI_PROMPTS.md`, `docs/context.md`, `docs/notes.md`, `docs/TODO.md`.

Keep this doc in sync whenever routes, providers, tokens, or feature files move. 

---

## Local stub data sources (and where they are consumed)

The app currently runs on fakes/in-memory sources. Replace these providers in `app/app.dart` when wiring real backends.

- `features/onboarding/infrastructure/memory_plan_repository.dart` — holds the onboarding plan in memory only.
- `features/today/data/repositories_impl/plan_repository_fake.dart` — seeded plan for Today (also read by Nutrition).
- `features/nutrition/data/repositories_impl/food_log_repository_fake.dart` — fake food logs consumed by `NutritionDayViewModel`.
- `features/training/data/repositories_impl/training_overview_repository_fake.dart` — fake training overview used by `TrainingOverviewViewModel`.
- Program Builder — no persistence yet; `ProgramBuilderViewModel` stores transient name/split/schedule state only.
- `core/analytics/firebase_analytics_service.dart` — real Firebase analytics wiring.
- `core/services/scaffold_notification_service.dart` — local snackbar-based notifications (no OS scheduling).
