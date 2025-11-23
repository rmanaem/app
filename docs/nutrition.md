Next slice: Nutrition screen (v1)

We’ll mirror what worked for Today:

Contract → Fake repo → ViewModel → Page

1. Contract (domain)

Create a minimal repository for daily food logs.

File (example):
lib/src/features/nutrition/domain/repositories/food_log_repository.dart

Methods something like:

Future<DayFoodLog> getLogForDate(DateTime date);

Future<void> addQuickEntry(FoodEntry entry);

Keep it tiny for now: just what NutritionPage needs for v1.

2. Fake repo (data)

Seed realistic‑looking data so the UI feels alive immediately.

File:
lib/src/features/nutrition/data/repositories_impl/food_log_repository_fake.dart

Hard‑code a log for “today”:

2–3 meals with names, calories, and macros.

Implement getLogForDate with:

await Future.delayed(...) to simulate network.

Return your fake DayFoodLog.

addQuickEntry can just print(...) + update in‑memory list.

3. ViewModel + state (presentation)

Similar to TodayViewModel, but focused on a single day.

Files:

lib/src/features/nutrition/presentation/viewstate/nutrition_day_view_state.dart

lib/src/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel.dart

State should expose UI‑ready fields, not raw entities:

String dateLabel (e.g. Sat, Nov 22)

int caloriesConsumed

int caloriesTarget (from plan)

Macros: proteinConsumed/Target, carbsConsumed/Target, fatConsumed/Target

List of meals:

String title (e.g. “Breakfast”)

String subtitle (short description “2 items · 430 kcal”)

Loading + error flags.

For v1 it’s fine if macros/targets come from the same fake plan you already use on Today; just don’t recalc fancy stuff yet.

4. NutritionPage UI (presentation)

File:
lib/src/features/nutrition/presentation/pages/nutrition_page.dart

Use the Today layout as a reference so it feels like the same app:

Sections:

Header

NUTRITION

Today / Sat, Nov 22

Left/right arrows for previous/next day (hook them up later, can be disabled initially).

Daily summary card

Reuse the same NutritionSummaryCard layout or a variant focused on “Today’s intake”.

Shows calories + macros (consumed vs target).

Meals / timeline

A simple vertical list of “meal cards”:

Breakfast, Lunch, Dinner, Snacks (or just the meals present in the log).

Each row: meal name + calories + small “x items” subtitle.

A floating/inline “+ Add food” button at bottom or under each meal card:

For now, tapping can open a simple “Quick add” bottom sheet (calories only).

Quick add sheet (v1)

Bottom sheet with:

Energy text field (kcal).

Optional macros input (can be placeholders for now).

Log button → calls viewModel.addQuickEntry(...).

All of this should use:

AppColors.bg/surface/surface2/ringTrack

Your typography tokens (textTheme) and spacing steps.


1. Files and responsibilities

For MVP, we only need one new file (you can break it into widgets later):

lib/src/features/nutrition/presentation/pages/nutrition_page.dart

Inside this file we’ll define:

NutritionPage – public page wired into the app shell / router.

_NutritionContent – main scrollable column.

_DaySelector – “week strip” at the top.

_DailySummaryCard – calories + macros summary card (reusing the same visual language as NutritionSummaryCard).

_MealListSection – header + placeholder list for meals.

_EmptyMealState – “no meals logged yet” copy.

All widgets are presentational only: they accept plain values as props and don’t know about repositories/use‑cases. Later, you’ll feed them from NutritionVm / NutritionViewState exactly like Today.

2. Widget structure (high‑level)

Conceptual tree for NutritionPage:
NutritionPage
 └─ Scaffold
    └─ SafeArea
       └─ Padding(16,12)
          └─ Column
             ├─ _DaySelector
             ├─ SizedBox(height: 16)
             ├─ _DailySummaryCard
             ├─ SizedBox(height: 16)
             └─ Expanded
                └─ _MealListSection
                   ├─ Section header ("Meals", "Today")
                   └─ Either:
                      - ListView of meal rows (later), or
                      - _EmptyMealState for MVP


Later, when you wire a NutritionVm, the page just becomes:
final vm = context.watch<NutritionVm>();
final state = vm.state;

// pass state values into _NutritionContent(...)
Same pattern as Today.

3. nutrition_page.dart (MVP skeleton code)

This version:

Uses only Flutter + AppColors.

Has placeholder numbers and a fake “today” date so you can see the structure immediately.

Is ready to be refactored to accept a real NutritionViewState later.

// lib/src/features/nutrition/presentation/pages/nutrition_page.dart

import 'package:flutter/material.dart';

import '../../../../app/design_system/app_colors.dart';

