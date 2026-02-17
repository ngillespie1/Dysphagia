import 'package:equatable/equatable.dart';

import '../../../core/models/program.dart';
import '../../../core/models/program_week.dart';

abstract class ProgramState extends Equatable {
  const ProgramState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class ProgramInitial extends ProgramState {
  const ProgramInitial();
}

/// Loading program data
class ProgramLoading extends ProgramState {
  const ProgramLoading();
}

/// No program selected yet
class ProgramNotSelected extends ProgramState {
  const ProgramNotSelected();
}

/// Program is loaded and active
class ProgramLoaded extends ProgramState {
  final Program program;
  final int selectedWeek;

  const ProgramLoaded({
    required this.program,
    this.selectedWeek = 0,
  });

  ProgramWeek? get currentWeekData => program.currentWeekData;

  ProgramWeek? get selectedWeekData {
    if (selectedWeek < 1 || selectedWeek > program.weeks.length) return null;
    return program.weeks[selectedWeek - 1];
  }

  @override
  List<Object?> get props => [program, selectedWeek];

  ProgramLoaded copyWith({
    Program? program,
    int? selectedWeek,
  }) {
    return ProgramLoaded(
      program: program ?? this.program,
      selectedWeek: selectedWeek ?? this.selectedWeek,
    );
  }
}

/// Error loading program
class ProgramError extends ProgramState {
  final String message;

  const ProgramError(this.message);

  @override
  List<Object?> get props => [message];
}
