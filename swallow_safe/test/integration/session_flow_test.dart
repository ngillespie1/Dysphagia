import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:swallow_safe/features/exercise/bloc/session_bloc.dart';
import 'package:swallow_safe/features/progress/bloc/streak_bloc.dart';
import 'package:swallow_safe/data/repositories/program_repository.dart';
import 'package:swallow_safe/data/repositories/user_repository.dart';
import 'package:swallow_safe/core/services/haptic_service.dart';
import 'package:swallow_safe/core/models/program.dart' as core;
import 'package:swallow_safe/data/models/program.dart';
import 'package:swallow_safe/data/models/exercise.dart';
import 'package:swallow_safe/data/models/session.dart';
import 'package:swallow_safe/data/models/user_profile.dart';

// Mocks
class MockProgramRepository extends Mock implements ProgramRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockHapticService extends Mock implements HapticService {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(Session(
      id: 'fallback',
      programId: 'fallback',
      completedAt: DateTime(2020),
      duration: Duration.zero,
      exercisesCompleted: 0,
      totalExercises: 0,
    ));
  });

  late MockProgramRepository mockProgramRepository;
  late MockUserRepository mockUserRepository;
  late MockHapticService mockHapticService;
  late SessionBloc sessionBloc;

  final testProgram = Program(
    id: 'test_program',
    title: 'Test Program',
    description: 'A test program for integration testing',
    exercises: const [
      Exercise(
        id: 'ex_1',
        name: 'Test Exercise 1',
        description: 'First test exercise',
        videoUrl: 'https://example.com/video1.mp4',
        reps: 10,
      ),
      Exercise(
        id: 'ex_2',
        name: 'Test Exercise 2',
        description: 'Second test exercise',
        videoUrl: 'https://example.com/video2.mp4',
        reps: 8,
      ),
      Exercise(
        id: 'ex_3',
        name: 'Test Exercise 3',
        description: 'Third test exercise',
        videoUrl: 'https://example.com/video3.mp4',
        reps: 6,
      ),
    ],
  );

  final testProfile = UserProfile(
    id: 'test_user',
    createdAt: DateTime.now(),
    streakData: const StreakData(
      currentStreak: 5,
      longestStreak: 10,
      totalSessions: 20,
    ),
  );

  setUp(() {
    mockProgramRepository = MockProgramRepository();
    mockUserRepository = MockUserRepository();
    mockHapticService = MockHapticService();

    // Setup mocks
    when(() => mockProgramRepository.getCurrentProgram(any()))
        .thenAnswer((_) async => testProgram);
    when(() => mockUserRepository.initialize()).thenAnswer((_) async {});
    when(() => mockUserRepository.getUserProfile())
        .thenAnswer((_) async => testProfile);
    when(() => mockUserRepository.getThisWeekSessions())
        .thenAnswer((_) async => []);
    when(() => mockUserRepository.saveSession(any()))
        .thenAnswer((_) async {});
    when(() => mockUserRepository.updateStreakOnCompletion())
        .thenAnswer((_) async => const StreakData(currentStreak: 6));
    when(() => mockHapticService.lightImpact()).thenAnswer((_) async {});
    when(() => mockHapticService.successPattern()).thenAnswer((_) async {});

    sessionBloc = SessionBloc(
      programRepository: mockProgramRepository,
      userRepository: mockUserRepository,
      hapticService: mockHapticService,
    );
  });

  tearDown(() {
    sessionBloc.close();
  });

  group('Session Flow Integration', () {
    test('full session lifecycle: load → start → complete all exercises',
        () async {
      // 1. Initial state
      expect(sessionBloc.state, isA<SessionInitial>());

      // 2. Load session
      sessionBloc.add(const LoadSession());
      await expectLater(
        sessionBloc.stream,
        emitsInOrder([
          isA<SessionLoading>(),
          isA<SessionReady>(),
        ]),
      );

      final readyState = sessionBloc.state as SessionReady;
      expect(readyState.program.id, 'test_program');
      expect(readyState.program.exercises.length, 3);

      // 3. Start session
      sessionBloc.add(const StartSession());
      await expectLater(
        sessionBloc.stream,
        emits(isA<SessionActive>()),
      );

      final activeState = sessionBloc.state as SessionActive;
      expect(activeState.currentExerciseIndex, 0);
      expect(activeState.program.exercises[0].name, 'Test Exercise 1');

      // 4. Complete first exercise → transitions, then continue to exercise 2
      sessionBloc.add(const CompleteExercise());
      await expectLater(
        sessionBloc.stream,
        emits(isA<SessionTransitioning>()),
      );
      sessionBloc.add(const ContinueToNext());
      await expectLater(
        sessionBloc.stream,
        emits(isA<SessionActive>()),
      );
      expect(
          (sessionBloc.state as SessionActive).currentExerciseIndex, 1);

      // 5. Complete second exercise → transitions, then continue to exercise 3
      sessionBloc.add(const CompleteExercise());
      await expectLater(
        sessionBloc.stream,
        emits(isA<SessionTransitioning>()),
      );
      sessionBloc.add(const ContinueToNext());
      await expectLater(
        sessionBloc.stream,
        emits(isA<SessionActive>()),
      );
      expect(
          (sessionBloc.state as SessionActive).currentExerciseIndex, 2);

      // 6. Complete third (last) exercise → session complete
      sessionBloc.add(const CompleteExercise());
      await expectLater(
        sessionBloc.stream,
        emits(isA<SessionComplete>()),
      );

      // 7. Verify side effects
      verify(() => mockUserRepository.saveSession(any())).called(1);
      verify(() => mockUserRepository.updateStreakOnCompletion()).called(1);
      verify(() => mockHapticService.successPattern()).called(greaterThanOrEqualTo(1));

      // 8. Verify completion data
      final completeState = sessionBloc.state as SessionComplete;
      expect(completeState.newStreak, 6);
    });

    test('pause and resume during session', () async {
      // Load and start
      sessionBloc.add(const LoadSession());
      await expectLater(
        sessionBloc.stream,
        emitsInOrder([isA<SessionLoading>(), isA<SessionReady>()]),
      );
      sessionBloc.add(const StartSession());
      await expectLater(sessionBloc.stream, emits(isA<SessionActive>()));

      // Pause
      sessionBloc.add(const PauseSession());
      await expectLater(
        sessionBloc.stream,
        emits(isA<SessionActive>()
            .having((s) => s.isPaused, 'isPaused', true)),
      );

      // Resume
      sessionBloc.add(const ResumeSession());
      await expectLater(
        sessionBloc.stream,
        emits(isA<SessionActive>()
            .having((s) => s.isPaused, 'isPaused', false)),
      );
    });

    test('ProgramRepository returns correct program for each type', () {
      final repo = ProgramRepository();

      for (final type in core.ProgramType.values) {
        repo.setSelectedProgramType(type);
        final program = repo.getProgramForType(type);
        expect(program.exercises.isNotEmpty, isTrue,
            reason: '${type.name} program should have exercises');
        expect(program.exercises.every((e) => e.videoUrl.isNotEmpty), isTrue,
            reason: '${type.name} exercises should all have video URLs');
      }
    });

    test('StreakBloc loads streak data correctly', () async {
      final streakBloc = StreakBloc(userRepository: mockUserRepository);

      streakBloc.add(const LoadStreakData());
      await expectLater(
        streakBloc.stream,
        emitsInOrder([
          isA<StreakLoading>(),
          isA<StreakLoaded>(),
        ]),
      );

      final loadedState = streakBloc.state as StreakLoaded;
      expect(loadedState.streakData.currentStreak, 5);
      expect(loadedState.streakData.longestStreak, 10);
      expect(loadedState.streakData.totalSessions, 20);

      await streakBloc.close();
    });
  });
}
