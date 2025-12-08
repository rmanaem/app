import 'package:meta/meta.dart';
import 'package:starter_app/src/features/training/domain/entities/training_day_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/workout_summary.dart';

/// Immutable UI state for the training overview page.
@immutable
class TrainingOverviewViewState {
  /// Creates a view state snapshot.
  const TrainingOverviewViewState({
    required this.isLoading,
    required this.selectedDate,
    required this.dateLabel,
    required this.weekDays,
    required this.hasProgram,
    required this.completedWorkouts,
    required this.plannedWorkouts,
    this.nextWorkout,
    this.lastWorkout,
    this.activeProgramId,
    this.errorMessage,
  });

  /// Initial loading state anchored to [today].
  factory TrainingOverviewViewState.initial(DateTime today) {
    final anchor = DateTime(today.year, today.month, today.day);
    return TrainingOverviewViewState(
      isLoading: true,
      selectedDate: anchor,
      dateLabel: '',
      weekDays: const [],
      hasProgram: false,
      completedWorkouts: 0,
      plannedWorkouts: 0,
    );
  }

  /// Whether the overview is loading.
  final bool isLoading;

  /// Currently selected day in the week strip.
  final DateTime selectedDate;

  /// Formatted label for the selected date (e.g. "MONDAY, DEC 12").
  final String dateLabel;

  /// Seven-day overview entries.
  final List<TrainingDayOverview> weekDays;

  /// Upcoming workout summary, if any.
  final WorkoutSummary? nextWorkout;

  /// Most recent workout summary, if any.
  final WorkoutSummary? lastWorkout;

  /// Optional error message when loading fails.
  final String? errorMessage;

  /// Whether the user has a program configured.
  final bool hasProgram;

  /// Completed workouts count for the week.
  final int completedWorkouts;

  /// Planned workouts count for the week.
  final int plannedWorkouts;

  /// The ID of the currently active program, if any.
  final String? activeProgramId;

  /// True when [errorMessage] is non-null.
  bool get hasError => errorMessage != null;

  /// Creates a copy with updated fields.
  TrainingOverviewViewState copyWith({
    bool? isLoading,
    DateTime? selectedDate,
    String? dateLabel,
    List<TrainingDayOverview>? weekDays,
    WorkoutSummary? nextWorkout,
    WorkoutSummary? lastWorkout,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? hasProgram,
    int? completedWorkouts,
    int? plannedWorkouts,
    String? activeProgramId,
  }) {
    return TrainingOverviewViewState(
      isLoading: isLoading ?? this.isLoading,
      selectedDate: selectedDate ?? this.selectedDate,
      dateLabel: dateLabel ?? this.dateLabel,
      weekDays: weekDays ?? this.weekDays,
      nextWorkout: nextWorkout ?? this.nextWorkout,
      lastWorkout: lastWorkout ?? this.lastWorkout,
      activeProgramId: activeProgramId ?? this.activeProgramId,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      hasProgram: hasProgram ?? this.hasProgram,
      completedWorkouts: completedWorkouts ?? this.completedWorkouts,
      plannedWorkouts: plannedWorkouts ?? this.plannedWorkouts,
    );
  }
}