/// Main Nutrition tab page.
///
/// For MVP this is a purely presentational scaffold with stubbed data.
/// Later, you can inject a NutritionVm and pass its `state` down into
/// [_NutritionContent] instead of the hard-coded values.
class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _NutritionContent(
            // TODO: replace these with values from NutritionViewState.
            selectedDate: DateTime.now(),
            consumedCalories: 1350,
            targetCalories: 2250,
            consumedProtein: 110,
            targetProtein: 180,
            consumedCarbs: 140,
            targetCarbs: 225,
            consumedFat: 35,
            targetFat: 70,
            hasMealsLogged: false,
          ),
        ),
      ),
      // Later: this FAB can open your “log food” flow directly.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: hook into nutrition logging sheet / flow.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NutritionContent extends StatelessWidget {
  const _NutritionContent({
    required this.selectedDate,
    required this.consumedCalories,
    required this.targetCalories,
    required this.consumedProtein,
    required this.targetProtein,
    required this.consumedCarbs,
    required this.targetCarbs,
    required this.consumedFat,
    required this.targetFat,
    required this.hasMealsLogged,
  });

  final DateTime selectedDate;

  final int consumedCalories;
  final int targetCalories;

  final int consumedProtein;
  final int targetProtein;

  final int consumedCarbs;
  final int targetCarbs;

  final int consumedFat;
  final int targetFat;

  final bool hasMealsLogged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DaySelector(
          selectedDate: selectedDate,
          onDateSelected: (date) {
            // TODO: call vm.onDateSelected(date);
          },
        ),
        const SizedBox(height: 16),
        _DailySummaryCard(
          consumedCalories: consumedCalories,
          targetCalories: targetCalories,
          consumedProtein: consumedProtein,
          targetProtein: targetProtein,
          consumedCarbs: consumedCarbs,
          targetCarbs: targetCarbs,
          consumedFat: consumedFat,
          targetFat: targetFat,
          onTap: () {
            // Optional: scroll to meals list or open a detail view.
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _MealListSection(
            hasMealsLogged: hasMealsLogged,
          ),
        ),
      ],
    );
  }
}

