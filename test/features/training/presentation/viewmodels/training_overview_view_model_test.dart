import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/src/features/training/domain/entities/training_day_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/training_overview.dart';
import 'package:starter_app/src/features/training/domain/entities/workout_summary.dart';
import 'package:starter_app/src/features/training/domain/repositories/training_overview_repository.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/training_overview_view_model.dart';

class _MockTrainingOverviewRepository extends Mock
    implements TrainingOverviewRepository {}

void main() {
  group('TrainingOverviewViewModel', () {
    late TrainingOverviewRepository repository;
    late TrainingOverviewViewModel viewModel;
    late TrainingOverview overview;
    final today = DateTime(2024, 1, 10);

    setUp(() {
      repository = _MockTrainingOverviewRepository();
      overview = TrainingOverview(
        anchorDate: today,
        weekDays: <TrainingDayOverview>[
          TrainingDayOverview(
            date: DateTime(2024, 1, 10),
            status: TrainingDayStatus.planned,
          ),
        ],
        nextWorkout: const WorkoutSummary(
          id: 'next',
          name: 'Upper A',
          dayLabel: 'Tomorrow',
          timeLabel: '18:00',
          meta: '3 exercises · 45 min',
        ),
        lastWorkout: const WorkoutSummary(
          id: 'last',
          name: 'Lower B',
          dayLabel: 'Mon',
          timeLabel: '42 min',
          meta: '4 exercises · 50 min',
        ),
        hasProgram: true,
        completedWorkouts: 2,
        plannedWorkouts: 4,
      );

      when(
        () => repository.getOverviewForWeek(any()),
      ).thenAnswer((_) async => overview);

      viewModel = TrainingOverviewViewModel(
        repository: repository,
        today: today,
      );
    });

    test('loads overview on init', () async {
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.weekDays, isNotEmpty);
      expect(viewModel.state.nextWorkout?.name, 'Upper A');
      expect(viewModel.state.completedWorkouts, 2);
    });

    test('handles repository failure', () async {
      when(
        () => repository.getOverviewForWeek(any()),
      ).thenThrow(Exception('network'));

      await viewModel.load();

      expect(viewModel.state.hasError, isTrue);
      expect(viewModel.state.isLoading, isFalse);
    });

    test('onSelectDate updates state', () async {
      await Future<void>.delayed(Duration.zero);
      final newDate = today.add(const Duration(days: 1));

      viewModel.onSelectDate(newDate);

      expect(viewModel.state.selectedDate.day, newDate.day);
    });
  });
}
