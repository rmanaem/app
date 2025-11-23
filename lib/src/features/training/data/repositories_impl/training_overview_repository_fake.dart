import 'dart:async';

import 'package:starter_app/src/features/training/domain/entities/training_day_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/training_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/workout_summary.dart';
import 'package:starter_app/src/features/training/domain/repositories/training_overview_repository.dart';

/// Fake repository that returns seeded training overview data.
class TrainingOverviewRepositoryFake implements TrainingOverviewRepository {
  /// Creates the fake repository.
  const TrainingOverviewRepositoryFake();

  /// Returns a seeded overview for the week containing [anchorDate].
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
      if (date.isAtSameMomentAs(today)) {
        return TrainingDayOverview(
          date: date,
          status: TrainingDayStatus.planned,
        );
      }
      if (index == 4) {
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

    const nextWorkout = WorkoutSummary(
      id: 'next-1',
      name: 'Upper A',
      dayLabel: 'Tomorrow',
      timeLabel: '18:00',
      meta: '3 exercises · ~45 min',
    );

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
      nextWorkout: nextWorkout,
      lastWorkout: lastWorkout,
      hasProgram: true,
      completedWorkouts: 2,
      plannedWorkouts: 4,
    );
  }

  @override
  Future<void> refresh() async {
    await Future<void>.delayed(Duration.zero);
  }
}
