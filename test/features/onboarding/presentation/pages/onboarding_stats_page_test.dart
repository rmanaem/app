import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/activity_level.dart';
import 'package:starter_app/src/features/onboarding/domain/value_objects/unit_system.dart';
import 'package:starter_app/src/features/onboarding/presentation/pages/onboarding_stats_page.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewmodels/onboarding_vm.dart';
import 'package:starter_app/src/features/onboarding/presentation/viewstate/onboarding_stats_view_state.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

class MockOnboardingVm extends Mock implements OnboardingVm {}

void main() {
  setUpAll(() {
    registerFallbackValue(UnitSystem.metric);
    registerFallbackValue(ActivityLevel.moderatelyActive);
  });

  group('OnboardingStatsPage default selections', () {
    late OnboardingVm mockVm;

    setUp(() {
      mockVm = MockOnboardingVm();
      when(() => mockVm.statsState).thenReturn(
        const OnboardingStatsViewState(unitSystem: UnitSystem.metric),
      );
      when(() => mockVm.logStatsScreenViewed()).thenAnswer((_) async {});
      when(() => mockVm.setUnitSystem(any())).thenAnswer((_) {});
      when(() => mockVm.setHeightCm(any())).thenAnswer((_) {});
      when(
        () => mockVm.setHeightImperial(
          ft: any(named: 'ft'),
          inch: any(named: 'inch'),
        ),
      ).thenAnswer((_) {});
      when(() => mockVm.setWeightKg(any())).thenAnswer((_) {});
      when(() => mockVm.setWeightLb(any())).thenAnswer((_) {});
      when(() => mockVm.setActivityLevel(any())).thenAnswer((_) {});
    });

    Widget buildSubject() {
      return ChangeNotifierProvider<OnboardingVm>.value(
        value: mockVm,
        child: MaterialApp(
          theme: makeTheme(AppColors.light, dark: false),
          home: const OnboardingStatsPage(),
        ),
      );
    }

    testWidgets(
      'confirming untouched height writes the default value',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.text('HEIGHT'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(AppButton, 'CONFIRM'));
        await tester.pumpAndSettle();

        verify(() => mockVm.setHeightCm(175)).called(1);
      },
    );

    testWidgets(
      'confirming untouched weight writes the default value',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.text('WEIGHT'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(AppButton, 'CONFIRM'));
        await tester.pumpAndSettle();

        verify(() => mockVm.setWeightKg(75)).called(1);
      },
    );

    testWidgets(
      'confirming untouched activity writes the default value',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.text('ACTIVITY LEVEL'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(AppButton, 'CONFIRM'));
        await tester.pumpAndSettle();

        verify(
          () => mockVm.setActivityLevel(ActivityLevel.moderatelyActive),
        ).called(1);
      },
    );
  });
}
