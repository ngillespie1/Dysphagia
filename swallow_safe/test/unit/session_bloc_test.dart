import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:swallow_safe/features/exercise/bloc/session_bloc.dart';
import 'package:swallow_safe/data/repositories/program_repository.dart';
import 'package:swallow_safe/data/repositories/user_repository.dart';
import 'package:swallow_safe/core/services/haptic_service.dart';
import 'package:swallow_safe/data/models/program.dart';
import 'package:swallow_safe/data/models/exercise.dart';
import 'package:swallow_safe/data/models/session.dart';
import 'package:swallow_safe/data/models/user_profile.dart';

// Mocks
class MockProgramRepository extends Mock implements ProgramRepository {}
class MockUserRepository extends Mock implements UserRepository {}
class MockHapticService extends Mock implements HapticService {}

void main() {
  // Register fallback values for mocktail's `any()` matcher
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

  late SessionBloc sessionBloc;
  late MockProgramRepository mockProgramRepository;
  late MockUserRepository mockUserRepository;
  late MockHapticService mockHapticService;
  
  final testProgram = Program(
    id: 'test_program',
    title: 'Test Program',
    description: 'A test program',
    exercises: const [
      Exercise(
        id: 'ex_1',
        name: 'Test Exercise 1',
        description: 'First exercise',
        videoUrl: 'https://example.com/video1.mp4',
        reps: 10,
      ),
      Exercise(
        id: 'ex_2',
        name: 'Test Exercise 2',
        description: 'Second exercise',
        videoUrl: 'https://example.com/video2.mp4',
        reps: 8,
      ),
    ],
  );
  
  setUp(() {
    mockProgramRepository = MockProgramRepository();
    mockUserRepository = MockUserRepository();
    mockHapticService = MockHapticService();
    
    // Setup default mock behaviors
    when(() => mockProgramRepository.getCurrentProgram(any()))
        .thenAnswer((_) async => testProgram);
    when(() => mockHapticService.successPattern())
        .thenAnswer((_) async {});
    when(() => mockUserRepository.saveSession(any()))
        .thenAnswer((_) async {});
    when(() => mockUserRepository.updateStreakOnCompletion())
        .thenAnswer((_) async => const StreakData(currentStreak: 1));
    
    sessionBloc = SessionBloc(
      programRepository: mockProgramRepository,
      userRepository: mockUserRepository,
      hapticService: mockHapticService,
    );
  });
  
  tearDown(() {
    sessionBloc.close();
  });
  
  group('SessionBloc', () {
    test('initial state is SessionInitial', () {
      expect(sessionBloc.state, isA<SessionInitial>());
    });
    
    blocTest<SessionBloc, SessionState>(
      'emits [SessionLoading, SessionReady] when LoadSession is added',
      build: () => sessionBloc,
      act: (bloc) => bloc.add(const LoadSession()),
      expect: () => [
        isA<SessionLoading>(),
        isA<SessionReady>(),
      ],
      verify: (_) {
        verify(() => mockProgramRepository.getCurrentProgram(any())).called(1);
      },
    );
    
    blocTest<SessionBloc, SessionState>(
      'emits SessionActive when StartSession is added after SessionReady',
      build: () => sessionBloc,
      seed: () => SessionReady(program: testProgram),
      act: (bloc) => bloc.add(const StartSession()),
      expect: () => [
        isA<SessionActive>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SessionActive;
        expect(state.currentExerciseIndex, 0);
        expect(state.program, testProgram);
      },
    );
    
    blocTest<SessionBloc, SessionState>(
      'transitions to next exercise when CompleteExercise is added',
      build: () => sessionBloc,
      seed: () => SessionActive(
        program: testProgram,
        currentExerciseIndex: 0,
        startTime: DateTime.now(),
      ),
      act: (bloc) {
        bloc.add(const CompleteExercise());
        bloc.add(const ContinueToNext());
      },
      wait: const Duration(milliseconds: 600),
      expect: () => [
        isA<SessionTransitioning>(),
        isA<SessionActive>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SessionActive;
        expect(state.currentExerciseIndex, 1);
      },
    );
    
    blocTest<SessionBloc, SessionState>(
      'completes session when last exercise is completed',
      build: () => sessionBloc,
      seed: () => SessionActive(
        program: testProgram,
        currentExerciseIndex: 1, // Last exercise
        startTime: DateTime.now(),
      ),
      act: (bloc) => bloc.add(const CompleteExercise()),
      expect: () => [
        isA<SessionComplete>(),
      ],
      verify: (_) {
        verify(() => mockHapticService.successPattern()).called(1);
        verify(() => mockUserRepository.saveSession(any())).called(1);
        verify(() => mockUserRepository.updateStreakOnCompletion()).called(1);
      },
    );
    
    blocTest<SessionBloc, SessionState>(
      'pauses and resumes session correctly',
      build: () => sessionBloc,
      seed: () => SessionActive(
        program: testProgram,
        currentExerciseIndex: 0,
        startTime: DateTime.now(),
        isPaused: false,
      ),
      act: (bloc) {
        bloc.add(const PauseSession());
        bloc.add(const ResumeSession());
      },
      expect: () => [
        isA<SessionActive>().having((s) => s.isPaused, 'isPaused', true),
        isA<SessionActive>().having((s) => s.isPaused, 'isPaused', false),
      ],
    );
  });
}
