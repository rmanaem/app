/// Represents a fully finished workout session in the logbook.
class CompletedWorkout {
  /// Creates a [CompletedWorkout].
  const CompletedWorkout({
    required this.id,
    required this.name,
    required this.completedAt,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.prCount,
    required this.exerciseCount,
    required this.totalSets,
    this.exercises = const [],
    this.note,
  });

  /// Unique identifier for the completed session.
  final String id;

  /// Name of the workout (e.g. "Upper Power").
  final String name;

  /// Optional user note for the workout.
  final String? note;

  /// Date and time when the workout was finished.
  final DateTime completedAt;

  /// Total duration in seconds.
  final int durationSeconds;

  /// Total volume lifted in kg.
  final int totalVolumeKg;

  /// Number of Personal Records broken.
  final int prCount;

  /// Total number of exercises performed.
  final int exerciseCount;

  /// Total sets completed.
  final int totalSets;

  /// List of exercises performed in this session.
  final List<Map<String, dynamic>> exercises;

  /// Formatted duration string (e.g. "1h 12m").
  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  /// Formatted volume string (e.g. "12.5k").
  String get formattedVolume {
    if (totalVolumeKg > 1000) {
      return '${(totalVolumeKg / 1000).toStringAsFixed(1)}k';
    }
    return '$totalVolumeKg';
  }

  /// Helper copyWith for updating the note.
  CompletedWorkout copyWith({String? note}) {
    return CompletedWorkout(
      id: id,
      name: name,
      completedAt: completedAt,
      durationSeconds: durationSeconds,
      totalVolumeKg: totalVolumeKg,
      prCount: prCount,
      exerciseCount: exerciseCount,
      totalSets: totalSets,
      note: note ?? this.note,
      exercises: exercises,
    );
  }
}
