import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';

void main() {
  group('Value Objects', () {
    group('Goal', () {
      test('has correct string representation', () {
        expect(Goal.lose.toString(), contains('lose'));
      });
    });

    group('ActivityLevel', () {
      test('values are distinct', () {
        expect(ActivityLevel.low, isNot(equals(ActivityLevel.high)));
      });
    });

    group('BodyWeight', () {
      test('converts kg to lbs correctly', () {
        final weight = BodyWeight.fromKg(100);
        expect(weight.lb, closeTo(220.462, 0.001));
      });

      test('converts lbs to kg correctly', () {
        final weight = BodyWeight.fromLb(220.462);
        expect(weight.kg, closeTo(100, 0.001));
      });
    });

    group('Stature', () {
      test('converts cm to ft/in correctly', () {
        final height = Stature.fromCm(182.88); // ~6ft
        expect(height.feet, 6);
        expect(height.inchesRemainder, closeTo(0, 0.01));
      });

      test('converts ft/in to cm correctly', () {
        final height = Stature.fromImperial(ft: 6, inch: 0);
        expect(height.cm, closeTo(182.88, 0.01));
      });
    });
  });
}
