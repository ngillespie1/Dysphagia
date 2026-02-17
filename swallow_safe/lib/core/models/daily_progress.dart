import 'package:equatable/equatable.dart';

/// Represents daily exercise progress
class DailyProgress extends Equatable {
  final DateTime date;
  final int exercisesCompleted;
  final int exercisesTotal;
  final int durationMinutes;
  final Mood? mood;
  final String? notes;
  final bool sessionCompleted;

  const DailyProgress({
    required this.date,
    this.exercisesCompleted = 0,
    this.exercisesTotal = 0,
    this.durationMinutes = 0,
    this.mood,
    this.notes,
    this.sessionCompleted = false,
  });

  /// Get date key for storage
  String get dateKey => 
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Completion percentage
  double get completionPercent {
    if (exercisesTotal == 0) return 0;
    return exercisesCompleted / exercisesTotal;
  }

  /// Whether user practiced today
  bool get hasPracticed => exercisesCompleted > 0;

  /// Check if this is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  DailyProgress copyWith({
    DateTime? date,
    int? exercisesCompleted,
    int? exercisesTotal,
    int? durationMinutes,
    Mood? mood,
    String? notes,
    bool? sessionCompleted,
  }) {
    return DailyProgress(
      date: date ?? this.date,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      exercisesTotal: exercisesTotal ?? this.exercisesTotal,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      sessionCompleted: sessionCompleted ?? this.sessionCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'exercisesCompleted': exercisesCompleted,
      'exercisesTotal': exercisesTotal,
      'durationMinutes': durationMinutes,
      'mood': mood?.name,
      'notes': notes,
      'sessionCompleted': sessionCompleted,
    };
  }

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date'] as String),
      exercisesCompleted: json['exercisesCompleted'] as int? ?? 0,
      exercisesTotal: json['exercisesTotal'] as int? ?? 0,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      mood: json['mood'] != null 
          ? Mood.values.firstWhere(
              (m) => m.name == json['mood'],
              orElse: () => Mood.okay,
            )
          : null,
      notes: json['notes'] as String?,
      sessionCompleted: json['sessionCompleted'] as bool? ?? false,
    );
  }

  /// Create empty progress for a date
  factory DailyProgress.empty(DateTime date) {
    return DailyProgress(date: date);
  }

  @override
  List<Object?> get props => [
        date,
        exercisesCompleted,
        exercisesTotal,
        durationMinutes,
        mood,
        notes,
        sessionCompleted,
      ];
}

/// Mood levels for daily tracking
enum Mood {
  veryBad,
  bad,
  okay,
  good,
  great,
}

extension MoodExtension on Mood {
  String get emoji {
    switch (this) {
      case Mood.veryBad:
        return '😢';
      case Mood.bad:
        return '😕';
      case Mood.okay:
        return '😐';
      case Mood.good:
        return '😊';
      case Mood.great:
        return '😁';
    }
  }

  String get label {
    switch (this) {
      case Mood.veryBad:
        return 'Very Bad';
      case Mood.bad:
        return 'Bad';
      case Mood.okay:
        return 'Okay';
      case Mood.good:
        return 'Good';
      case Mood.great:
        return 'Great';
    }
  }

  int get value {
    switch (this) {
      case Mood.veryBad:
        return 1;
      case Mood.bad:
        return 2;
      case Mood.okay:
        return 3;
      case Mood.good:
        return 4;
      case Mood.great:
        return 5;
    }
  }
}
