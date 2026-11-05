import 'package:flutter/material.dart';

class HabitIconInfo {
  final String key;
  final String label;
  final IconData icon;

  const HabitIconInfo({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class AppIcons {
  static const List<HabitIconInfo> availableIcons = [
    HabitIconInfo(key: 'fitness', label: 'Tập thể dục', icon: Icons.fitness_center),
    HabitIconInfo(key: 'book', label: 'Đọc sách', icon: Icons.menu_book),
    HabitIconInfo(key: 'water', label: 'Uống nước', icon: Icons.water_drop),
    HabitIconInfo(key: 'alarm', label: 'Dậy sớm', icon: Icons.alarm),
    HabitIconInfo(key: 'bed', label: 'Ngủ sớm', icon: Icons.bedtime),
    HabitIconInfo(key: 'meditation', label: 'Thiền định', icon: Icons.self_improvement),
    HabitIconInfo(key: 'study', label: 'Học tập', icon: Icons.school),
    HabitIconInfo(key: 'code', label: 'Lập trình', icon: Icons.code),
    HabitIconInfo(key: 'run', label: 'Chạy bộ', icon: Icons.directions_run),
    HabitIconInfo(key: 'journal', label: 'Viết nhật ký', icon: Icons.edit_note),
    HabitIconInfo(key: 'eat', label: 'Ăn lành mạnh', icon: Icons.restaurant),
    HabitIconInfo(key: 'savings', label: 'Tiết kiệm', icon: Icons.savings),
    HabitIconInfo(key: 'clean', label: 'Dọn dẹp', icon: Icons.cleaning_services),
    HabitIconInfo(key: 'heart', label: 'Sức khỏe', icon: Icons.favorite),
    HabitIconInfo(key: 'task', label: 'Việc quan trọng', icon: Icons.check_circle_outline),
  ];

  static IconData getIconByKey(String key) {
    final found = availableIcons.firstWhere(
      (element) => element.key == key,
      orElse: () => const HabitIconInfo(key: 'task', label: 'Việc quan trọng', icon: Icons.check_circle_outline),
    );
    return found.icon;
  }
}
