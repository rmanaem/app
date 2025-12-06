import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_theme.dart';
import 'package:starter_app/src/features/training/presentation/pages/active_session_page.dart';
import 'package:starter_app/src/features/training/presentation/viewmodels/active_session_view_model.dart';
import 'package:starter_app/src/features/training/presentation/widgets/micro_tuner_sheet.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/exercise_tuner_sheet.dart';

class MockActiveSessionViewModel extends Mock
    implements ActiveSessionViewModel {}

void main() {
  late MockActiveSessionViewModel mockVM;

  setUp(() {
    mockVM = MockActiveSessionViewModel();
    when(() => mockVM.isLoading).thenReturn(false);
    when(() => mockVM.exercises).thenReturn([]);
    when(() => mockVM.timerSeconds).thenReturn(90);
    when(() => mockVM.timerTotalSeconds).thenReturn(90);
    when(() => mockVM.restDurationSeconds).thenReturn(90);
    when(() => mockVM.activeRestExerciseIndex).thenReturn(null);
    when(() => mockVM.activeRestSetIndex).thenReturn(null);
  });

  testWidgets(
    'Interceptor Flow: Add Exercise tap opens Selection, then Tuner, '
    'then calls VM',
    (tester) async {
      // 1. Setup Routes for Navigation
      final router = GoRouter(
        initialLocation: '/session',
        routes: [
          GoRoute(
            path: '/session',
            builder: (context, state) =>
                ChangeNotifierProvider<ActiveSessionViewModel>.value(
                  value: mockVM,
                  child: const ActiveSessionPage(),
                ),
          ),
          GoRoute(
            path: '/training/builder/editor/select',
            builder: (context, state) {
              // Verify correct params passed
              final extra = state.extra as Map<String, dynamic>?;
              expect(extra, isNotNull);
              expect(extra!['isSingleSelect'], true);
              expect(extra['submitButtonText'], 'ADD');

              // Simulate immediately selecting an exercise
              // ignore: discarded_futures - This is test utility
              Future.microtask(() {
                if (context.mounted) {
                  context.pop([
                    {'name': 'Test Exercise', 'muscle': 'Chest', 'id': '1'},
                  ]);
                }
              });
              return const Scaffold(
                body: Center(child: Text('Selection Page')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: makeTheme(AppColors.dark, dark: true),
        ),
      );
      await tester.pumpAndSettle(); // Settle initial build

      // 2. Find and Tap "ADD EXERCISE"
      // Since list is empty, it should be visible or at top
      final addBtn = find.text('ADD EXERCISE');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle(); // Allow navigation to selection and back

      // 3. Verify Tuner Sheet is Open
      expect(find.byType(ExerciseTunerSheet), findsOneWidget);

      // 4. Tap "SAVE CONFIGURATION" on Tuner
      final saveBtn = find.text('SAVE CONFIGURATION');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle(); // Allow sheet to close

      // 5. Verify VM.appendExercise was called
      verify(() => mockVM.appendExercise(any())).called(1);
    },
  );
  testWidgets(
    'MicroTuner: Tapping set weight opens MicroTunerSheet and updates VM',
    (tester) async {
      // 1. Setup Data with 1 Exercise, 1 Set
      when(() => mockVM.exercises).thenReturn([
        {
          'id': 'ex1',
          'name': 'Bench Press',
          'sets': [
            {'weight': 50.0, 'reps': 10, 'rpe': 8.0, 'done': false},
          ],
        },
      ]);

      // 2. Pump Widget
      await tester.pumpWidget(
        MaterialApp(
          theme: makeTheme(AppColors.dark, dark: true),
          home: ChangeNotifierProvider<ActiveSessionViewModel>.value(
            value: mockVM,
            child: const ActiveSessionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 3. Find "50.0" (Weight) and Tap
      // Weight formatting might display "50" or "50.0".
      final weightText = find.textContaining('50');
      expect(weightText, findsOneWidget);
      await tester.tap(weightText);
      await tester.pumpAndSettle();

      // 4. Verify MicroTunerSheet is Open
      expect(find.byType(MicroTunerSheet), findsOneWidget);
      expect(find.text('SET 1 LOAD'), findsOneWidget);

      // 5. Tap "CONFIRM"
      final confirmBtn = find.text('CONFIRM');
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // 6. Verify VM update called
      verify(
        () => mockVM.updateSet(0, 0, any(that: containsPair('weight', 50.0))),
      ).called(1);
    },
  );
}
