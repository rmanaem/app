import 'package:meta/meta.dart';

/// Single logged food entry within a day's log.
@immutable
class FoodEntry {
  /// Creates a food entry.
  const FoodEntry({
    required this.title,
    required this.calories,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    this.id,
    this.itemsCount,
    this.slot,
  });

  /// Unique identifier (optional for compatibility).
  final String? id;

  /// Name of the meal or entry (e.g. "Breakfast", "Chicken Bowl").
  final String title;

  /// Energy in kcal.
  final int calories;

  /// Protein in grams.
  final int proteinGrams;

  /// Carbohydrates in grams.
  final int carbGrams;

  /// Fat in grams.
  final int fatGrams;

  /// Optional count of sub-items (e.g. number of foods).
  final int? itemsCount;

  /// The meal slot this entry belongs to (e.g. "Breakfast", "Lunch").
  final String? slot;
}
