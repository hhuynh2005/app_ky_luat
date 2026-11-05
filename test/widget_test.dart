import 'package:flutter_test/flutter_test.dart';
import 'package:habit_discipline_app/models/habit.dart';
import 'package:habit_discipline_app/utils/date_helper.dart';

void main() {
  group('Habit Discipline Tests', () {
    test('Habit model serialization and deserialization', () {
      final habit = Habit(
        id: 1,
        name: 'Đọc sách 20 phút',
        description: 'Mở rộng tư duy',
        frequency: 'daily',
        targetDays: [1, 2, 3, 4, 5, 6, 7],
        reminderTime: '21:00',
        iconKey: 'book',
        colorValue: 0xFF4F46E5,
      );

      final map = habit.toMap();
      final fromMap = Habit.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.name, 'Đọc sách 20 phút');
      expect(fromMap.frequency, 'daily');
      expect(fromMap.targetDays.length, 7);
      expect(fromMap.reminderTime, '21:00');
    });

    test('Habit schedule check for weekday', () {
      final habitDaily = Habit(
        name: 'Uống nước',
        description: 'Đủ 2 lít',
        frequency: 'daily',
        reminderTime: '08:00',
      );

      final habitCustom = Habit(
        name: 'Tập gym',
        description: 'T2, T4, T6',
        frequency: 'custom',
        targetDays: [1, 3, 5],
        reminderTime: '17:00',
      );

      final monday = DateTime(2026, 11, 2); // Thứ Hai (weekday = 1)
      final tuesday = DateTime(2026, 11, 3); // Thứ Ba (weekday = 2)

      expect(habitDaily.isScheduledForDate(monday), true);
      expect(habitDaily.isScheduledForDate(tuesday), true);

      expect(habitCustom.isScheduledForDate(monday), true);
      expect(habitCustom.isScheduledForDate(tuesday), false);
    });

    test('DateHelper calculations', () {
      final date = DateTime(2026, 11, 5);
      expect(DateHelper.toDbDate(date), '2026-11-05');
      final daysOfWeek = DateHelper.getDaysOfWeek(date);
      expect(daysOfWeek.length, 7);
    });
  });
}
