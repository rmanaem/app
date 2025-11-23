# Training v2

## 0. Goals

The Training tab should feel like:

- **A clear weekly overview** of your lifting week.
- **A launcher for action**: start today’s workout, review yesterday, or build a simple program.
- **Consistent with Today & Nutrition** in layout, typography, and card design (performance minimalism, dark/light theme, cards with clear hierarchy).

For v1 (MVP), the Training tab:

- Uses **fake data** (no real persistence yet), just like Today/Nutrition during early UI work.
- Shows **this week’s schedule** with a 7‑day strip.
- Highlights **Next workout** and **Last workout** with meaningful summaries.
- Provides **CTAs to start a workout** and navigates to the Training feature for logging.
- Stays **purely presentational** in widgets; all logic lives in viewmodels/repositories.

Later, this will grow into:

- A full **program/template builder** (Strong‑style).
- **Exercise‑level logging**, including **comments/notes per exercise** that surface into “Last workout” summaries.
- PRs, streaks, and richer analytics.

---

## 1. UX layout & interactions

### 1.1 Page anatomy

High‑level structure (similar to Today):

- **Header**
  - Label: `TRAINING`
  - Subtitle: `This week`
- **Week strip**
  - 7 day chips (Mon–Sun), each showing:
    - Day letter (M, T, W…)
    - Dot or small label for status (Planned / Done / Rest)
  - Selected day is today by default.
- **Next workout card**
  - Section label: `Next`
  - Workout name: `Upper A`, `Push day`, etc.
  - Time: `Today · 18:00` or `Tomorrow · 18:00`
  - Meta: `3 exercises · ~45 min`
  - Primary CTA button: **Start workout**
- **Last workout card**
  - Section label: `Last`
  - Date/time: `Mon · 42 min`
  - Meta line:
    - simple: `3 exercises · 9 sets`
    - plus short **comment snippet** if available: `"Focus on bracing on squats."`
- **Program / actions row**
  - Simple row of action chips:
    - `View program`
    - `Create program` (later)
    - `View history`
- **Empty states**
  - No program: explain and show **Create program** as primary CTA.
  - Program but no last workout: “You haven’t logged a session yet.”

Visually this should match Today/Nutrition:

- Background: `AppColors.bg`.
- Cards: `AppColors.surface2` with `AppColors.ringTrack` borders.
- Typography: `Theme.of(context).textTheme` + your AppTypography tokens.
- Spacing: `AppSpacing` steps.

### 1.2 Widget tree (conceptual)

