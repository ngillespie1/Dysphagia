import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/symptom_entry.dart';
import '../../../data/repositories/symptoms_repository.dart';
import '../../../core/services/haptic_service.dart';

// Events
abstract class SymptomsEvent extends Equatable {
  const SymptomsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadTodaySymptoms extends SymptomsEvent {
  const LoadTodaySymptoms();
}

class UpdatePainLevel extends SymptomsEvent {
  final int level;
  const UpdatePainLevel(this.level);
  
  @override
  List<Object?> get props => [level];
}

class UpdateSwallowingEase extends SymptomsEvent {
  final int level;
  const UpdateSwallowingEase(this.level);
  
  @override
  List<Object?> get props => [level];
}

class UpdateDryMouth extends SymptomsEvent {
  final int level;
  const UpdateDryMouth(this.level);
  
  @override
  List<Object?> get props => [level];
}

class SaveSymptomEntry extends SymptomsEvent {
  const SaveSymptomEntry();
}

// States
abstract class SymptomsState extends Equatable {
  const SymptomsState();
  
  @override
  List<Object?> get props => [];
}

class SymptomsInitial extends SymptomsState {
  const SymptomsInitial();
}

class SymptomsLoading extends SymptomsState {
  const SymptomsLoading();
}

class SymptomsEditing extends SymptomsState {
  final int? painLevel;
  final int? swallowingEase;
  final int? dryMouth;
  final bool isSaving;
  final bool hasExistingEntry;
  
  const SymptomsEditing({
    this.painLevel,
    this.swallowingEase,
    this.dryMouth,
    this.isSaving = false,
    this.hasExistingEntry = false,
  });
  
  bool get isComplete => 
    painLevel != null && 
    swallowingEase != null && 
    dryMouth != null;
  
  SymptomsEditing copyWith({
    int? painLevel,
    int? swallowingEase,
    int? dryMouth,
    bool? isSaving,
    bool? hasExistingEntry,
  }) {
    return SymptomsEditing(
      painLevel: painLevel ?? this.painLevel,
      swallowingEase: swallowingEase ?? this.swallowingEase,
      dryMouth: dryMouth ?? this.dryMouth,
      isSaving: isSaving ?? this.isSaving,
      hasExistingEntry: hasExistingEntry ?? this.hasExistingEntry,
    );
  }
  
  @override
  List<Object?> get props => [painLevel, swallowingEase, dryMouth, isSaving, hasExistingEntry];
}

class SymptomsSaved extends SymptomsState {
  final SymptomEntry entry;
  
  const SymptomsSaved({required this.entry});
  
  @override
  List<Object?> get props => [entry];
}

class SymptomsError extends SymptomsState {
  final String message;
  
  const SymptomsError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class SymptomsBloc extends Bloc<SymptomsEvent, SymptomsState> {
  final SymptomsRepository repository;
  final HapticService hapticService;
  
  SymptomsBloc({
    required this.repository,
    required this.hapticService,
  }) : super(const SymptomsInitial()) {
    on<LoadTodaySymptoms>(_onLoadTodaySymptoms);
    on<UpdatePainLevel>(_onUpdatePainLevel);
    on<UpdateSwallowingEase>(_onUpdateSwallowingEase);
    on<UpdateDryMouth>(_onUpdateDryMouth);
    on<SaveSymptomEntry>(_onSaveEntry);
  }
  
  Future<void> _onLoadTodaySymptoms(
    LoadTodaySymptoms event,
    Emitter<SymptomsState> emit,
  ) async {
    emit(const SymptomsLoading());
    
    try {
      final existingEntry = await repository.getTodayEntry();
      
      if (existingEntry != null) {
        emit(SymptomsEditing(
          painLevel: existingEntry.painLevel,
          swallowingEase: existingEntry.swallowingEase,
          dryMouth: existingEntry.dryMouth,
          hasExistingEntry: true,
        ));
      } else {
        emit(const SymptomsEditing());
      }
    } catch (e) {
      emit(const SymptomsEditing());
    }
  }
  
  void _onUpdatePainLevel(
    UpdatePainLevel event,
    Emitter<SymptomsState> emit,
  ) {
    final currentState = state;
    if (currentState is SymptomsEditing) {
      emit(currentState.copyWith(painLevel: event.level));
    }
  }
  
  void _onUpdateSwallowingEase(
    UpdateSwallowingEase event,
    Emitter<SymptomsState> emit,
  ) {
    final currentState = state;
    if (currentState is SymptomsEditing) {
      emit(currentState.copyWith(swallowingEase: event.level));
    }
  }
  
  void _onUpdateDryMouth(
    UpdateDryMouth event,
    Emitter<SymptomsState> emit,
  ) {
    final currentState = state;
    if (currentState is SymptomsEditing) {
      emit(currentState.copyWith(dryMouth: event.level));
    }
  }
  
  Future<void> _onSaveEntry(
    SaveSymptomEntry event,
    Emitter<SymptomsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SymptomsEditing && currentState.isComplete) {
      emit(currentState.copyWith(isSaving: true));
      
      try {
        final entry = SymptomEntry(
          id: const Uuid().v4(),
          date: DateTime.now(),
          painLevel: currentState.painLevel!,
          swallowingEase: currentState.swallowingEase!,
          dryMouth: currentState.dryMouth!,
          createdAt: DateTime.now(),
        );
        
        await repository.saveEntry(entry);
        await hapticService.successPattern();
        
        emit(SymptomsSaved(entry: entry));
      } catch (e) {
        emit(SymptomsError(message: e.toString()));
        emit(currentState.copyWith(isSaving: false));
      }
    }
  }
}
