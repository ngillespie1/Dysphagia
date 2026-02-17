import 'package:equatable/equatable.dart';

/// Categories for achievements
enum AchievementCategory {
  streak,
  session,
  milestone,
  consistency,
}

/// The metric an achievement tracks
enum AchievementMetric {
  sessions,
  streak,
  checkIns,
  programProgress, // 0-100 scale (percent)
  weekComplete, // special: 1 = complete
}

/// A single achievement definition + unlock state
class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String hint; // short teaser shown when locked (e.g. "Complete 10 sessions")
  final String icon; // emoji string
  final AchievementCategory category;
  final AchievementMetric metric;
  final int target; // numeric threshold (e.g. 10 sessions, 7-day streak, 25% = 25)
  final DateTime? unlockedAt;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.hint = '',
    this.metric = AchievementMetric.sessions,
    this.target = 1,
    this.unlockedAt,
    this.xpReward = 50,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement unlock() => Achievement(
        id: id,
        name: name,
        description: description,
        hint: hint,
        icon: icon,
        category: category,
        metric: metric,
        target: target,
        unlockedAt: DateTime.now(),
        xpReward: xpReward,
      );

  /// Compute progress toward this achievement (0.0 - 1.0)
  double progressFor({
    int totalSessions = 0,
    int currentStreak = 0,
    int totalCheckIns = 0,
    double programProgress = 0.0,
  }) {
    if (isUnlocked) return 1.0;
    final current = _currentValueFor(
      totalSessions: totalSessions,
      currentStreak: currentStreak,
      totalCheckIns: totalCheckIns,
      programProgress: programProgress,
    );
    return (current / target).clamp(0.0, 1.0);
  }

  /// Current raw value for progress display (e.g. "3 / 7")
  int currentValueFor({
    int totalSessions = 0,
    int currentStreak = 0,
    int totalCheckIns = 0,
    double programProgress = 0.0,
  }) {
    return _currentValueFor(
      totalSessions: totalSessions,
      currentStreak: currentStreak,
      totalCheckIns: totalCheckIns,
      programProgress: programProgress,
    ).clamp(0, target);
  }

  int _currentValueFor({
    required int totalSessions,
    required int currentStreak,
    required int totalCheckIns,
    required double programProgress,
  }) {
    switch (metric) {
      case AchievementMetric.sessions:
        return totalSessions;
      case AchievementMetric.streak:
        return currentStreak;
      case AchievementMetric.checkIns:
        return totalCheckIns;
      case AchievementMetric.programProgress:
        return (programProgress * 100).round();
      case AchievementMetric.weekComplete:
        return 0; // tracked separately
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'category': category.name,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'xpReward': xpReward,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final def = AchievementDefinitions.getById(json['id'] as String);
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String? ?? def?.name ?? '',
      description: json['description'] as String? ?? def?.description ?? '',
      hint: def?.hint ?? '',
      icon: json['icon'] as String? ?? def?.icon ?? '🔒',
      category: AchievementCategory.values.byName(
        json['category'] as String? ?? def?.category.name ?? 'session',
      ),
      metric: def?.metric ?? AchievementMetric.sessions,
      target: def?.target ?? 1,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      xpReward: json['xpReward'] as int? ?? 50,
    );
  }

  @override
  List<Object?> get props => [id, unlockedAt];
}

