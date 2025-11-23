import 'package:meta/meta.dart';

/// Indicates the status of a training day within the weekly strip.
enum TrainingDayStatus {
  /// Rest day.
  rest,

  /// Planned workout.
  planned,

  /// Completed workout.
  completed,
}

/// Overview information for a single day in the training week.
@immutable
class TrainingDayOverview {
  /// Creates a [TrainingDayOverview] for the given [date] and [status].
  const TrainingDayOverview({
    required this.date,
    required this.status,
  });

  /// Calendar date represented by this entry (date-only).
  final DateTime date;

  /// Status of the day (rest/planned/completed).
  final TrainingDayStatus status;
}
