import 'package:equatable/equatable.dart';

/// A completed exercise session
class Session extends Equatable {
  final String id;
  final String programId;
  final DateTime completedAt;
  final Duration duration;
  final int exercisesCompleted;
  final int totalExercises;
  
  const Session({
    required this.id,
    required this.programId,
    required this.completedAt,
    required this.duration,
    required this.exercisesCompleted,
    required this.totalExercises,
  });
  
  /// Create from JSON (Firestore document)
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String? ?? '',
      programId: json['program_id'] as String? ?? '',
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : DateTime.now(),
      duration: Duration(
        seconds: json['duration_seconds'] as int? ?? 0,
      ),
      exercisesCompleted: json['exercises_completed'] as int? ?? 0,
      totalExercises: json['total_exercises'] as int? ?? 0,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'program_id': programId,
      'completed_at': completedAt.toIso8601String(),
      'duration_seconds': duration.inSeconds,
      'exercises_completed': exercisesCompleted,
      'total_exercises': totalExercises,
    };
  }
  
  /// Check if session was fully completed
  bool get isComplete => exercisesCompleted == totalExercises;
  
  /// Get completion percentage
  double get completionPercentage => 
      totalExercises > 0 ? exercisesCompleted / totalExercises : 0;
  
  /// Format duration for display
  String get durationDisplay {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
  
  @override
  List<Object?> get props => [
    id,
    programId,
    completedAt,
    duration,
    exercisesCompleted,
    totalExercises,
  ];
}
