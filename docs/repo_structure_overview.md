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

Global composition + design system:

- `app.dart`: Environment-aware entry widget; wires GoRouter routes, global providers (analytics, repositories, viewmodels) and theming (`AppColors` / `AppTheme`). Entries such as `main_dev.dart` now temporarily load showcase pages (e.g. `GlassSandboxPage`) while we tune the new glass components.
- `design_system/`: Tokens for colors, spacing, typography and design docs (`design-makeover.md`). The design system feeds every atom (buttons, toggles, cards) including the new glass widgets.
- `shell/`: Bottom navigation shell (`presentation/pages/app_shell_page.dart`).
- `bootstrap/`, `config/`: Startup helpers, env configuration & firebase wiring.
- `presentation/pages/metal_sandbox_page.dart` & `presentation/pages/glass_sandbox_page.dart`: playgrounds for metal/glass looks. `glass_sandbox_page.dart` now mirrors the “ultra thin” neon reference and is the quickest way to preview `GlassButton`, `StatGlassCard`, and `GlassToggle` in isolation.

### Design atoms / molecules

Under `lib/src/presentation/atoms/` we now ship production-grade glass atoms:

- `glass_button.dart`: Crystal button with neon rim, blur + border painter.
- `glass_toggle.dart`: Capsule toggle with dark track + bright thumb. Reads from design tokens (no hard-coded palette beyond subtle track overlay).
- `lib/src/features/onboarding/presentation/widgets/stat_glass_card.dart`: Reworked glass stat platter with blur/fill/border cascade; consumed by onboarding stats and the sandbox.
- These atoms plus the `GlassSandboxPage` act as living documentation for future screens adopting the new aesthetic.

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

#### Onboarding & previews

- Onboarding recently gained the glass welcome / stats experiences: `presentation/pages/welcome_page.dart`, `onboarding_goal_page.dart`, `onboarding_stats_page.dart` plus the glass atoms described above. Viewmodels remain under `presentation/viewmodels/` (`OnboardingVm`, etc.) and domain value objects live in `domain/value_objects/` (Goal, ActivityLevel, measurements, etc.).
- Presentation widgets such as `glass_button.dart`, `glass_toggle.dart`, `stat_glass_card.dart`, and `GlassSandboxPage` are reused during onboarding experiments and showcased in the sandbox.
- Settings, sample counter, and future feature spikes still follow the same domain/data/presentation pattern; docs live under `docs/` (e.g., `nutrition.md`, `trainingv2.md`).

## Entry points & previews

- `lib/main.dart`, `main_dev.dart`, `main_prod.dart`: flavor entries. During design work `main_dev.dart` can point at `GlassSandboxPage` (while still using the app theme) so designers/devs can iterate on glass without navigating the app shell. For production builds, swap back to `App(envName: 'dev')`.
- `lib/firebase_options_*.dart`: generated Firebase config per environment.

## Documentation (`docs/`)

- `ARCHITECTURE.md`: clean architecture rules (atomic design, MVVM, feature boundaries).
- Feature specs (`nutrition.md`, `training.md`, `trainingv2.md`), lint guide (`VERY_GOOD_ANALYSIS.md`), and other contributor docs.
- `docs/design-makeover.md` + this repo overview help onboard designers to the new glass/metal treatments and explain where sandbox pages live.

This structure keeps features isolated, testable, and ready to swap fake repositories for real data as the app evolves.
