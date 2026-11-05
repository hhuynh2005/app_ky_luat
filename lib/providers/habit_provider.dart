import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/habit_repository.dart';
import '../utils/date_helper.dart';

class DayStat {
  final DateTime date;
  final int totalScheduled;
  final int completedCount;
  final double completionRate; // 0.0 to 1.0

  DayStat({
    required this.date,
    required this.totalScheduled,
    required this.completedCount,
    required this.completionRate,
  });
}

class WeeklyStat {
  final List<DayStat> dailyStats; // 7 ngày T2 -> CN
  final int totalCompleted;
  final int totalScheduled;
  final double averageRate;

  WeeklyStat({
    required this.dailyStats,
    required this.totalCompleted,
    required this.totalScheduled,
    required this.averageRate,
  });
}

class MonthlyStat {
  final DateTime month;
  final int totalCompleted;
  final int totalScheduled;
  final double averageRate;
  final int perfectDaysCount; // Số ngày hoàn thành 100% thói quen
  final List<double> weeklyAverages; // Tỷ lệ trung bình của các tuần trong tháng

  MonthlyStat({
    required this.month,
    required this.totalCompleted,
    required this.totalScheduled,
    required this.averageRate,
    required this.perfectDaysCount,
    required this.weeklyAverages,
  });
}

class HabitProvider with ChangeNotifier {
  final HabitRepository _repository = HabitRepository();

  List<Habit> _habits = [];
  List<HabitLog> _logs = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  List<Habit> get habits => _habits;
  List<HabitLog> get logs => _logs;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  HabitProvider() {
    loadData();
  }

  /// Nạp toàn bộ dữ liệu ban đầu
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await _repository.initializeDefaultDataIfNeeded();
    _habits = await _repository.getHabits();
    _logs = await _repository.getAllLogs();

