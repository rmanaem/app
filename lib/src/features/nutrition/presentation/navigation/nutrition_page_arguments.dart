import 'package:meta/meta.dart';

/// Arguments for the Nutrition page route.
@immutable
class NutritionPageArguments {
  /// Creates arguments for the Nutrition page.
  const NutritionPageArguments({this.showQuickAddSheet = false});

  /// Whether to open the quick-add sheet on first build.
  final bool showQuickAddSheet;
}
