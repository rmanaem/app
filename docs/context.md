1. Updated MVP plan (high‑level)

Architecture & stack

Flutter (multi‑platform).

Clean-ish feature architecture (lib/src/features/...) with:

domain/ (entities, value objects, repositories)

presentation/ (pages, widgets, viewmodels/controllers)

app/design_system/ (AppColors, AppTypography, AppSpacing, etc.)

Routing: go_router.

Backend: Firebase (Auth + Firestore) – still to be fully wired.

Subscriptions: RevenueCat (MVP, but after free features are implemented and tested).

Analytics: Firebase Analytics (MVP).

Visual language

“Performance minimalism”:

High contrast, macrofactor‑style black/white core.

Careful use of neutral grays for surfaces.

Navy variant theme later (already experimented with).

Atomic design thinking: tokens → atoms → molecules → screens.

Welcome + onboarding + shell all share the same design system.

Core free MVP features

Onboarding (4 steps)

Welcome screen (already implemented).

Step 1 – Goal selection: lose / maintain / gain.

Step 2 – “About you” stats:

DOB, height, weight, activity level.

Each editable via bottom sheets / pickers.

Step 3 – Goal preview:

Target weight slider.

Weekly rate slider (kg/week; sign fixed by goal).

Shows: daily kcal, projected end date, preview macros.

Step 4 – Summary:

Recap goal + pace + target weight + rate + projected end.

Recap stats (DOB, height, weight, activity).

“Start tracking” → creates a plan and enters the main shell.

Main shell (4 tabs + central + button)

Today (Dashboard)

Nutrition

Training

Settings

Center FAB → quick action sheet (log food, log weight, start workout, etc.)

Nutrition (free)

Daily macro & calorie targets from plan.

View intake vs target for current day.

Log food (MVP can be manual/quick‑add at first).

Weekly/day navigation (7‑day strip).

Training (free)

Workout template/program creator (inspired by Strong):

Choose exercises from a library (body part, equipment, type filters).

Add sets/reps/weight.

Per‑exercise comments (form tweaks, pain, difficulty, etc.).

Logging workouts:

Edit sets & weights during a session.

Show last session data for each exercise (and surface last comments in some way).

Basic workout history.

Settings (free)

Auth management (email, Apple, Google).

Units: metric / imperial (weight, height).

Theme: system / light / dark.

Legal: Terms, Privacy, Health disclaimer.

Placeholders for coach/strategy toggles (wiring later, but UI slot exists).

Paid / Pro MVP features

Implemented after free core is stable and tested; RevenueCat integration is included in MVP.

Nutrition Coach (Pro)

Weekly weight trend → adjust calorie & macro targets using validated formulas.

Configurable goal type + aggressiveness.

Training Coach (Pro)

Uses logged performance & RPE/comments to adjust:

Progression (load/volume).

Potential deload or fatigue flags.

Fatigue / readiness flagging is explicitly Pro‑only.

Combo (Pro+)

Both diet + training coach at a bundled price.

Out‑of‑scope for initial MVP but on roadmap

HealthKit/Google Fit integration (steps, weight).

Advanced analytics (custom charts, nutrition scores, etc.).

Photo‑based logging, AI food recognition.

Calories scheduling and weekly calorie distribution + protein preference (already earmarked as post‑MVP paid features).

2. MVP_CONTEXT.md (copy‑paste ready)

# MVP Context – Diet & Training App

> This document is meant to give full context to continue working on the MVP
> even if this is a fresh conversation with no previous chat history.

---

## 1. Product concept

A mobile app that combines **nutrition tracking** and **weight training** tracking, with optional **coaching layers** for both.

- **Free tier:**  
  - Users set their own goals, see a reasonable starting calorie/macro plan,
    log food, log workouts, and track progress.
- **Paid tier (Pro):**  
  - “Nutrition coach” that adjusts macros based on weight trends.  
  - “Training coach” that adjusts progression & flags fatigue.

The UX should feel:

- **Fast** (minimal friction, short flows, clear CTAs).
- **Grounded in science** (no nonsense, honest about estimates).
- **Delightfully premium** (design users want to screenshot and share).

---

## 2. Design philosophy

### 2.1 Visual language – “Performance minimalism”

Key ideas:

- High contrast, macrofactor-like core:
  - **Black / near‑black backgrounds** for dark mode.
  - **White / near‑white** for light mode.
  - Grays for surface elevations and dividers.
