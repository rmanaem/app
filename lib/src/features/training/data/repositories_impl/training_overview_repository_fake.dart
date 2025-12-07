import 'dart:async';

import 'package:starter_app/src/features/training/domain/entities/training_day_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/training_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/workout_summary.dart';
import 'package:starter_app/src/features/training/domain/repositories/training_overview_repository.dart';

/// Fake repository that returns seeded training overview data.
/// Fake repository that returns seeded training overview data.
class TrainingOverviewRepositoryFake implements TrainingOverviewRepository {
  /// Creates the fake repository.
  TrainingOverviewRepositoryFake();

  // Simple in-memory state for the fake to simulate updates
  static bool _isNextWorkoutCompleted = false;

  static String? _lastCompletedWorkoutId; // ID of the actual history record

  /// Returns a seeded overview for the week containing [anchorDate].
  @override
  Future<TrainingOverview> getOverviewForWeek(DateTime anchorDate) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final today = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);

    // Simple mock logic for week days since we don't have full logic
    final weekDays = List.generate(7, (index) {
      final date = today.add(Duration(days: index - today.weekday + 1));
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isPast = date.isBefore(today);

      var status = TrainingDayStatus.planned;
      // Mock logic: Rest on Thu (index 3) and Sun (index 6)
      if (index == 3 || index == 6) status = TrainingDayStatus.rest;

      if (isPast && status != TrainingDayStatus.rest) {
        status = TrainingDayStatus.completed;
      }

      if (isToday) {
        status = _isNextWorkoutCompleted
            ? TrainingDayStatus.completed
            : TrainingDayStatus.planned;
      }

      return TrainingDayOverview(
        date: date,
        status: status,
      );
    });

    var completedCount = 3; // Base mock count
    if (_isNextWorkoutCompleted) completedCount++;

    // If completed, we KEEP the next workout but mark it as completed/done-today
    // This allows the UI to show "Today's Session" in the main slot.
    final nextWorkout = _isNextWorkoutCompleted
        ? WorkoutSummary(
            id:
                _lastCompletedWorkoutId ??
                'next-1', // Link to ACTUAL history ID
            name: 'Upper A',
            dayLabel: 'TODAY',
            timeLabel: 'DONE',
            meta: 'Completed',
            isCompleted: true, // Mark as completed
          )
        : const WorkoutSummary(
            id: 'next-1',
            name: 'Upper A',
            dayLabel: 'Tomorrow',
            timeLabel: '18:00',
            meta: '3 exercises · ~45 min',
          );

    // The "Last Workout" remains the ACTUAL previous session (yesterday etc)
    const lastWorkout = WorkoutSummary(
      id: 'last-1',
      name: 'Lower B',
      dayLabel: 'Mon',
      timeLabel: '42 min',
      meta: '4 exercises · 50 min',
      notePreview: 'Focus on bracing on squats.',
    );

    return TrainingOverview(
      anchorDate: today,
      weekDays: weekDays,
      completedWorkouts: completedCount,
      plannedWorkouts: 4, // Mock total
      hasProgram: true,
      activeProgramId: 'p1', // Mock program ID
      nextWorkout: nextWorkout,
      lastWorkout: lastWorkout,
    );
  }

  @override
  Future<void> refresh() async {
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> markWorkoutAsCompleted(
    String workoutId, {
    String? completedWorkoutId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _isNextWorkoutCompleted = true;
    _lastCompletedWorkoutId = completedWorkoutId;
  }
}
