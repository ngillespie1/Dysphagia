import 'package:uuid/uuid.dart';
import '../database_service.dart';

/// Repository for user data operations
class UserRepository {
  final DatabaseService _db;
  static const _uuid = Uuid();

  UserRepository(this._db);

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final db = await _db.database;
    final results = await db.query('users', limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  /// Create a new user
  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    String? programType,
  }) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    
    final user = {
      'id': _uuid.v4(),
      'name': name,
      'email': email,
      'program_type': programType,
      'program_start_date': programType != null ? now : null,
      'notification_enabled': 1,
      'notification_times': '["09:00","14:00","19:00"]',
      'subscription_tier': 'free',
      'onboarding_complete': 0,
      'sync_status': 'pending',
      'created_at': now,
      'updated_at': now,
    };

    await db.insert('users', user);
    return user;
  }

  /// Update user profile
  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    final db = await _db.database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    updates['sync_status'] = 'pending';
    
    await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update user name
  Future<void> updateName(String id, String name) async {
    await updateUser(id, {'name': name});
  }

  /// Update program type
  Future<void> updateProgram(String id, String programType) async {
    await updateUser(id, {
      'program_type': programType,
      'program_start_date': DateTime.now().toIso8601String(),
    });
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding(String id) async {
    await updateUser(id, {'onboarding_complete': 1});
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(
    String id, {
    required bool enabled,
    required List<String> times,
  }) async {
    await updateUser(id, {
      'notification_enabled': enabled ? 1 : 0,
      'notification_times': times.toString(),
    });
  }

  /// Update subscription tier
  Future<void> updateSubscriptionTier(String id, String tier) async {
    await updateUser(id, {'subscription_tier': tier});
  }

  /// Delete user and all related data
  Future<void> deleteUser(String id) async {
    final db = await _db.database;
    await db.delete('chat_messages', where: 'user_id = ?', whereArgs: [id]);
    await db.delete('sessions', where: 'user_id = ?', whereArgs: [id]);
    await db.delete('check_ins', where: 'user_id = ?', whereArgs: [id]);
    await db.delete('daily_progress', where: 'user_id = ?', whereArgs: [id]);
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// Check if user exists
  Future<bool> hasUser() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    final user = await getCurrentUser();
    return user?['onboarding_complete'] == 1;
  }

  /// Get notification times as list
  Future<List<String>> getNotificationTimes(String userId) async {
    final user = await getCurrentUser();
    if (user == null) return ['09:00', '14:00', '19:00'];
    
    final timesStr = user['notification_times'] as String?;
    if (timesStr == null || timesStr.isEmpty) {
      return ['09:00', '14:00', '19:00'];
    }
    
    // Parse JSON array string
    final cleaned = timesStr.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
    return cleaned.split(',').map((e) => e.trim()).toList();
  }
}