```dart
TrainingPage
 └─ Scaffold
    └─ SafeArea
       └─ Padding(16, 12)
          └─ SingleChildScrollView
             └─ Column(
                  crossAxisAlignment: stretch,
                  children: [
                    TrainingHeader(state: vm.state),
                    SizedBox(height: 16),
                    TrainingWeekStrip(
                      days: state.weekDays,
                      selectedDate: state.selectedDate,
                      onSelect: vm.onSelectDate,
                    ),
                    SizedBox(height: 16),
                    TrainingNextCard(
                      next: state.nextWorkout,
                      onStart: vm.onStartNextWorkout,
                    ),
                    SizedBox(height: 12),
                    TrainingLastCard(
                      last: state.lastWorkout,
                      onOpenDetails: vm.onOpenLastWorkout,
                    ),
                    SizedBox(height: 12),
                    TrainingActionsRow(
                      onViewProgram: vm.onViewProgram,
                      onCreateProgram: vm.onCreateProgram, // later OK
                      onViewHistory: vm.onViewHistory,
                    ),
                    SizedBox(height: 24),
                  ],
                )

All these widgets are dumb: they take plain props and callbacks, and never talk to repositories/use‑cases directly.

2. Domain model & contracts
2.1 Entities

Minimal entities to support the UI:

// lib/src/features/training/domain/entities/training_day_overview.dart
enum TrainingDayStatus {
  rest,
  planned,
  completed,
}

class TrainingDayOverview {
  TrainingDayOverview({
    required this.date,
    required this.status,
  });

  final DateTime date;
  final TrainingDayStatus status;
}


// lib/src/features/training/domain/entities/training_overview.dart
class TrainingOverview {
  TrainingOverview({
    required this.anchorDate,      // usually "today"
    required this.weekDays,        // 7 x TrainingDayOverview
    this.nextWorkout,
    this.lastWorkout,
    required this.hasProgram,
  });

  final DateTime anchorDate;
  final List<TrainingDayOverview> weekDays;
  final WorkoutSummary? nextWorkout;
  final WorkoutSummary? lastWorkout;
  final bool hasProgram;
}


2.2 Repository contract
// lib/src/features/training/domain/repositories/training_overview_repository.dart
import '../entities/training_overview.dart';

abstract class TrainingOverviewRepository {
  /// Returns an overview for the training week containing [anchorDate].
  Future<TrainingOverview> getOverviewForWeek(DateTime anchorDate);
}
We keep it single‑responsibility:

Just enough for the Training tab overview.

The program builder and workout logger can add more repositories/entities later.



3. Data layer (fake repo)

For MVP, we mirror the pattern used by PlanRepositoryFake and FoodLogRepositoryFake

// lib/src/features/training/data/repositories_impl/training_overview_repository_fake.dart
import 'dart:async';

import '../../domain/entities/training_day_overview.dart';
import '../../domain/entities/training_overview.dart';
import '../../domain/entities/workout_summary.dart';
import '../../domain/repositories/training_overview_repository.dart';

class TrainingOverviewRepositoryFake implements TrainingOverviewRepository {
  @override
  Future<TrainingOverview> getOverviewForWeek(DateTime anchorDate) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final today = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);

    final weekDays = List<TrainingDayOverview>.generate(7, (index) {
      final date = today.add(Duration(days: index - 3));
      if (date.isBefore(today)) {
        return TrainingDayOverview(
          date: date,
          status: TrainingDayStatus.completed,
        );
      }
      if (index == 3) {
        return TrainingDayOverview(
          date: date,
          status: TrainingDayStatus.planned,
        );
      }
      return TrainingDayOverview(
        date: date,
        status: TrainingDayStatus.rest,
      );
    });

    final nextWorkout = WorkoutSummary(
      id: 'next-1',
      name: 'Upper A',
      dayLabel: 'Tomorrow',
      timeLabel: '18:00',
      meta: '3 exercises · ~45 min',
    );

    final lastWorkout = WorkoutSummary(
      id: 'last-1',
      name: 'Lower B',
      dayLabel: 'Mon',
      timeLabel: '42 min',
      meta: '3 exercises · 9 sets',
      notePreview: 'Focus on bracing on squats.',
    );

    return TrainingOverview(
      anchorDate: today,
      weekDays: weekDays,
      nextWorkout: nextWorkout,
      lastWorkout: lastWorkout,
      hasProgram: true,
    );
  }
}
This gives the UI something realistic to chew on and tests loading states.

4. Presentation: state & viewmodel
4.1 ViewState

// lib/src/features/training/presentation/viewstate/training_overview_view_state.dart
import '../../domain/entities/training_day_overview.dart';
import '../../domain/entities/workout_summary.dart';

class TrainingOverviewViewState {
  const TrainingOverviewViewState({
    required this.isLoading,
    required this.selectedDate,
    required this.weekDays,
    this.nextWorkout,
    this.lastWorkout,
    this.errorMessage,
    required this.hasProgram,
  });

  final bool isLoading;
  final DateTime selectedDate;
  final List<TrainingDayOverview> weekDays;
  final WorkoutSummary? nextWorkout;
  final WorkoutSummary? lastWorkout;
  final String? errorMessage;
  final bool hasProgram;

  bool get hasError => errorMessage != null;

  TrainingOverviewViewState copyWith({
    bool? isLoading,
    DateTime? selectedDate,
    List<TrainingDayOverview>? weekDays,
    WorkoutSummary? nextWorkout,
    WorkoutSummary? lastWorkout,
    String? errorMessage,
    bool? hasProgram,
  }) {
    return TrainingOverviewViewState(
      isLoading: isLoading ?? this.isLoading,
      selectedDate: selectedDate ?? this.selectedDate,
      weekDays: weekDays ?? this.weekDays,
      nextWorkout: nextWorkout ?? this.nextWorkout,
      lastWorkout: lastWorkout ?? this.lastWorkout,
      errorMessage: errorMessage,
      hasProgram: hasProgram ?? this.hasProgram,
    );
  }

  factory TrainingOverviewViewState.initial(DateTime today) {
    return TrainingOverviewViewState(
      isLoading: true,
      selectedDate: today,
      weekDays: const [],
      nextWorkout: null,
      lastWorkout: null,
      errorMessage: null,
      hasProgram: false,
    );
  }
}

4.2 ViewModel

// lib/src/features/training/presentation/viewmodels/training_overview_view_model.dart
import 'package:flutter/foundation.dart';

import '../../domain/repositories/training_overview_repository.dart';
import '../viewstate/training_overview_view_state.dart';

class TrainingOverviewViewModel extends ChangeNotifier {
  TrainingOverviewViewModel({
    required TrainingOverviewRepository repository,
    DateTime? today,
  })  : _repository = repository,
        _today = today ?? DateTime.now(),
        _state = TrainingOverviewViewState.initial(today ?? DateTime.now()) {
    load();
  }

  final TrainingOverviewRepository _repository;
  final DateTime _today;

  TrainingOverviewViewState _state;
  TrainingOverviewViewState get state => _state;

  Future<void> load() async {
    _emit(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      final overview = await _repository.getOverviewForWeek(_today);
      _emit(
        TrainingOverviewViewState(
          isLoading: false,
          selectedDate: overview.anchorDate,
          weekDays: overview.weekDays,
          nextWorkout: overview.nextWorkout,
          lastWorkout: overview.lastWorkout,
          errorMessage: null,
          hasProgram: overview.hasProgram,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load training overview.',
        ),
      );
    }
  }

  void onSelectDate(DateTime date) {
    _emit(_state.copyWith(selectedDate: date));
    // Later: load overview anchored to [date] or filter last/next.
  }

  void _emit(TrainingOverviewViewState newState) {
    _state = newState;
    notifyListeners();
  }

  // Navigation hooks – implemented by the page using callbacks/router.
  void onStartNextWorkout() {
    // TODO: call into navigation/service later.
  }

  void onOpenLastWorkout() {
    // TODO
  }

  void onViewProgram() {
    // TODO
  }

  void onCreateProgram() {
    // TODO (post‑MVP)
  }

  void onViewHistory() {
    // TODO
  }
}


ViewModel follows the same MVVM & ChangeNotifier pattern you’re using on Today/Nutrition.


5. UI: TrainingPage & widgets
5.1 File & placement

Page

lib/src/features/training/presentation/pages/training_page.dart

Widgets (optional extraction once stable)

lib/src/features/training/presentation/widgets/training_header.dart

lib/src/features/training/presentation/widgets/training_week_strip.dart

lib/src/features/training/presentation/widgets/training_next_card.dart

lib/src/features/training/presentation/widgets/training_last_card.dart

lib/src/features/training/presentation/widgets/training_actions_row.dart

Initially, you can keep them all in training_page.dart (like NutritionPage v1), then extract as they grow.

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final vm = context.watch<TrainingOverviewViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.hasError
                  ? _TrainingError(message: state.errorMessage!)
                  : _TrainingContent(
                      state: state,
                      onSelectDate: vm.onSelectDate,
                      onStartNextWorkout: vm.onStartNextWorkout,
                      onOpenLastWorkout: vm.onOpenLastWorkout,
                      onViewProgram: vm.onViewProgram,
                      onCreateProgram: vm.onCreateProgram,
                      onViewHistory: vm.onViewHistory,
                    ),
        ),
      ),
    );
  }
}
_TrainingContent then implements the widget tree from §1.2 using the design system (AppColors, AppSpacing, TextTheme) and no business logic.


6. Wiring & navigation

Register TrainingOverviewViewModel similarly to Today/Nutrition in your router/app shell:

Wrap the Training route in a ChangeNotifierProvider.

Quick actions:

Today’s Start workout quick action → navigate to this Training tab (or a dedicated start‑workout page) and call vm.onStartNextWorkout.

TrainingNextCard Start workout button → same.

TrainingActionsRow buttons → route stubs (program screen/history screen) for no


7. MVP vs later
MVP (v1) – must have

TrainingOverviewRepositoryFake returning:

7‑day week overview.

Next + last workout summaries.

TrainingOverviewViewModel + TrainingOverviewViewState.

TrainingPage with:

Header (TRAINING / This week).

Week strip with selected day.

Next workout card with Start button (navigates to Training logging shell or stub).

Last workout card (navigates to placeholder history/details).

Program/actions row with at least View program and View history wired to stubs.

UI uses design system exclusively and matches the Today/Nutrition card style.

Later (post‑MVP)

Program/template builder (Strong‑style):

Splits, days of week, date range, exercises, etc.

Real repositories for programs and workout logs.

Exercise logging, including per‑exercise comments (which feed notePreview in WorkoutSummary).

Streaks, PRs, and richer metrics on the Training tab.

Calendar view beyond 7‑day strip.

Animations (card transitions, progress indicators) and more nuanced empty states.

---

## Implementation plan

1. **Domain layer**
   - Add `TrainingDayStatus`, `TrainingDayOverview`, `WorkoutSummary`, and `TrainingOverview` under `lib/src/features/training/domain/entities/`.
   - Define `TrainingOverviewRepository` (week overview contract) in `domain/repositories/`.

2. **Data (fake repo)**
   - Implement `TrainingOverviewRepositoryFake` in `data/repositories_impl/` with seeded week data, next/last workout summaries, and async delay (mirroring other fake repos).

3. **Presentation state & ViewModel**
   - Create `TrainingOverviewViewState` (immutable, copyWith, initial factory).
   - Implement `TrainingOverviewViewModel` (ChangeNotifier) that loads via the repository, handles errors, exposes `onSelectDate` and navigation callbacks.

4. **UI**
   - Refactor `TrainingPage` to consume the ViewModel via Provider; render loading/error/content states.
   - Implement the widget tree (header, week strip, next/last cards, actions row) using design-system tokens; keep widgets presentational.

5. **Routing/DI**
   - Update router to wrap `/training` in a `ChangeNotifierProvider<TrainingOverviewViewModel>` wired to the fake repo until real data lands.

6. **Testing**
   - Add unit tests for the ViewModel (success/error load, date selection, callbacks).
   - Optional golden/widget tests once week strip/cards stabilize.

---

## What’s implemented now

- **Domain & data**
  - Added `TrainingDayOverview`, `TrainingOverview`, and `WorkoutSummary` entities plus the `TrainingOverviewRepository` contract.
  - Introduced `TrainingOverviewRepositoryFake` with seeded seven-day data, next/last workout summaries, completed/planned counts, and an async delay to mimic loading.

- **Presentation**
  - Implemented `TrainingOverviewViewState` (immutable state with copyWith + initial factory) and `TrainingOverviewViewModel` (ChangeNotifier) that loads via the repository, exposes `onSelectDate`, and stubs navigation callbacks.
  - Refactored `TrainingPage` to use the ViewModel via Provider, rendering loading/error/content states with design-system tokens. The page now shows header, weekly summary card, week strip, next/last workout cards, and action chips; the week strip handles selection without overflow.

- **Routing/DI**
  - `/training` route now wraps the page in a `ChangeNotifierProvider<TrainingOverviewViewModel>` wired to `TrainingOverviewRepositoryFake`.

- **Testing**
  - Added `test/features/training/presentation/viewmodels/training_overview_view_model_test.dart` covering successful load, error handling, and date selection updates.
