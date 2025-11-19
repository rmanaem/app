import 'package:equatable/equatable.dart';

import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';

/// ViewState for the onboarding stats & units screen.
class OnboardingStatsViewState extends Equatable {
  /// Creates a stats state representation.
  const OnboardingStatsViewState({
    required this.unitSystem,
    this.dob,
    this.height,
    this.weight,
    this.activity,
  });

  /// Active unit system to display inputs in.
  final UnitSystem unitSystem;

  /// Date of birth.
  final DateTime? dob;

  /// User stature.
  final Stature? height;

  /// User body weight.
  final BodyWeight? weight;

  /// Baseline activity level.
  final ActivityLevel? activity;

  /// True when all required fields for the step are satisfied.
  bool get isValid =>
      dob != null && height != null && weight != null && activity != null;

  /// Creates a copy overriding provided fields.
  OnboardingStatsViewState copyWith({
    UnitSystem? unitSystem,
    DateTime? dob,
    Stature? height,
    BodyWeight? weight,
    ActivityLevel? activity,
  }) {
    return OnboardingStatsViewState(
      unitSystem: unitSystem ?? this.unitSystem,
      dob: dob ?? this.dob,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activity: activity ?? this.activity,
    );
  }

  @override
  List<Object?> get props => [unitSystem, dob, height, weight, activity];
}
