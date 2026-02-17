import 'package:equatable/equatable.dart';

import '../../../core/models/program.dart';

abstract class ProgramEvent extends Equatable {
  const ProgramEvent();

  @override
  List<Object?> get props => [];
}

/// Load the user's current program
class LoadProgram extends ProgramEvent {
  const LoadProgram();
}

/// Select a new program type
class SelectProgramType extends ProgramEvent {
  final ProgramType type;
  final String? prescribedBy;

  const SelectProgramType(this.type, {this.prescribedBy});

  @override
  List<Object?> get props => [type, prescribedBy];
}

/// Navigate to a specific week
class SelectWeek extends ProgramEvent {
  final int weekNumber;

  const SelectWeek(this.weekNumber);

  @override
  List<Object?> get props => [weekNumber];
}

/// Complete an exercise in the current week
class CompleteExercise extends ProgramEvent {
  final String exerciseId;

  const CompleteExercise(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}

/// Mark a week as complete
class CompleteWeek extends ProgramEvent {
  final int weekNumber;

  const CompleteWeek(this.weekNumber);

  @override
  List<Object?> get props => [weekNumber];
}

/// Unlock the next week
class UnlockNextWeek extends ProgramEvent {
  const UnlockNextWeek();
}

/// Update rest day schedule
class UpdateRestDays extends ProgramEvent {
  final List<int> restDays;

  const UpdateRestDays(this.restDays);

  @override
  List<Object?> get props => [restDays];
}

/// Reset program progress
class ResetProgram extends ProgramEvent {
  const ResetProgram();
}
