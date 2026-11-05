# ỨNG DỤNG THEO DÕI VÀ RÈN LUYỆN KỶ LUẬT CÁ NHÂN (FLUTTER)

> **Môn học:** Lập trình Thiết bị Di động (Mobile App Development)  
> **Nền tảng:** Flutter 3.x & Dart 3.x (Hỗ trợ Android, iOS, Web, Windows)  
> **Kiến trúc:** Provider Pattern + Clean Separation (Model - View - Provider - Repository - Database)  
> **Lưu trữ dữ liệu:** SQLite (`sqflite`) + SharedPreferences Fallback  
> **Giao diện:** Material 3, Dark/Light Mode, Google Fonts, Biểu đồ thống kê `fl_chart`

---

## 🎯 BÁO CÁO KẾT QUẢ ĐẠT ĐƯỢC THEO CHECKLIST ĐỀ BÀI (5/5 MỤC)

| STT | Yêu cầu Đề bài | Trạng thái | Chi tiết hiện thực trong mã nguồn |
| :---: | :--- | :---: | :--- |
| **1** | **Thiết kế UI 3 màn hình chính** (Danh sách thói quen, Thêm/sửa thói quen, Thống kê tiến độ) | ✅ **HOÀN THÀNH 100%** | • Màn hình danh sách (`HomeScreen`): Thẻ tiến độ hôm nay, dải lịch chọn ngày trực quan, bộ lọc, thẻ thói quen bo góc hiện đại.<br>• Màn hình thêm/sửa (`AddEditHabitScreen`): Form nhập liệu, chọn icon, chọn bảng màu, chọn tần suất, bộ chọn giờ TimePicker.<br>• Màn hình thống kê (`StatisticsScreen`): Điều hướng bằng TabBar (Theo Ngày, Theo Tuần, Theo Tháng), tóm tắt chỉ số kỷ luật. |
| **2** | **Tính năng Thêm, Xóa, Sửa thói quen** (Tên, mô tả, tần suất, thời gian nhắc nhở) | ✅ **HOÀN THÀNH 100%** | • Hỗ trợ đầy đủ các thuộc tính: `name`, `description`, `frequency` ('daily' / 'custom' theo thứ trong tuần), `reminderTime` (HH:mm), `iconKey`, `colorValue`.<br>• Dialog xác nhận xóa an toàn để tránh thao tác nhầm.<br>• Form validation kiểm tra dữ liệu hợp lệ trước khi lưu. |
| **3** | **Đánh dấu hoàn thành thói quen hàng ngày** trực quan | ✅ **HOÀN THÀNH 100%** | • Nút tròn Checkbox tương tác với hiệu ứng chuyển màu xanh ngọc bích (`AppColors.success`).<br>• Thói quen hoàn thành tự động gạch ngang chữ và làm mờ nhẹ để phân biệt.<br>• Dải lịch ngang (`DatePickerTimeline`) cho phép xem lại và tích hoàn thành cho các ngày trước hoặc ngày hôm nay.<br>• SnackBar khích lệ tức thì khi hoàn thành mục tiêu. |
| **4** | **Lưu trữ dữ liệu cục bộ** (SQLite / SharedPreferences) không mất khi tắt app | ✅ **HOÀN THÀNH 100%** | • Lớp `DatabaseHelper`: Tạo cơ sở dữ liệu SQLite `habits_discipline.db` với 2 bảng liên kết: `habits` và `habit_logs`.<br>• Lớp `HabitRepository`: Quản lý lưu trữ thông minh, tự động fallback sang `SharedPreferences` khi chạy trên môi trường Web/Test để đảm bảo app luôn chạy mượt 100% trên mọi thiết bị.<br>• Tự động tạo dữ liệu mẫu phong phú khi mở ứng dụng lần đầu. |
| **5** | **Màn hình thống kê tỷ lệ hoàn thành theo Ngày, Tuần, Tháng** | ✅ **HOÀN THÀNH 100%** | • **Theo Ngày:** Tỷ lệ % hoàn thành, số thói quen đã xong/chưa xong, danh sách chi tiết.<br>• **Theo Tuần:** Biểu đồ cột tương tác (`fl_chart`) thể hiện tỷ lệ % từ T2 đến CN, tỷ lệ trung bình tuần.<br>• **Theo Tháng:** Tỷ lệ trung bình toàn tháng, số "Ngày Hoàn Hảo" (đạt 100%), tiến độ qua từng tuần, hiệu suất từng thói quen trong 30 ngày. |

---

## 📁 CẤU TRÚC THƯ MỤC DỰ ÁN

