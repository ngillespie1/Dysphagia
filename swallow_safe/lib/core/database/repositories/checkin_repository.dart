import 'package:uuid/uuid.dart';
import '../database_service.dart';

/// Repository for symptom check-in data
class CheckInRepository {
  final DatabaseService _db;
  static const _uuid = Uuid();

  CheckInRepository(this._db);

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get check-in for a specific date
  Future<Map<String, dynamic>?> getCheckInForDate(String userId, DateTime date) async {
    final db = await _db.database;
    final dateKey = _dateToKey(date);
    
    final results = await db.query(
      'check_ins',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateKey],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    
    return results.isNotEmpty ? results.first : null;
  }

  /// Get today's check-in
  Future<Map<String, dynamic>?> getTodayCheckIn(String userId) async {
    return await getCheckInForDate(userId, DateTime.now());
  }

  /// Get recent check-ins
  Future<List<Map<String, dynamic>>> getRecentCheckIns(String userId, {int limit = 7}) async {
    final db = await _db.database;
    return await db.query(
      'check_ins',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  /// Get check-ins in date range
  Future<List<Map<String, dynamic>>> getCheckInsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db.database;
    final startKey = _dateToKey(start);
    final endKey = _dateToKey(end);
    
    return await db.query(
      'check_ins',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startKey, endKey],
      orderBy: 'date DESC',
    );
  }

  /// Save a check-in
  Future<void> saveCheckIn({
    required String userId,
    required int painLevel,
    required int swallowingEase,
    required int dryMouth,
    String? overallFeeling,
    String? notes,
  }) async {
    final db = await _db.database;
    final now = DateTime.now();
    final dateKey = _dateToKey(now);
    
    await db.insert('check_ins', {
      'id': _uuid.v4(),
      'user_id': userId,
      'date': dateKey,
      'pain_level': painLevel,
      'swallowing_ease': swallowingEase,
      'dry_mouth': dryMouth,
      'overall_feeling': overallFeeling,
      'notes': notes,
      'sync_status': 'pending',
      'created_at': now.toIso8601String(),
    });
  }

  /// Get latest mood from most recent check-in
  Future<String?> getLatestMood(String userId) async {
    final recent = await getRecentCheckIns(userId, limit: 1);
    if (recent.isEmpty) return null;
    return recent.first['overall_feeling'] as String?;
  }

  /// Get weekly mood summary for mood wave
  Future<List<Map<String, dynamic>>> getWeeklyMoodData(String userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final moods = <Map<String, dynamic>>[];
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      final checkIn = await getCheckInForDate(userId, date);
      
      moods.add({
        'date': _dateToKey(date),
        'mood': checkIn?['overall_feeling'],
        'hasCheckIn': checkIn != null,
        'swallowingEase': checkIn?['swallowing_ease'],
      });
    }
    
    return moods;
  }

  /// Delete a check-in
  Future<void> deleteCheckIn(String id) async {
    final db = await _db.database;
    await db.delete('check_ins', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all check-ins
  Future<List<Map<String, dynamic>>> getAllCheckIns(String userId) async {
    final db = await _db.database;
    return await db.query(
      'check_ins',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }
}
