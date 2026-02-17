import 'package:equatable/equatable.dart';

/// A single day's exercise progress record
class DailyProgress extends Equatable {
  final String id;
  final String date; // YYYY-MM-DD
  final int exercisesCompleted;
  final int exercisesTotal;
  final int durationMinutes;
  final String? mood;
  final bool sessionCompleted;

  const DailyProgress({
    required this.id,
    required this.date,
    this.exercisesCompleted = 0,
    this.exercisesTotal = 0,
    this.durationMinutes = 0,
    this.mood,
    this.sessionCompleted = false,
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      exercisesCompleted: json['exercises_completed'] as int? ?? 0,
      exercisesTotal: json['exercises_total'] as int? ?? 0,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      mood: json['mood'] as String?,
      sessionCompleted: (json['session_completed'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'exercises_completed': exercisesCompleted,
      'exercises_total': exercisesTotal,
      'duration_minutes': durationMinutes,
      'mood': mood,
      'session_completed': sessionCompleted ? 1 : 0,
    };
  }

  double get completionPercentage =>
      exercisesTotal > 0 ? exercisesCompleted / exercisesTotal : 0;

  @override
  List<Object?> get props => [
        id,
        date,
        exercisesCompleted,
        exercisesTotal,
        durationMinutes,
        mood,
        sessionCompleted,
      ];
}
