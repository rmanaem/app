import 'package:meta/meta.dart';

/// Lightweight summary for a workout session shown on the overview.
@immutable
class WorkoutSummary {
  /// Creates a summary entry.
  const WorkoutSummary({
    required this.id,
    required this.name,
    required this.dayLabel,
    required this.timeLabel,
    required this.meta,
    this.notePreview,
  });

  /// Unique identifier for linking to detail/log screens.
  final String id;

  /// Display name (e.g. "Upper A").
  final String name;

  /// Day label (e.g. "Tomorrow" or "Mon").
  final String dayLabel;

  /// Time or duration label ("18:00" / "42 min").
  final String timeLabel;

  /// Meta summary ("3 exercises · 9 sets").
  final String meta;

  /// Optional preview of user notes from last session.
  final String? notePreview;
}
