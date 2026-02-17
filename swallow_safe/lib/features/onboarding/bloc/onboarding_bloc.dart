import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/program.dart';
import '../../../core/models/user_profile.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class SetName extends OnboardingEvent {
  final String name;

  const SetName(this.name);

  @override
  List<Object?> get props => [name];
}

class SetEmail extends OnboardingEvent {
  final String email;

  const SetEmail(this.email);

  @override
  List<Object?> get props => [email];
}

class AcceptDisclaimer extends OnboardingEvent {
  const AcceptDisclaimer();
}

class SetBaselineSymptoms extends OnboardingEvent {
  final int painLevel;
  final int swallowingEase;
  final int energyLevel;

  const SetBaselineSymptoms({
    required this.painLevel,
    required this.swallowingEase,
    required this.energyLevel,
  });

  @override
  List<Object?> get props => [painLevel, swallowingEase, energyLevel];
}

class SetGoals extends OnboardingEvent {
  final List<String> goals;

  const SetGoals(this.goals);

  @override
  List<Object?> get props => [goals];
}

class SetProgramType extends OnboardingEvent {
  final ProgramType programType;

  const SetProgramType(this.programType);

  @override
  List<Object?> get props => [programType];
}

class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

class CheckOnboardingStatus extends OnboardingEvent {
  const CheckOnboardingStatus();
}

class ResetOnboarding extends OnboardingEvent {
  const ResetOnboarding();
}

// States
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingInProgress extends OnboardingState {
  final String? name;
  final String? email;
  final ProgramType? programType;
  final bool disclaimerAccepted;
  final DateTime? disclaimerAcceptedAt;
  final int? baselinePain;
  final int? baselineSwallowing;
  final int? baselineEnergy;
  final List<String>? goals;

  const OnboardingInProgress({
    this.name,
    this.email,
    this.programType,
    this.disclaimerAccepted = false,
    this.disclaimerAcceptedAt,
    this.baselinePain,
    this.baselineSwallowing,
    this.baselineEnergy,
    this.goals,
  });

  OnboardingInProgress copyWith({
    String? name,
    String? email,
    ProgramType? programType,
    bool? disclaimerAccepted,
    DateTime? disclaimerAcceptedAt,
    int? baselinePain,
    int? baselineSwallowing,
    int? baselineEnergy,
    List<String>? goals,
  }) {
    return OnboardingInProgress(
      name: name ?? this.name,
      email: email ?? this.email,
      programType: programType ?? this.programType,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      disclaimerAcceptedAt: disclaimerAcceptedAt ?? this.disclaimerAcceptedAt,
      baselinePain: baselinePain ?? this.baselinePain,
      baselineSwallowing: baselineSwallowing ?? this.baselineSwallowing,
      baselineEnergy: baselineEnergy ?? this.baselineEnergy,
      goals: goals ?? this.goals,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        programType,
        disclaimerAccepted,
        disclaimerAcceptedAt,
        baselinePain,
        baselineSwallowing,
        baselineEnergy,
        goals,
      ];
}

class OnboardingComplete extends OnboardingState {
  final UserProfile userProfile;

  const OnboardingComplete(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<SetName>(_onSetName);
    on<SetEmail>(_onSetEmail);
    on<AcceptDisclaimer>(_onAcceptDisclaimer);
    on<SetBaselineSymptoms>(_onSetBaselineSymptoms);
    on<SetGoals>(_onSetGoals);
    on<SetProgramType>(_onSetProgramType);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<ResetOnboarding>(_onResetOnboarding);
  }

  void _onSetName(SetName event, Emitter<OnboardingState> emit) {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      emit(currentState.copyWith(name: event.name));
    } else {
      emit(OnboardingInProgress(name: event.name));
    }
  }

  void _onSetEmail(SetEmail event, Emitter<OnboardingState> emit) {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      emit(currentState.copyWith(email: event.email));
    } else {
      emit(OnboardingInProgress(email: event.email));
    }
  }

  void _onAcceptDisclaimer(AcceptDisclaimer event, Emitter<OnboardingState> emit) {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      emit(currentState.copyWith(
        disclaimerAccepted: true,
        disclaimerAcceptedAt: DateTime.now(),
      ));
    } else {
      emit(OnboardingInProgress(
        disclaimerAccepted: true,
        disclaimerAcceptedAt: DateTime.now(),
      ));
    }
  }

  void _onSetBaselineSymptoms(
      SetBaselineSymptoms event, Emitter<OnboardingState> emit) {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      emit(currentState.copyWith(
        baselinePain: event.painLevel,
        baselineSwallowing: event.swallowingEase,
        baselineEnergy: event.energyLevel,
      ));
    } else {
      emit(OnboardingInProgress(
        baselinePain: event.painLevel,
        baselineSwallowing: event.swallowingEase,
        baselineEnergy: event.energyLevel,
      ));
    }
  }

  void _onSetGoals(SetGoals event, Emitter<OnboardingState> emit) {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      emit(currentState.copyWith(goals: event.goals));
    } else {
      emit(OnboardingInProgress(goals: event.goals));
    }
  }

  void _onSetProgramType(SetProgramType event, Emitter<OnboardingState> emit) {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      emit(currentState.copyWith(programType: event.programType));
    } else {
      emit(OnboardingInProgress(programType: event.programType));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is OnboardingInProgress) {
      emit(const OnboardingLoading());

      try {
        // Create user profile
        final userProfile = UserProfile(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: currentState.name ?? 'User',
          email: currentState.email ?? '',
          selectedProgramType: currentState.programType,
          programStartDate: DateTime.now(),
          onboardingComplete: true,
          disclaimerAccepted: currentState.disclaimerAccepted,
          disclaimerAcceptedAt: currentState.disclaimerAcceptedAt,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );

        // TODO: Save to local storage (Hive) and/or Firebase

        emit(OnboardingComplete(userProfile));
      } catch (e) {
        emit(OnboardingError(e.toString()));
      }
    }
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());

    try {
      // TODO: Check local storage for existing user
      // For now, assume new user
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if we have a saved user profile
      // If yes, emit OnboardingComplete
      // If no, emit OnboardingInitial

      // For demo purposes, always show onboarding
      emit(const OnboardingInitial());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  void _onResetOnboarding(ResetOnboarding event, Emitter<OnboardingState> emit) {
    emit(const OnboardingInitial());
  }
}