- Highly legible typography.
- Clean, card-based layouts with lots of breathing room.
- Minimal color accents reserved for:
  - State (errors/success).
  - Highlights (active ring, important metric).
  - Future navy theme variant.

We use a token-based design system in code:

- `AppColors` – color tokens (bg, surfaces, ink, accent, ringTrack, etc.)
- `AppTypography` – text styles (display, headline, title, body, label).
- `AppSpacing` – spacing tokens (xs/s/m/l/xl, etc.).

### 2.2 Atomic design mindset

- **Tokens** → `AppColors`, `AppTypography`, `AppSpacing`.
- **Atoms** → Buttons, text fields, chips, sliders, cards.
- **Molecules** → Metric tiles, goal cards, macro rings, exercise rows.
- **Organisms/screens** → Onboarding steps, Today tab, Nutrition tab, etc.

This keeps AI‑generated code composable and consistent.

---

## 3. Architecture & stack

### 3.1 Tech stack

- **Flutter** for iOS + Android (single codebase).
- **Routing**: `go_router`.
- **Backend**: Firebase (Firestore + Auth).
- **Subscription management**: RevenueCat (added once free core is solid).
- **Analytics**: Firebase Analytics.

### 3.2 Code architecture (high level)

Under `lib/src`:

- `features/`
  - `onboarding/`
  - `today/`
  - `nutrition/`
  - `training/`
  - `settings/`
- `app/`
  - `design_system/` (AppColors, AppTypography, AppSpacing, theming)
  - `shell/` (main app shell / navigation)
- `core/`
  - Shared abstractions (analytics, storage, etc.)

Within each feature:

- `domain/` – entities, value objects, repositories (pure Dart).
- `presentation/` – pages, widgets, viewmodels/controllers.
- (Optionally `application/` or `use_cases/` for orchestration logic.)

We follow **very_good_analysis** lints:
- No undocumented public members.
- No unused imports / fields.
- No `Future`-returning calls in non‑`async` functions, etc.

---

## 4. MVP scope – features

### 4.1 Onboarding flow

The onboarding is currently 4 steps (after the initial welcome screen).

#### 0. Welcome screen

- Shows placeholder logo (Flutter logo for now).
- Tagline: e.g. **“Log fast. Train smart. See progress.”**
- Buttons:
  - **Get Started** (go to Step 1).
  - **Log In**.
- Legal text at bottom (Terms of Service, Privacy Policy, Consumer Health Privacy).

#### Step 1 – Goal selection

- Screen title: **“What’s your goal?”**
- Options (cards or big buttons):
  - Lose weight
  - Maintain weight
  - Gain weight
- Only one selectable.
- “Next” enabled once a goal is selected.

#### Step 2 – About you (“stats”)

Purpose: collect the minimum to build a personalized starting plan, but keep it human and non‑clinical.

- Title: more personal, e.g. **“Tell us about you”**, not “Stats”.
- Fields (each shown as a tappable row card):
  - Date of birth
  - Height
  - Weight
  - Activity level
- Tapping each opens a **modal picker** similar to MacroFactor:
  - DOB: day / month / year scroll wheels.
  - Height: numeric picker with unit system (cm or ft/in).
  - Weight: numeric picker with unit system (kg or lb).
  - Activity level:
    - Low – “Mostly sedentary, typically under ~5k steps/day”
    - Moderate – “On your feet sometimes, roughly 5k–15k steps/day”
    - High – “On your feet most of the day or training hard, often 15k+ steps/day”
- Step progress bar at top (e.g. 1/4, 2/4…).
- “Next” disabled until all fields are filled with valid values.

#### Step 3 – Plan preview (Set new goal)

User tunes **target** and **pace** before committing:

- Top metrics (cards):
  - **Daily calories** (initial daily budget).
  - **Projected end date**.
- Section: **Target weight**
  - Slider from `minTargetKg` to `maxTargetKg` (derived from current weight & goal).
  - Label shows value in the user’s unit system (kg / lb).
- Section: **Weekly rate**
  - Slider from `minRateKg` to `maxRateKg` (signed; negative for loss, positive for gain).
  - Label shows:
    - kg (or lb) per week
    - %BW per week
    - Text label: Gentle / Standard / Aggressive (based on %BW/week).
- Macro preview:
  - Simple breakdown of Protein, Fat, Carbs in grams.
- All computed via a **`PreviewEstimator` interface** with a temporary implementation (`SimplePreviewEstimator`).  
  Later, this gets replaced with validated coach math.

