import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_profile.dart';
import '../models/session.dart';

/// Repository for managing user data
class UserRepository {
  static const String _userBoxName = 'user_data';
  static const String _sessionsBoxName = 'sessions';
  static const String _profileKey = 'profile';
  
  Box<dynamic>? _userBox;
  Box<dynamic>? _sessionsBox;
  
  /// Initialize Hive boxes
  Future<void> initialize() async {
    _userBox = await Hive.openBox(_userBoxName);
    _sessionsBox = await Hive.openBox(_sessionsBoxName);
  }
  
  /// Get current user profile
  Future<UserProfile> getUserProfile() async {
    if (_userBox == null) await initialize();
    
    final data = _userBox?.get(_profileKey);
    if (data != null) {
      return UserProfile.fromJson(Map<String, dynamic>.from(data));
    }
    
    // Return default profile if none exists
    return UserProfile(
      id: 'local_user',
      createdAt: DateTime.now(),
    );
  }
  
  /// Save user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    if (_userBox == null) await initialize();
    await _userBox?.put(_profileKey, profile.toJson());
  }
  
  /// Get streak data
  Future<StreakData> getStreakData() async {
    final profile = await getUserProfile();
    return profile.streakData;
  }
  
  /// Update streak after session completion
  Future<StreakData> updateStreakOnCompletion() async {
    final profile = await getUserProfile();
    final now = DateTime.now();
    final streak = profile.streakData;
    
    // Check if already completed today
    if (streak.completedToday) {
      return streak;
    }
    
    int newStreak;
    if (streak.isStreakActive) {
      // Continue streak
      newStreak = streak.currentStreak + 1;
    } else {
      // Start new streak
      newStreak = 1;
    }
    
    final newStreakData = StreakData(
      currentStreak: newStreak,
      longestStreak: newStreak > streak.longestStreak ? newStreak : streak.longestStreak,
      totalSessions: streak.totalSessions + 1,
      lastCompletedAt: now,
    );
    
    final updatedProfile = profile.copyWith(streakData: newStreakData);
    await saveUserProfile(updatedProfile);
    
    return newStreakData;
  }
  
  /// Save a completed session
  Future<void> saveSession(Session session) async {
    if (_sessionsBox == null) await initialize();
    await _sessionsBox?.put(session.id, session.toJson());
  }
  
  /// Get all sessions
  Future<List<Session>> getAllSessions() async {
    if (_sessionsBox == null) await initialize();
    
    final sessions = <Session>[];
    for (final key in _sessionsBox?.keys ?? []) {
      final data = _sessionsBox?.get(key);
      if (data != null) {
        sessions.add(Session.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }
  
  /// Get sessions for a specific date range
  Future<List<Session>> getSessionsInRange(DateTime start, DateTime end) async {
    final allSessions = await getAllSessions();
    return allSessions.where((s) {
      return s.completedAt.isAfter(start) && s.completedAt.isBefore(end);
    }).toList();
  }
  
  /// Get sessions for this week
  Future<List<Session>> getThisWeekSessions() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return getSessionsInRange(start, now.add(const Duration(days: 1)));
  }
  
  /// Get sessions for this month
  Future<List<Session>> getThisMonthSessions() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return getSessionsInRange(start, now.add(const Duration(days: 1)));
  }
  
  /// Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    final profile = await getUserProfile();
    final updatedProfile = profile.copyWith(notificationSettings: settings);
    await saveUserProfile(updatedProfile);
  }
}
