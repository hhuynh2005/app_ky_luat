import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../utils/date_helper.dart';
import 'database_helper.dart';

class HabitRepository {
  static const String _prefsHabitsKey = 'saved_habits_list';
  static const String _prefsLogsKey = 'saved_habit_logs_list';
  static const String _prefsInitializedKey = 'is_app_initialized_v1';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Khởi tạo dữ liệu mẫu nếu đây là lần đầu mở app
  Future<void> initializeDefaultDataIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_prefsInitializedKey) ?? false;

    if (!isInitialized) {
      final defaultHabits = [
        Habit(
          id: 1,
          name: 'Uống 2 lít nước',
          description: 'Cung cấp đủ nước cho cơ thể, tăng cường trao đổi chất',
          frequency: 'daily',
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          reminderTime: '07:30',
          iconKey: 'water',
          colorValue: 0xFF06B6D4, // Cyan
        ),
        Habit(
          id: 2,
          name: 'Đọc sách 20 phút',
          description: 'Phát triển tư duy, mở rộng vốn từ và nâng cao kiến thức',
          frequency: 'daily',
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          reminderTime: '21:30',
          iconKey: 'book',
          colorValue: 0xFF4F46E5, // Indigo
        ),
        Habit(
          id: 3,
          name: 'Tập thể dục / Gym',
          description: 'Rèn luyện sức bền, sự dẻo dai và vóc dáng khỏe mạnh',
          frequency: 'custom',
          targetDays: [1, 3, 5, 6], // T2, T4, T6, T7
          reminderTime: '17:30',
          iconKey: 'fitness',
          colorValue: 0xFF10B981, // Emerald
        ),
        Habit(
          id: 4,
          name: 'Dậy sớm trước 6:30',
          description: 'Bắt đầu ngày mới tràn đầy năng lượng và làm chủ thời gian',
          frequency: 'daily',
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          reminderTime: '06:00',
          iconKey: 'alarm',
          colorValue: 0xFFF59E0B, // Amber
        ),
        Habit(
          id: 5,
          name: 'Học Lập trình Flutter',
          description: 'Hoàn thiện đồ án, rèn luyện kỹ năng coding mỗi ngày',
          frequency: 'daily',
          targetDays: [1, 2, 3, 4, 5, 6, 7],
          reminderTime: '20:00',
          iconKey: 'code',
          colorValue: 0xFF8B5CF6, // Purple
        ),
      ];

      // Tạo một số logs mẫu trong vài ngày qua để biểu đồ thống kê có dữ liệu đẹp
      final now = DateTime.now();
      final sampleLogs = <HabitLog>[];

      for (int i = 0; i < 7; i++) {
        final d = now.subtract(Duration(days: i));
        final dateStr = DateHelper.toDbDate(d);
        // Habit 1 & 2 hoàn thành nhiều
        sampleLogs.add(HabitLog(habitId: 1, date: dateStr, isCompleted: true));
        if (i % 2 == 0) {
          sampleLogs.add(HabitLog(habitId: 2, date: dateStr, isCompleted: true));
        }
        if (i % 3 != 0) {
          sampleLogs.add(HabitLog(habitId: 3, date: dateStr, isCompleted: true));
        }
        if (i < 3) {
          sampleLogs.add(HabitLog(habitId: 4, date: dateStr, isCompleted: true));
        }
      }

      if (kIsWeb) {
        // Lưu SharedPreferences
        final habitsJson = jsonEncode(defaultHabits.map((h) => h.toMap()).toList());
        final logsJson = jsonEncode(sampleLogs.map((l) => l.toMap()).toList());
        await prefs.setString(_prefsHabitsKey, habitsJson);
        await prefs.setString(_prefsLogsKey, logsJson);
      } else {
        // Lưu SQLite
        try {
          for (final habit in defaultHabits) {
            await _dbHelper.insertHabit(habit);
          }
          for (final log in sampleLogs) {
            await _dbHelper.setHabitCompletion(
              habitId: log.habitId,
              date: log.date,
              isCompleted: log.isCompleted,
            );
          }
        } catch (e) {
          debugPrint('Error inserting default SQLite data: $e');
        }
      }

      await prefs.setBool(_prefsInitializedKey, true);
    }
  }

  // --- GET ALL HABITS ---
  Future<List<Habit>> getHabits() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString(_prefsHabitsKey);
      if (habitsJson == null) return [];
      final List decoded = jsonDecode(habitsJson);
      return decoded.map((e) => Habit.fromMap(e as Map<String, dynamic>)).toList();
    } else {
      try {
        final habits = await _dbHelper.getAllHabits();
        if (habits.isNotEmpty) return habits;
        // Fallback prefs if empty
        final prefs = await SharedPreferences.getInstance();
        final habitsJson = prefs.getString(_prefsHabitsKey);
        if (habitsJson != null) {
          final List decoded = jsonDecode(habitsJson);
          return decoded.map((e) => Habit.fromMap(e as Map<String, dynamic>)).toList();
        }
        return [];
      } catch (_) {
        final prefs = await SharedPreferences.getInstance();
        final habitsJson = prefs.getString(_prefsHabitsKey);
        if (habitsJson == null) return [];
        final List decoded = jsonDecode(habitsJson);
        return decoded.map((e) => Habit.fromMap(e as Map<String, dynamic>)).toList();
      }
    }
  }

  // --- ADD HABIT ---
  Future<Habit> addHabit(Habit habit) async {
    if (kIsWeb) {
      final habits = await getHabits();
      final newId = habits.isEmpty ? 1 : (habits.map((h) => h.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      final newHabit = habit.copyWith(id: newId);
      habits.add(newHabit);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsHabitsKey, jsonEncode(habits.map((h) => h.toMap()).toList()));
      return newHabit;
    } else {
      try {
        final insertedId = await _dbHelper.insertHabit(habit);
        final newHabit = habit.copyWith(id: insertedId);
        // Đồng bộ bản sao SharedPreferences
        _syncToPrefs();
        return newHabit;
      } catch (e) {
        // Fallback
        final habits = await getHabits();
        final newId = habits.isEmpty ? 1 : (habits.map((h) => h.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
        final newHabit = habit.copyWith(id: newId);
        habits.add(newHabit);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsHabitsKey, jsonEncode(habits.map((h) => h.toMap()).toList()));
        return newHabit;
      }
    }
  }

  // --- UPDATE HABIT ---
  Future<void> updateHabit(Habit habit) async {
    if (kIsWeb) {
      final habits = await getHabits();
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        habits[index] = habit;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsHabitsKey, jsonEncode(habits.map((h) => h.toMap()).toList()));
      }
    } else {
      try {
        await _dbHelper.updateHabit(habit);
        _syncToPrefs();
      } catch (_) {
        final habits = await getHabits();
        final index = habits.indexWhere((h) => h.id == habit.id);
        if (index != -1) {
          habits[index] = habit;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefsHabitsKey, jsonEncode(habits.map((h) => h.toMap()).toList()));
        }
      }
    }
  }

  // --- DELETE HABIT ---
  Future<void> deleteHabit(int id) async {
    if (kIsWeb) {
      final habits = await getHabits();
      habits.removeWhere((h) => h.id == id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsHabitsKey, jsonEncode(habits.map((h) => h.toMap()).toList()));

      // Xóa các logs liên quan
      final logs = await getAllLogs();
      logs.removeWhere((l) => l.habitId == id);
      await prefs.setString(_prefsLogsKey, jsonEncode(logs.map((l) => l.toMap()).toList()));
    } else {
      try {
        await _dbHelper.deleteHabit(id);
        _syncToPrefs();
      } catch (_) {
        final habits = await getHabits();
        habits.removeWhere((h) => h.id == id);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsHabitsKey, jsonEncode(habits.map((h) => h.toMap()).toList()));
      }
    }
  }

  // --- TOGGLE COMPLETION ---
  Future<void> toggleHabitCompletion({
    required int habitId,
    required String date,
    required bool isCompleted,
  }) async {
    if (kIsWeb) {
      final logs = await getAllLogs();
      final existingIndex = logs.indexWhere((l) => l.habitId == habitId && l.date == date);
      if (existingIndex != -1) {
        logs[existingIndex] = logs[existingIndex].copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
      } else {
        logs.add(HabitLog(
          habitId: habitId,
          date: date,
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        ));
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsLogsKey, jsonEncode(logs.map((l) => l.toMap()).toList()));
    } else {
      try {
        await _dbHelper.setHabitCompletion(
          habitId: habitId,
          date: date,
          isCompleted: isCompleted,
        );
        _syncLogsToPrefs();
      } catch (_) {
        final logs = await getAllLogs();
        final existingIndex = logs.indexWhere((l) => l.habitId == habitId && l.date == date);
        if (existingIndex != -1) {
          logs[existingIndex] = logs[existingIndex].copyWith(
            isCompleted: isCompleted,
            completedAt: isCompleted ? DateTime.now() : null,
          );
        } else {
          logs.add(HabitLog(
            habitId: habitId,
            date: date,
            isCompleted: isCompleted,
            completedAt: isCompleted ? DateTime.now() : null,
          ));
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsLogsKey, jsonEncode(logs.map((l) => l.toMap()).toList()));
      }
    }
  }

  // --- GET ALL LOGS ---
  Future<List<HabitLog>> getAllLogs() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_prefsLogsKey);
      if (logsJson == null) return [];
      final List decoded = jsonDecode(logsJson);
      return decoded.map((e) => HabitLog.fromMap(e as Map<String, dynamic>)).toList();
    } else {
      try {
        final logs = await _dbHelper.getAllLogs();
        if (logs.isNotEmpty) return logs;
        final prefs = await SharedPreferences.getInstance();
        final logsJson = prefs.getString(_prefsLogsKey);
        if (logsJson != null) {
          final List decoded = jsonDecode(logsJson);
          return decoded.map((e) => HabitLog.fromMap(e as Map<String, dynamic>)).toList();
        }
        return [];
      } catch (_) {
        final prefs = await SharedPreferences.getInstance();
        final logsJson = prefs.getString(_prefsLogsKey);
        if (logsJson == null) return [];
        final List decoded = jsonDecode(logsJson);
        return decoded.map((e) => HabitLog.fromMap(e as Map<String, dynamic>)).toList();
      }
    }
  }

  Future<void> _syncToPrefs() async {
    try {
      final habits = await _dbHelper.getAllHabits();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsHabitsKey, jsonEncode(habits.map((h) => h.toMap()).toList()));
    } catch (_) {}
  }

  Future<void> _syncLogsToPrefs() async {
    try {
      final logs = await _dbHelper.getAllLogs();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsLogsKey, jsonEncode(logs.map((l) => l.toMap()).toList()));
    } catch (_) {}
  }
}
