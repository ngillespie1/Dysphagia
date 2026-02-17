import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/program.dart';
import '../../../core/models/program_week.dart';
import '../../../data/repositories/program_repository.dart';
import 'program_event.dart';
import 'program_state.dart';

class ProgramBloc extends Bloc<ProgramEvent, ProgramState> {
  final ProgramRepository programRepository;

  ProgramBloc({required this.programRepository})
      : super(const ProgramInitial()) {
    on<LoadProgram>(_onLoadProgram);
    on<SelectProgramType>(_onSelectProgramType);
    on<SelectWeek>(_onSelectWeek);
    on<CompleteExercise>(_onCompleteExercise);
    on<CompleteWeek>(_onCompleteWeek);
    on<UnlockNextWeek>(_onUnlockNextWeek);
    on<UpdateRestDays>(_onUpdateRestDays);
    on<ResetProgram>(_onResetProgram);
  }

  Future<void> _onLoadProgram(
    LoadProgram event,
    Emitter<ProgramState> emit,
  ) async {
    emit(const ProgramLoading());

    try {
      // Simulate loading from storage/API
      await Future.delayed(const Duration(milliseconds: 500));

      // Load program for the currently selected type in the repository
      final type = programRepository.selectedProgramType;
      final program = Program.sample(type);

      // Sync type to repository so SessionBloc picks it up
      programRepository.setSelectedProgramType(type);

      emit(ProgramLoaded(
        program: program,
        selectedWeek: program.currentWeek,
      ));
    } catch (e) {
      emit(ProgramError(e.toString()));
    }
  }

  Future<void> _onSelectProgramType(
    SelectProgramType event,
    Emitter<ProgramState> emit,
  ) async {
    emit(const ProgramLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // Sync selected type to repository so SessionBloc picks it up
      programRepository.setSelectedProgramType(event.type);

      final program = Program.sample(event.type).copyWith(
        prescribedBy: event.prescribedBy,
        startDate: DateTime.now(),
        currentWeek: 1,
      );

      // Reset all weeks to initial state for new program
      final resetWeeks = program.weeks.map((week) {
        if (week.weekNumber == 1) {
          return week.copyWith(isUnlocked: true, completionPercent: 0.0);
        }
        return week.copyWith(isUnlocked: false, completionPercent: 0.0);
      }).toList();

      emit(ProgramLoaded(
        program: program.copyWith(weeks: resetWeeks),
        selectedWeek: 1,
      ));
    } catch (e) {
      emit(ProgramError(e.toString()));
    }
  }

  void _onSelectWeek(
    SelectWeek event,
    Emitter<ProgramState> emit,
  ) {
    final currentState = state;
    if (currentState is ProgramLoaded) {
      // Only allow selecting unlocked weeks
      final week = currentState.program.weeks[event.weekNumber - 1];
      if (week.isUnlocked) {
        emit(currentState.copyWith(selectedWeek: event.weekNumber));
      }
    }
  }

  void _onCompleteExercise(
    CompleteExercise event,
    Emitter<ProgramState> emit,
  ) {
    final currentState = state;
    if (currentState is ProgramLoaded) {
      final program = currentState.program;
      final weekIndex = program.currentWeek - 1;
      final week = program.weeks[weekIndex];

      // Calculate new completion percentage
      final exerciseIndex = week.exerciseIds.indexOf(event.exerciseId);
      if (exerciseIndex >= 0) {
        final newCompletedCount = week.completedExercises + 1;
        final newPercent = newCompletedCount / week.exerciseCount;

        final updatedWeeks = List<ProgramWeek>.from(program.weeks);
        updatedWeeks[weekIndex] = week.copyWith(
          completionPercent: newPercent.clamp(0.0, 1.0),
        );

        emit(currentState.copyWith(
          program: program.copyWith(weeks: updatedWeeks),
        ));
      }
    }
  }

  void _onCompleteWeek(
    CompleteWeek event,
    Emitter<ProgramState> emit,
  ) {
    final currentState = state;
    if (currentState is ProgramLoaded) {
      final program = currentState.program;
      final weekIndex = event.weekNumber - 1;

      final updatedWeeks = List<ProgramWeek>.from(program.weeks);
      updatedWeeks[weekIndex] = updatedWeeks[weekIndex].copyWith(
        completionPercent: 1.0,
      );

      // Unlock next week if available
      if (weekIndex + 1 < updatedWeeks.length) {
        updatedWeeks[weekIndex + 1] = updatedWeeks[weekIndex + 1].copyWith(
          isUnlocked: true,
        );
      }

      // Move to next week if not at end
      final newCurrentWeek = event.weekNumber < program.totalWeeks
          ? event.weekNumber + 1
          : event.weekNumber;

      emit(currentState.copyWith(
        program: program.copyWith(
          weeks: updatedWeeks,
          currentWeek: newCurrentWeek,
        ),
        selectedWeek: newCurrentWeek,
      ));
    }
  }

  void _onUnlockNextWeek(
    UnlockNextWeek event,
    Emitter<ProgramState> emit,
  ) {
    final currentState = state;
    if (currentState is ProgramLoaded) {
      final program = currentState.program;
      final nextWeekIndex = program.currentWeek;

      if (nextWeekIndex < program.weeks.length) {
        final updatedWeeks = List<ProgramWeek>.from(program.weeks);
        updatedWeeks[nextWeekIndex] = updatedWeeks[nextWeekIndex].copyWith(
          isUnlocked: true,
        );

        emit(currentState.copyWith(
          program: program.copyWith(weeks: updatedWeeks),
        ));
      }
    }
  }

  void _onUpdateRestDays(
    UpdateRestDays event,
    Emitter<ProgramState> emit,
  ) {
    final currentState = state;
    if (currentState is ProgramLoaded) {
      emit(currentState.copyWith(
        program: currentState.program.copyWith(restDays: event.restDays),
      ));
    }
  }

  void _onResetProgram(
    ResetProgram event,
    Emitter<ProgramState> emit,
  ) {
    emit(const ProgramNotSelected());
  }
}
