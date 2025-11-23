# Repo Structure Overview

This document captures how the app is organized under `lib/`, focusing on architecture (clean layers, atomic design, MVVM) and current feature implementations.

## Top-level layout

```
lib/
 └─ src/
     ├─ app/
     ├─ core/
     └─ features/
```

### `lib/src/app/`

Global composition and design system:

- `app.dart`: Entry widget; wires GoRouter, global providers (analytics, repositories, viewmodels) and theming (AppColors/AppTheme).
- `design_system/`: Tokens for colors, spacing, typography, DS documentation (`design-makeover.md`).
- `shell/`: Bottom navigation shell (`presentation/pages/app_shell_page.dart`).
- `bootstrap/`, `config/`: Startup helpers, env configuration.

### `lib/src/core/`

Cross-cutting utilities (analytics services, logging, result types) that are feature-agnostic.

### `lib/src/features/`

Each feature follows the same clean-layer structure:

```
<feature>/
 ├─ domain/            # pure Dart: entities, repositories, usecases
 ├─ data/              # fake/real repository implementations, DTOs
 └─ presentation/      # MVVM: viewmodels, viewstate, pages, widgets
```

#### Today (`features/today/`)

- `domain/usecases/get_current_plan.dart`: Fetches the onboarding plan snapshot.
- `data/repositories_impl/plan_repository_fake.dart`: Seeded plan for UI work.
- `presentation/viewmodels/today_viewmodel.dart`: ChangeNotifier driving TodayPage; exposes TodayViewState and derived metrics (remaining calories, next workout info, etc.).
- `presentation/pages/today_page.dart`: Dashboard layout (header, calorie hero, quick actions, nutrition/training/weight cards) built from presentational widgets in `presentation/widgets/`.

#### Nutrition (`features/nutrition/`)

- `domain/entities/day_food_log.dart`, `food_entry.dart`, `domain/repositories/food_log_repository.dart`.
- `data/repositories_impl/food_log_repository_fake.dart`: Fake plan/log data.
- `presentation/viewmodels/nutrition_day_viewmodel.dart`: Loads logs via `GetCurrentPlan`, tracks quick-add state.
- `presentation/pages/nutrition_page.dart`: Header + day selector, summary card, meal list; uses `QuickAddFoodSheet` in `presentation/widgets/` and navigation args in `presentation/navigation/`.
- `presentation/models/quick_food_entry_input.dart`: DTO for the sheet -> ViewModel call.

#### Training (`features/training/`)

- `domain/entities/`: `TrainingDayOverview`, `WorkoutSummary`, `TrainingOverview` capture week overview data; `domain/repositories/training_overview_repository.dart` defines the contract.
- `data/repositories_impl/training_overview_repository_fake.dart`: Async fake repo returning seeded seven-day data, next/last workout summaries, and program info.
- `presentation/viewmodels/training_overview_view_model.dart`: ChangeNotifier that loads the overview, handles selection, and exposes navigation callbacks.
- `presentation/viewstate/training_overview_view_state.dart`: Immutable state snapshot with copyWith/initial factory.
- `presentation/pages/training_page.dart`: MVVM-driven layout (header, weekly summary card, 7-day strip, next/last cards, action chips). Uses design tokens, presentational widgets, and Provider wiring (see `app.dart`).

#### Other features

- Onboarding, Settings, Sample Counter, etc. follow the same pattern: domain value objects, data fakes, presentation viewmodels/pages. Documentation for future slices lives in `docs/` (e.g., `nutrition.md`, `trainingv2.md`).

## Entry points

- `lib/main.dart`, `main_dev.dart`, `main_prod.dart`: app entry per flavor.
- `lib/firebase_options_*.dart`: generated Firebase config per environment.

## Documentation (`docs/`)

- `ARCHITECTURE.md`: clean architecture rules (atomic design, MVVM, feature boundaries).
- Feature specs (`nutrition.md`, `training.md`, `trainingv2.md`), lint guide (`VERY_GOOD_ANALYSIS.md`), and other contributor docs.

This structure keeps features isolated, testable, and ready to swap fake repositories for real data as the app evolves.
