# Testing Plan

# Testing Plan

This document defines the testing strategy and concrete test files for the MVP of the Nutrition & Training app.

It is written to guide both humans and AI assistants when adding or updating tests.

We follow a **small but solid test pyramid**:

1. **Unit tests** – domain logic and viewmodels.
2. **Widget tests** – key pages/components.
3. **Integration tests** – a few critical flows (esp. onboarding → shell).
4. **Optional** golden tests – for UI regression later.

We use `very_good_analysis`, so tests should be clean and idiomatic.

---

## 1. Tooling & conventions

- **Packages**
  - `flutter_test`
  - `mocktail` (or similar) for mocks/fakes.
  - `integration_test` for end‑to‑end flows.

- **Structure**
  ```text
  test/
    features/
      <feature_name>/
        domain/
        presentation/
          viewmodels/
          pages/
        ...
  integration_test/
    <flow_name>_test.dart


Style

Use arrange–act–assert in tests.

No hitting real Firebase/RevenueCat in tests – always mock abstractions.

Name tests descriptively: should_doX_when_Y.

Important abstractions to mock

PlanRepository (creating/loading a plan).

Any Estimator (e.g. PreviewEstimator / SimplePreviewEstimator) when testing VMs.

Analytics/reporting.

Coaching services (when we reach that phase).

2. Test tiers (priority)

We tag each test file:

[MVP‑CRITICAL] – must be in place before shipping an MVP build.

[LATER] – nice-to-have, can be added after core MVP is stable.

3. Onboarding tests
3.1 Domain – estimators & value objects

File:
test/features/onboarding/domain/preview_estimator_test.dart
Priority: [MVP‑CRITICAL]

Covers:

PreviewEstimator (or SimplePreviewEstimator) behavior:

Given:

goal = lose / maintain / gain

current weight, target weight, weekly rate

activity level

Asserts:

dailyKcal moves in the correct direction:

higher loss rate → lower kcal

higher gain rate → higher kcal

projectedEndDate moves in the correct direction:

higher rate → earlier end date (for loss/gain).

Macros are non‑negative and energy from macros ≈ dailyKcal within tolerance.

Safe bounds:

Weekly rate is clamped to safe %BW/week.

Edge cases: target weight equal to current weight (maintain).

Mocking:
None – this is pure logic. If the estimator depends on other services, provide a simple fake implementation.

File:
test/features/onboarding/domain/value_objects_test.dart
Priority: [MVP‑CRITICAL]

Covers:

Height & weight value objects (if present):

kg ↔ lb conversion correctness.

cm ↔ ft/in conversion correctness.

Any goal enums or types:

Mapping to strings/labels (Lose / Maintain / Gain).

Mocking:
None – pure value objects.

3.2 Presentation – ViewModels

**Unified Onboarding VM**

File:
test/features/onboarding/presentation/viewmodels/onboarding_vm_test.dart
Priority: [MVP‑CRITICAL]

Covers:

**Goal Selection:**

Initial state:

No goal selected (`goalState.selected == null`).

`goalState.canContinue == false`.

Selecting a goal:

Selecting each goal sets the correct enum/value.

`goalState.canContinue == true` after a valid goal is chosen.

Reselection:

Changing the goal updates state accordingly.

Analytics events fired on goal selection.

**Stats Entry:**

Initial state:

All fields null/empty (`statsState.dob == null`, etc.).

`statsState.isValid == false`.

Setting each field:

Setting DOB alone doesn't allow continue.

Setting height/weight/activity individually still not enough.

Only when all fields are valid → `statsState.isValid == true`.

Analytics events fired on navigation.

Mocking:
Mock `AnalyticsService` for logging events.



**Goal Configuration VM**

File:
test/features/onboarding/presentation/viewmodels/goal_configuration_vm_test.dart
Priority: [MVP‑CRITICAL]

Covers:

Initialization:

Accepts goal, stats (DOB, height, weight, activity) as constructor arguments.

Computes starting `targetWeight`, `weeklyRate`, `dailyKcal`, `projectedEndDate`.

Bounds:

`targetWeightBounds` derive correctly from goal type and current weight.

`weeklyRateBounds` are within safe ranges based on goal.

Rate & target interactions:

Updating target weight:

Recalculates preview with new target.

Exposes updated `dailyKcal` and `projectedEndDate`.

Updating weekly rate:

Recalculates preview with new rate.

Loss rate increase → decreases `dailyKcal`, pulls `projectedEndDate` closer.

Estimator integration:

VM calls `PreviewEstimator.estimate()` with correct arguments.

Exposes estimator output (`dailyKcal`, `projectedEndDate`, macros).

Mocking:

Mock `PreviewEstimator` using mocktail.

Configure it to return known `PreviewOutput`.

Verify VM passes expected arguments to estimator.

Summary VM

File:
test/features/onboarding/presentation/viewmodels/onboarding_summary_vm_test.dart
Priority: [MVP‑CRITICAL]

Covers:

Summary mapping:

Given a preview + stats, summary exposes:

Goal label, target weight, weekly rate, pace label.

Daily calories & projected end date.

savePlan() behavior:

Toggles isSaving from false → true → false after async call.

Calls PlanRepository.createPlan with expected data.

Stores returned planId / plan object.

Error handling (if implemented):

On exception, isSaving resets and an error state is set.

Mocking:

Mock PlanRepository with mocktail.

when(() => createPlan(...)) → Future.value(fakePlan).

3.3 Presentation – Page/widget tests
Goal page

File:
test/features/onboarding/presentation/pages/onboarding_goal_page_test.dart
Priority: [MVP‑CRITICAL]

Covers:

Renders:

Correct title (“What’s your goal?”)

Three goal options.

Disabled Next button initially.

Interaction:

Tapping a goal updates VM and enables Next.

Tapping Next calls onNext or navigates appropriately (using a fake VM/router).

Mocking:

Provide a fake VM implementation with observable properties.

Or use a real VM and inject a fake repository/estimator as needed.

Stats page

File:
test/features/onboarding/presentation/pages/onboarding_stats_page_test.dart
Priority: [MVP‑CRITICAL]

Covers:

Renders:

Title (“Tell us about you” or equivalent).

4 tappable rows: DOB, Height, Weight, Activity.

Disabled Next button initially.

Interaction:

Simulate filling valid stats (through VM or by directly updating state).

Verify Next button becomes enabled.

Tapping Next triggers onNext or navigation.

Mocking:

Same approach as goal page: use fake or real VM with fakes injected.

Goal configuration page

File:
test/features/onboarding/presentation/pages/goal_configuration_page_test.dart
Priority: [MVP‑CRITICAL]

Covers:

Renders:

Daily calorie card.

Projected end date card.

Target weight slider & label.

Weekly rate slider & label + pace label.

Interaction:

Change slider values and ensure:

VM’s updateTargetWeight and updateWeeklyRate get called.

Displayed values change accordingly (basic checks).

Mocking:

Fake VM with:

Public fields for targetWeight, weeklyRate, dailyKcal, endDate.

Methods that update fields and notify listeners.

Summary page

File:
test/features/onboarding/presentation/pages/onboarding_summary_page_test.dart
Priority: [MVP‑CRITICAL]

Covers:

Renders:

Goal label, pace label, target weight, weekly rate.

Daily calories + projected end date.

“Start tracking” button.

Interaction:

Tapping “Start tracking” calls VM savePlan().

When VM is in isSaving == true, show loading state (e.g. progress indicator or disabled button).

Mocking:

Fake VM that tracks whether savePlan() was called and exposes isSaving.

3.4 Onboarding flow test (widget‑level)

File:
test/features/onboarding/onboarding_flow_test.dart
Priority: [LATER] but recommended

Covers:

Pump the onboarding flow as a whole (may be a minimal router config).

Simulate:

Choosing a goal.

Entering valid stats.

Accepting default preview.

Completing summary.

Assert:

A fake PlanRepository’s createPlan was called.

Navigation intent triggered to the shell entry route.

Mocking:

Mock PlanRepository.

Possibly mock router using MockGoRouter or a simple fake.

4. Shell & navigation tests

**Note:** Shell navigation uses GoRouter's `StatefulNavigationShell` which manages tab state internally. No separate ViewModel is needed.

**App shell page**

File:
test/features/shell/presentation/pages/app_shell_page_test.dart
Priority: [MVP‑CRITICAL]

Covers:

Renders bottom navigation bar with 4 items: Today, Nutrition, Training, Settings.

Shows correct tab based on GoRouter's current route.

Tab switching:

Tapping each nav item navigates to the appropriate route.

Verifies `StatefulNavigationShell.goBranch()` is called with correct index.

FAB:

Renders floating action button.

Implementation:

Uses **real GoRouter** with `StatefulShellRoute.indexedStack`.

Provides simple placeholder pages for each tab branch.

Tests integrated navigation behavior, not mocked state.

5. Today tab tests

These can be done once Today tab has basic widgets.

5.1 Today ViewModel

File:
test/features/today/presentation/viewmodels/today_vm_test.dart
Priority: [LATER]

Covers:

Combining data:

Given plan + recent weights + recent workouts + today’s nutrition:

Exposes daily macro stats (consumed, remaining).

Exposes next/last workout summaries.

Exposes weight trend summary (sparkline data + text).

Handling loading/error states gracefully.

Mocking:

Mock:

PlanRepository

NutritionRepository

TrainingRepository

WeightRepository

Use simple stub data to assert derived fields.

5.2 Today page

File:
test/features/today/presentation/pages/today_page_test.dart
Priority: [LATER]

Covers:

Renders:

Diet card

Training card

Weigh‑in card

Quick actions row

Interaction:

Tapping “Log food” invokes navigation to Nutrition tab or opens logging sheet.

Tapping “Start workout” routes to Training.

Mocking:

Fake VM that exposes simple static values for metrics and has callback spies.

6. Nutrition tests
6.1 Nutrition VM

File:
test/features/nutrition/presentation/viewmodels/nutrition_vm_test.dart
Priority: [LATER]

Covers:

Selecting days:

Exposes current day and allows switching.

Macro summary:

Given a list of food entries:

Calculates totals correctly.

Calculates remaining vs target correctly.

Logging:

Adding a quick‑add entry updates totals.

Mocking:

Mock NutritionRepository that returns lists of entries.

For logging, verify VM calls repo and updates state.

6.2 Nutrition page

File:
test/features/nutrition/presentation/pages/nutrition_page_test.dart
Priority: [LATER]

Covers:

Renders:

Date strip or day selector

Macro summary

Time slots with + buttons

Interaction:

Tapping a + button opens the log sheet.

Tapping “Quick add” in sheet updates visible totals (may require fake VM).

Mocking:

Fake VM with:

Public fields for macros and entries.

Methods to add entries.

7. Training tests
7.1 Training VM

File:
test/features/training/presentation/viewmodels/training_vm_test.dart
Priority: [LATER]

Covers:

Program state:

Exposes current program and workouts this week.

Exposes “next workout” and “last workout”.

Logging:

Starting a workout creates a session object.

Logging sets for an exercise:

Updates volume and summary.

Stores comments per exercise.

Comment surfacing:

For a given exercise, last session’s comments are accessible.

Mocking:

Mock TrainingRepository and ProgramRepository.

7.2 Training page

File:
test/features/training/presentation/pages/training_page_test.dart
Priority: [LATER]

Covers:

Renders:

Upcoming workout card

Last workout card

Program card (or empty state)

Interaction:

Tapping “Start workout” navigates to workout logging page.

Mocking:

Fake VM that exposes static program & workout data.

7.3 Workout logging page

File:
test/features/training/presentation/pages/workout_logging_page_test.dart
Priority: [LATER]

Covers:

Renders:

Exercises

Set rows for each exercise

Comment field per exercise

Interaction:

Editing reps/weight updates VM.

Entering a comment for an exercise updates VM.

Mocking:

Fake VM with:

Methods updateSet, updateComment.

Data structure representing exercises & sets.

8. Settings & coaching tests
8.1 Settings VM

File:
test/features/settings/presentation/viewmodels/settings_vm_test.dart
Priority: [LATER]

Covers:

Units:

Toggling kg ↔ lb updates stored preference.

Theme:

Theme mode changes.

Coaching flags:

Displays correct Pro/free status based on mocked subscription state.

Mocking:

Mock PreferencesRepository.

Later: mock SubscriptionRepository (built on top of RevenueCat wrapper).

9. Integration tests
9.1 Onboarding → shell happy path

File:
integration_test/onboarding_flow_test.dart
Priority: [MVP‑CRITICAL]

Covers:

Scenario:

App launched with:

Authenticated user (stubbed)

No existing plan

Flow:

Welcome → “Get Started”

Step 1: select goal

Step 2: fill DOB/height/weight/activity with valid values

Step 3: leave default preview or make a simple change

Step 4: “Start tracking”

Outcome:

Shell is shown (Today tab).

Some visible element confirms we are in main app (e.g. “Today” header).

Mocking:

Inject a fake PlanRepository via dependency injection so:

createPlan returns a dummy plan quickly.

Optionally stub any network calls.

9.2 Returning user path (later)

File:
integration_test/returning_user_flow_test.dart
Priority: [LATER]

Covers:

Scenario:

App launched with:

Authenticated user

EXISTING plan in storage

Outcome:

App bypasses onboarding and lands directly in the shell (Today tab).

Mocking:

Same as onboarding test, but PlanRepository.getPlan returns a plan.

10. Golden tests (optional, later)

If we want stricter visual regression:

Add golden_test/ directory and snapshot:

Onboarding screens (light/dark)

Today tab (light/dark)

These are [LATER] and only necessary when UI becomes more stable.

11. Summary of MVP‑critical tests

Must‑have before shipping MVP externally:

**Domain:**
- `preview_estimator_test.dart`
- `value_objects_test.dart`

**ViewModels:**
- `onboarding_vm_test.dart` (tests goal selection + stats entry)
- `goal_configuration_vm_test.dart` (tests target weight + weekly rate)
- `onboarding_summary_vm_test.dart` (tests summary display + savePlan)

**Pages:**
- `onboarding_goal_page_test.dart`
- `onboarding_stats_page_test.dart`
- `goal_configuration_page_test.dart`
- `onboarding_summary_page_test.dart`
- `app_shell_page_test.dart`

**Integration:**
- `integration_test/onboarding_flow_test.dart`

Everything else is incremental hardening once the core experience is stable.


UPDATE: after [MVP‑CRITICAL] tests implementation:
Key Findings by Level
Unit Tests (9/10): Test public contracts, pure domain logic, fast and isolated

ViewModel Tests (9/10): Mock external services, test state transitions and public API only

Widget Tests (8/10): Good use of pump/pumpAndSettle, test user interactions

⚠️ Missing: Widget keys, semantics/accessibility testing
Integration Test (7/10): Covers critical user journey end-to-end

⚠️ Needs: Error path coverage, test doubles for external services
Priority Recommendations
HIGH:

Add widget keys for robust selectors
Add semantics testing for accessibility
Add error path tests in integration
MEDIUM: 4. Consider golden tests for visual regression 5. Add edge case coverage

The detailed analysis with code examples, specific scores, and implementation guidance is available in the test quality report artifact.
