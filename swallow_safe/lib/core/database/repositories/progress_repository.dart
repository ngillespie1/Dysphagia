import 'package:uuid/uuid.dart';
import '../database_service.dart';

/// Repository for daily progress data
class ProgressRepository {
  final DatabaseService _db;
  static const _uuid = Uuid();

  ProgressRepository(this._db);

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get progress for a specific date
  Future<Map<String, dynamic>?> getProgressForDate(String userId, DateTime date) async {
    final db = await _db.database;
    final dateKey = _dateToKey(date);
    
    final results = await db.query(
      'daily_progress',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateKey],
    );
    
    return results.isNotEmpty ? results.first : null;
  }

  /// Get progress for a date range
  Future<List<Map<String, dynamic>>> getProgressInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db.database;
    final startKey = _dateToKey(start);
    final endKey = _dateToKey(end);
    
    return await db.query(
      'daily_progress',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startKey, endKey],
      orderBy: 'date ASC',
    );
  }

  /// Get today's progress
  Future<Map<String, dynamic>?> getTodayProgress(String userId) async {
    return await getProgressForDate(userId, DateTime.now());
  }

  /// Get this week's progress
  Future<List<Map<String, dynamic>>> getThisWeekProgress(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return await getProgressInRange(userId, start, now);
  }

  /// Get week completion count
  Future<int> getWeekCompletedDays(String userId) async {
    final weekProgress = await getThisWeekProgress(userId);
    return weekProgress.where((p) => p['session_completed'] == 1).length;
  }

  /// Save or update daily progress
  Future<void> saveProgress({
    required String userId,
    required DateTime date,
    int exercisesCompleted = 0,
    int exercisesTotal = 0,
    int durationMinutes = 0,
    String? mood,
    String? notes,
    bool sessionCompleted = false,
  }) async {
    final db = await _db.database;
    final dateKey = _dateToKey(date);
    final now = DateTime.now().toIso8601String();
    
    final existing = await getProgressForDate(userId, date);
    
    if (existing != null) {
      await db.update(
        'daily_progress',
        {
          'exercises_completed': exercisesCompleted,
          'exercises_total': exercisesTotal,
          'duration_minutes': durationMinutes,
          'mood': mood,
          'notes': notes,
          'session_completed': sessionCompleted ? 1 : 0,
          'sync_status': 'pending',
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [existing['id']],
      );
    } else {
      await db.insert('daily_progress', {
        'id': _uuid.v4(),
        'user_id': userId,
        'date': dateKey,
        'exercises_completed': exercisesCompleted,
        'exercises_total': exercisesTotal,
        'duration_minutes': durationMinutes,
        'mood': mood,
        'notes': notes,
        'session_completed': sessionCompleted ? 1 : 0,
        'sync_status': 'pending',
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// Mark today's session as complete
  Future<void> completeSession(
    String userId, {
    required int exercisesCompleted,
    required int exercisesTotal,
    required int durationMinutes,
    String? mood,
  }) async {
    await saveProgress(
      userId: userId,
      date: DateTime.now(),
      exercisesCompleted: exercisesCompleted,
      exercisesTotal: exercisesTotal,
      durationMinutes: durationMinutes,
      mood: mood,
      sessionCompleted: true,
    );
  }

  /// Get all progress entries for user
  Future<List<Map<String, dynamic>>> getAllProgress(String userId) async {
    final db = await _db.database;
    return await db.query(
      'daily_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  /// Get streak data.
  ///
  /// When [restDayWeekdays] is provided (e.g. `[4, 7]` for Thu & Sun),
  /// scheduled rest days will not break the streak — they are skipped
  /// during gap analysis so that exercising Mon-Wed, skipping Thu (rest),
  /// then exercising Fri still counts as a continuous streak.
  Future<Map<String, int>> getStreakData(
    String userId, {
    List<int> restDayWeekdays = const [],
  }) async {
    final allProgress = await getAllProgress(userId);

    int currentStreak = 0;
    int longestStreak = 0;
    int totalSessions = 0;

    // Sort by date descending
    allProgress.sort(
        (a, b) => (b['date'] as String).compareTo(a['date'] as String));

    DateTime? lastDate;
    int tempStreak = 0;

    for (final progress in allProgress) {
      if (progress['session_completed'] == 1) {
        totalSessions++;
        final date = DateTime.parse(progress['date'] as String);

        if (lastDate == null) {
          // Check if it's today or yesterday (or today is a rest day
          // and the session was the last active day before today)
          final today = DateTime.now();
          final todayKey = _dateToKey(today);
          final yesterdayKey =
              _dateToKey(today.subtract(const Duration(days: 1)));

          if (progress['date'] == todayKey ||
              progress['date'] == yesterdayKey) {
            tempStreak = 1;
            lastDate = date;
          } else if (restDayWeekdays.isNotEmpty) {
            // Check if all days between the session and today are rest days
            final gapDays = today.difference(date).inDays;
            if (gapDays > 0 &&
                _allDaysAreRestDays(date, today, restDayWeekdays)) {
              tempStreak = 1;
              lastDate = date;
            }
          }
        } else {
          final diff = lastDate.difference(date).inDays;
          if (diff == 1) {
            // Consecutive day
            tempStreak++;
            lastDate = date;
          } else if (diff > 1 &&
              restDayWeekdays.isNotEmpty &&
              _allDaysAreRestDays(date, lastDate, restDayWeekdays)) {
            // Gap is entirely rest days — streak continues
            tempStreak++;
            lastDate = date;
          } else {
            // Streak broken
            if (tempStreak > longestStreak) longestStreak = tempStreak;
            if (currentStreak == 0) currentStreak = tempStreak;
            tempStreak = 1;
            lastDate = date;
          }
        }
      }
    }

    if (tempStreak > longestStreak) longestStreak = tempStreak;
    if (currentStreak == 0) currentStreak = tempStreak;

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalSessions': totalSessions,
    };
  }

  /// Returns `true` when **every** day strictly between [from] and [to]
  /// is a rest day (i.e. its `DateTime.weekday` is in [restDays]).
  bool _allDaysAreRestDays(
      DateTime from, DateTime to, List<int> restDays) {
    // Walk from the day after `from` up to (but not including) `to`
    final start = DateTime(from.year, from.month, from.day)
        .add(const Duration(days: 1));
    final end = DateTime(to.year, to.month, to.day);

    for (var d = start; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      if (!restDays.contains(d.weekday)) return false;
    }
    return true;
  }
}
