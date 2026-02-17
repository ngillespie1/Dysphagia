import 'package:equatable/equatable.dart';

/// An individual exercise with video guidance
class Exercise extends Equatable {
  final String id;
  final String name;
  final String description;
  final String videoUrl;
  final int reps;
  final Duration holdDuration;
  final String instructions;
  final String? thumbnailUrl;
  
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    this.reps = 10,
    this.holdDuration = Duration.zero,
    this.instructions = '',
    this.thumbnailUrl,
  });
  
  /// Create from JSON (Firestore document)
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      reps: json['reps'] as int? ?? 10,
      holdDuration: Duration(
        seconds: json['hold_duration_seconds'] as int? ?? 0,
      ),
      instructions: json['instructions'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'video_url': videoUrl,
      'reps': reps,
      'hold_duration_seconds': holdDuration.inSeconds,
      'instructions': instructions,
      'thumbnail_url': thumbnailUrl,
    };
  }
  
  /// Formatted rep count for display
  String get repsDisplay => holdDuration.inSeconds > 0
      ? 'Hold for ${holdDuration.inSeconds}s × $reps'
      : '$reps reps';
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    videoUrl,
    reps,
    holdDuration,
    instructions,
    thumbnailUrl,
  ];
}
