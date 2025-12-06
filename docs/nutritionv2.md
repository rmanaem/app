
---

```md
# Nutrition Tab – UX & Implementation Spec (v2)

## 1. Purpose

The **Nutrition** tab is a day‑centric food log:

- Show **today’s** calorie and macro status in more detail than the Today tab.
- Provide a clear, simple view of meals for the selected day.
- Make it fast to log food via quick actions and a bottom sheet.
- Share visual language with the Today tab for consistency.

---

## 2. UX / Layout

### 2.1 Overall structure

Vertical layout with three main pieces:

1. **Day selector** (7‑day strip)  
2. **Daily summary card** (calories + macros)  
3. **Meals list section** (+ empty state)  

Plus:

- Floating action button → quick logging/shortcuts sheet.
- Optional quick‑add bottom sheet from meal section (later).

### 2.2 Day selector

**Goal:** Quickly move between recent days while showing which day is currently selected.

Content:

- Label: `Food log`
- Date label: e.g. `Sat, Nov 22`
- Horizontal 7‑day strip centered around “today”:
  - Each day chip shows:
    - Weekday letter: `M, T, W, T, F, S, S`
    - Day number: `10, 11, 12…`

Visual:

- Selected chip:
  - Background: `AppColors.ink`
  - Text: `AppColors.bg`
  - Border: `AppColors.ink`
- Unselected chip:
  - Background: `AppColors.surface2`
  - Weekday: `inkSubtle`
  - Day: `ink`
  - Border: `ringTrack`

Behavior:

- Tapping a chip → change `selectedDate` and reload log for that date.
- Left/right arrows are optional; the 7‑day strip is the main control.

Data (`NutritionDayViewState`):

- `DateTime selectedDate`
- `String dateLabel` (e.g. `Sat, Nov 22`)

### 2.3 Daily summary card

**Goal:** Show calories & macros for the selected day.

Content:

- Title: `Today’s nutrition`
- Subtitle: `Calories and macros based on your plan.`
- Primary row:
  - Left: `remainingCalories` big + `kcal remaining`
  - Right: `Calories` + `{consumed} / {target} kcal`
- Macro row:
  - Protein / Carbs / Fat chips:
    - `{consumed} / {target} g` each.

Behavior:

- Tapping card can either:
  - Scroll down to meals section, or
  - Stay static in MVP (nav is handled from Today tab).

Visual:

- Reuse `NutritionSummaryCard` style from Today (same border, radii, spacing).

Data (`NutritionDayViewState`):

- `int consumedCalories`
- `int targetCalories`
- `int remainingCalories`
- `int consumedProtein`, `targetProtein`
- `int consumedCarbs`, `targetCarbs`
- `int consumedFat`, `targetFat`

### 2.4 Meals list section

**Goal:** Show a compact overview of what’s been logged.

Content (for v1):

- Section title: `Meals`
- Either:
  - **Empty state**, if nothing logged:
    - Icon (e.g., `Icons.restaurant_outlined`)
    - Title: `No meals logged yet`
    - Subtitle: `Tap the + button to log your first meal today.`
  - A simple vertical list of meal rows (when log exists).

Each meal row:

- `mealName` – e.g. `Breakfast`, `Lunch`, `Dinner`, `Snacks`, or freeform label.
- `subtitle` – e.g. `2 items · 430 kcal`.
- Light card styling (`surface2`, `ringTrack`, 12–16px radius).

Behavior:

- Tapping a meal row can be a no‑op in MVP, or later open a day detail/meal edit.

Data (`NutritionDayViewState`):

- `bool hasMeals`
- `List<MealSummary>` where:

```dart
class MealSummary {
  const MealSummary({
    required this.title,
    required this.subtitle,
    required this.calories,
  });

  final String title;
  final String subtitle; // e.g. "3 items · 540 kcal"
  final int calories;
}