#### Step 4 – Summary

Recap + confirmation:

- Progress bar completed (step 4/4).
- Metrics:
  - Daily calories
  - Projected end date
- Goal chip row:
  - Goal label (Lose / Maintain / Gain)
  - Pace label (Gentle / Standard / Aggressive)
  - Target weight
  - Weekly rate
- “Your details” section:
  - DOB
  - Height
  - Current weight
  - Activity level (friendly labels)
- Primary CTA: **“Start tracking”**
  - Creates a `UserPlan` via a `PlanRepository` abstraction.
  - After saving, navigates into the main shell (Today tab).
- Secondary: **“Back to adjust”** (returns to preview screen).

> Fatigue flagging and advanced adjustments are **NOT** part of the onboarding. They belong to the **coaching layer**.

---

## 5. Main shell structure

After onboarding, the user enters the **main app shell**.

### 5.1 Navigation pattern

- Bottom navigation with 4 tabs:
  1. **Today** (default)
  2. **Nutrition**
  3. **Training**
  4. **Settings**
- Center **+ FAB** opens a **quick‑action bottom sheet**:
  - Log food
  - Log weight
  - Start workout
  - (Later) Add note, start fast, etc.
- Implemented as:
  - Either a `ShellRoute` with nested `GoRoute`s for each tab, or
  - A dedicated `AppShellPage` with an `IndexedStack` for tabs, integrated into `go_router`.

Suggested routes:

- `/today`
- `/nutrition`
- `/training`
- `/settings`

### 5.2 Today tab (Dashboard)

Fused performance overview for the day.

**Layout:**

- Header:
  - “Today”
  - Date
- Cards:
  1. **Daily nutrition card**
     - Calorie ring (target / consumed / remaining).
     - Macro chips (P/F/C).
     - Tapping opens Nutrition tab on current day.
  2. **Training card**
     - Next scheduled workout: name, day, key lifts.
     - Last completed workout: date, short summary, maybe a PR badge.
     - Tapping opens Training tab.
  3. **Weigh‑in card**
     - Sparkline for last 7 days.
     - Most recent weight + trend text.
     - CTA “Log weight”.
  4. **Quick actions row**
     - Horizontal row of pill buttons:
       - Log food
       - Weigh in
       - Start workout
     - Duplicates the most common actions from the global quick‑action sheet.

### 5.3 Nutrition tab

Daily logging + simple history.

- Top bar:
  - 7‑day date strip (Mon–Sun) or previous/next day buttons.
  - Daily macros summary (calories + macros).
- Body:
  - Meal/time layout (similar to MacroFactor’s timeline):
    - 7am, 8am… each with a “+” for quickly adding food.
  - Tapping a slot opens a **log sheet** with:
    - Search
    - Quick add (manual nutrition values)
    - (Later) barcode, favorites, recipes, AI helpers.
- Bottom:
  - Search bar for foods.
  - Possibly a mini filter / options chip row.
- Quick actions:
  - FAB and/or center + sheet focusing on nutrition operations when originating from this tab.

### 5.4 Training tab

Programs and workouts.

- Header:
  - Current program name (or empty state prompting program creation).
- Cards:
  1. **Next workout**
     - Day, name, focus, estimated duration.
     - Big “Start workout” button.
  2. **Last workout**
     - Date, key stats (volume, sets, time).
     - Quick view of last exercise comments (e.g. “Remember to brace hard on squats”).
  3. **Program card**
     - Split (e.g., ULxULx), start/end dates.
     - CTA: “View program” → program detail.

**Program + workout behavior (MVP):**

- Users can create a program:
  - Choose split / days (e.g. M/W/F).
  - Create workouts.
- Each workout:
  - Exercise list built from an exercise library (name, body part, equipment).
  - Each exercise has sets with reps, weight, and **comments per exercise**.
  - When starting a workout:
    - Show last session performance and comments for that exercise.
    - User logs new sets, weights, comments.

### 5.5 Settings tab

- Account:
  - Email, sign‑in providers, sign out.
- Units:
  - Weight: kg / lb
  - Height: cm / ft + in
- Appearance:
  - Theme: system / light / dark.
- Coaching / strategy:
  - Nutrition coach status (Pro).
  - Training coach status (Pro).
  - Buttons to manage or upgrade (RevenueCat paywall later).
- Legal:
  - Terms of Service
  - Privacy Policy
  - Health disclaimer.

---

## 6. Coaching & monetization (for reference)

