import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_program.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/draft_workout.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';
import 'package:starter_app/src/features/training/program_builder/domain/repositories/program_builder_repository.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/pages/workout_editor_page.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/viewmodels/workout_editor_view_model.dart';
import 'package:starter_app/src/features/training/program_builder/presentation/widgets/exercise_module_card.dart';

class MockProgramBuilderRepository extends Mock
    implements ProgramBuilderRepository {}

void main() {
  late MockProgramBuilderRepository repository;
  late WorkoutEditorViewModel viewModel;

  setUp(() {
    repository = MockProgramBuilderRepository();

    // Mock successful draft loading with one workout
    when(() => repository.getCurrentDraft()).thenAnswer(
      (_) async => const DraftProgram(
        id: 'draft_1',
        name: 'Test Program',
        split: ProgramSplit.ppl,
        schedule: {},
        workouts: [
          DraftWorkout(id: 'w1', name: 'Push Day', description: ''),
        ],
      ),
    );

    viewModel =
        WorkoutEditorViewModel(
          repository: repository,
          workoutId: 'w1',
        )..onExercisesAdded([
          {
            'name': 'Exercise 1',
            'muscle': 'Chest',
            'sets': 3,
            'reps': '10',
            'weight': 50.0,
            'rest': 60,
          },
          {
            'name': 'Exercise 2',
            'muscle': 'Back',
            'sets': 3,
            'reps': '10',
            'weight': 50.0,
            'rest': 60,
          },
          {
            'name': 'Exercise 3',
            'muscle': 'Legs',
            'sets': 3,
            'reps': '10',
            'weight': 50.0,
            'rest': 60,
          },
        ]);
  });

  Widget createSubject() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkoutEditorViewModel>.value(value: viewModel),
      ],
      child: MaterialApp(
        theme: ThemeData(
          extensions: [
            AppColors.dark,
            AppTypography.from(AppColors.dark),
            AppSpacing.base,
          ],
        ),
        home: const WorkoutEditorPage(),
      ),
    );
  }

  testWidgets('swiping an exercise card removes it from the UI', (
    tester,
  ) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Verify initial state (3 seeded exercises)
    expect(find.byType(ExerciseModuleCard), findsNWidgets(3));

    // Find the first exercise card
    final exerciseCard = find.byType(ExerciseModuleCard).first;

    // Swipe left
    await tester.drag(exerciseCard, const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Verify card is removed (2 remaining)
    expect(find.byType(ExerciseModuleCard), findsNWidgets(2));
  });

  testWidgets('removing all exercises shows empty state', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Remove all 3 exercises
    for (var i = 0; i < 3; i++) {
      final exerciseCard = find.byType(ExerciseModuleCard).first;
      await tester.drag(exerciseCard, const Offset(-500, 0));
      await tester.pumpAndSettle();
    }

    // Verify empty state is shown
    expect(find.text('NO EXERCISES'), findsOneWidget);
    expect(find.byType(ExerciseModuleCard), findsNothing);
  });
}
