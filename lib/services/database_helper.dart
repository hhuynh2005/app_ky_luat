import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/habit.dart';
import '../models/habit_log.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null; // SQLite native không chạy trực tiếp trên web không có WASM
    if (_database != null) return _database!;
    _database = await _initDB('habits_discipline.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Bảng thói quen
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        frequency TEXT NOT NULL,
        target_days TEXT NOT NULL,
        reminder_time TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Bảng nhật ký hoàn thành thói quen theo ngày
    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        UNIQUE(habit_id, date) ON CONFLICT REPLACE,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- CRUD HABITS ---
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    if (db == null) return -1;
    final habitMap = habit.toMap();
    habitMap.remove('id');
    return await db.insert('habits', habitMap);
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query('habits', orderBy: 'id ASC');
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    if (db == null) return -1;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    if (db == null) return -1;
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD HABIT LOGS ---
  Future<int> setHabitCompletion({
    required int habitId,
    required String date,
    required bool isCompleted,
  }) async {
    final db = await database;
    if (db == null) return -1;

    final log = HabitLog(
      habitId: habitId,
      date: date,
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );

    return await db.insert(
      'habit_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HabitLog>> getLogsForDate(String date) async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query(
      'habit_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map((map) => HabitLog.fromMap(map)).toList();
  }

  Future<List<HabitLog>> getAllLogs() async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query('habit_logs');
    return maps.map((map) => HabitLog.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    if (db != null) {
      await db.close();
    }
  }
}