### 6.1 Nutrition coach (Pro)

- Uses validated formulas (to be finalized and fully cited) for:
  - Estimating energy expenditure.
  - Adjusting calorie targets based on weight trends and adherence.
- Core behaviors:
  - Weekly check‑in: weight trend + adherence → adjust daily budget and macros.
  - Avoids aggressive, unsafe rates by enforcing min/max %BW per week.

### 6.2 Training coach (Pro)

- Uses logged progression, last session performance, and user comments/RPE to:
  - Suggest load increases or decreases.
  - Suggest volume adjustments (sets).
  - Flag potential fatigue patterns (only in Pro tier).
- Behavior is implemented behind domain interfaces so it can be iterated on safely.

### 6.3 Pricing (MVP starting point)

- Individual Diet coach (monthly).
- Individual Training coach (monthly).
- Bundle (Diet + Training) at a discount.

(Exact prices can be refined later; there’s already a notionally “approved” price structure from earlier discussion.)

---

## 7. Testing strategy & skeleton

We want a small but solid test pyramid.

### 7.1 Goals

- Protect math / domain logic.
- Protect onboarding flow behavior.
- Ensure the app shell doesn’t break basic navigation.
- One happy-path integration test from onboarding → shell.

### 7.2 Suggested test layout

```text
test/
  features/
    onboarding/
      domain/
        simple_preview_estimator_test.dart
        value_objects_test.dart
      presentation/
        onboarding_preview_vm_test.dart
        onboarding_summary_vm_test.dart
        onboarding_goal_page_test.dart
        onboarding_stats_page_test.dart
        onboarding_preview_page_test.dart
        onboarding_summary_page_test.dart
  app/
    shell/
      app_shell_navigation_test.dart

integration_test/
  onboarding_flow_test.dart
7.3 Unit tests (examples)

simple_preview_estimator_test.dart

Maintain vs loss vs gain affects dailyKcal in the expected direction.

projectedEndDate moves as expected with different target weights / rates.

Macros are non‑negative and roughly match daily kcal when converted.

value_objects_test.dart

Weight and height conversions (kg↔lb, cm↔ft-in) are consistent.

onboarding_preview_vm_test.dart

Boundaries for target weight and weekly rate for each goal.

Rate sign enforcement (loss always negative, gain always positive).

Changes in rate/target trigger recomputation of kcal and end date.

onboarding_summary_vm_test.dart

paceLabel classification based on %BW/week.

goalLabel matches enum.

savePlan() toggles isSaving and stores planId returned from repo.

7.4 Widget tests (examples)

onboarding_goal_page_test.dart

Renders the three goals and keeps “Next” disabled until one is selected.

Selecting a goal enables “Next”.

onboarding_stats_page_test.dart

Shows DOB, Height, Weight, Activity rows.

“Next” is disabled until valid values are provided.

onboarding_preview_page_test.dart

Shows daily kcal, target weight, rate, macros.

Moving sliders invokes the correct VM methods (verified with a fake VM).

onboarding_summary_page_test.dart

Displays recap correctly given a known SummaryVm state.

Tapping “Start tracking” calls savePlan() and shows a loading state.

7.5 Shell test

app_shell_navigation_test.dart

Shell initially shows Today tab.

Tapping tab icons switches visible tab.

FAB opens quick-action bottom sheet.

7.6 Integration test

integration_test/onboarding_flow_test.dart

Launch app with no onboarding completion flag.

Run through:

Welcome → Get Started

Goal selection

Stats entry

Preview (accept defaults)

Summary → Start tracking

Assert we reach the main shell and see something unique to Today tab.

8. Next steps after onboarding

Once onboarding screens are solid:

Implement main shell & Today tab

Create AppShellPage / ShellRoute.

Build Today tab with placeholder data wired to the plan.

Implement Nutrition tab (minimal)

Day selector, macro summary, and quick manual logging.

Implement Training tab (minimal)

Ability to create a simple workout and log one session with comments.

Build Settings tab scaffolding

Units, theme toggle, legal pages.

Placeholder for coach/Pro settings.

Introduce Plan persistence

Replace MemoryPlanRepository with Firestore implementation.

Wire onboarding completion flag → app start routing.

Implement tests per the testing plan

Start with unit tests for estimators and VMs.

Add widget tests for onboarding screens.

Add the main integration test.

Integrate RevenueCat & Pro features

Gate coach behaviors behind paywalls and adapt UI accordingly.