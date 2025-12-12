import 'package:starter_app/src/features/nutrition/domain/entities/day_food_log.dart';
import 'package:starter_app/src/features/nutrition/domain/entities/food_entry.dart';

/// Repository contract for daily food logs.
abstract class FoodLogRepository {
  /// Returns the log for the given [date], or an empty log if none exists.
  Future<DayFoodLog> getLogForDate(DateTime date);

  /// Adds a quick entry to the given day's log.
  Future<void> addQuickEntry(DateTime date, FoodEntry entry);

  /// Updates an existing entry on the given day.
  Future<void> updateEntry(DateTime date, FoodEntry entry);

  /// Deletes an entry by ID from the given day.
  Future<void> deleteEntry(DateTime date, String entryId);

  /// Stream of dates that have had their logs updated.
  Stream<DateTime> get logUpdates;
}
