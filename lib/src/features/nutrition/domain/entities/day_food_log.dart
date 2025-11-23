import 'package:meta/meta.dart';
import 'package:starter_app/src/features/nutrition/domain/entities/food_entry.dart';

/// Logged meals for a specific calendar day.
@immutable
class DayFoodLog {
  /// Creates a log for the given [date].
  const DayFoodLog({
    required this.date,
    required this.entries,
  });

  /// The calendar day this log represents (date-only).
  final DateTime date;

  /// Entries logged for this day.
  final List<FoodEntry> entries;
}