/// Top horizontal day selector (for now, a simple 7‑day strip).
class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    // Simple 7‑day window centered on today.
    final today = DateTime.now();
    final days = List<DateTime>.generate(
      7,
      (index) => DateTime(
        today.year,
        today.month,
        today.day - 3 + index,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Food log',
          style: textTheme.labelSmall?.copyWith(color: colors.inkSubtle),
        ),
        const SizedBox(height: 4),
        Text(
          _formatFullDate(selectedDate),
          style: textTheme.headlineSmall?.copyWith(color: colors.ink),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = _isSameDay(date, selectedDate);

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  width: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.ink : colors.surface2,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(
                      color: isSelected ? colors.ink : colors.ringTrack,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekdayLetter(date),
                        style: textTheme.labelSmall?.copyWith(
                          color: isSelected ? colors.bg : colors.inkSubtle,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date.day.toString(),
                        style: textTheme.titleMedium?.copyWith(
                          color: isSelected ? colors.bg : colors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _weekdayLetter(DateTime date) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // DateTime.weekday is 1..7 (Mon..Sun)
    return letters[date.weekday - 1];
  }

  String _formatFullDate(DateTime date) {
    // Very lightweight formatter to avoid extra deps.
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[date.month - 1];
    final weekday = _weekdayLetter(date);
    return '$weekday, $month ${date.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Daily calories + macros summary, matching the general look of
/// `NutritionSummaryCard` on the Today tab.
class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({
    required this.consumedCalories,
    required this.targetCalories,
    required this.consumedProtein,
    required this.targetProtein,
    required this.consumedCarbs,
    required this.targetCarbs,
    required this.consumedFat,
    required this.targetFat,
    this.onTap,
  });

  final int consumedCalories;
  final int targetCalories;

  final int consumedProtein;
  final int targetProtein;

  final int consumedCarbs;
  final int targetCarbs;

  final int consumedFat;
  final int targetFat;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final remainingCalories =
        (targetCalories - consumedCalories).clamp(0, targetCalories);

    final card = Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.ringTrack),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(
                'Today’s nutrition',
                style:
                    textTheme.titleMedium?.copyWith(color: colors.ink),
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colors.inkSubtle,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Calories and macros based on your plan.',
            style:
                textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 16),

          // Calories row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remainingCalories.toString(),
                      style: textTheme.headlineLarge?.copyWith(
                        color: colors.ink,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'kcal remaining',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.inkSubtle,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Calories',
                    style: textTheme.bodySmall
                        ?.copyWith(color: colors.inkSubtle),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$consumedCalories / $targetCalories kcal',
                    style: textTheme.titleMedium
                        ?.copyWith(color: colors.ink),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Macro row (Protein / Carbs / Fat)
          Row(
            children: [
              Expanded(
                child: _MacroChip(
                  label: 'Protein',
                  consumed: consumedProtein,
                  target: targetProtein,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroChip(
                  label: 'Carbs',
                  consumed: consumedCarbs,
                  target: targetCarbs,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroChip(
                  label: 'Fat',
                  consumed: consumedFat,
                  target: targetFat,
                  unit: 'g',
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
  });

  final String label;
  final int consumed;
  final int target;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: colors.ringTrack),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.inkSubtle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$consumed / $target $unit',
            style: textTheme.titleMedium?.copyWith(
              color: colors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section that will eventually show meals for the selected day.
///
/// For MVP, this shows a simple empty state if no meals are logged.
class _MealListSection extends StatelessWidget {
  const _MealListSection({
    required this.hasMealsLogged,
  });

  final bool hasMealsLogged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    if (!hasMealsLogged) {
      return _EmptyMealState();
    }

    // Placeholder for future Meal list:
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meals',
          style: textTheme.titleMedium?.copyWith(color: colors.ink),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border.all(color: colors.ringTrack),
                ),
                child: Text(
                  'Meal ${index + 1}  ·  Placeholder',
                  style: textTheme.bodyMedium?.copyWith(color: colors.ink),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyMealState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_outlined,
            color: colors.inkSubtle,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'No meals logged yet',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the + button to log your first meal today.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colors.inkSubtle,
            ),
          ),
        ],
      ),
    );
  }
}


How to evolve this later

Introduce NutritionViewState in viewstate/ and replace the hard‑coded arguments in _NutritionContent with real state fields.

Move _DailySummaryCard, _MacroChip, _MealListSection into widgets/ if they grow.

Plug your logging flow into the FAB + empty state CTA.

5. Current implementation status (repo snapshot)

- Routing/UI: `lib/src/features/nutrition/presentation/pages/nutrition_page.dart` exists but is a placeholder scaffold with centered text. No day selector, summary card, or meal list yet.
- Domain/data: No `FoodLogRepository`, no `DayFoodLog`/`FoodEntry` models, and no fake implementation under nutrition/data.
- ViewModel/state: No `NutritionDayViewState` or `NutritionDayViewModel`; NutritionPage is not wired through a provider.
- Design system: The placeholder page uses AppColors/textTheme correctly for its scaffold/app bar but doesn’t implement the planned layout.

6. What needs to be added/changed to match this doc

- Domain:
  - Add `FoodLogRepository` interface with `getLogForDate(DateTime)` and `addQuickEntry(FoodEntry)`.
  - Define simple entities/DTOs: `DayFoodLog` (date, meals, totals), `FoodEntry` (title, calories, macros, maybe meal type).
- Data:
  - Add `FoodLogRepositoryFake` seeded with a realistic “today” log (2–3 meals with calories/macros), with delayed `getLogForDate` and in-memory `addQuickEntry`.
- Presentation state/VM:
  - Add `NutritionDayViewState` exposing UI-ready fields: `dateLabel`, `caloriesConsumed/Target`, macro consumed/target, meals (title + subtitle like “2 items · 430 kcal”), loading/error flags.
  - Add `NutritionDayViewModel` to orchestrate loading for a selected date (start with today), map fake plan targets/macros, and expose commands for date selection and quick add.
- UI:
  - Replace the placeholder NutritionPage with the planned layout:
    - Header/day selector (`_DaySelector` 7-day strip).
    - Daily summary card (reuse Today’s Nutrition card styling).
    - Meal list section with empty state and an FAB/CTA for quick add.
  - Keep widgets presentational (primitives only), use AppColors/textTheme, and align spacing/radii/borders with Today.
- Wiring:
  - Register `NutritionDayViewModel` in the router (similar to Today’s ChangeNotifierProvider) and pass state into the page.
  - Hook quick-add sheet trigger (can be a stub) and date selection callbacks to the VM.

7. Implementation plan (MVP)

1) Domain + data
  - Create `lib/src/features/nutrition/domain/entities/day_food_log.dart` and `food_entry.dart`.
  - Create `lib/src/features/nutrition/domain/repositories/food_log_repository.dart` with `getLogForDate`/`addQuickEntry`.
  - Add `lib/src/features/nutrition/data/repositories_impl/food_log_repository_fake.dart` with seeded today data and simple in-memory add/update.

2) Presentation state + VM
  - Add `lib/src/features/nutrition/presentation/viewstate/nutrition_day_view_state.dart` with UI fields + loading/error.
  - Add `lib/src/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel.dart` to load today’s log, format dateLabel, map macros/calories, and expose onDateSelected/addQuickEntry.

3) NutritionPage refactor
  - Replace the placeholder with the documented layout: `_DaySelector`, `_DailySummaryCard` (reuse NutritionSummaryCard style), `_MealListSection`/`_EmptyMealState`, FAB for quick add.
  - Keep all subwidgets presentational (primitives) and in the page file initially; move to widgets/ later if they grow.

4) Wiring
  - Update router to provide `NutritionDayViewModel` (e.g., ChangeNotifierProvider) and pass state into the page.
  - Wire date taps to `vm.onDateSelected`, FAB/CTA to `vm.addQuickEntry` (or stub).

5) Later enhancements
  - Real persistence instead of fake repo.
  - Meal detail rows with items, macros, and editing.
  - Quick add bottom sheet with validation and macro inputs.
  - Per-meal type grouping and history across dates.
