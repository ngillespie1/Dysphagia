import 'package:uuid/uuid.dart';
import '../database_service.dart';

/// Repository for AI chat messages
class ChatRepository {
  final DatabaseService _db;
  static const _uuid = Uuid();

  ChatRepository(this._db);

  /// Get all messages for user
  Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    final db = await _db.database;
    return await db.query(
      'chat_messages',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
  }

  /// Add a message
  Future<void> addMessage({
    required String userId,
    required String content,
    required bool isUser,
  }) async {
    final db = await _db.database;
    await db.insert('chat_messages', {
      'id': _uuid.v4(),
      'user_id': userId,
      'content': content,
      'is_user': isUser ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Clear all messages for user
  Future<void> clearMessages(String userId) async {
    final db = await _db.database;
    await db.delete(
      'chat_messages',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Get message count
  Future<int> getMessageCount(String userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM chat_messages WHERE user_id = ?',
      [userId],
    );
    return result.first['count'] as int? ?? 0;
  }
}
