import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../utils/date_helper.dart';
import '../widgets/stat_summary_card.dart';
import '../widgets/weekly_bar_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final today = DateTime.now();
    final dailyStat = habitProvider.getDailyStats(today);
    final weeklyStat = habitProvider.getWeeklyStats(today);
    final monthlyStat = habitProvider.getMonthlyStats(today);

    final currentStreak = habitProvider.calculateCurrentStreak();
    final bestStreak = habitProvider.calculateBestStreak();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống Kê Tiến Độ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Theo Ngày'),
            Tab(text: 'Theo Tuần'),
            Tab(text: 'Theo Tháng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. TAB THEO NGÀY
          _buildDayTab(context, dailyStat, currentStreak, bestStreak, habitProvider),

          // 2. TAB THEO TUẦN
          _buildWeekTab(context, weeklyStat, currentStreak, habitProvider),

          // 3. TAB THEO THÁNG
          _buildMonthTab(context, monthlyStat, habitProvider),
        ],
      ),
    );
  }

  // ================= 1. TAB THEO NGÀY =================
  Widget _buildDayTab(
    BuildContext context,
    DayStat stat,
    int currentStreak,
    int bestStreak,
    HabitProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentInt = (stat.completionRate * 100).toInt();

    final metrics = [
      StatMetricItem(
        title: 'Chuỗi Kỷ Luật',
        value: '$currentStreak ngày',
        subtitle: 'Kỷ lục: $bestStreak ngày',
        icon: Icons.local_fire_department,
        color: AppColors.warning,
      ),
      StatMetricItem(
        title: 'Tỷ Lệ Hoàn Thành',
        value: '$percentInt%',
        subtitle: '${stat.completedCount}/${stat.totalScheduled} thói quen',
        icon: Icons.pie_chart,
        color: AppColors.primary,
      ),
      StatMetricItem(
        title: 'Đã Hoàn Thành',
        value: '${stat.completedCount}',
        subtitle: 'Mục tiêu hôm nay',
        icon: Icons.check_circle,
        color: AppColors.success,
      ),
      StatMetricItem(
        title: 'Chưa Xong',
        value: '${stat.totalScheduled - stat.completedCount}',
        subtitle: 'Cần tiếp tục cố gắng',
        icon: Icons.pending_actions,
        color: AppColors.error,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ngày hiện tại
          Text(
            DateHelper.formatFullDate(stat.date),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Lưới chỉ số
          StatSummaryGrid(metrics: metrics),
          const SizedBox(height: 24),

          // Danh sách chi tiết thói quen hôm nay
          Text(
            'Chi tiết thói quen hôm nay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (provider.habits.isEmpty)
            _buildEmptyStat(isDark, 'Chưa có thói quen nào.')
          else
            ...provider.habits.map((habit) {
              final isDone = provider.isHabitCompleted(habit.id ?? -1, stat.date);
              final isScheduled = habit.isScheduledForDate(stat.date);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: habit.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(AppIcons.getIconByKey(habit.iconKey), color: habit.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            isScheduled ? 'Nhắc nhở: ${habit.reminderTime}' : 'Không có lịch hôm nay',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: !isScheduled
                            ? Colors.grey.withOpacity(0.15)
                            : (isDone ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        !isScheduled
                            ? 'Nghỉ'
                            : (isDone ? 'Đã hoàn thành' : 'Chưa xong'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !isScheduled
                              ? Colors.grey
                              : (isDone ? AppColors.success : AppColors.error),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ================= 2. TAB THEO TUẦN =================
  Widget _buildWeekTab(
    BuildContext context,
    WeeklyStat weeklyStat,
    int currentStreak,
    HabitProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avgPercent = (weeklyStat.averageRate * 100).toInt();

    final metrics = [
      StatMetricItem(
        title: 'Tỷ Lệ Tuần',
        value: '$avgPercent%',
        subtitle: 'Trung bình tuần này',
        icon: Icons.trending_up,
        color: AppColors.primary,
      ),
      StatMetricItem(
        title: 'Tổng Hoàn Thành',
        value: '${weeklyStat.totalCompleted}',
        subtitle: 'Trên ${weeklyStat.totalScheduled} lượt giao',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      StatMetricItem(
        title: 'Chuỗi Kỷ Luật',
        value: '$currentStreak ngày',
        subtitle: 'Duy trì liên tục',
        icon: Icons.local_fire_department,
        color: AppColors.warning,
      ),
      StatMetricItem(
        title: 'Mục Tiêu Tuần',
        value: '${(weeklyStat.totalScheduled / 7).toStringAsFixed(1)}/ngày',
        subtitle: 'Kế hoạch trung bình',
        icon: Icons.flag,
        color: AppColors.accent,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Biểu đồ cột fl_chart tuần
          WeeklyBarChart(weeklyStat: weeklyStat),
          const SizedBox(height: 20),

          // Lưới tóm tắt chỉ số tuần
          StatSummaryGrid(metrics: metrics),
          const SizedBox(height: 24),

          // Chi tiết từng ngày trong tuần
          Text(
            'Tiến độ 7 ngày trong tuần',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ...weeklyStat.dailyStats.map((dayStat) {
            final rate = (dayStat.completionRate * 100).toInt();
            final dayName = DateHelper.getDayOfWeekName(dayStat.date.weekday);
            final shortDate = DateHelper.formatShortDate(dayStat.date);
            final isToday = DateHelper.isSameDay(dayStat.date, DateTime.now());

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isToday ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isToday ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isToday ? AppColors.primary : null,
                              ),
                            ),
                            if (isToday)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Hôm nay',
                                  style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          shortDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: dayStat.completionRate,
                        minHeight: 8,
                        backgroundColor: isDark ? Colors.white12 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          rate == 100 ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '$rate%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= 3. TAB THEO THÁNG =================
  Widget _buildMonthTab(
    BuildContext context,
    MonthlyStat monthlyStat,
    HabitProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avgMonthPercent = (monthlyStat.averageRate * 100).toInt();

    final metrics = [
      StatMetricItem(
        title: 'Tỷ Lệ Tháng',
        value: '$avgMonthPercent%',
        subtitle: DateHelper.formatMonthYear(monthlyStat.month),
        icon: Icons.calendar_month,
        color: AppColors.primary,
      ),
      StatMetricItem(
        title: 'Ngày Hoàn Hảo',
        value: '${monthlyStat.perfectDaysCount} ngày',
        subtitle: 'Đạt 100% mục tiêu',
        icon: Icons.star,
        color: AppColors.warning,
      ),
      StatMetricItem(
        title: 'Lượt Hoàn Thành',
        value: '${monthlyStat.totalCompleted}',
        subtitle: 'Trong tháng này',
        icon: Icons.task_alt,
        color: AppColors.success,
      ),
      StatMetricItem(
        title: 'Tổng Thói Quen',
        value: '${provider.habits.length}',
        subtitle: 'Đang rèn luyện',
        icon: Icons.fitness_center,
        color: AppColors.accent,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thẻ tháng
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFEEF2FF), Colors.white],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateHelper.formatMonthYear(monthlyStat.month),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tổng quan kỷ luật tháng này',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lưới tóm tắt chỉ số tháng
          StatSummaryGrid(metrics: metrics),
          const SizedBox(height: 24),

          // Tiến độ qua các tuần trong tháng
          Text(
            'Tiến độ qua các tuần',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: List.generate(monthlyStat.weeklyAverages.length, (i) {
                final rate = (monthlyStat.weeklyAverages[i] * 100).toInt();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          'Tuần ${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: monthlyStat.weeklyAverages[i],
                            minHeight: 10,
                            backgroundColor: isDark ? Colors.white12 : Colors.black12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              rate >= 75 ? AppColors.success : (rate >= 50 ? AppColors.primary : AppColors.warning),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$rate%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Đánh giá hiệu suất từng thói quen trong 30 ngày qua
          Text(
            'Hiệu suất từng thói quen (30 ngày)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (provider.habits.isEmpty)
            _buildEmptyStat(isDark, 'Chưa có thói quen nào.')
          else
            ...provider.habits.map((habit) {
              final rate30 = provider.getHabit30DayRate(habit.id ?? -1);
              final percent = (rate30 * 100).toInt();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: habit.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(AppIcons.getIconByKey(habit.iconKey), color: habit.color, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            habit.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: habit.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: rate30,
                        minHeight: 6,
                        backgroundColor: isDark ? Colors.white12 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(habit.color),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyStat(bool isDark, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}
