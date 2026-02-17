import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional imports for database (sqflite not available on web)
import '../database/database_service_stub.dart' if (dart.library.io) '../database/database_service.dart';
import '../database/repositories/user_repository_stub.dart' if (dart.library.io) '../database/repositories/user_repository.dart' as db_user_repo;
import '../database/repositories/progress_repository_stub.dart' if (dart.library.io) '../database/repositories/progress_repository.dart' as db_progress_repo;
import '../database/repositories/checkin_repository_stub.dart' if (dart.library.io) '../database/repositories/checkin_repository.dart' as db_checkin_repo;
import '../database/repositories/chat_repository_stub.dart' if (dart.library.io) '../database/repositories/chat_repository.dart' as db_chat_repo;

import '../../data/models/achievement.dart';
import '../../data/models/appointment.dart';
import '../../data/models/care_team_member.dart';
import '../../data/models/check_in.dart';
import '../../data/models/daily_progress.dart';
import '../../data/models/food_entry.dart';
import '../../data/models/mood_entry.dart';
import '../../data/models/streak_data.dart';
import '../../data/models/user_level.dart';

/// Unified data service that coordinates all repositories.
///
/// Returns **typed models** instead of raw `Map<String, dynamic>`.
/// The underlying DB repositories still traffic in maps; conversion happens
/// here so that consumers never deal with untyped data.
///
/// On web, uses in-memory storage since sqflite doesn't support web.
class DataSyncService {
  final DatabaseService? _db;

  dynamic userRepo;
  dynamic progressRepo;
  dynamic checkInRepo;
  dynamic chatRepo;

  String? _currentUserId;

  // Web fallback – in-memory storage
  final bool _isWeb = kIsWeb;
  Map<String, dynamic>? _webUser;
  final List<Map<String, dynamic>> _webProgress = [];
  final List<Map<String, dynamic>> _webCheckIns = [];

  // Gamification in-memory storage (works on both web and native)
  final Map<String, Achievement> _unlockedAchievements = {};
  UserLevel _userLevel = const UserLevel();

  // Food diary & hydration in-memory storage
  final List<FoodEntry> _foodEntries = [];
  final Map<String, HydrationEntry> _hydrationEntries = {};

  // Care team & appointments in-memory storage
  final List<CareTeamMember> _careTeamMembers = [];
  final List<Appointment> _appointments = [];

  DataSyncService(this._db) {
    if (!_isWeb && _db != null) {
      userRepo = db_user_repo.UserRepository(_db!);
      progressRepo = db_progress_repo.ProgressRepository(_db!);
      checkInRepo = db_checkin_repo.CheckInRepository(_db!);
      chatRepo = db_chat_repo.ChatRepository(_db!);
    }
  }

  /// Initialize and load current user
  Future<void> initialize() async {
    if (_isWeb) {
      _currentUserId = _webUser?['id'] as String?;
      return;
    }
    if (userRepo != null) {
      final user = await userRepo!.getCurrentUser();
      _currentUserId = user?['id'] as String?;
    }
  }

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Check if user is logged in
  bool get hasUser => _isWeb ? _webUser != null : _currentUserId != null;

  // ============ User Operations ============

