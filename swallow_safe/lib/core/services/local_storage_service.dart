import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';

/// Local storage service using Hive for persistence
/// Provides type-safe access to user data, progress, and check-ins
class LocalStorageService {
  static const String _userBoxName = 'user_profile';
  static const String _progressBoxName = 'daily_progress';
  static const String _checkInBoxName = 'check_ins';
  static const String _settingsBoxName = 'settings';

  Box<Map>? _userBox;
  Box<Map>? _progressBox;
  Box<Map>? _checkInBox;
  Box<dynamic>? _settingsBox;

  bool _isInitialized = false;

  /// Initialize Hive and open all boxes
  /// Note: Hive.initFlutter() should already be called in main.dart
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Open all boxes (Hive is already initialized in main.dart)
      _userBox = await Hive.openBox<Map>(_userBoxName);
      _progressBox = await Hive.openBox<Map>(_progressBoxName);
      _checkInBox = await Hive.openBox<Map>(_checkInBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);

      _isInitialized = true;
    } catch (e) {
      // Log error but don't crash - use in-memory fallback
      debugPrint('LocalStorageService initialization error: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  // ============ User Profile ============

  /// Save user profile
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      await _userBox?.put('current_user', Map<String, dynamic>.from(profile));
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  /// Get user profile
  Map<String, dynamic>? getUserProfile() {
    try {
      final data = _userBox?.get('current_user');
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// Check if user exists
  bool hasUser() {
    try {
      return _userBox?.containsKey('current_user') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clear user profile
  Future<void> clearUserProfile() async {
    try {
      await _userBox?.delete('current_user');
    } catch (e) {
      debugPrint('Error clearing user profile: $e');
    }
  }

  // ============ Daily Progress ============

  /// Save daily progress entry
  Future<void> saveDailyProgress(String dateKey, Map<String, dynamic> progress) async {
    try {
      await _progressBox?.put(dateKey, Map<String, dynamic>.from(progress));
    } catch (e) {
      debugPrint('Error saving daily progress: $e');
    }
  }

  /// Get progress for a specific date
  Map<String, dynamic>? getDailyProgress(String dateKey) {
    try {
      final data = _progressBox?.get(dateKey);
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      debugPrint('Error getting daily progress: $e');
      return null;
    }
  }

  /// Get all progress entries
  List<Map<String, dynamic>> getAllProgress() {
    try {
      final entries = <Map<String, dynamic>>[];
      _progressBox?.toMap().forEach((key, value) {
        entries.add(Map<String, dynamic>.from(value)..['dateKey'] = key);
      });
      return entries;
    } catch (e) {
      debugPrint('Error getting all progress: $e');
      return [];
    }
  }

  /// Get progress for date range
  List<Map<String, dynamic>> getProgressInRange(DateTime start, DateTime end) {
    try {
      final entries = <Map<String, dynamic>>[];
      final startKey = _dateToKey(start);
      final endKey = _dateToKey(end);

      _progressBox?.toMap().forEach((key, value) {
        if (key.compareTo(startKey) >= 0 && key.compareTo(endKey) <= 0) {
          entries.add(Map<String, dynamic>.from(value)..['dateKey'] = key);
        }
      });

      entries.sort((a, b) => (a['dateKey'] as String).compareTo(b['dateKey'] as String));
      return entries;
    } catch (e) {
      debugPrint('Error getting progress in range: $e');
      return [];
    }
  }

  // ============ Check-Ins ============

  /// Save a check-in entry
  Future<void> saveCheckIn(String id, Map<String, dynamic> checkIn) async {
    try {
      await _checkInBox?.put(id, Map<String, dynamic>.from(checkIn));
    } catch (e) {
      debugPrint('Error saving check-in: $e');
    }
  }

  /// Get a specific check-in
  Map<String, dynamic>? getCheckIn(String id) {
    try {
      final data = _checkInBox?.get(id);
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      debugPrint('Error getting check-in: $e');
      return null;
    }
  }

  /// Get all check-ins sorted by date (newest first)
  List<Map<String, dynamic>> getAllCheckIns() {
    try {
      final entries = <Map<String, dynamic>>[];
      _checkInBox?.toMap().forEach((key, value) {
        entries.add(Map<String, dynamic>.from(value)..['id'] = key);
      });
      
      entries.sort((a, b) {
        final dateA = a['date'] as String? ?? '';
        final dateB = b['date'] as String? ?? '';
        return dateB.compareTo(dateA); // Descending
      });
      
      return entries;
    } catch (e) {
      debugPrint('Error getting all check-ins: $e');
      return [];
    }
  }

  /// Get recent check-ins (last n entries)
  List<Map<String, dynamic>> getRecentCheckIns(int count) {
    final all = getAllCheckIns();
    return all.take(count).toList();
  }

  /// Delete a check-in
  Future<void> deleteCheckIn(String id) async {
    try {
      await _checkInBox?.delete(id);
    } catch (e) {
      debugPrint('Error deleting check-in: $e');
    }
  }

  // ============ Settings ============

  /// Save a setting
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox?.put(key, value);
    } catch (e) {
      debugPrint('Error saving setting: $e');
    }
  }

  /// Get a setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      debugPrint('Error getting setting: $e');
      return defaultValue;
    }
  }

  /// Check if onboarding is complete
  bool isOnboardingComplete() {
    return getSetting<bool>('onboarding_complete', defaultValue: false) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete(bool value) async {
    await saveSetting('onboarding_complete', value);
  }

  // ============ Utilities ============

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await _userBox?.clear();
      await _progressBox?.clear();
      await _checkInBox?.clear();
      await _settingsBox?.clear();
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    }
  }

  /// Close all boxes
  Future<void> close() async {
    try {
      await _userBox?.close();
      await _progressBox?.close();
      await _checkInBox?.close();
      await _settingsBox?.close();
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error closing boxes: $e');
    }
  }
}

void debugPrint(String message) {
  if (kIsWeb) {
    // ignore for web in production
  } else {
    print(message);
  }
}
