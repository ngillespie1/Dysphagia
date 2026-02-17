import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/program.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/user_data_service.dart';

// ============ Events ============

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {
  const LoadUser();
}

class UpdateUserName extends UserEvent {
  final String name;

  const UpdateUserName(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateUserProgram extends UserEvent {
  final ProgramType programType;

  const UpdateUserProgram(this.programType);

  @override
  List<Object?> get props => [programType];
}

class CompleteUserOnboarding extends UserEvent {
  final String name;
  final String email;
  final ProgramType programType;
  final bool disclaimerAccepted;
  final DateTime? disclaimerAcceptedAt;

  const CompleteUserOnboarding({
    required this.name,
    required this.email,
    required this.programType,
    this.disclaimerAccepted = false,
    this.disclaimerAcceptedAt,
  });

  @override
  List<Object?> get props => [name, email, programType, disclaimerAccepted, disclaimerAcceptedAt];
}

class LogoutUser extends UserEvent {
  const LogoutUser();
}

class RefreshUser extends UserEvent {
  const RefreshUser();
}

// ============ States ============

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final UserProfile user;

  const UserLoaded(this.user);

  /// Convenience getter for first name
  String get firstName => user.firstName;

  /// Convenience getter for full name
  String get fullName => user.name;

  @override
  List<Object?> get props => [user];
}

class UserNotFound extends UserState {
  const UserNotFound();
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============ Bloc ============

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserDataService _userDataService;

  UserBloc({required UserDataService userDataService})
      : _userDataService = userDataService,
        super(const UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUserName>(_onUpdateUserName);
    on<UpdateUserProgram>(_onUpdateUserProgram);
    on<CompleteUserOnboarding>(_onCompleteOnboarding);
    on<LogoutUser>(_onLogout);
    on<RefreshUser>(_onRefreshUser);
  }

  void _onLoadUser(LoadUser event, Emitter<UserState> emit) {
    emit(const UserLoading());

    try {
      final user = _userDataService.getCurrentUser();
      
      if (user != null && _userDataService.isUserReady()) {
        emit(UserLoaded(user));
      } else {
        emit(const UserNotFound());
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserName(
    UpdateUserName event,
    Emitter<UserState> emit,
  ) async {
    try {
      final updated = await _userDataService.updateUserName(event.name);
      if (updated != null) {
        emit(UserLoaded(updated));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProgram(
    UpdateUserProgram event,
    Emitter<UserState> emit,
  ) async {
    try {
      final updated = await _userDataService.updateProgram(event.programType);
      if (updated != null) {
        emit(UserLoaded(updated));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteUserOnboarding event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      final user = await _userDataService.completeOnboarding(
        name: event.name,
        email: event.email,
        programType: event.programType,
        disclaimerAccepted: event.disclaimerAccepted,
        disclaimerAcceptedAt: event.disclaimerAcceptedAt,
      );
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());

    try {
      await _userDataService.logout();
      emit(const UserNotFound());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void _onRefreshUser(RefreshUser event, Emitter<UserState> emit) {
    final user = _userDataService.getCurrentUser();
    if (user != null) {
      emit(UserLoaded(user));
    }
  }
}
