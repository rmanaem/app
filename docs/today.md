Today tab should feel like a clean, high‑signal dashboard:

One scrollable column of sections/cards.

Strong hierarchy:

Header (Today + date + plan chips).

Primary metric (calories remaining).

Quick actions row (log food / weight / workout).

Three main cards:

Nutrition card (macros & calories).

Training card (last & next workout).

Weight card (last weigh‑in & trend).

Internally, think of TodayPage as:
Scaffold
  SafeArea
    Padding
      Column
        Header
        Big calorie card
        Quick actions row
        Nutrition card
        Training card
        Weight card

All surfaces/cards use design system:

AppColors.bg for background.

AppColors.surface2 (or equivalent) for cards.

Borders using AppColors.ringTrack.

Typography from Theme.of(context).textTheme.

2. Sections & cards
2.1 Header

Purpose: ground the user in time & plan at a glance.

Contents:

Left:

Small label: TODAY

Date label: e.g. Wed, Nov 27

Right:

Optional small chip showing plan summary:

Lose · Standard or Maintain / Gain · Gentle etc.

Visual:

TODAY – label style, small caps: t.labelSmall with inkSubtle.

Date – t.headlineSmall with ink.

Plan chip – pill with border:

🟦 Lose weight · Standard

Interaction:

Tapping the plan chip could later open a “Plan details” / “Manage plan” page, but for MVP this can be non‑interactive.

2.2 Primary metric “kcal remaining” (hero)

Purpose: one big number that tells you how you’re doing today.

Contents:

Big number: remainingCalories

Sub label: kcal remaining

Tiny label below: X eaten · Y target

(e.g. 1,350 eaten · 2,250 target)

Visual:

Centered block.

Big number: t.displayMedium or headlineLarge, ink.

Sub label: t.bodySmall, inkSubtle, letterspacing slightly widened.

Microcopy: t.bodySmall using inkSubtle.

Interaction:

Tapping the whole block scrolls/focuses the Nutrition card (or navigates to Nutrition tab).

2.3 Quick actions row

Purpose: the three things the user should be able to do in 1 tap from Today.

Actions:

Log food

Log weight

Start workout

Visual:

Horizontal row of 3 equal pill buttons / chips.

Each pill:

Icon + label: e.g. 🍽 Log food, ⚖ Weigh in, 🏋 Start workout.

Uses surface2 with border; on press, filled with accent.

Interaction:

Log food: opens nutrition logging sheet (or navigates to Nutrition tab + opens log).

Weigh in: opens weight picker bottom sheet.

Start workout: starts next workout or opens Training tab on logging view.

No need to implement all flows right away; but the UI docs them so the layout doesn’t change later.

2.4 Nutrition card

Purpose: macro & calorie summary for the day, readable at a glance.

Contents:

Title: Nutrition

Subtitle: Today’s intake

Top row:

Calories: consumed / target (e.g. 1,350 / 2,250 kcal)

Middle:

Three macro chips or mini bars:

Protein

Carbs

Fats

Each shows consumed / target g.

Bottom:

Mini text: Based on your current plan.

States:

Loading: placeholder skeletons.

No plan: card shows “No plan yet – finish onboarding to get targets.” (should be rare now).

No logs yet today: show 0 / target and possibly “Start by logging your first meal”.

Visual:

Card container:

Background: AppColors.surface2.

Border: AppColors.ringTrack.

Radius: 14–16.

Padding: 16.

Example layout:

+--------------------------------------+
| Nutrition                           |
| Today’s intake                      |
|                                      |
| Calories: 1350 / 2250 kcal          |
|                                      |
| [Protein]  110 / 180 g              |
| [Carbs]    140 / 225 g              |
| [Fats]      35 /  70 g              |
|                                      |
| Based on your current plan.         |
+--------------------------------------+

Interaction:

Tapping the card navigates to Nutrition tab → today, where they can see the full log.

(Later) long‑press could open a quick add.

2.5 Training card

Purpose: show the user where they are in their training week without overwhelming detail.

Contents:

Title: Training

Subtitle: This week

Two main blocks:

Next workout

Label: Next

Workout name: Upper A / Push day etc.

Day/time: Tomorrow · 6:00 PM or Today · 7:00 PM.