    _isLoading = false;
    notifyListeners();
  }

  /// Thay đổi ngày đang chọn để xem danh sách và hoàn thành
  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  /// Danh sách thói quen được lên lịch cho ngày đang chọn
  List<Habit> get habitsForSelectedDate {
    return _habits.where((habit) => habit.isScheduledForDate(_selectedDate)).toList();
  }

  /// Kiểm tra xem thói quen có hoàn thành vào ngày chỉ định không
  bool isHabitCompleted(int habitId, DateTime date) {
    final dateStr = DateHelper.toDbDate(date);
    final log = _logs.firstWhere(
      (l) => l.habitId == habitId && l.date == dateStr,
      orElse: () => HabitLog(habitId: habitId, date: dateStr, isCompleted: false),
    );
    return log.isCompleted;
  }

  /// Bật / Tắt trạng thái hoàn thành thói quen cho ngày đang chọn (hoặc ngày cụ thể)
  Future<void> toggleHabitCompletion(int habitId, {DateTime? date}) async {
    final targetDate = date ?? _selectedDate;
    final dateStr = DateHelper.toDbDate(targetDate);
    final currentStatus = isHabitCompleted(habitId, targetDate);
    final newStatus = !currentStatus;

    // Cập nhật local state trước để UI phản hồi tức thì
    final existingIndex = _logs.indexWhere((l) => l.habitId == habitId && l.date == dateStr);
    if (existingIndex != -1) {
      _logs[existingIndex] = _logs[existingIndex].copyWith(
        isCompleted: newStatus,
        completedAt: newStatus ? DateTime.now() : null,
      );
    } else {
      _logs.add(HabitLog(
        habitId: habitId,
        date: dateStr,
        isCompleted: newStatus,
        completedAt: newStatus ? DateTime.now() : null,
      ));
    }
    notifyListeners();

    // Lưu vào cơ sở dữ liệu
    await _repository.toggleHabitCompletion(
      habitId: habitId,
      date: dateStr,
      isCompleted: newStatus,
    );
  }

  /// Thêm thói quen mới
  Future<void> addHabit(Habit habit) async {
    final newHabit = await _repository.addHabit(habit);
    _habits.add(newHabit);
    notifyListeners();
  }

  /// Cập nhật thói quen
  Future<void> updateHabit(Habit habit) async {
    await _repository.updateHabit(habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();
    }
  }

  /// Xóa thói quen
  Future<void> deleteHabit(int habitId) async {
    await _repository.deleteHabit(habitId);
    _habits.removeWhere((h) => h.id == habitId);
    _logs.removeWhere((l) => l.habitId == habitId);
    notifyListeners();
  }

  // ================= THỐNG KÊ (STATISTICS) =================

  /// Thống kê ngày: Số lượng thói quen, đã hoàn thành, tỷ lệ %
  DayStat getDailyStats(DateTime date) {
    final scheduled = _habits.where((h) => h.isScheduledForDate(date)).toList();
    if (scheduled.isEmpty) {
      return DayStat(
        date: date,
        totalScheduled: 0,
        completedCount: 0,
        completionRate: 0.0,
      );
    }

    int completed = 0;
    for (final habit in scheduled) {
      if (isHabitCompleted(habit.id ?? -1, date)) {
        completed++;
      }
    }

    final rate = completed / scheduled.length;
    return DayStat(
      date: date,
      totalScheduled: scheduled.length,
      completedCount: completed,
      completionRate: rate,
    );
  }

  /// Thống kê tuần: 7 ngày từ Thứ Hai đến Chủ Nhật
  WeeklyStat getWeeklyStats(DateTime date) {
    final daysOfWeek = DateHelper.getDaysOfWeek(date);
    final dailyStats = daysOfWeek.map((day) => getDailyStats(day)).toList();

    int totalCompleted = 0;
    int totalScheduled = 0;

    for (final stat in dailyStats) {
      totalCompleted += stat.completedCount;
      totalScheduled += stat.totalScheduled;
    }

    final averageRate = totalScheduled == 0 ? 0.0 : (totalCompleted / totalScheduled);

    return WeeklyStat(
      dailyStats: dailyStats,
      totalCompleted: totalCompleted,
      totalScheduled: totalScheduled,
      averageRate: averageRate,
    );
  }

  /// Thống kê tháng: Toàn bộ ngày trong tháng
  MonthlyStat getMonthlyStats(DateTime date) {
    final daysInMonth = DateHelper.getDaysInMonth(date);
    int totalCompleted = 0;
    int totalScheduled = 0;
    int perfectDays = 0;

    for (final day in daysInMonth) {
      final stat = getDailyStats(day);
      totalCompleted += stat.completedCount;
      totalScheduled += stat.totalScheduled;
      if (stat.totalScheduled > 0 && stat.completedCount == stat.totalScheduled) {
        perfectDays++;
      }
    }

    final averageRate = totalScheduled == 0 ? 0.0 : (totalCompleted / totalScheduled);

    // Tính tỷ lệ theo 4 tuần trong tháng
    List<double> weeklyAverages = [];
    for (int i = 0; i < daysInMonth.length; i += 7) {
      int end = (i + 7 > daysInMonth.length) ? daysInMonth.length : i + 7;
      int subCompleted = 0;
      int subScheduled = 0;
      for (int j = i; j < end; j++) {
        final stat = getDailyStats(daysInMonth[j]);
        subCompleted += stat.completedCount;
        subScheduled += stat.totalScheduled;
      }
      weeklyAverages.add(subScheduled == 0 ? 0.0 : (subCompleted / subScheduled));
    }

    return MonthlyStat(
      month: date,
      totalCompleted: totalCompleted,
      totalScheduled: totalScheduled,
      averageRate: averageRate,
      perfectDaysCount: perfectDays,
      weeklyAverages: weeklyAverages,
    );
  }

  /// Tính chuỗi ngày kỷ luật hiện tại (Current Streak)
  int calculateCurrentStreak() {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    // Nếu hôm nay đã hoàn thành ít nhất 1 thói quen, tính từ hôm nay.
    // Nếu chưa, kiểm tra hôm qua.
    final todayStat = getDailyStats(checkDate);
    if (todayStat.completedCount > 0) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final stat = getDailyStats(checkDate);
      if (stat.totalScheduled > 0 && stat.completedCount > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Tính chuỗi kỷ luật dài nhất (Best Streak)
  int calculateBestStreak() {
    int maxStreak = 0;
    int currentStreak = 0;

    // Xem xét trong 60 ngày gần nhất
    final now = DateTime.now();
    for (int i = 60; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final stat = getDailyStats(date);
      if (stat.totalScheduled > 0 && stat.completedCount > 0) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }
    return maxStreak;
  }

  /// Tính tỷ lệ hoàn thành của một thói quen cụ thể trong 30 ngày qua
  double getHabit30DayRate(int habitId) {
    int completed = 0;
    int total = 0;
    final now = DateTime.now();
    final habit = _habits.firstWhere((h) => h.id == habitId, orElse: () => Habit(name: '', description: '', reminderTime: ''));

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      if (habit.isScheduledForDate(date)) {
        total++;
        if (isHabitCompleted(habitId, date)) {
          completed++;
        }
      }
    }

    return total == 0 ? 0.0 : (completed / total);
  }
}
