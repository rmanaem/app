import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/src/features/nutrition/domain/entities/day_food_log.dart';
import 'package:starter_app/src/features/nutrition/domain/entities/food_entry.dart';
import 'package:starter_app/src/features/nutrition/domain/repositories/food_log_repository.dart';
import 'package:starter_app/src/features/nutrition/presentation/models/quick_food_entry_input.dart';
import 'package:starter_app/src/features/nutrition/presentation/viewmodels/nutrition_day_viewmodel.dart';
import 'package:starter_app/src/features/plan/domain/entities/user_plan.dart';
import 'package:starter_app/src/features/plan/domain/repositories/plan_repository.dart';
import 'package:starter_app/src/features/plan/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/plan/domain/value_objects/goal.dart';

class MockFoodLogRepository extends Mock implements FoodLogRepository {}

class MockPlanRepository extends Mock implements PlanRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const FoodEntry(
        title: 'fallback',
        calories: 0,
        proteinGrams: 0,
        carbGrams: 0,
        fatGrams: 0,
      ),
    );
  });

  group('NutritionDayViewModel', () {
    late MockFoodLogRepository foodLogRepository;
    late MockPlanRepository planRepository;
    late NutritionDayViewModel viewModel;
    final loggedEntries = <FoodEntry>[];

    late UserPlan samplePlan;

    setUp(() async {
      foodLogRepository = MockFoodLogRepository();
      planRepository = MockPlanRepository();
      loggedEntries.clear();

      samplePlan = UserPlan(
        goal: Goal.maintain,
        targetWeightKg: 75,
        weeklyRateKg: 0,
        dailyCalories: 2200,
        proteinGrams: 150,
        fatGrams: 70,
        carbGrams: 250,
        projectedEndDate: DateTime(2024, 6),
        currentWeightKg: 75,
        heightCm: 180,
        dob: DateTime(1990),
        activity: ActivityLevel.moderatelyActive,
        createdAt: DateTime(2023),
      );

      when(
        () => planRepository.getCurrentPlan(),
      ).thenAnswer((_) async => samplePlan);

      when(() => foodLogRepository.getLogForDate(any())).thenAnswer((
        invocation,
      ) async {
        final date = invocation.positionalArguments.first as DateTime;
        return DayFoodLog(
          date: date,
          entries: List<FoodEntry>.from(loggedEntries),
        );
      });

      when(() => foodLogRepository.addQuickEntry(any(), any())).thenAnswer((
        invocation,
      ) async {
        final entry = invocation.positionalArguments[1] as FoodEntry;
        loggedEntries.add(entry);
      });

      viewModel = NutritionDayViewModel(
        foodLogRepository: foodLogRepository,
        planRepository: planRepository,
      );

      await _pumpEventLoop();
    });

    test('addQuickEntry updates totals on success', () async {
      final success = await viewModel.addQuickEntry(
        const QuickFoodEntryInput(
          mealLabel: 'Snack',
          calories: 250,
        ),
      );

      expect(success, isTrue);
      expect(viewModel.state.caloriesConsumed, 250);
      expect(viewModel.state.meals, isNotEmpty);
      expect(viewModel.state.isAddingEntry, isFalse);
    });

    test('addQuickEntry surfaces error when repository fails', () async {
      when(
        () => foodLogRepository.addQuickEntry(any(), any()),
      ).thenThrow(Exception('network'));

      final success = await viewModel.addQuickEntry(
        const QuickFoodEntryInput(
          mealLabel: 'Dinner',
          calories: 500,
        ),
      );

      expect(success, isFalse);
      expect(viewModel.state.addEntryErrorMessage, isNotNull);
      expect(viewModel.state.isAddingEntry, isFalse);
    });
  });
}

Future<void> _pumpEventLoop() => Future<void>.delayed(Duration.zero);