Last workout

Label: Last

Date: Mon · 45 min

Summary: something like

3 exercises · 9 sets

or Bench 5×5 @ 80 kg

or short comment preview: "Focus on bracing on squats."

States:

No program yet:

Show “No program set up yet” with CTA button: Create program (later).

Program exists but no last workout:

Last section shows “You haven’t logged a session yet.”

Visual:

Two stacked rows inside the card:

+--------------------------------------+
| Training                            |
| This week                           |
|                                      |
| Next                                |
| Upper A · Tomorrow                  |
| 3 exercises · ~45 min               |
|                                      |
| Last                                |
| Mon · 42 min                        |
| Bench 5×5 @ 80 kg                   |
+--------------------------------------+

Interaction:

Tapping the “Next” area or a small “Start” button:

Starts the workout directly or navigates to Training tab with that workout open.

Tapping the “Last” area:

Opens workout detail / history later.

For MVP, it’s okay if both taps just push to the Training tab.

2.6 Weight card

Purpose: give users a clear feel of their short‑term trend, not just the last number.

Contents:

Title: Weight

Subtitle: e.g. Last 7 days

Main row:

Left: last weight: 82.4 kg

Right: small text: −0.4 kg vs last week or Stable if < small threshold.

Below:

Sparkline or very simple visual representing daily weights.

For MVP: can be:

7 circles with heights scaled or

a placeholder until we do a real sparkline.

CTA:

Small button or text link: Weigh in on the right.

States:

No data yet:

Show No weight logged yet and emphasize Weigh in CTA.

Only one value:

Show last weight and “Not enough data for a trend yet.”

Visual:

+--------------------------------------+
| Weight                              |
| Last 7 days                         |
|                                      |
| 82.4 kg          −0.4 kg vs last wk |
|                                      |
| ●   ●   ●   ●   ●   ●   ●           |
|                                      |
| [Weigh in]                          |
+--------------------------------------+

Interaction:

Tapping Weigh in opens the weight picker bottom sheet.

Tapping the card could later open a Progress / Weight History screen.

3. Rough widget tree for TodayPage

Here’s a conceptual widget hierarchy that matches the sections above and uses your design system (no raw colors):

```Dart
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final t = Theme.of(context).textTheme;
    final vm = context.watch<TodayViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.hasError
                  ? _ErrorState(message: state.errorMessage)
                  : _TodayContent(state: state),
        ),
      ),
    );
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final t = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TodayHeader(state: state),
          const SizedBox(height: 24),
          TodayCalorieHero(state: state),
          const SizedBox(height: 16),
          TodayQuickActionsRow(),
          const SizedBox(height: 16),
          NutritionSummaryCard(state: state),
          const SizedBox(height: 12),
          TrainingSummaryCard(state: state),
          const SizedBox(height: 12),
          WeightSummaryCard(state: state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
```
Then each card is its own widget (NutritionSummaryCard, TrainingSummaryCard, WeightSummaryCard), all drawing styles from AppColors and TextTheme.

4. MVP vs “later” within Today

To keep scope under control:

MVP Today:

Header with date + simple plan chip label.

Calorie hero (remaining + eaten/target text).

Quick actions row (buttons wired to TODO flows but UI present).

Nutrition card:

Calories consumed vs target.

Macros consumed vs target (numbers only).

Training card:

Basic text: “Next workout: [name]” / “Last workout: [name / date]” with placeholder values from fake training repo (or static for now).

Weight card:

Last weight only, no real trend calculation yet (text: “Last weigh‑in: xx kg”).

“Weigh in” CTA.

Later:

Sparkline in the weight card.

More detailed training stats (sets, volume, etc.).

Fine‑tuned microcopy, animations, and haptics.



A standalone NutritionSummaryCard widget.

Designed to plug into your TodayViewModel/state.

Using your design system (AppColors + TextTheme), no raw colors.

With optional onTap so you can hook it to the Nutrition tab.

You can drop this under something like:
lib/src/features/today/presentation/widgets/nutrition_summary_card.dart


NutritionSummaryCard:

```Dart
import 'package:flutter/material.dart';

import '../../../../app/design_system/app_colors.dart';

/// Card showing today's calorie and macro status.
///
/// Intended for use on the Today tab. All numbers are passed in as plain
/// integers so this widget stays purely presentational.
///
/// Example:
/// ```dart
/// NutritionSummaryCard(
///   consumedCalories: 1350,
///   targetCalories: 2250,
///   consumedProtein: 110,
///   targetProtein: 180,
///   consumedCarbs: 140,
///   targetCarbs: 225,
///   consumedFat: 35,
///   targetFat: 70,
///   onTap: () => context.go('/nutrition'),
/// )
/// ```
class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({
    super.key,
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

  /// Optional tap handler. If provided, the card becomes tappable and
  /// shows ink feedback; if null, it's static.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final remainingCalories = (targetCalories - consumedCalories).clamp(0, targetCalories);

    final card = Container(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: colors.ringTrack, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: title + optional chevron to hint navigation.
          Row(
            children: [
              Text(
                'Nutrition today',
                style: textTheme.titleMedium?.copyWith(color: colors.ink),
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: colors.inkSubtle,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Calories and macros based on your plan.',
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 16),

          // Main calories line (hero-ish but still card-sized).
          _CaloriesRow(
            consumedCalories: consumedCalories,
            targetCalories: targetCalories,
            remainingCalories: remainingCalories,
          ),

          const SizedBox(height: 16),

          // Macro row: three chips: Protein, Carbs, Fat.
          Row(
            children: [
              Expanded(
                child: _MacroStat(
                  label: 'Protein',
                  consumed: consumedProtein,
                  target: targetProtein,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroStat(
                  label: 'Carbs',
                  consumed: consumedCarbs,
                  target: targetCarbs,
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroStat(
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

    // Make the whole card tappable when onTap is provided.
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

class _CaloriesRow extends StatelessWidget {
  const _CaloriesRow({
    required this.consumedCalories,
    required this.targetCalories,
    required this.remainingCalories,
  });

  final int consumedCalories;
  final int targetCalories;
  final int remainingCalories;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Remaining kcal (primary).
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                remainingCalories.toString(),
                style: textTheme.headlineLarge?.copyWith(
                  color: colors.ink,
                  height: 1.0,
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

        // Right: Consumed vs target.
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Calories',
              style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
            ),
            const SizedBox(height: 4),
            Text(
              '$consumedCalories / $targetCalories kcal',
              style: textTheme.titleMedium?.copyWith(color: colors.ink),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({
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
            style: textTheme.bodySmall?.copyWith(color: colors.inkSubtle),
          ),
          const SizedBox(height: 4),
          Text(
            '$consumed / $target $unit',
            style: textTheme.titleMedium?.copyWith(color: colors.ink),
          ),
        ],
      ),
    );
  }
}
```

…and _onNutritionCardTapped would navigate to your Nutrition tab (via go_router, tab controller, or whatever you’re using).

Why this is a good pattern to copy for other cards

Purely presentational: no repo or VM access inside, just inputs → UI.

Design system only: uses AppColors + TextTheme, no hard‑coded palette.

Well‑documented: top‑level dartdoc and clear props make it AI‑friendly.

Composable: you can reuse _MacroStat elsewhere (e.g., in Nutrition tab detail views).

Lint‑friendly: const constructors, small focused widgets, no side effects.

5. Current implementation status (repo snapshot)

5.1 What’s already implemented

- Navigation + shell:
  - Today tab exists as a shell branch with route `/today` wired in `App` (`lib/src/app/app.dart`).
  - Nutrition and Training tabs/pages exist as placeholder destinations for quick actions.
- Today MVVM + data:
  - `TodayViewState` models plan + consumed calories/macros (`lib/src/features/today/presentation/viewstate/today_view_state.dart`).
  - `TodayViewModel` loads a plan via `GetCurrentPlan`, seeds fake “consumed” values, exposes `remainingCalories`, and handles loading/error (`lib/src/features/today/presentation/viewmodels/today_viewmodel.dart`).
  - `GetCurrentPlan` use case wraps `PlanRepository` (`lib/src/features/today/domain/usecases/get_current_plan.dart`).
  - `PlanRepositoryFake` returns a hard-coded `UserPlan` for UI work (`lib/src/features/today/data/repositories_impl/plan_repository_fake.dart`).
- Today UI (initial pass):
  - `TodayPage` already shows:
    - TODAY label + formatted date header.
    - A big “kcal remaining” number + label.
    - A simple horizontal macro row (Protein/Fats/Carbs, consumed vs plan target).
  - Uses `AppColors` and `TextTheme` correctly and handles:
    - Loading → `CircularProgressIndicator`.
    - Missing plan → simple text error.

5.2 What’s missing vs this spec (MVP scope)

- Layout & structure:
  - Switch to `SingleChildScrollView` with a vertical stack of sections:
    - Header → hero → quick actions → Nutrition/Training/Weight cards.
  - Factor out section widgets (`TodayHeader`, `TodayCalorieHero`, `TodayQuickActionsRow`, `NutritionSummaryCard`, `TrainingSummaryCard`, `WeightSummaryCard`) instead of one big column.
- Header:
  - Add right-aligned plan chip (e.g. “Lose · Standard”) derived from `UserPlan` goal/plan type.
  - Ensure typography matches spec (labelSmall for TODAY, headlineSmall/Medium for date).
- Hero (“kcal remaining”):
  - Add microcopy line: `X eaten · Y target` based on `consumedCalories` and `plan.dailyCalories`.
  - Make the hero tappable to focus the Nutrition card or navigate to the Nutrition tab.
- Quick actions row:
  - Implement 3 pill buttons (Log food, Log weight, Start workout) using design tokens:
    - Log food → for now, navigate to `/nutrition` (logging sheet can be a later enhancement).
    - Log weight → open `showWeightPickerSheet` from onboarding module.
    - Start workout → navigate to `/training` (starting a concrete workout can be “later”).
- Nutrition card:
  - Replace the inline macro row with a dedicated `NutritionSummaryCard`:
    - Card styles: `surface2` background, `ringTrack` border, radius ~16, padding 16.
    - Content: title/subtitle, calories consumed vs target, macro chips/bars, “Based on your current plan” microcopy.
  - States for MVP:
    - Loading → simple shimmer/placeholder or reuse Today’s loading state.
    - No plan → “No plan yet – finish onboarding to get targets.”
    - No logs yet → show 0 / target and “Start by logging your first meal.”
- Training card:
  - Add `TrainingSummaryCard` showing “Next” and “Last” workouts with placeholder/fake data:
    - Next: name + when (e.g. “Upper A · Tomorrow”).
    - Last: date + short summary line.
  - For MVP, use hard-coded or simple fake training data (no real program repository yet).
  - Tap → navigate to Training tab; detailed history/progress can be “later”.
- Weight card:
  - Add `WeightSummaryCard`:
    - Last weight (e.g. “82.4 kg”).
    - Simple trend text (e.g. “−0.4 kg vs last week” or “Stable”).
    - For MVP: 7 circles / placeholder row instead of a real sparkline.
    - “Weigh in” CTA button that opens `showWeightPickerSheet`.
  - Use placeholder weight data for now; full trend logic + persistence is “later”.
- State modeling:
  - Extend `TodayViewState`/`TodayViewModel` with additional view data needed for:
    - Header plan chip label.
    - Hero microcopy (eaten/target).
    - Training summary (next/last workout text).
    - Weight summary (last weight, delta label, basic trend state flags).
  - Keep these view-model level (strings/basic numbers/flags) so cards remain presentational.

6. Implementation plan for Today screen MVP

6.1 ViewState + ViewModel

- Extend `TodayViewState` to include:
  - `String? planLabel` (e.g. “Lose · Standard”).
  - `int eatenCalories`, `int targetCalories` (can map from `plan` + `consumedCalories`).
  - Simple training fields:
    - `String? nextWorkoutTitle`, `String? nextWorkoutSubtitle`.
    - `String? lastWorkoutTitle`, `String? lastWorkoutSubtitle`.
  - Simple weight fields:
    - `double? lastWeightKg`.
    - `String? weightDeltaLabel` (e.g. “−0.4 kg vs last week” or “Stable”).
    - Optional flags like `bool hasWeightTrend`.
- Update `TodayViewModel` to:
  - Map `UserPlan` → `planLabel`, calorie targets, and macro targets.
  - Populate training fields with placeholder values for now.
  - Populate weight fields with placeholder values for now.
  - Expose convenience getters for “eaten vs target” strings if useful for the hero.

6.2 TodayPage layout + section widgets

- Refactor `TodayPage` to:
  - Wrap content in `Padding` + `SingleChildScrollView` + `Column` as in the conceptual widget tree.
  - Replace inline UI with small, focused section widgets:
    - `TodayHeader(state: state)` (TODAY, date, plan chip).
    - `TodayCalorieHero(state: state, onTap: _onCalorieHeroTap)`.
    - `TodayQuickActionsRow(onLogFood: ..., onLogWeight: ..., onStartWorkout: ...)`.
    - `NutritionSummaryCard(...)`.
    - `TrainingSummaryCard(...)`.
    - `WeightSummaryCard(...)`.
- Keep `TodayPage` responsible for:
  - Reading `TodayViewModel` / `TodayViewState`.
  - Wiring navigation + bottom sheets into callbacks.

6.3 Cards + quick actions (presentational widgets)

- Implement `NutritionSummaryCard` in `lib/src/features/today/presentation/widgets/`:
  - Use the existing Nutrition card sketch earlier in this doc as reference.
  - Take primitive props only (int/double/string) and an optional `VoidCallback onTap`.
- Implement `TrainingSummaryCard`:
  - Title/subtitle, “Next” block, “Last” block, all from passed-in strings.
  - Optional `VoidCallback onTapNext`, `VoidCallback onTapLast`.
- Implement `WeightSummaryCard`:
  - Title/subtitle, last weight text, delta label, placeholder trend row, `Weigh in` button.
  - Optional `VoidCallback onWeighIn` + card tap callback.
- Implement `TodayQuickActionsRow`:
  - 3 pill buttons (atoms/molecules from design system if available; otherwise simple decorated `InkWell`s) with icons + labels.
  - Only handle taps via injected callbacks (navigation/business logic stays in page/VM).

6.4 Navigation + interactions

- In `TodayPage`:
  - `onCalorieHeroTap` and `onNutritionCardTap` → push `/nutrition` route.
  - `onStartWorkoutTap` and Training card taps → push `/training`.
  - `onWeighInTap` and Weight card CTA → call `showWeightPickerSheet` from onboarding widgets.
  - Log screen views / important actions via `AnalyticsService` later if needed (not required for MVP).

6.5 MVP “later” follow-ups (parking lot)

- Replace placeholder training and weight data with real domain features:
  - Training program repository + “next/last session” use case.
  - Weight log repository + “last N days + trend” use case.
- Add proper skeleton loading for each card instead of whole-page loader.
- Replace weight placeholder circles with a real sparkline component using shared charting primitives.
- Add haptics, subtle animations (e.g. hero number changes), and microcopy refinements once behavior is stable.


tweaks past v1 implementation:

Card consistency

Make sure all cards (hero, Nutrition, Training, Weight) share:

The same corner radius (e.g., 16).

The same border style (ringTrack) and background (surface2).

Right now the hero and Nutrition card look close, but just double‑check radii/borders so they feel like one system.

Quick actions visual hierarchy

Slightly reduce the visual weight of the quick‑action pills so the hero and cards still feel like the main focal points:

Use surface with a subtle border, instead of feeling as heavy as full cards.

Keep icons + labels, but maybe a touch smaller text.

Training card content

Fill out the Training card to match the intended structure:

“Next” block: workout name + simple subtitle (e.g. Upper A · Tomorrow · ~45 min).

“Last” block: date + 1‑line summary (e.g. Mon · 42 min · Bench 5×5 @ 80 kg).

Even with fake data, seeing both “Next” and “Last” will make the card feel intentional and complete.

Microcopy and spacing pass

Do one small round where you:

Use consistent spacing steps (e.g., 8 / 12 / 16 / 24) vertically between sections.

Keep all helper text in a consistent tone (e.g., “Based on your current plan.” vs “Calories and macros based on your plan.” → choose one style and reuse).

Tap targets wired (even if flows are TODO)

Ensure the following are all tappable:

Hero + Nutrition card → Nutrition tab.

Training card → Training tab.

Weight card CTA → weight picker sheet.

Even if the destination is still a stub, this makes the screen feel “alive” and we won’t have to change the layout later.