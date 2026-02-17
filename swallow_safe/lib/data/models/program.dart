import 'package:equatable/equatable.dart';

import 'exercise.dart';

/// A rehabilitation program containing a sequence of exercises
class Program extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<Exercise> exercises;
  final bool aiAccessRequired;
  final String difficulty;
  final Duration estimatedDuration;
  
  const Program({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
    this.aiAccessRequired = false,
    this.difficulty = 'beginner',
    this.estimatedDuration = const Duration(minutes: 10),
  });
  
  /// Create from JSON (Firestore document)
  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      aiAccessRequired: json['ai_access_required'] as bool? ?? false,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      estimatedDuration: Duration(
        minutes: json['estimated_duration_minutes'] as int? ?? 10,
      ),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'ai_access_required': aiAccessRequired,
      'difficulty': difficulty,
      'estimated_duration_minutes': estimatedDuration.inMinutes,
    };
  }
  
  /// Get total number of exercises
  int get exerciseCount => exercises.length;
  
  /// Calculate total reps across all exercises
  int get totalReps => exercises.fold(0, (sum, e) => sum + e.reps);
  
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    exercises,
    aiAccessRequired,
    difficulty,
    estimatedDuration,
  ];
}
