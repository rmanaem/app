import 'package:meta/meta.dart';

/// Input captured from the quick-add food sheet.
@immutable
class QuickFoodEntryInput {
  /// Creates a quick food entry payload.
  const QuickFoodEntryInput({
    required this.mealLabel,
    required this.calories,
    this.title,
    this.proteinGrams,
    this.carbGrams,
    this.fatGrams,
  });

  /// Optional title/description for the entry.
  final String? title;

  /// Calories in kilocalories.
  final int calories;

  /// Optional protein grams.
  final int? proteinGrams;

  /// Optional carbohydrate grams.
  final int? carbGrams;

  /// Optional fat grams.
  final int? fatGrams;

  /// Meal label (e.g. Breakfast, Lunch).
  final String mealLabel;
}
