import 'package:equatable/equatable.dart';

import 'program_week.dart';

/// Types of dysphagia recovery programs based on condition
enum ProgramType {
  postStroke,
  postSurgery,
  neurological,
  headNeckCancer,
  aging,
}

/// Extension for display properties and program configuration
extension ProgramTypeExtension on ProgramType {
  String get displayName {
    switch (this) {
      case ProgramType.postStroke:
        return 'Post-Stroke Recovery';
      case ProgramType.postSurgery:
        return 'Post-Surgery Rehabilitation';
      case ProgramType.neurological:
        return 'Neurological Conditions';
      case ProgramType.headNeckCancer:
        return 'Head & Neck Cancer';
      case ProgramType.aging:
        return 'Age-Related Changes';
    }
  }

  String get description {
    switch (this) {
      case ProgramType.postStroke:
        return 'Rebuild swallowing function after stroke with targeted exercises';
      case ProgramType.postSurgery:
        return 'Recover from head, neck, or throat surgery procedures';
      case ProgramType.neurological:
        return 'Support for Parkinson\'s, MS, ALS, and other conditions';
      case ProgramType.headNeckCancer:
        return 'Recovery during and after radiation or chemotherapy';
      case ProgramType.aging:
        return 'Strengthen swallowing muscles affected by natural aging';
    }
  }

  String get icon {
    switch (this) {
      case ProgramType.postStroke:
        return '🧠';
      case ProgramType.postSurgery:
        return '🏥';
      case ProgramType.neurological:
        return '🔬';
      case ProgramType.headNeckCancer:
        return '🎗️';
      case ProgramType.aging:
        return '👤';
    }
  }

  /// Program duration in weeks - varies by condition
  int get durationWeeks {
    switch (this) {
      case ProgramType.postStroke:
        return 8;
      case ProgramType.postSurgery:
        return 6;
      case ProgramType.neurological:
        return 12;
      case ProgramType.headNeckCancer:
        return 10;
      case ProgramType.aging:
        return 4;
    }
  }

  /// Number of exercises per week
  int get exercisesPerWeek {
    switch (this) {
      case ProgramType.postStroke:
        return 4;
      case ProgramType.postSurgery:
        return 3;
      case ProgramType.neurological:
        return 5;
      case ProgramType.headNeckCancer:
        return 4;
      case ProgramType.aging:
        return 3;
    }
  }

  /// Focus area for the program
  String get focusArea {
    switch (this) {
      case ProgramType.postStroke:
        return 'Rebuilding neural pathways';
      case ProgramType.postSurgery:
        return 'Healing and strength';
      case ProgramType.neurological:
        return 'Maintaining function';
      case ProgramType.headNeckCancer:
        return 'Radiation recovery';
      case ProgramType.aging:
        return 'Preventive strengthening';
    }
  }

  /// Duration display string
  String get durationDisplay => '$durationWeeks weeks';

  /// Recommended rest days per week (recovery-aware defaults).
  ///
  /// More intensive programs have more rest days to prevent fatigue.
  int get restDaysPerWeek {
    switch (this) {
      case ProgramType.postStroke:
        return 2;
      case ProgramType.postSurgery:
        return 3; // gentler recovery
      case ProgramType.neurological:
        return 2;
      case ProgramType.headNeckCancer:
        return 3; // radiation fatigue
      case ProgramType.aging:
        return 2;
    }
  }

  /// Recommended rest day weekdays (1=Mon … 7=Sun) based on program.
  ///
  /// The default spread keeps rest days evenly spaced.
  List<int> get defaultRestDays {
    switch (restDaysPerWeek) {
      case 3:
        return const [2, 4, 7]; // Tue, Thu, Sun
      case 2:
        return const [4, 7]; // Thu, Sun
      case 1:
        return const [7]; // Sun
      default:
        return const [4, 7];
    }
  }
}

/// Variable-length recovery program
class Program extends Equatable {
  final String id;
  final ProgramType type;
  final List<ProgramWeek> weeks;
  final String? prescribedBy;
  final DateTime startDate;
  final int currentWeek;

  /// Weekdays that are rest days (1=Mon … 7=Sun).
  ///
  /// Defaults to the program type's recommended rest days.
  final List<int> restDays;

  const Program({
    required this.id,
    required this.type,
    required this.weeks,
    this.prescribedBy,
    required this.startDate,
    this.currentWeek = 1,
    this.restDays = const [],
  });

  /// Total duration in weeks
  int get totalWeeks => weeks.length;

  /// Overall completion percentage
  double get overallProgress {
    if (weeks.isEmpty) return 0.0;
    final total = weeks.fold<double>(
      0.0,
      (sum, week) => sum + week.completionPercent,
    );
    return total / weeks.length;
  }

  /// Get current week data
  ProgramWeek? get currentWeekData {
    if (currentWeek < 1 || currentWeek > weeks.length) return null;
    return weeks[currentWeek - 1];
  }

  /// Check if program is complete
  bool get isComplete => overallProgress >= 1.0;

