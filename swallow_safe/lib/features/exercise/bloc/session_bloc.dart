import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/program.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/program_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/services/haptic_service.dart';

// Events
abstract class SessionEvent extends Equatable {
  const SessionEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadSession extends SessionEvent {
  const LoadSession();
}

class StartSession extends SessionEvent {
  const StartSession();
}

class CompleteExercise extends SessionEvent {
  const CompleteExercise();
}

class PauseSession extends SessionEvent {
  const PauseSession();
}

class ResumeSession extends SessionEvent {
  const ResumeSession();
}

class ContinueToNext extends SessionEvent {
  const ContinueToNext();
}

class EndSession extends SessionEvent {
  const EndSession();
}

// States
abstract class SessionState extends Equatable {
  const SessionState();
  
  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SessionReady extends SessionState {
  final Program program;
  
  const SessionReady({required this.program});
  
  @override
  List<Object?> get props => [program];
}

class SessionActive extends SessionState {
  final Program program;
  final int currentExerciseIndex;
  final DateTime startTime;
  final bool isPaused;
  
  const SessionActive({
    required this.program,
    required this.currentExerciseIndex,
    required this.startTime,
    this.isPaused = false,
  });
  
  Exercise get currentExercise => program.exercises[currentExerciseIndex];
  int get exerciseNumber => currentExerciseIndex + 1;
  int get totalExercises => program.exercises.length;
  double get progress => exerciseNumber / totalExercises;
  bool get isLastExercise => currentExerciseIndex == program.exercises.length - 1;
  
  SessionActive copyWith({
    Program? program,
    int? currentExerciseIndex,
    DateTime? startTime,
    bool? isPaused,
  }) {
    return SessionActive(
      program: program ?? this.program,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      startTime: startTime ?? this.startTime,
      isPaused: isPaused ?? this.isPaused,
    );
  }
  
  @override
  List<Object?> get props => [program, currentExerciseIndex, startTime, isPaused];
}

class SessionTransitioning extends SessionState {
  final Program program;
  final int completedExerciseIndex;
  final int nextExerciseIndex;
  
  const SessionTransitioning({
    required this.program,
    required this.completedExerciseIndex,
    required this.nextExerciseIndex,
  });
  
  Exercise get completedExercise => program.exercises[completedExerciseIndex];
  Exercise get nextExercise => program.exercises[nextExerciseIndex];
  
  @override
  List<Object?> get props => [program, completedExerciseIndex, nextExerciseIndex];
}

class SessionComplete extends SessionState {
  final Session session;
  final int newStreak;
  final int totalSessions;
  
  const SessionComplete({
    required this.session,
    required this.newStreak,
    this.totalSessions = 0,
  });
  
  @override
  List<Object?> get props => [session, newStreak, totalSessions];
}

class SessionError extends SessionState {
  final String message;
  
  const SessionError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final ProgramRepository programRepository;
  final UserRepository userRepository;
  final HapticService hapticService;
  
  DateTime? _sessionStartTime;
  
  SessionBloc({
    required this.programRepository,
    required this.hapticService,
    required this.userRepository,
  }) : super(const SessionInitial()) {
    on<LoadSession>(_onLoadSession);
    on<StartSession>(_onStartSession);
    on<CompleteExercise>(_onCompleteExercise);
    on<ContinueToNext>(_onContinueToNext);
    on<PauseSession>(_onPauseSession);
    on<ResumeSession>(_onResumeSession);
    on<EndSession>(_onEndSession);
  }
  
  Future<void> _onLoadSession(
    LoadSession event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    
    try {
      final program = await programRepository.getCurrentProgram('current_user');
      emit(SessionReady(program: program));
    } catch (e) {
      emit(SessionError(message: e.toString()));
    }
  }
  
  Future<void> _onStartSession(
    StartSession event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionReady) {
      _sessionStartTime = DateTime.now();
      emit(SessionActive(
        program: currentState.program,
        currentExerciseIndex: 0,
        startTime: _sessionStartTime!,
      ));
    }
  }
  
  Future<void> _onCompleteExercise(
    CompleteExercise event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionActive) {
      // Haptic feedback for exercise completion
      await hapticService.successPattern();
      
      if (currentState.isLastExercise) {
        // Session complete!
        final sessionDuration = DateTime.now().difference(currentState.startTime);
        
        final session = Session(
          id: const Uuid().v4(),
          programId: currentState.program.id,
          completedAt: DateTime.now(),
          duration: sessionDuration,
          exercisesCompleted: currentState.totalExercises,
          totalExercises: currentState.totalExercises,
        );
        
        // Save session and update streak
        await userRepository.saveSession(session);
        final streakData = await userRepository.updateStreakOnCompletion();
        
        emit(SessionComplete(
          session: session,
          newStreak: streakData.currentStreak,
          totalSessions: streakData.totalSessions,
        ));
      } else {
        // Emit transitioning — UI controls when to advance via ContinueToNext
        emit(SessionTransitioning(
          program: currentState.program,
          completedExerciseIndex: currentState.currentExerciseIndex,
          nextExerciseIndex: currentState.currentExerciseIndex + 1,
        ));
      }
    }
  }

  Future<void> _onContinueToNext(
    ContinueToNext event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionTransitioning) {
      emit(SessionActive(
        program: currentState.program,
        currentExerciseIndex: currentState.nextExerciseIndex,
        startTime: DateTime.now(),
      ));
    }
  }
  
  Future<void> _onPauseSession(
    PauseSession event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionActive) {
      emit(currentState.copyWith(isPaused: true));
    }
  }
  
  Future<void> _onResumeSession(
    ResumeSession event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionActive) {
      emit(currentState.copyWith(isPaused: false));
    }
  }
  
  Future<void> _onEndSession(
    EndSession event,
    Emitter<SessionState> emit,
  ) async {
    // Reset to ready state
    try {
      final program = await programRepository.getCurrentProgram('current_user');
      emit(SessionReady(program: program));
    } catch (e) {
      emit(const SessionInitial());
    }
  }
}
