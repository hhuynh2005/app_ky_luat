import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../utils/date_helper.dart';
import '../widgets/daily_progress_card.dart';
import '../widgets/date_picker_timeline.dart';
import '../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all'; // 'all', 'pending', 'completed'

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng 🌅';
    if (hour < 18) return 'Chào buổi chiều 🌤️';
    return 'Chào buổi tối 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedDate = habitProvider.selectedDate;
    final isToday = DateHelper.isSameDay(selectedDate, DateTime.now());
    final scheduledHabits = habitProvider.habitsForSelectedDate;

    // Lọc thói quen theo bộ lọc
    final filteredHabits = scheduledHabits.where((h) {
      final isDone = habitProvider.isHabitCompleted(h.id ?? -1, selectedDate);
      if (_filter == 'pending') return !isDone;
      if (_filter == 'completed') return isDone;
      return true;
    }).toList();

    // Thống kê ngày được chọn
    final dayStat = habitProvider.getDailyStats(selectedDate);

    return Scaffold(
      body: SafeArea(
        child: habitProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar / Top Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Kỷ Luật Cá Nhân',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Nút chuyển Dark/Light theme
                              IconButton(
                                icon: Icon(
                                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                  color: themeProvider.isDarkMode ? Colors.amber : AppColors.primary,
                                ),
                                tooltip: 'Chuyển đổi giao diện Sáng / Tối',
                                onPressed: () => themeProvider.toggleTheme(),
                              ),
                              // Nút đến trang Thống kê
                              IconButton(
                                icon: const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 28),
                                tooltip: 'Xem thống kê tiến độ',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Daily Progress Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: DailyProgressCard(
                        totalCount: dayStat.totalScheduled,
                        completedCount: dayStat.completedCount,
                        percentage: dayStat.completionRate,
                      ),
                    ),
                  ),

                  // Date Picker Timeline
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: DatePickerTimeline(
                        selectedDate: selectedDate,
                        onDateSelected: (date) {
                          habitProvider.selectDate(date);
                        },
                      ),
                    ),
                  ),

                  // Section Title & Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isToday ? 'Thói quen hôm nay' : 'Lịch: ${DateHelper.getShortDayName(selectedDate.weekday)}, ${DateHelper.formatShortDate(selectedDate)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${dayStat.completedCount}/${dayStat.totalScheduled} xong',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('Tất cả (${scheduledHabits.length})', 'all'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Chưa làm (${dayStat.totalScheduled - dayStat.completedCount})', 'pending'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Đã xong (${dayStat.completedCount})', 'completed'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // List of Habits
                  if (filteredHabits.isEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _filter == 'completed' ? Icons.check_circle_outline : Icons.sentiment_satisfied_alt,
                              size: 56,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _filter == 'completed'
                                  ? 'Chưa có thói quen nào hoàn thành'
                                  : (_filter == 'pending' ? 'Tất cả thói quen đã hoàn thành!' : 'Không có thói quen cho ngày này'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _filter == 'completed'
                                  ? 'Hãy tích vào các thói quen để ghi nhận sự kỷ luật của bạn!'
                                  : 'Nhấn nút dấu (+) bên dưới để tạo thêm thói quen mới.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final habit = filteredHabits[index];
                          final isCompleted = habitProvider.isHabitCompleted(habit.id ?? -1, selectedDate);

                          return HabitCard(
                            habit: habit,
                            isCompleted: isCompleted,
                            onToggle: () {
                              habitProvider.toggleHabitCompletion(habit.id ?? -1);
                              final updatedStatus = !isCompleted;
                              if (updatedStatus) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text('Đã hoàn thành "${habit.name}"! Kỷ luật tạo nên sức mạnh 💪')),
                                      ],
                                    ),
                                    backgroundColor: AppColors.success,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditHabitScreen(habit: habit),
                                ),
                              );
                            },
                            onDelete: () {
                              _confirmDeleteHabit(context, habit);
                            },
                          );
                        },
                        childCount: filteredHabits.length,
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 90), // chừa khoảng trống cho FAB
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditHabitScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm Thói Quen',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _filter = value);
      },
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _confirmDeleteHabit(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa thói quen "${habit.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              if (habit.id != null) {
                Provider.of<HabitProvider>(context, listen: false).deleteHabit(habit.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa thói quen.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
