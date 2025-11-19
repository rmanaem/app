import 'package:equatable/equatable.dart';

import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';

/// Immutable UI snapshot for the onboarding goal step.
class OnboardingGoalViewState extends Equatable {
  /// Creates a state representation with an optional [selected] goal.
  const OnboardingGoalViewState({this.selected});

  /// Currently selected goal, if any.
  final Goal? selected;

  /// Indicates whether the next CTA should be enabled.
  bool get canContinue => selected != null;

  /// Copies the current state while overriding [selected] when provided.
  OnboardingGoalViewState copyWith({Goal? selected}) =>
      OnboardingGoalViewState(selected: selected ?? this.selected);

  @override
  List<Object?> get props => [selected];
}
