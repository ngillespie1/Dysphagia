import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database service with sync-ready architecture
/// All tables include server_id and sync_status for future cloud sync
class DatabaseService {
  static Database? _database;
  static const int _version = 1;
  static const String _dbName = 'swallow_safe.db';

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        server_id TEXT,
        name TEXT NOT NULL,
        email TEXT,
        program_type TEXT,
        program_start_date TEXT,
        notification_enabled INTEGER DEFAULT 1,
        notification_times TEXT,
        subscription_tier TEXT DEFAULT 'free',
        onboarding_complete INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Daily progress table
    await db.execute('''
      CREATE TABLE daily_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        exercises_completed INTEGER DEFAULT 0,
        exercises_total INTEGER DEFAULT 0,
        duration_minutes INTEGER DEFAULT 0,
        mood TEXT,
        notes TEXT,
        session_completed INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Check-ins table
    await db.execute('''
      CREATE TABLE check_ins (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        pain_level INTEGER,
        swallowing_ease INTEGER,
        dry_mouth INTEGER,
        overall_feeling TEXT,
        notes TEXT,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Sessions table
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        week_number INTEGER NOT NULL,
        exercises_completed INTEGER DEFAULT 0,
        duration_seconds INTEGER DEFAULT 0,
        completed_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Chat messages table (for AI assistant)
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        content TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Create indexes for common queries
    await db.execute('CREATE INDEX idx_progress_date ON daily_progress(date)');
    await db.execute('CREATE INDEX idx_progress_user ON daily_progress(user_id)');
    await db.execute('CREATE INDEX idx_checkins_date ON check_ins(date)');
    await db.execute('CREATE INDEX idx_checkins_user ON check_ins(user_id)');
    await db.execute('CREATE INDEX idx_sessions_user ON sessions(user_id)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add migration logic here for future versions
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear all data (for logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('chat_messages');
    await db.delete('sessions');
    await db.delete('check_ins');
    await db.delete('daily_progress');
    await db.delete('users');
  }

  /// Get records that need syncing
  Future<List<Map<String, dynamic>>> getPendingSyncRecords(String table) async {
    final db = await database;
    return await db.query(
      table,
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
  }

  /// Mark records as synced
  Future<void> markAsSynced(String table, List<String> ids) async {
    final db = await database;
    await db.update(
      table,
      {'sync_status': 'synced'},
      where: 'id IN (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
  }
}
