import 'package:intl/intl.dart';

class DateHelper {
  /// Format date to "YYYY-MM-DD" for database storage and comparisons
  static String toDbDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parse "YYYY-MM-DD" to DateTime
  static DateTime fromDbDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  /// Format date to Vietnamese display (e.g., "Thứ Năm, 05/11/2026")
  static String formatFullDate(DateTime date) {
    final dayOfWeek = getDayOfWeekName(date.weekday);
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    return '$dayOfWeek, $dateStr';
  }

  /// Format short date (e.g., "05/11")
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  /// Format month and year (e.g., "Tháng 11, 2026")
  static String formatMonthYear(DateTime date) {
    return 'Tháng ${date.month}, ${date.year}';
  }

  /// Get Vietnamese short day name (T2, T3, T4, T5, T6, T7, CN)
  static String getShortDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  /// Get Vietnamese full day name
  static String getDayOfWeekName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  /// Check if two dates represent the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get list of 7 days in the week containing the given date (Monday to Sunday)
  static List<DateTime> getDaysOfWeek(DateTime date) {
    final startMonday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) {
      final day = startMonday.add(Duration(days: index));
      return DateTime(day.year, day.month, day.day);
    });
  }

  /// Get list of days in the current month
  static List<DateTime> getDaysInMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0);
    final daysCount = lastDay.day;
    return List.generate(daysCount, (index) => DateTime(date.year, date.month, index + 1));
  }
}
