import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../utils/date_helper.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit; // Nếu null thì là Thêm mới, khác null thì là Sửa

  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  late String _frequency; // 'daily' hoặc 'custom'
  late List<int> _targetDays;
  late TimeOfDay _reminderTime;
  late String _selectedIconKey;
  late int _selectedColorValue;

  bool get isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nameController = TextEditingController(text: h?.name ?? '');
    _descriptionController = TextEditingController(text: h?.description ?? '');
    _frequency = h?.frequency ?? 'daily';
    _targetDays = h != null ? List<int>.from(h.targetDays) : [1, 2, 3, 4, 5, 6, 7];

    if (h != null) {
      final parts = h.reminderTime.split(':');
      if (parts.length == 2) {
        _reminderTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 7,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      } else {
        _reminderTime = const TimeOfDay(hour: 7, minute: 0);
      }
    } else {
      _reminderTime = const TimeOfDay(hour: 7, minute: 0);
    }

    _selectedIconKey = h?.iconKey ?? 'fitness';
    _selectedColorValue = h?.colorValue ?? AppColors.primary.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      helpText: 'CHỌN THỜI GIAN NHẮC NHỞ',
      confirmText: 'CHỌN',
      cancelText: 'HỦY',
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _toggleWeekday(int day) {
    setState(() {
      if (_targetDays.contains(day)) {
        if (_targetDays.length > 1) {
          _targetDays.remove(day);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng chọn ít nhất 1 ngày trong tuần'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _targetDays.add(day);
        _targetDays.sort();
      }
    });
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    final habit = Habit(
      id: widget.habit?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      frequency: _frequency,
      targetDays: _frequency == 'daily' ? [1, 2, 3, 4, 5, 6, 7] : _targetDays,
      reminderTime: _formatTimeOfDay(_reminderTime),
      iconKey: _selectedIconKey,
      colorValue: _selectedColorValue,
      createdAt: widget.habit?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      habitProvider.updateHabit(habit);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật thói quen thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      habitProvider.addHabit(habit);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm thói quen mới thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    }

    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thói quen "${widget.habit?.name}" không? Toàn bộ lịch sử hoàn thành sẽ bị xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.habit?.id != null) {
                Provider.of<HabitProvider>(context, listen: false).deleteHabit(widget.habit!.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa thói quen.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Chỉnh Sửa Thói Quen' : 'Thêm Thói Quen Mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Xóa thói quen',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Box
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(_selectedColorValue).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Color(_selectedColorValue), width: 2),
                  ),
                  child: Icon(
                    AppIcons.getIconByKey(_selectedIconKey),
                    color: Color(_selectedColorValue),
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 1. Tên thói quen
              const Text(
                'Tên thói quen *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Đọc sách 30 phút, Uống nước...',
                  prefixIcon: const Icon(Icons.task_alt),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tên thói quen';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // 2. Mô tả thói quen
              const Text(
                'Mô tả mục tiêu / Động lực',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Rèn luyện khả năng tập trung và nâng cao kiến thức...',
                  prefixIcon: const Icon(Icons.notes),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // 3. Tần suất (Frequency)
              const Text(
                'Tần suất thực hiện *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Hàng ngày')),
                      selected: _frequency == 'daily',
                      onSelected: (selected) {
                        if (selected) setState(() => _frequency = 'daily');
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _frequency == 'daily' ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Tùy chỉnh ngày')),
                      selected: _frequency == 'custom',
                      onSelected: (selected) {
                        if (selected) setState(() => _frequency = 'custom');
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _frequency == 'custom' ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Nếu chọn Tùy chỉnh ngày: Hiển thị 7 ngày T2 -> CN
              if (_frequency == 'custom') ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final day = index + 1; // 1 (T2) -> 7 (CN)
                    final isSelected = _targetDays.contains(day);
                    return GestureDetector(
                      onTap: () => _toggleWeekday(day),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : (isDark ? AppColors.darkCard : Colors.white),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            DateHelper.getShortDayName(day),
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
              const SizedBox(height: 22),

              // 4. Thời gian nhắc nhở (Reminder Time)
              const Text(
                'Thời gian nhắc nhở *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            _formatTimeOfDay(_reminderTime),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Đổi giờ',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // 5. Chọn Biểu tượng (Icon)
              const Text(
                'Biểu tượng nhận diện',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppIcons.availableIcons.length,
                  itemBuilder: (context, index) {
                    final item = AppIcons.availableIcons[index];
                    final isSelected = item.key == _selectedIconKey;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIconKey = item.key),
                      child: Container(
                        width: 52,
                        height: 52,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : (isDark ? AppColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black54),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),

              // 6. Chọn Màu sắc
              const Text(
                'Màu sắc chủ đề',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.habitColors.length,
                  itemBuilder: (context, index) {
                    final color = AppColors.habitColors[index];
                    final isSelected = color.value == _selectedColorValue;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorValue = color.value),
                      child: Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.6),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    isEditing ? 'LƯU THAY ĐỔI' : 'TẠO THÓI QUEN MỚI',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
