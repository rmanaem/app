import 'dart:async';

import 'package:starter_app/src/features/nutrition/domain/entities/day_food_log.dart';
import 'package:starter_app/src/features/nutrition/domain/entities/food_entry.dart';
import 'package:starter_app/src/features/nutrition/domain/repositories/food_log_repository.dart';

/// Fake implementation of [FoodLogRepository] with in-memory data.
class FoodLogRepositoryFake implements FoodLogRepository {
  /// Creates the fake repository seeded with a sample log for today.
  FoodLogRepositoryFake() {
    final today = _dateOnly(DateTime.now());
    _logs[today] = DayFoodLog(
      date: today,
      entries: const [
        FoodEntry(
          id: '1',
          title: 'Oatmeal & Eggs',
          calories: 430,
          proteinGrams: 30,
          carbGrams: 40,
          fatGrams: 15,
          itemsCount: 2,
          slot: 'Breakfast',
        ),
        FoodEntry(
          id: '2',
          title: 'Chicken Salad',
          calories: 620,
          proteinGrams: 45,
          carbGrams: 55,
          fatGrams: 20,
          itemsCount: 3,
          slot: 'Lunch',
        ),
        FoodEntry(
          id: '3',
          title: 'Salmon & Rice',
          calories: 540,
          proteinGrams: 35,
          carbGrams: 50,
          fatGrams: 18,
          itemsCount: 2,
          slot: 'Dinner',
        ),
      ],
    );
  }

  final Map<DateTime, DayFoodLog> _logs = {};
  final _controller = StreamController<DateTime>.broadcast();

  @override
  Stream<DateTime> get logUpdates => _controller.stream;

  @override
  Future<DayFoodLog> getLogForDate(DateTime date) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final key = _dateOnly(date);
    return _logs[key] ?? DayFoodLog(date: key, entries: const []);
  }

  @override
  Future<void> addQuickEntry(DateTime date, FoodEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final key = _dateOnly(date);
    final existing = _logs[key]?.entries ?? <FoodEntry>[];
    _logs[key] = DayFoodLog(
      date: key,
      entries: [...existing, entry],
    );
    _controller.add(key);
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
