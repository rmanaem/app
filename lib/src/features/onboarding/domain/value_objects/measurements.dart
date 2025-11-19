import 'package:equatable/equatable.dart';

/// Strongly-typed stature (height), stored internally as centimeters.
class Stature extends Equatable {
  const Stature._(this.cm);

  /// Creates a stature from centimeters.
  factory Stature.fromCm(double cm) => Stature._(cm);

  /// Creates a stature from imperial feet/inches.
  factory Stature.fromImperial({required int ft, required double inch}) {
    final totalInches = (ft * 12) + inch;
    return Stature._(totalInches * 2.54);
  }

  /// Height stored in centimeters.
  final double cm;

  /// Feet component (rounded down).
  int get feet => (cm / 2.54 / 12).floor();

  /// Inches remainder rounded to a single decimal place.
  double get inchesRemainder =>
      double.parse(((cm / 2.54) - (feet * 12)).toStringAsFixed(1));

  /// Returns a copy with the provided [newCm].
  Stature copyWithCm(double newCm) => Stature._(newCm);

  /// Returns a copy using the provided imperial values.
  Stature copyWithImperial({required int ft, required double inch}) =>
      Stature.fromImperial(ft: ft, inch: inch);

  @override
  List<Object?> get props => [cm];
}

/// Strongly-typed body weight, stored internally as kilograms.
class BodyWeight extends Equatable {
  const BodyWeight._(this.kg);

  /// Creates a weight from kilograms.
  factory BodyWeight.fromKg(double kg) => BodyWeight._(kg);

  /// Creates a weight from pounds.
  factory BodyWeight.fromLb(double lb) => BodyWeight._(lb / 2.20462);

  /// Weight stored in kilograms.
  final double kg;

  /// Pounds conversion convenience getter.
  double get lb => kg * 2.20462;

  /// Returns a copy with the provided [newKg].
  BodyWeight copyWithKg(double newKg) => BodyWeight._(newKg);

  /// Returns a copy using pounds.
  BodyWeight copyWithLb(double newLb) => BodyWeight.fromLb(newLb);

  @override
  List<Object?> get props => [kg];
}
