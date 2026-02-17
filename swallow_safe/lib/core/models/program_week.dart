import 'package:equatable/equatable.dart';

/// Represents a single week in the 8-week program
class ProgramWeek extends Equatable {
  final int weekNumber;
  final String title;
  final String summary;
  final String focus;
  final List<String> exerciseIds;
  final bool isUnlocked;
  final double completionPercent;

  const ProgramWeek({
    required this.weekNumber,
    required this.title,
    required this.summary,
    required this.focus,
    required this.exerciseIds,
    this.isUnlocked = false,
    this.completionPercent = 0.0,
  });

  /// Status of the week
  WeekStatus get status {
    if (completionPercent >= 1.0) return WeekStatus.completed;
    if (completionPercent > 0) return WeekStatus.inProgress;
    if (isUnlocked) return WeekStatus.available;
    return WeekStatus.locked;
  }

  /// Number of exercises in this week
  int get exerciseCount => exerciseIds.length;

  /// Number of completed exercises
  int get completedExercises => (exerciseCount * completionPercent).round();

  /// Display label for the week
  String get label => 'Week $weekNumber';

  /// Short display for timeline
  String get shortLabel => 'W$weekNumber';

  ProgramWeek copyWith({
    int? weekNumber,
    String? title,
    String? summary,
    String? focus,
    List<String>? exerciseIds,
    bool? isUnlocked,
    double? completionPercent,
  }) {
    return ProgramWeek(
      weekNumber: weekNumber ?? this.weekNumber,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      focus: focus ?? this.focus,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      completionPercent: completionPercent ?? this.completionPercent,
    );
  }

  @override
  List<Object?> get props => [
        weekNumber,
        title,
        summary,
        focus,
        exerciseIds,
        isUnlocked,
        completionPercent,
      ];
}

/// Status of a program week
enum WeekStatus {
  locked,
  available,
  inProgress,
  completed,
}

extension WeekStatusExtension on WeekStatus {
  bool get isAccessible => this != WeekStatus.locked;
  
  bool get showProgress => this == WeekStatus.inProgress || this == WeekStatus.completed;
}
