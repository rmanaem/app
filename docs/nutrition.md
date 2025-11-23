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

Introduce NutritionViewState in viewstate/ and replace the hard-coded arguments in _NutritionContent with real state fields.

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

---

## Implementation status (latest)

**Completed**
- Domain contracts and entities: `FoodLogRepository`, `DayFoodLog`, `FoodEntry`.
- Fake repository seeded with today’s meals and in-memory quick add (`FoodLogRepositoryFake`).
- Presentation state and logic: `NutritionDayViewState` and `NutritionDayViewModel` (load today, date selection, quick add, totals, plan targets).
- Nutrition page refactor: day selector, daily summary card, meal list/empty state, error/loading handling, Provider wiring in router, design-system styling.

**Missing / pending**
- Quick-add flow UI (FAB tap currently TODO; no bottom sheet).
- Persistent storage / real data source beyond the fake repository.
- More detailed meal rows (items list, editing) and navigation hooks.
- Additional widget extraction/tests once components grow.


## Next steps after the above:

Design the quick‑add interaction

Trigger points:

Nutrition FAB (+)

“Log food” quick action on Today tab

UX:

showModalBottomSheet with:

Title: “Quick add”

Field: Energy (kcal, required)

Optional fields (can be MVP‑optional): Protein / Carbs / Fat (g)

Meal type dropdown (“Breakfast / Lunch / Dinner / Snack”) or default “Uncategorized”

Primary button: Log food

Secondary: Cancel

Add a dedicated widget

File (example):
lib/src/features/nutrition/presentation/widgets/quick_add_food_sheet.dart

Props:

Future<void> Function(int kcal, {int? protein, int? carbs, int? fat, String? mealLabel}) onSubmit

The sheet is pure UI: it validates and calls onSubmit.

Extend the ViewModel

In NutritionDayViewModel:

Add a method like Future<void> addQuickEntry(QuickFoodEntryInput input) that:

Builds a FoodEntry entity

Calls FoodLogRepository.addQuickEntry

Reloads the current day log (or mutates state in place)

Expose a simple bool isAdding flag + error string to show loading state / error snackbars.

Wire things together

Nutrition FAB:

onPressed → open bottom sheet, pass vm.addQuickEntry.

Today → “Log food” quick action:

For MVP, push to Nutrition tab and then open the same sheet, or just open the sheet directly if you can safely reuse the Nutrition VM.

After successful add:

Dismiss sheet

Updated NutritionDayViewState should cause:

New total calories/macros in summary card

New meal row (or updated “Today” totals) in the list section.

Add a minimal test

New test file (following your testing plan):
test/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel_test.dart

MVP‑critical cases:

When addQuickEntry succeeds, state.caloriesConsumed increases.

When repo throws, state.errorMessage is set and loading flag resets.


1. File + public API

Suggested file path: lib/src/features/core/presentation/widgets/quick_actions_sheet.dart

(If it's better practice to keep it under Today for now, move it to
lib/src/features/today/presentation/widgets/quick_actions_sheet.dart without changing the API.)

lib/src/features/today/presentation/widgets/quick_actions_sheet.dart without changing the API.)

Public API

/// Shows the global quick actions bottom sheet.
///
/// Usage:
/// ```dart
/// await QuickActionsSheet.show(
///   context,
///   onLogFood: () { /* open food log */ },
///   onLogWeight: () { /* open weight sheet */ },
///   onStartWorkout: () { /* go to training */ },
/// );
/// ```
class QuickActionsSheet extends StatelessWidget {
  const QuickActionsSheet({
    super.key,
    required this.onLogFood,
    required this.onLogWeight,
    required this.onStartWorkout,
  });

  final VoidCallback onLogFood;
  final VoidCallback onLogWeight;
  final VoidCallback onStartWorkout;

  /// Convenience entry point to present the sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLogFood,
    required VoidCallback onLogWeight,
    required VoidCallback onStartWorkout,
  });
}


Full widget code
// lib/src/features/core/presentation/widgets/quick_actions_sheet.dart

import 'package:flutter/material.dart';

import '../../../../app/design_system/app_colors.dart';

/// Global "Shortcuts" / quick-actions bottom sheet.
///
/// This is a purely presentational widget: it just renders three primary
/// actions tailored to this app:
///
///  * Log food
///  * Log weight
///  * Start workout
///
/// All navigation / logging flows are injected via callbacks.
///
/// Typical usage:
/// ```dart
/// await QuickActionsSheet.show(
///   context,
///   onLogFood: () { /* open food logging */ },
///   onLogWeight: () { /* open weight picker */ },
///   onStartWorkout: () { /* go to training tab */ },
/// );
/// ```
class QuickActionsSheet extends StatelessWidget {
  const QuickActionsSheet({
    super.key,
    required this.onLogFood,
    required this.onLogWeight,
    required this.onStartWorkout,
  });

  /// Called when the user taps "Log food".
  final VoidCallback onLogFood;

  /// Called when the user taps "Log weight".
  final VoidCallback onLogWeight;

  /// Called when the user taps "Workout".
  final VoidCallback onStartWorkout;