```
lib/
├── main.dart                       # Entry point, cấu hình MultiProvider và Theme sáng/tối
├── models/
│   ├── habit.dart                  # Model Thói quen (tên, mô tả, tần suất, giờ nhắc, màu, icon)
│   └── habit_log.dart              # Model Nhật ký hoàn thành thói quen theo ngày
├── services/
│   ├── database_helper.dart        # SQLite Database (bảng habits và habit_logs)
│   └── habit_repository.dart       # Quản lý tầng dữ liệu, nạp dữ liệu mẫu ban đầu, đồng bộ
├── providers/
│   ├── habit_provider.dart         # State management: Thêm/Sửa/Xóa, Toggle hoàn thành, thuật toán thống kê
│   └── theme_provider.dart         # Quản lý chế độ Sáng / Tối (Dark / Light mode)
├── screens/
│   ├── main_navigation_screen.dart # Thanh điều hướng NavigationBar dưới đáy màn hình
│   ├── home_screen.dart            # Màn hình chính danh sách thói quen & tiến độ hôm nay
│   ├── add_edit_habit_screen.dart  # Màn hình thêm mới & chỉnh sửa thói quen
│   └── statistics_screen.dart      # Màn hình thống kê tỷ lệ hoàn thành Ngày, Tuần, Tháng
├── widgets/
│   ├── daily_progress_card.dart    # Thẻ tiến độ hôm nay với Circular Indicator & câu truyền động lực
│   ├── date_picker_timeline.dart   # Dải lịch chọn ngày ngang 14 ngày
│   ├── habit_card.dart             # Thẻ thói quen với nút check, menu sửa/xóa, icon & tag giờ
│   ├── weekly_bar_chart.dart       # Biểu đồ cột fl_chart tỷ lệ hoàn thành tuần (T2-CN)
│   └── stat_summary_card.dart      # Lưới thẻ metric tóm tắt chỉ số kỷ luật
└── utils/
    ├── app_colors.dart             # Bảng màu kỷ luật & màu chủ đề thói quen
    ├── app_icons.dart              # Danh sách 15 icon đại diện cho các thói quen
    └── date_helper.dart            # Tiện ích xử lý ngày tháng, thứ tiếng Việt, tuần, tháng
```

---

## 🚀 HƯỚNG DẪN CÀI ĐẶT & CHẠY ỨNG DỤNG

### 1. Yêu cầu môi trường
- Đã cài đặt [Flutter SDK](https://flutter.dev/docs/get-started/install) (phiên bản 3.x trở lên).
- Thiết bị chạy: Điện thoại Android / Máy ảo Android Emulator / Trình duyệt Chrome / Edge.

### 2. Các bước chạy ứng dụng
Mở terminal tại thư mục dự án `APP_Ky_luat_ca_nhan`:

```bash
# 1. Tải các gói phụ thuộc
flutter pub get

# 2. Kiểm tra mã nguồn (Đạt 0 lỗi: No issues found!)
flutter analyze

# 3. Chạy kiểm thử Unit Test (All tests passed!)
flutter test

# 4. Chạy ứng dụng trên máy ảo hoặc thiết bị di động
flutter run

# Hoặc chạy thử nghiệm ngay trên trình duyệt Chrome:
flutter run -d chrome
```

---

## 🌟 ĐIỂM NỔI BẬT & TÍNH NĂNG NÂNG CAO

1. **Giao diện Material 3 Đẳng Cấp:** Hỗ trợ mượt mà cả **Chế độ Sáng (Light Mode)** và **Chế độ Tối (Dark Mode)**, có nút chuyển đổi ngay trên thanh tiêu đề.
2. **Thuật toán Chuỗi Kỷ Luật (Streak Counter):** Tự động tính chuỗi ngày liên tiếp người dùng hoàn thành thói quen (`Current Streak` và `Best Streak`) để khuyến khích tinh thần kỷ luật.
3. **Phân tích Hiệu Suất Từng Thói Quen (30 ngày):** Trong màn hình thống kê Tháng, mỗi thói quen có thanh tiến độ riêng biệt để người dùng biết thói quen nào mình duy trì tốt nhất.
4. **Trải nghiệm tức thì (Zero-friction Onboarding):** Khi vừa cài và mở app lần đầu, hệ thống đã nạp sẵn 5 thói quen mẫu phổ biến (Uống nước, Đọc sách, Tập thể dục, Dậy sớm, Học Flutter) cùng lịch sử mẫu giúp người chấm có thể trải nghiệm đầy đủ các tính năng mà không cần mất công tạo từ đầu.