  /// Days remaining in program
  int get daysRemaining {
    final endDate = startDate.add(Duration(days: totalWeeks * 7));
    return endDate.difference(DateTime.now()).inDays.clamp(0, totalWeeks * 7);
  }

  /// Estimated session duration in minutes
  int get estimatedSessionMinutes {
    return type.exercisesPerWeek * 3; // ~3 min per exercise
  }

  /// The effective rest days — uses explicit [restDays] if set,
  /// otherwise falls back to the program type's defaults.
  List<int> get effectiveRestDays =>
      restDays.isNotEmpty ? restDays : type.defaultRestDays;

  /// Whether [date] falls on a scheduled rest day.
  bool isRestDay(DateTime date) => effectiveRestDays.contains(date.weekday);

  /// Whether today is a scheduled rest day.
  bool get isTodayRestDay => isRestDay(DateTime.now());

  /// Active days per week (total 7 minus rest days).
  int get activeDaysPerWeek => 7 - effectiveRestDays.length;

  /// Coach-friendly rest day message.
  String get restDayMessage =>
      'Today is a rest day — your muscles recover and grow stronger while you recharge. '
      'Take it easy and stay hydrated! 💛';

  Program copyWith({
    String? id,
    ProgramType? type,
    List<ProgramWeek>? weeks,
    String? prescribedBy,
    DateTime? startDate,
    int? currentWeek,
    List<int>? restDays,
  }) {
    return Program(
      id: id ?? this.id,
      type: type ?? this.type,
      weeks: weeks ?? this.weeks,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      startDate: startDate ?? this.startDate,
      currentWeek: currentWeek ?? this.currentWeek,
      restDays: restDays ?? this.restDays,
    );
  }

  @override
  List<Object?> get props =>
      [id, type, weeks, prescribedBy, startDate, currentWeek, restDays];

  /// Create a new program for a given type (for fresh starts)
  factory Program.create(ProgramType type, {String? prescribedBy}) {
    final weeks = _generateWeeksForType(type);
    return Program(
      id: 'program_${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      weeks: weeks,
      prescribedBy: prescribedBy,
      startDate: DateTime.now(),
      currentWeek: 1,
    );
  }

  /// Create a sample program with some progress (for demos)
  factory Program.sample(ProgramType type) {
    final weeks = _generateWeeksForType(type, withProgress: true);
    return Program(
      id: 'program_${type.name}',
      type: type,
      weeks: weeks,
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      currentWeek: 3,
    );
  }
}

/// Generate weeks for a specific program type
List<ProgramWeek> _generateWeeksForType(ProgramType type, {bool withProgress = false}) {
  final weekCount = type.durationWeeks;
  final exerciseCount = type.exercisesPerWeek;
  
  final weekConfigs = _getWeekConfigs(type);
  
  return List.generate(weekCount, (index) {
    final weekNum = index + 1;
    final config = weekConfigs[index % weekConfigs.length];
    
    // Generate exercise IDs for this week
    final exerciseIds = List.generate(
      exerciseCount,
      (i) => '${config['prefix']}_exercise_${i + 1}',
    );

    // Calculate progress for sample programs
    double completionPercent = 0.0;
    bool isUnlocked = weekNum == 1;
    
    if (withProgress) {
      if (weekNum < 3) {
        completionPercent = 1.0;
        isUnlocked = true;
      } else if (weekNum == 3) {
        completionPercent = 0.6;
        isUnlocked = true;
      }
    }

    return ProgramWeek(
      weekNumber: weekNum,
      title: config['title'] as String,
      summary: config['summary'] as String,
      focus: config['focus'] as String,
      exerciseIds: exerciseIds,
      isUnlocked: isUnlocked,
      completionPercent: completionPercent,
    );
  });
}

