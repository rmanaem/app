/// Represents a single workout routine within a program (e.g., "Push A").
class DraftWorkout {
  /// Creates a draft workout.
  const DraftWorkout({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Unique identifier for the workout.
  final String id;

  /// Display name (e.g., "Push A").
  final String name;

  /// Short description of focus areas.
  final String description;
}
