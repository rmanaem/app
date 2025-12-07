import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/features/training/domain/entities/program.dart';
import 'package:starter_app/src/features/training/program_builder/domain/entities/program_split.dart';

void main() {
  test('Program entity accepts tags and defaults to empty list', () {
    const programWithTags = Program(
      id: '1',
      name: 'Test',
      split: ProgramSplit.fullBody,
      description: 'Desc',
      lastPerformed: null,
      tags: ['Tag1', 'Tag2'],
    );

    expect(programWithTags.tags, ['Tag1', 'Tag2']);

    const programWithoutTags = Program(
      id: '2',
      name: 'Test 2',
      split: ProgramSplit.fullBody,
      description: 'Desc',
      lastPerformed: null,
    );

    expect(programWithoutTags.tags, isEmpty);
  });
}