/// Get week configurations based on program type
List<Map<String, String>> _getWeekConfigs(ProgramType type) {
  switch (type) {
    case ProgramType.postStroke:
      return [
        {'prefix': 'stroke', 'title': 'Neural Awakening', 'summary': 'Gentle exercises to reestablish neural connections.', 'focus': 'Basic Swallow Reflex'},
        {'prefix': 'stroke', 'title': 'Foundation Building', 'summary': 'Build foundational swallowing patterns.', 'focus': 'Muscle Activation'},
        {'prefix': 'stroke', 'title': 'Strengthening', 'summary': 'Progressive resistance exercises.', 'focus': 'Muscle Strength'},
        {'prefix': 'stroke', 'title': 'Coordination', 'summary': 'Improve timing and coordination.', 'focus': 'Motor Control'},
        {'prefix': 'stroke', 'title': 'Endurance', 'summary': 'Build stamina for longer meals.', 'focus': 'Fatigue Resistance'},
        {'prefix': 'stroke', 'title': 'Integration', 'summary': 'Combine skills for real eating.', 'focus': 'Functional Practice'},
        {'prefix': 'stroke', 'title': 'Refinement', 'summary': 'Fine-tune your technique.', 'focus': 'Precision'},
        {'prefix': 'stroke', 'title': 'Maintenance', 'summary': 'Long-term success habits.', 'focus': 'Sustainability'},
      ];

    case ProgramType.postSurgery:
      return [
        {'prefix': 'surgery', 'title': 'Gentle Recovery', 'summary': 'Very gentle exercises during healing.', 'focus': 'Tissue Healing'},
        {'prefix': 'surgery', 'title': 'Mobility Return', 'summary': 'Restore range of motion.', 'focus': 'Flexibility'},
        {'prefix': 'surgery', 'title': 'Strength Building', 'summary': 'Gradually rebuild strength.', 'focus': 'Muscle Recovery'},
        {'prefix': 'surgery', 'title': 'Function Focus', 'summary': 'Focus on functional swallowing.', 'focus': 'Daily Function'},
        {'prefix': 'surgery', 'title': 'Integration', 'summary': 'Return to normal eating.', 'focus': 'Diet Progression'},
        {'prefix': 'surgery', 'title': 'Independence', 'summary': 'Achieve eating independence.', 'focus': 'Self-Management'},
      ];

    case ProgramType.neurological:
      return [
        {'prefix': 'neuro', 'title': 'Assessment', 'summary': 'Establish your baseline abilities.', 'focus': 'Baseline'},
        {'prefix': 'neuro', 'title': 'Stabilization', 'summary': 'Maintain current function.', 'focus': 'Function Preservation'},
        {'prefix': 'neuro', 'title': 'Strengthening', 'summary': 'Build compensatory strength.', 'focus': 'Compensation'},
        {'prefix': 'neuro', 'title': 'Coordination', 'summary': 'Improve timing and control.', 'focus': 'Motor Planning'},
        {'prefix': 'neuro', 'title': 'Adaptation', 'summary': 'Learn adaptive strategies.', 'focus': 'Compensatory Strategies'},
        {'prefix': 'neuro', 'title': 'Endurance', 'summary': 'Build fatigue resistance.', 'focus': 'Energy Management'},
        {'prefix': 'neuro', 'title': 'Daily Practice', 'summary': 'Integrate into daily life.', 'focus': 'Routine Building'},
        {'prefix': 'neuro', 'title': 'Advanced Skills', 'summary': 'Master complex techniques.', 'focus': 'Skill Mastery'},
        {'prefix': 'neuro', 'title': 'Maintenance A', 'summary': 'Maintain your progress.', 'focus': 'Consistency'},
        {'prefix': 'neuro', 'title': 'Maintenance B', 'summary': 'Long-term strategies.', 'focus': 'Long-term Health'},
        {'prefix': 'neuro', 'title': 'Refinement', 'summary': 'Fine-tune techniques.', 'focus': 'Optimization'},
        {'prefix': 'neuro', 'title': 'Independence', 'summary': 'Self-management mastery.', 'focus': 'Self-Care'},
      ];

    case ProgramType.headNeckCancer:
      return [
        {'prefix': 'cancer', 'title': 'Gentle Start', 'summary': 'Very gentle exercises during treatment.', 'focus': 'Comfort'},
        {'prefix': 'cancer', 'title': 'Tissue Care', 'summary': 'Exercises that support tissue health.', 'focus': 'Tissue Health'},
        {'prefix': 'cancer', 'title': 'Mobility', 'summary': 'Maintain range of motion.', 'focus': 'Flexibility'},
        {'prefix': 'cancer', 'title': 'Strengthening', 'summary': 'Gentle strength building.', 'focus': 'Muscle Support'},
        {'prefix': 'cancer', 'title': 'Swallow Practice', 'summary': 'Functional swallowing focus.', 'focus': 'Function'},
        {'prefix': 'cancer', 'title': 'Endurance', 'summary': 'Build stamina for meals.', 'focus': 'Energy'},
        {'prefix': 'cancer', 'title': 'Diet Progression', 'summary': 'Progress to varied textures.', 'focus': 'Diet Expansion'},
        {'prefix': 'cancer', 'title': 'Integration', 'summary': 'Return to social eating.', 'focus': 'Quality of Life'},
        {'prefix': 'cancer', 'title': 'Maintenance', 'summary': 'Long-term health habits.', 'focus': 'Sustainability'},
        {'prefix': 'cancer', 'title': 'Thriving', 'summary': 'Living well after treatment.', 'focus': 'Wellness'},
      ];

    case ProgramType.aging:
      return [
        {'prefix': 'aging', 'title': 'Awareness', 'summary': 'Understand your swallowing.', 'focus': 'Self-Awareness'},
        {'prefix': 'aging', 'title': 'Strengthening', 'summary': 'Build preventive strength.', 'focus': 'Prevention'},
        {'prefix': 'aging', 'title': 'Maintenance', 'summary': 'Maintain your abilities.', 'focus': 'Consistency'},
        {'prefix': 'aging', 'title': 'Lifestyle', 'summary': 'Healthy habits for life.', 'focus': 'Healthy Aging'},
      ];
  }
}
