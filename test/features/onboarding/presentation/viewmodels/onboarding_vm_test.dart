import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter_app/src/core/analytics/analytics_service.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/goal.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  group('OnboardingVm', () {
    late OnboardingVm vm;
    late MockAnalyticsService mockAnalytics;

    setUp(() {
      mockAnalytics = MockAnalyticsService();
      when(
        () => mockAnalytics.onboardingGoalSelected(any()),
      ).thenAnswer((_) async {});
      vm = OnboardingVm(mockAnalytics);
    });

    test('initial state is correct', () {
      expect(vm.goalState.selected, isNull);
      expect(vm.statsState.dob, isNull);
      expect(vm.goalState.canContinue, isFalse);
    });

    group('Goal Selection', () {
      test('selecting a goal updates state and enables continue', () {
        vm.selectGoal(Goal.lose);
        expect(vm.goalState.selected, Goal.lose);
        expect(vm.goalState.canContinue, isTrue);
      });

      test('selecting a goal logs analytics event', () {
        vm.selectGoal(Goal.gain);
        verify(
          () => mockAnalytics.onboardingGoalSelected('gain'),
        ).called(1);
      });
    });

    group('Stats Entry', () {
      test('setting DOB updates state', () {
        final dob = DateTime(1990);
        vm.setDob(dob);
        expect(vm.statsState.dob, dob);
      });

      test('setting height updates state', () {
        vm.setHeightCm(180);
        expect(vm.statsState.height?.cm, 180);
      });

      test('setting weight updates state', () {
        vm.setWeightKg(80);
        expect(vm.statsState.weight?.kg, 80);
      });

      test('setting activity updates state', () {
        vm.setActivityLevel(ActivityLevel.moderate);
        expect(vm.statsState.activity, ActivityLevel.moderate);
      });

      test('canContinue is true only when all stats are valid', () {
        // Initially false
        expect(vm.statsState.isValid, isFalse);

        vm.setDob(DateTime(1990));
        expect(vm.statsState.isValid, isFalse);

        vm.setHeightCm(180);
        expect(vm.statsState.isValid, isFalse);

        vm.setWeightKg(80);
        expect(vm.statsState.isValid, isFalse);

        vm.setActivityLevel(ActivityLevel.moderate);
        expect(vm.statsState.isValid, isTrue);
      });
    });
  });
}
