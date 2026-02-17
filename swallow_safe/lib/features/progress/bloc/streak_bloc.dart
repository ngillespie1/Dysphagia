import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/user_profile.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/user_repository.dart';

// Events
abstract class StreakEvent extends Equatable {
  const StreakEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadStreakData extends StreakEvent {
  const LoadStreakData();
}

class RefreshStreakData extends StreakEvent {
  const RefreshStreakData();
}

// States
abstract class StreakState extends Equatable {
  const StreakState();
  
  @override
  List<Object?> get props => [];
}

class StreakInitial extends StreakState {
  const StreakInitial();
}

class StreakLoading extends StreakState {
  const StreakLoading();
}

class StreakLoaded extends StreakState {
  final StreakData streakData;
  final List<Session> recentSessions;
  final List<bool> weeklyCompletion;
  
  const StreakLoaded({
    required this.streakData,
    required this.recentSessions,
    required this.weeklyCompletion,
  });
  
  @override
  List<Object?> get props => [streakData, recentSessions, weeklyCompletion];
}

class StreakError extends StreakState {
  final String message;
  
  const StreakError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final UserRepository userRepository;
  
  StreakBloc({required this.userRepository}) : super(const StreakInitial()) {
    on<LoadStreakData>(_onLoadStreakData);
    on<RefreshStreakData>(_onRefreshStreakData);
  }
  
  Future<void> _onLoadStreakData(
    LoadStreakData event,
    Emitter<StreakState> emit,
  ) async {
    emit(const StreakLoading());
    
    try {
      await userRepository.initialize();
      
      final profile = await userRepository.getUserProfile();
      final recentSessions = await userRepository.getThisWeekSessions();
      final weeklyCompletion = _calculateWeeklyCompletion(recentSessions);
      
      emit(StreakLoaded(
        streakData: profile.streakData,
        recentSessions: recentSessions,
        weeklyCompletion: weeklyCompletion,
      ));
    } catch (e) {
      emit(StreakError(message: e.toString()));
    }
  }
  
  Future<void> _onRefreshStreakData(
    RefreshStreakData event,
    Emitter<StreakState> emit,
  ) async {
    try {
      final profile = await userRepository.getUserProfile();
      final recentSessions = await userRepository.getThisWeekSessions();
      final weeklyCompletion = _calculateWeeklyCompletion(recentSessions);
      
      emit(StreakLoaded(
        streakData: profile.streakData,
        recentSessions: recentSessions,
        weeklyCompletion: weeklyCompletion,
      ));
    } catch (e) {
      // Keep current state on refresh error
    }
  }
  
  List<bool> _calculateWeeklyCompletion(List<Session> sessions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // Create a map of completed days
    final completedDays = <int>{};
    for (final session in sessions) {
      final dayOfWeek = session.completedAt.weekday;
      completedDays.add(dayOfWeek);
    }
    
    // Return 7 booleans for Mon-Sun
    return List.generate(7, (index) => completedDays.contains(index + 1));
  }
}