  /// Presents the sheet using [showModalBottomSheet].
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLogFood,
    required VoidCallback onLogWeight,
    required VoidCallback onStartWorkout,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return QuickActionsSheet(
          onLogFood: () {
            Navigator.of(sheetContext).pop();
            onLogFood();
          },
          onLogWeight: () {
            Navigator.of(sheetContext).pop();
            onLogWeight();
          },
          onStartWorkout: () {
            Navigator.of(sheetContext).pop();
            onStartWorkout();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Container(
        // Semi-transparent backdrop like the reference screenshot.
        color: colors.bg.withOpacity(0.6),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
                bottom: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // drag handle
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 4, bottom: 12),
                    decoration: BoxDecoration(
                      color: colors.ringTrack,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(999),
                      ),
                    ),
                  ),

                  // header row: close icon + title + (optional) placeholder for settings
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: colors.inkSubtle,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Shortcuts',
                            style: textTheme.titleMedium?.copyWith(
                              color: colors.ink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Right side: reserved for a future "customize" icon
                      IconButton(
                        icon: const Icon(Icons.tune),
                        color: colors.inkSubtle,
                        onPressed: () {
                          // TODO: hook up "Customize shortcuts" later.
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // primary actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickActionIconButton(
                        label: 'Log food',
                        icon: Icons.restaurant_outlined,
                        onTap: onLogFood,
                      ),
                      _QuickActionIconButton(
                        label: 'Log weight',
                        icon: Icons.monitor_weight_outlined,
                        onTap: onLogWeight,
                      ),
                      _QuickActionIconButton(
                        label: 'Workout',
                        icon: Icons.fitness_center_outlined,
                        onTap: onStartWorkout,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // subtle footer copy (optional)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fast access to the actions you use most.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.inkSubtle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionIconButton extends StatelessWidget {
  const _QuickActionIconButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: colors.surface2,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(
                icon,
                size: 22,
                color: colors.ink,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colors.ink,
          ),
        ),
      ],
    );
  }
}

Wire the sheet to the central FAB (or the Today quick‑actions row):

onPressed: () {
  QuickActionsSheet.show(
    context,
    onLogFood: () => _goToNutrition(context),
    onLogWeight: () => _showWeightPicker(context),
    onStartWorkout: () => _goToTraining(context),
  );
}

### Implementation plan (Quick add + shortcuts)

1. **Quick add sheet UI**
   - Create `lib/src/features/nutrition/presentation/widgets/quick_add_food_sheet.dart`.
   - Build inputs for required kcal plus optional macros and meal type, with submit/cancel actions.
   - Keep it presentational: use AppColors/textTheme, handle validation/loading, and invoke `onSubmit`.

2. **ViewModel and state updates**
   - Add a DTO (e.g., `QuickFoodEntryInput`) so the sheet can pass kcal/macros/meal label cleanly.
   - Extend `NutritionDayViewState` with `isAdding` and `addError` (or reuse `errorMessage`) for quick-add feedback.
   - Update `NutritionDayViewModel.addQuickEntry` to toggle `isAdding`, call the repo, refresh state, and handle errors.

3. **Trigger wiring**
   - NutritionPage FAB → `showModalBottomSheet` for `QuickAddFoodSheet`, hooking submit to `vm.addQuickEntry`.
   - Today “Log food” quick action (from the shortcuts sheet) navigates to Nutrition and opens the same sheet, or reuses the VM directly.

4. **Quick actions sheet**
   - Implement `QuickActionsSheet` (core presentation widgets) with callbacks for log food/weight/workout.
   - Wire the central FAB (e.g., in AppShell) to present this sheet so “Log food” can trigger step 3.

5. **Testing**
   - Add `test/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel_test.dart` covering:
     - Successful `addQuickEntry` increases calories/meals and resets `isAdding`.
     - Repository failure sets an error and resets `isAdding`.
   - (Optional) widget tests for `QuickAddFoodSheet` validation once stabilized.

---

## What’s implemented now

- **Domain & data**
  - `FoodLogRepository`, `DayFoodLog`, `FoodEntry`, and the seeded `FoodLogRepositoryFake` (with async delays + in-memory quick add) provide the contract→fake stack the spec called for.

- **ViewModel & state**
  - `NutritionDayViewModel` drives `NutritionDayViewState`, handling day selection, totals, plan targets, quick-entry submissions (`QuickFoodEntryInput`), and exposes loading + error flags for both load and quick-add flows.

- **Nutrition page**
  - `NutritionPage` matches the hierarchical layout (day selector, summary card, meal list/empty state) and is DI-wired via Provider. All subwidgets remain presentational, using AppColors/textTheme tokens.
  - FAB opens the new `QuickAddFoodSheet`; `/nutrition` accepts `NutritionPageArguments(showQuickAddSheet: true)` to auto-trigger it when navigating from Today/shortcuts.

- **Quick add sheet & shortcuts**
  - `QuickAddFoodSheet` collects kcal + optional macros + meal type, validates, surfaces VM errors, and closes on success.
  - `QuickActionsSheet` (hooked to the AppShell FAB) and Today’s quick actions now route to Nutrition with the quick-add sheet, or to weight/workout flows via injected callbacks.

- **Tests**
  - `test/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel_test.dart` verifies quick-add success (calorie totals update) and repository-failure handling (error surfaced, `isAddingEntry` reset).
