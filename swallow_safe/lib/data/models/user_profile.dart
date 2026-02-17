import 'package:equatable/equatable.dart';

/// User profile and streak data
class UserProfile extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String currentProgramId;
  final bool disclaimerAccepted;
  final DateTime? disclaimerAcceptedAt;
  final DateTime createdAt;
  final StreakData streakData;
  final NotificationSettings notificationSettings;
  
  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.currentProgramId = 'hnc_recovery_level_1',
    this.disclaimerAccepted = false,
    this.disclaimerAcceptedAt,
    required this.createdAt,
    this.streakData = const StreakData(),
    this.notificationSettings = const NotificationSettings(),
  });
  
  /// Create from JSON (Firestore document)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      email: json['email'] as String?,
      currentProgramId: json['current_program_id'] as String? ?? 'hnc_recovery_level_1',
      disclaimerAccepted: json['disclaimer_accepted'] as bool? ?? false,
      disclaimerAcceptedAt: json['disclaimer_accepted_at'] != null
          ? DateTime.parse(json['disclaimer_accepted_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      streakData: json['streak_data'] != null
          ? StreakData.fromJson(json['streak_data'] as Map<String, dynamic>)
          : const StreakData(),
      notificationSettings: json['notification_settings'] != null
          ? NotificationSettings.fromJson(
              json['notification_settings'] as Map<String, dynamic>)
          : const NotificationSettings(),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'current_program_id': currentProgramId,
      'disclaimer_accepted': disclaimerAccepted,
      'disclaimer_accepted_at': disclaimerAcceptedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'streak_data': streakData.toJson(),
      'notification_settings': notificationSettings.toJson(),
    };
  }
  
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? currentProgramId,
    bool? disclaimerAccepted,
    DateTime? disclaimerAcceptedAt,
    DateTime? createdAt,
    StreakData? streakData,
    NotificationSettings? notificationSettings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currentProgramId: currentProgramId ?? this.currentProgramId,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      disclaimerAcceptedAt: disclaimerAcceptedAt ?? this.disclaimerAcceptedAt,
      createdAt: createdAt ?? this.createdAt,
      streakData: streakData ?? this.streakData,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    email,
    currentProgramId,
    disclaimerAccepted,
    disclaimerAcceptedAt,
    createdAt,
    streakData,
    notificationSettings,
  ];
}

/// Streak tracking data
class StreakData extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final DateTime? lastCompletedAt;
  
  const StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.lastCompletedAt,
  });
  
  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      lastCompletedAt: json['last_completed_at'] != null
          ? DateTime.parse(json['last_completed_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_sessions': totalSessions,
      'last_completed_at': lastCompletedAt?.toIso8601String(),
    };
  }
  
  /// Check if user completed today
  bool get completedToday {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    return lastCompletedAt!.year == now.year &&
        lastCompletedAt!.month == now.month &&
        lastCompletedAt!.day == now.day;
  }
  
  /// Check if streak is still active (completed yesterday or today)
  bool get isStreakActive {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return completedToday ||
        (lastCompletedAt!.year == yesterday.year &&
            lastCompletedAt!.month == yesterday.month &&
            lastCompletedAt!.day == yesterday.day);
  }
  
  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalSessions,
    DateTime? lastCompletedAt,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    currentStreak,
    longestStreak,
    totalSessions,
    lastCompletedAt,
  ];
}

/// User notification preferences
class NotificationSettings extends Equatable {
  final bool enabled;
  final List<int> reminderHours; // Hours in 24h format
  
  const NotificationSettings({
    this.enabled = true,
    this.reminderHours = const [9, 14, 19], // 9am, 2pm, 7pm
  });
  
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      reminderHours: (json['reminder_hours'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? const [9, 14, 19],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'reminder_hours': reminderHours,
    };
  }
  
  @override
  List<Object?> get props => [enabled, reminderHours];
}
