import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';

/// A published training program.
class Program {
  /// Creates a [Program].
  const Program({
    required this.id,
    required this.name,
    required this.split,
    required this.description,
    required this.lastPerformed,
    this.isActive = false,
    this.isTemplate = false,
    this.tags = const [],
  });

  /// The unique identifier of the program.
  final String id;

  /// The display name of the program.
  final String name;

  /// The split strategy (e.g. PPL, Full Body).
  final ProgramSplit split;

  /// A brief description of the program.
  final String description;

  /// The last time this program was performed.
  final DateTime? lastPerformed;

  /// Whether this is the currently active program.
  final bool isActive;

  /// Whether this is a template (read-only) or user-created.
  final bool isTemplate;

  /// A list of descriptive tags (e.g. "Strength", "Beginner").
  final List<String> tags;

  /// Creates a copy of this `Program` with the given fields replaced.
  Program copyWith({
    String? id,
    String? name,
    ProgramSplit? split,
    String? description,
    DateTime? lastPerformed,
    bool? isActive,
    bool? isTemplate,
    List<String>? tags,
  }) {
    return Program(
      id: id ?? this.id,
      name: name ?? this.name,
      split: split ?? this.split,
      description: description ?? this.description,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      isActive: isActive ?? this.isActive,
      isTemplate: isTemplate ?? this.isTemplate,
      tags: tags ?? this.tags,
    );
  }
}