  /// Get current user data as a raw map.
  ///
  /// User data is already represented by [UserProfile] in the domain layer.
  /// We keep this as a map for backward-compat with the DB layer.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_isWeb) return _webUser;
    return await userRepo?.getCurrentUser();
  }

  /// Create new user during onboarding
  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    String? programType,
  }) async {
    if (_isWeb) {
      _webUser = {
        'id': 'web_user_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'email': email,
        'program_type': programType,
        'program_start_date': DateTime.now().toIso8601String(),
        'notification_enabled': 1,
        'notification_times': '["09:00","14:00","19:00"]',
        'subscription_tier': 'free',
        'onboarding_complete': 0,
        'created_at': DateTime.now().toIso8601String(),
      };
      _currentUserId = _webUser!['id'] as String;
      return _webUser!;
    }

    final user = await userRepo!.createUser(
      name: name,
      email: email,
      programType: programType,
    );
    _currentUserId = user['id'] as String;
    return user;
  }

  /// Update user name
  Future<void> updateUserName(String name) async {
    if (_isWeb) {
      _webUser?['name'] = name;
      return;
    }
    if (_currentUserId == null) return;
    await userRepo?.updateName(_currentUserId!, name);
  }

  /// Update user program
  Future<void> updateUserProgram(String programType) async {
    if (_isWeb) {
      _webUser?['program_type'] = programType;
      _webUser?['program_start_date'] = DateTime.now().toIso8601String();
      return;
    }
    if (_currentUserId == null) return;
    await userRepo?.updateProgram(_currentUserId!, programType);
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    if (_isWeb) {
      _webUser?['onboarding_complete'] = 1;
      return;
    }
    if (_currentUserId == null) return;
    await userRepo?.completeOnboarding(_currentUserId!);
  }

  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    if (_isWeb) return _webUser?['onboarding_complete'] == 1;
    return await userRepo?.isOnboardingComplete() ?? false;
  }

  /// Logout user
  Future<void> logout() async {
    if (_isWeb) {
      _webUser = null;
      _webProgress.clear();
      _webCheckIns.clear();
      _currentUserId = null;
      return;
    }
    if (_currentUserId != null && userRepo != null) {
      await userRepo!.deleteUser(_currentUserId!);
    }
    _currentUserId = null;
  }

  // ============ Progress Operations ============

  /// Get today's progress as a typed [DailyProgress].
  Future<DailyProgress?> getTodayProgress() async {
    Map<String, dynamic>? raw;
    if (_isWeb) {
      final today = _dateToKey(DateTime.now());
      raw = _webProgress.cast<Map<String, dynamic>?>().firstWhere(
            (p) => p?['date'] == today,
            orElse: () => null,
          );
    } else if (_currentUserId != null) {
      raw = await progressRepo?.getTodayProgress(_currentUserId!);
    }
    return raw != null ? DailyProgress.fromJson(raw) : null;
  }

  /// Get this week's progress.
  Future<List<DailyProgress>> getThisWeekProgress() async {
    List<Map<String, dynamic>> raw;
    if (_isWeb) {
      raw = _webProgress;
    } else if (_currentUserId != null) {
      raw = await progressRepo?.getThisWeekProgress(_currentUserId!) ?? [];
    } else {
      raw = [];
    }
    return raw.map((m) => DailyProgress.fromJson(m)).toList();
  }

  /// Get week completed days count
  Future<int> getWeekCompletedDays() async {
    if (_isWeb) {
      return _webProgress
          .where((p) => p['session_completed'] == 1)
          .length;
    }
    if (_currentUserId == null) return 0;
    return await progressRepo?.getWeekCompletedDays(_currentUserId!) ?? 0;
  }

  /// Get progress for date range.
  Future<List<DailyProgress>> getProgressInRange(
    DateTime start,
    DateTime end,
  ) async {
    List<Map<String, dynamic>> raw;
    if (_isWeb) {
      raw = _webProgress;
    } else if (_currentUserId != null) {
      raw = await progressRepo?.getProgressInRange(
              _currentUserId!, start, end) ??
          [];
    } else {
      raw = [];
    }
    return raw.map((m) => DailyProgress.fromJson(m)).toList();
  }

  /// Complete today's session
  Future<void> completeSession({
    required int exercisesCompleted,
    required int exercisesTotal,
    required int durationMinutes,
    String? mood,
  }) async {
    if (_isWeb) {
      _webProgress.add({
        'id': 'prog_${DateTime.now().millisecondsSinceEpoch}',
        'date': _dateToKey(DateTime.now()),
        'exercises_completed': exercisesCompleted,
        'exercises_total': exercisesTotal,
        'duration_minutes': durationMinutes,
        'mood': mood,
        'session_completed': 1,
      });
      return;
    }
    if (_currentUserId == null) return;
    await progressRepo?.completeSession(
      _currentUserId!,
      exercisesCompleted: exercisesCompleted,
      exercisesTotal: exercisesTotal,
      durationMinutes: durationMinutes,
      mood: mood,
    );
  }

  /// Get streak data as a typed [StreakInfo].
  ///
  /// When [restDayWeekdays] is provided, scheduled rest days will not
  /// break the streak — they are skipped during gap analysis.
  Future<StreakInfo> getStreakData({
    List<int> restDayWeekdays = const [],
  }) async {
    Map<String, dynamic> raw;
    if (_isWeb) {
      final completed =
          _webProgress.where((p) => p['session_completed'] == 1).length;
      raw = {
        'currentStreak': completed,
        'longestStreak': completed,
        'totalSessions': completed,
      };
    } else if (_currentUserId != null) {
      raw = await progressRepo?.getStreakData(
            _currentUserId!,
            restDayWeekdays: restDayWeekdays,
          ) ??
          {'currentStreak': 0, 'longestStreak': 0, 'totalSessions': 0};
    } else {
      raw = {'currentStreak': 0, 'longestStreak': 0, 'totalSessions': 0};
    }
    return StreakInfo.fromJson(raw);
  }

  // ============ Check-in Operations ============

  /// Get today's check-in as a typed [CheckIn].
  Future<CheckIn?> getTodayCheckIn() async {
    Map<String, dynamic>? raw;
    if (_isWeb) {
      final today = _dateToKey(DateTime.now());
      raw = _webCheckIns.cast<Map<String, dynamic>?>().firstWhere(
            (c) => c?['date'] == today,
            orElse: () => null,
          );
    } else if (_currentUserId != null) {
      raw = await checkInRepo?.getTodayCheckIn(_currentUserId!);
    }
    return raw != null ? CheckIn.fromJson(raw) : null;
  }

  /// Get recent check-ins as typed [CheckIn] list.
  Future<List<CheckIn>> getRecentCheckIns({int limit = 7}) async {
    List<Map<String, dynamic>> raw;
    if (_isWeb) {
      raw = _webCheckIns.take(limit).toList();
    } else if (_currentUserId != null) {
      raw = await checkInRepo?.getRecentCheckIns(
              _currentUserId!,
              limit: limit) ??
          [];
    } else {
      raw = [];
    }
    return raw.map((m) => CheckIn.fromJson(m)).toList();
  }

  /// Save check-in
  Future<void> saveCheckIn({
    required int painLevel,
    required int swallowingEase,
    required int dryMouth,
    String? overallFeeling,
    String? notes,
  }) async {
    if (_isWeb) {
      _webCheckIns.insert(0, {
        'id': 'checkin_${DateTime.now().millisecondsSinceEpoch}',
        'date': _dateToKey(DateTime.now()),
        'pain_level': painLevel,
        'swallowing_ease': swallowingEase,
        'dry_mouth': dryMouth,
        'overall_feeling': overallFeeling,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }
    if (_currentUserId == null) return;
    await checkInRepo?.saveCheckIn(
      userId: _currentUserId!,
      painLevel: painLevel,
      swallowingEase: swallowingEase,
      dryMouth: dryMouth,
      overallFeeling: overallFeeling,
      notes: notes,
    );
  }

  /// Get weekly mood data for visualization.
  Future<List<MoodEntry>> getWeeklyMoodData() async {
    List<Map<String, dynamic>> raw;
    if (_isWeb) {
      raw = List.generate(
        7,
        (i) => {
          'date':
              _dateToKey(DateTime.now().subtract(Duration(days: 6 - i))),
          'mood': null,
          'hasCheckIn': false,
        },
      );
    } else if (_currentUserId != null) {
      raw = await checkInRepo?.getWeeklyMoodData(_currentUserId!) ?? [];
    } else {
      raw = [];
    }
    return raw.map((m) => MoodEntry.fromJson(m)).toList();
  }

  // ============ Chat Operations ============

  /// Get chat messages (raw maps – ChatMessage model handles its own conversion)
  Future<List<Map<String, dynamic>>> getChatMessages() async {
    if (_isWeb) return [];
    if (_currentUserId == null) return [];
    return await chatRepo?.getMessages(_currentUserId!) ?? [];
  }

  /// Add chat message
  Future<void> addChatMessage({
    required String content,
    required bool isUser,
  }) async {
    if (_isWeb) return;
    if (_currentUserId == null) return;
    await chatRepo?.addMessage(
      userId: _currentUserId!,
      content: content,
      isUser: isUser,
    );
  }

  /// Clear chat
  Future<void> clearChat() async {
    if (_isWeb) return;
    if (_currentUserId == null) return;
    await chatRepo?.clearMessages(_currentUserId!);
  }

  // ============ Notification Settings ============

  /// Update notification settings
  Future<void> updateNotificationSettings({
    required bool enabled,
    required List<String> times,
  }) async {
    if (_isWeb) {
      _webUser?['notification_enabled'] = enabled ? 1 : 0;
      _webUser?['notification_times'] = times.toString();
      return;
    }
    if (_currentUserId == null) return;
    await userRepo?.updateNotificationSettings(
      _currentUserId!,
      enabled: enabled,
      times: times,
    );
  }

  /// Get notification times
  Future<List<String>> getNotificationTimes() async {
    if (_isWeb) return ['09:00', '14:00', '19:00'];
    if (_currentUserId == null) return ['09:00', '14:00', '19:00'];
    return await userRepo?.getNotificationTimes(_currentUserId!) ??
        ['09:00', '14:00', '19:00'];
  }

  // ============ Gamification ============

  /// Get current user level
  UserLevel getUserLevel() => _userLevel;

  /// Add XP and return new level + whether leveled up
  ({UserLevel newLevel, bool leveledUp}) addXP(int amount) {
    final result = _userLevel.addXP(amount);
    _userLevel = result.newLevel;
    return result;
  }

  /// Get all unlocked achievements
  List<Achievement> getUnlockedAchievements() =>
      _unlockedAchievements.values.toList();

  /// Check if an achievement is already unlocked
  bool isAchievementUnlocked(String id) =>
      _unlockedAchievements.containsKey(id);

  /// Unlock an achievement. Returns the unlocked achievement or null if already unlocked.
  Achievement? unlockAchievement(String achievementId) {
    if (_unlockedAchievements.containsKey(achievementId)) return null;

    final def = AchievementDefinitions.getById(achievementId);
    if (def == null) return null;

    final unlocked = def.unlock();
    _unlockedAchievements[achievementId] = unlocked;
    return unlocked;
  }

  /// Get full achievements list (definitions + unlock state merged)
  List<Achievement> getAllAchievements() {
    return AchievementDefinitions.all.map((def) {
      return _unlockedAchievements[def.id] ?? def;
    }).toList();
  }

  /// Get total session count from streak data
  Future<int> getTotalSessionCount() async {
    final streak = await getStreakData();
    return streak.totalSessions;
  }

  /// Get total check-in count
  Future<int> getTotalCheckInCount() async {
    if (_isWeb) return _webCheckIns.length;
    if (_currentUserId != null) {
      final checkIns = await checkInRepo?.getRecentCheckIns(
              _currentUserId!, limit: 999) ??
          [];
      return (checkIns as List).length;
    }
    return 0;
  }

  // ============ Food Diary Operations ============

  /// Add a food diary entry
  Future<void> addFoodEntry(FoodEntry entry) async {
    _foodEntries.add(entry);
  }

  /// Get food entries for a specific date
  List<FoodEntry> getFoodEntriesForDate(DateTime date) {
    final key = _dateToKey(date);
    return _foodEntries.where((e) => e.dateKey == key).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get food entries for a date range (for charts)
  List<FoodEntry> getFoodEntriesInRange(DateTime start, DateTime end) {
    return _foodEntries
        .where((e) =>
            e.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
            e.timestamp.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Delete a food entry
  Future<void> deleteFoodEntry(String id) async {
    _foodEntries.removeWhere((e) => e.id == id);
  }

  /// Get today's food entry count
  int get todayFoodEntryCount => getFoodEntriesForDate(DateTime.now()).length;

  // ============ Hydration Operations ============

  /// Get today's hydration
  HydrationEntry getTodayHydration() {
    final key = _dateToKey(DateTime.now());
    return _hydrationEntries[key] ?? HydrationEntry(date: key);
  }

  /// Add a glass of water
  Future<HydrationEntry> addGlass() async {
    final key = _dateToKey(DateTime.now());
    final current = _hydrationEntries[key] ?? HydrationEntry(date: key);
    final updated = current.addGlass();
    _hydrationEntries[key] = updated;
    return updated;
  }

  /// Remove a glass of water
  Future<HydrationEntry> removeGlass() async {
    final key = _dateToKey(DateTime.now());
    final current = _hydrationEntries[key] ?? HydrationEntry(date: key);
    final updated = current.removeGlass();
    _hydrationEntries[key] = updated;
    return updated;
  }

  /// Get hydration for a date range
  List<HydrationEntry> getHydrationInRange(DateTime start, DateTime end) {
    final entries = <HydrationEntry>[];
    var current = start;
    while (!current.isAfter(end)) {
      final key = _dateToKey(current);
      entries.add(_hydrationEntries[key] ?? HydrationEntry(date: key));
      current = current.add(const Duration(days: 1));
    }
    return entries;
  }

  // ============ Care Team Operations ============

  /// Get all care team members
  List<CareTeamMember> get careTeamMembers =>
      List.unmodifiable(_careTeamMembers);

  /// Add a care team member
  Future<void> addCareTeamMember(CareTeamMember member) async {
    _careTeamMembers.add(member);
  }

  /// Remove a care team member
  Future<void> removeCareTeamMember(String id) async {
    _careTeamMembers.removeWhere((m) => m.id == id);
  }

  // ============ Appointment Operations ============

  /// Get all appointments
  List<Appointment> get allAppointments =>
      List.unmodifiable(_appointments)
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  /// Get upcoming appointments
  List<Appointment> get upcomingAppointments => _appointments
      .where((a) => a.isUpcoming && !a.isCompleted)
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  /// Get today's appointments
  List<Appointment> get todayAppointments =>
      _appointments.where((a) => a.isToday).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  /// Add an appointment
  Future<void> addAppointment(Appointment appointment) async {
    _appointments.add(appointment);
  }

  /// Remove an appointment
  Future<void> removeAppointment(String id) async {
    _appointments.removeWhere((a) => a.id == id);
  }

  /// Mark an appointment as completed
  Future<void> completeAppointment(String id) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _appointments[index] = _appointments[index].copyWith(isCompleted: true);
    }
  }

  // ============ Helpers ============

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