/// Hardcoded achievement definitions
class AchievementDefinitions {
  static const List<Achievement> all = [
    // ── Session milestones ──
    Achievement(
      id: 'first_session',
      name: 'First Steps',
      description: 'Complete your very first session',
      hint: 'Complete your first session',
      icon: '🌱',
      category: AchievementCategory.session,
      metric: AchievementMetric.sessions,
      target: 1,
      xpReward: 25,
    ),
    Achievement(
      id: 'sessions_10',
      name: 'Getting Stronger',
      description: 'Complete 10 sessions',
      hint: 'Complete 10 sessions',
      icon: '💪',
      category: AchievementCategory.session,
      metric: AchievementMetric.sessions,
      target: 10,
      xpReward: 75,
    ),
    Achievement(
      id: 'sessions_25',
      name: 'Dedicated',
      description: 'Complete 25 sessions',
      hint: 'Complete 25 sessions',
      icon: '⭐',
      category: AchievementCategory.session,
      metric: AchievementMetric.sessions,
      target: 25,
      xpReward: 150,
    ),
    Achievement(
      id: 'sessions_50',
      name: 'Half Century',
      description: 'Complete 50 sessions',
      hint: 'Complete 50 sessions',
      icon: '🏅',
      category: AchievementCategory.session,
      metric: AchievementMetric.sessions,
      target: 50,
      xpReward: 300,
    ),
    Achievement(
      id: 'sessions_100',
      name: 'Century Club',
      description: 'Complete 100 sessions',
      hint: 'Complete 100 sessions',
      icon: '🏆',
      category: AchievementCategory.session,
      metric: AchievementMetric.sessions,
      target: 100,
      xpReward: 500,
    ),

    // ── Streak achievements ──
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      hint: 'Keep a 7-day streak going',
      icon: '🔥',
      category: AchievementCategory.streak,
      metric: AchievementMetric.streak,
      target: 7,
      xpReward: 100,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Monthly Master',
      description: 'Maintain a 30-day streak',
      hint: 'Keep a 30-day streak going',
      icon: '🌟',
      category: AchievementCategory.streak,
      metric: AchievementMetric.streak,
      target: 30,
      xpReward: 500,
    ),

    // ── Milestone achievements ──
    Achievement(
      id: 'first_checkin',
      name: 'Self-Aware',
      description: 'Complete your first symptom check-in',
      hint: 'Do your first check-in',
      icon: '📝',
      category: AchievementCategory.milestone,
      metric: AchievementMetric.checkIns,
      target: 1,
      xpReward: 25,
    ),
    Achievement(
      id: 'week_complete',
      name: 'Week Complete',
      description: 'Complete all sessions in a program week',
      hint: 'Finish a full program week',
      icon: '📅',
      category: AchievementCategory.milestone,
      metric: AchievementMetric.weekComplete,
      target: 1,
      xpReward: 100,
    ),

    // ── Program milestones ──
    Achievement(
      id: 'program_25',
      name: 'Quarter Way',
      description: 'Reach 25% program completion',
      hint: 'Reach 25% of your program',
      icon: '🎯',
      category: AchievementCategory.milestone,
      metric: AchievementMetric.programProgress,
      target: 25,
      xpReward: 75,
    ),
    Achievement(
      id: 'program_50',
      name: 'Halfway There',
      description: 'Reach 50% program completion',
      hint: 'Reach 50% of your program',
      icon: '🚀',
      category: AchievementCategory.milestone,
      metric: AchievementMetric.programProgress,
      target: 50,
      xpReward: 150,
    ),
    Achievement(
      id: 'program_75',
      name: 'Almost There',
      description: 'Reach 75% program completion',
      hint: 'Reach 75% of your program',
      icon: '💫',
      category: AchievementCategory.milestone,
      metric: AchievementMetric.programProgress,
      target: 75,
      xpReward: 250,
    ),
    Achievement(
      id: 'program_100',
      name: 'Recovery Champion',
      description: 'Complete your entire program',
      hint: 'Complete your entire program',
      icon: '👑',
      category: AchievementCategory.milestone,
      metric: AchievementMetric.programProgress,
      target: 100,
      xpReward: 1000,
    ),

    // ── Consistency ──
    Achievement(
      id: 'consistency_5_checkins',
      name: 'Tracking Pro',
      description: 'Complete 5 symptom check-ins',
      hint: 'Do 5 symptom check-ins',
      icon: '📊',
      category: AchievementCategory.consistency,
      metric: AchievementMetric.checkIns,
      target: 5,
      xpReward: 50,
    ),
  ];

  /// Get achievement definition by id
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
