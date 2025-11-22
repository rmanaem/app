import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/measurements.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/onboarding_stats_page.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewstate/onboarding_stats_view_state.dart';

class MockOnboardingVm extends Mock implements OnboardingVm {}

void main() {
  group('OnboardingStatsPage', () {
    late OnboardingVm mockVm;

    setUp(() {
      mockVm = MockOnboardingVm();
      when(() => mockVm.statsState).thenReturn(
        const OnboardingStatsViewState(unitSystem: UnitSystem.metric),
      );
      when(() => mockVm.logStatsScreenViewed()).thenAnswer((_) async {});
      when(() => mockVm.setHeightCm(any())).thenAnswer((_) async {});
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<OnboardingVm>.value(
        value: mockVm,
        child: MaterialApp(
          theme: makeTheme(AppColors.light, dark: false),
          home: const OnboardingStatsPage(),
        ),
      );
    }

    testWidgets('renders title and fields', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('About you'), findsOneWidget);
      expect(find.text('Date of birth'), findsOneWidget);
      expect(find.text('Height'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Activity level'), findsOneWidget);
    });

    testWidgets('Next button is disabled initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final nextButton = find.widgetWithText(FilledButton, 'Next');
      expect(tester.widget<FilledButton>(nextButton).onPressed, isNull);
    });

    testWidgets('Next button is enabled when stats are valid', (
      tester,
    ) async {
      when(() => mockVm.statsState).thenReturn(
        OnboardingStatsViewState(
          unitSystem: UnitSystem.metric,
          dob: DateTime(1990),
          height: Stature.fromCm(180),
          weight: BodyWeight.fromKg(80),
          activity: ActivityLevel.moderatelyActive,
        ),
      );
      await tester.pumpWidget(createWidgetUnderTest());

      final nextButton = find.widgetWithText(FilledButton, 'Next');
      expect(tester.widget<FilledButton>(nextButton).onPressed, isNotNull);
    });
  });
}
