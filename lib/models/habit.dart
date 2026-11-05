import 'dart:convert';
import 'package:flutter/material.dart';

class Habit {
  final int? id;
  final String name;
  final String description;
  final String frequency; // 'daily' hoặc 'custom'
  final List<int> targetDays; // [1,2,3,4,5,6,7] (1: Thứ 2, 7: CN)
  final String reminderTime; // ví dụ "07:00"
  final String iconKey; // key icon
  final int colorValue; // mã ARGB integer của màu
  final DateTime createdAt;

  Habit({
    this.id,
    required this.name,
    required this.description,
    this.frequency = 'daily',
    this.targetDays = const [1, 2, 3, 4, 5, 6, 7],
    required this.reminderTime,
    this.iconKey = 'task',
    this.colorValue = 0xFF4F46E5,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get color => Color(colorValue);

  /// Kiểm tra thói quen có được lên lịch vào ngày cụ thể không
  bool isScheduledForDate(DateTime date) {
    if (frequency == 'daily') return true;
    return targetDays.contains(date.weekday);
  }

  /// Chuyển đổi sang Map để lưu trữ vào SQLite / SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'frequency': frequency,
      'target_days': jsonEncode(targetDays),
      'reminder_time': reminderTime,
      'icon_key': iconKey,
      'color_value': colorValue,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Khởi tạo đối tượng từ Map (đọc từ SQLite / SharedPreferences)
  factory Habit.fromMap(Map<String, dynamic> map) {
    List<int> parsedDays = [1, 2, 3, 4, 5, 6, 7];
    if (map['target_days'] != null) {
      try {
        final decoded = jsonDecode(map['target_days'] as String);
        if (decoded is List) {
          parsedDays = decoded.map((e) => e as int).toList();
        }
      } catch (_) {
        parsedDays = [1, 2, 3, 4, 5, 6, 7];
      }
    }

    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      frequency: map['frequency'] as String? ?? 'daily',
      targetDays: parsedDays,
      reminderTime: map['reminder_time'] as String? ?? '07:00',
      iconKey: map['icon_key'] as String? ?? 'task',
      colorValue: map['color_value'] as int? ?? 0xFF4F46E5,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    String? frequency,
    List<int>? targetDays,
    String? reminderTime,
    String? iconKey,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      reminderTime: reminderTime ?? this.reminderTime,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
