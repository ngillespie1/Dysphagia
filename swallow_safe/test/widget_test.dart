import 'package:flutter_test/flutter_test.dart';

import 'package:swallow_safe/data/models/program.dart';
import 'package:swallow_safe/data/models/exercise.dart';
import 'package:swallow_safe/data/repositories/program_repository.dart';
import 'package:swallow_safe/core/models/program.dart' as core;

void main() {
  group('Smoke tests', () {
    test('ProgramRepository returns a valid program for every ProgramType', () {
      final repo = ProgramRepository();

      for (final type in core.ProgramType.values) {
        final program = repo.getProgramForType(type);
        expect(program.id, isNotEmpty, reason: '${type.name} program has id');
        expect(program.title, isNotEmpty,
            reason: '${type.name} program has title');
        expect(program.exercises, isNotEmpty,
            reason: '${type.name} program has exercises');
      }
    });

    test('All exercises have non-empty video URLs', () {
      final repo = ProgramRepository();

      for (final type in core.ProgramType.values) {
        final program = repo.getProgramForType(type);
        for (final exercise in program.exercises) {
          expect(exercise.videoUrl, isNotEmpty,
              reason:
                  '${type.name} / ${exercise.name} should have a video URL');
          expect(exercise.videoUrl, startsWith('https://'),
              reason:
                  '${type.name} / ${exercise.name} video URL should be HTTPS');
        }
      }
    });

    test('Every exercise has name, description, and instructions', () {
      final repo = ProgramRepository();

      for (final type in core.ProgramType.values) {
        final program = repo.getProgramForType(type);
        for (final exercise in program.exercises) {
          expect(exercise.name, isNotEmpty);
          expect(exercise.description, isNotEmpty);
          expect(exercise.instructions, isNotEmpty);
          expect(exercise.reps, greaterThan(0));
        }
      }
    });

    test('setSelectedProgramType correctly updates getCurrentProgram', () async {
      final repo = ProgramRepository();

      for (final type in core.ProgramType.values) {
        repo.setSelectedProgramType(type);
        final program = await repo.getCurrentProgram('any_user');
        final expected = repo.getProgramForType(type);
        expect(program.id, expected.id,
            reason: 'getCurrentProgram should return ${type.name}');
      }
    });

    test('Exercise.repsDisplay formats correctly for hold exercises', () {
      const holdExercise = Exercise(
        id: 'test',
        name: 'Test',
        description: 'Test',
        videoUrl: 'https://example.com/test.mp4',
        reps: 10,
        holdDuration: Duration(seconds: 5),
      );
      expect(holdExercise.repsDisplay, 'Hold for 5s × 10');

      const normalExercise = Exercise(
        id: 'test2',
        name: 'Test2',
        description: 'Test2',
        videoUrl: 'https://example.com/test2.mp4',
        reps: 8,
      );
      expect(normalExercise.repsDisplay, '8 reps');
    });

    test('Program serialization round-trip', () {
      final repo = ProgramRepository();
      final original = repo.getProgramForType(core.ProgramType.postStroke);
      final json = original.toJson();
      final restored = Program.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.exercises.length, original.exercises.length);
      for (int i = 0; i < original.exercises.length; i++) {
        expect(restored.exercises[i].name, original.exercises[i].name);
        expect(restored.exercises[i].videoUrl, original.exercises[i].videoUrl);
      }
    });
  });
}
