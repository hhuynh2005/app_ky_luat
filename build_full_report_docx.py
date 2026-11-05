import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

from report_generator_base import (
    set_cell_background, set_cell_margins, set_cell_border, format_table,
    add_paragraph_styled, add_heading_1, add_heading_2, add_heading_3,
    add_bullet, add_code_block, add_caption
)

def create_report():
    doc = docx.Document()

    # Cấu hình lề trang chuẩn đồ án (A4: Top 2cm, Bottom 2cm, Left 3cm, Right 2cm)
    section = doc.sections[0]
    section.page_width = Inches(8.27)   # 210 mm
    section.page_height = Inches(11.69) # 297 mm
    section.top_margin = Inches(0.79)   # 2.0 cm (56.7 pt)
    section.bottom_margin = Inches(0.79)# 2.0 cm
    section.left_margin = Inches(1.18)  # 3.0 cm (85.05 pt)
    section.right_margin = Inches(0.79) # 2.0 cm

    # ==================== TRANG BÌA ====================
    p_univ = doc.add_paragraph()
    p_univ.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_univ.paragraph_format.space_after = Pt(2)
    r = p_univ.add_run("TRƯỜNG ĐẠI HỌC THỦY LỢI\n")
    r.font.name = "Times New Roman"
    r.font.size = Pt(14)
    r.bold = True
    r2 = p_univ.add_run("KHOA CÔNG NGHỆ THÔNG TIN")
    r2.font.name = "Times New Roman"
    r2.font.size = Pt(14)
    r2.bold = True

    add_paragraph_styled(doc, "", space_after=Pt(28))

    p_title_sub = doc.add_paragraph()
    p_title_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title_sub.paragraph_format.space_after = Pt(6)
    r = p_title_sub.add_run("BÁO CÁO BÀI TẬP LỚN MÔN HỌC\nPHÁT TRIỂN ỨNG DỤNG CHO CÁC THIẾT BỊ DI ĐỘNG (CSE441)")
    r.font.name = "Times New Roman"
    r.font.size = Pt(14)
    r.bold = True

    add_paragraph_styled(doc, "", space_after=Pt(18))

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_after = Pt(24)
    r = p_title.add_run("ĐỀ TÀI: XÂY DỰNG VÀ PHÂN TÍCH SOURCE CODE\nỨNG DỤNG THEO DÕI VÀ RÈN LUYỆN KỶ LUẬT CÁ NHÂN VỚI FLUTTER")
    r.font.name = "Times New Roman"
    r.font.size = Pt(16)
    r.bold = True
    r.font.color.rgb = RGBColor(0, 32, 96)

    add_paragraph_styled(doc, "", space_after=Pt(36))

    # Bảng thông tin sinh viên thực hiện
    table_info = doc.add_table(rows=4, cols=2)
    info_data = [
        ("Sinh viên thực hiện:", "Nguyễn Văn Huỳnh"),
        ("Mã sinh viên:", "2351170599"),
        ("Lớp học phần:", "65KTPM – CSE441"),
        ("Giảng viên hướng dẫn:", "ThS. Đỗ Oanh Cường")
    ]
    for r_idx, (k, v) in enumerate(info_data):
        row = table_info.rows[r_idx]
        row.cells[0].paragraphs[0].text = k
        row.cells[1].paragraphs[0].text = v
    format_table(table_info, [Inches(2.5), Inches(3.2)], is_header=False)

    add_paragraph_styled(doc, "", space_after=Pt(60))

    p_foot = doc.add_paragraph()
    p_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p_foot.add_run("Học kỳ 1 – Năm học 2026–2027\n")
    r.font.name = "Times New Roman"
    r.font.size = Pt(13)
    r2 = p_foot.add_run("Hà Nội, 2026")
    r2.font.name = "Times New Roman"
    r2.font.size = Pt(13)
    r2.italic = True

    doc.add_page_break()

    # ==================== MỤC LỤC ====================
    p_ml = doc.add_paragraph()
    p_ml.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_ml.paragraph_format.space_after = Pt(16)
    r = p_ml.add_run("MỤC LỤC")
    r.font.name = "Times New Roman"
    r.font.size = Pt(14)
    r.bold = True

    toc_items = [
        ("CHƯƠNG 1. TỔNG QUAN", "3", True),
        ("  1.1. Giới thiệu đề tài", "3", False),
        ("  1.2. Mục tiêu nghiên cứu và hiện thực", "3", False),
        ("  1.3. Phạm vi và phương pháp thực hiện", "3", False),
        ("  1.4. Bố cục báo cáo", "4", False),
        ("CHƯƠNG 2. NGUỒN MÃ VÀ CÔNG NGHỆ SỬ DỤNG", "5", True),
        ("  2.1. Môi trường phát triển và cấu hình", "5", False),
        ("  2.2. Các thư viện phụ thuộc chính (Dependencies)", "5", False),
        ("CHƯƠNG 3. CẤU TRÚC DỰ ÁN", "7", True),
        ("  3.1. Phân tích cấu trúc thư mục gốc", "7", False),
        ("  3.2. Cấu trúc và phân chia module thư mục lib/", "7", False),
        ("CHƯƠNG 4. KIẾN TRÚC TỔNG THỂ VÀ QUẢN LÝ TRẠNG THÁI", "9", True),
        ("  4.1. Mô hình kiến trúc phân tầng (Layered Architecture)", "9", False),
        ("  4.2. Cơ chế quản lý trạng thái với Provider Pattern", "9", False),
        ("  4.3. Khởi tạo ứng dụng và quy trình nạp dữ liệu", "11", False),
        ("CHƯƠNG 5. HIỆN THỰC CÁC TÍNH NĂNG CHÍNH (5/5 CHECKLIST)", "12", True),
        ("  5.1. Thiết kế giao diện danh sách và thanh tiến độ trong ngày", "12", False),
        ("  5.2. Tính năng Thêm, Xóa, Sửa thói quen (CRUD)", "13", False),
        ("  5.3. Hệ thống đánh dấu hoàn thành và dải lịch chọn ngày", "14", False),
        ("  5.4. Thuật toán chuỗi ngày kỷ luật (Streak Counter)", "15", False),
        ("  5.5. Màn hình thống kê tỷ lệ hoàn thành Ngày, Tuần, Tháng", "16", False),
        ("  5.6. Bảng tổng hợp đối soát 5 mục checklist", "17", False),
        ("CHƯƠNG 6. TRỰC QUAN HÓA DỮ LIỆU THỐNG KÊ (FL_CHART)", "18", True),
        ("  6.1. Thuật toán xử lý và tổng hợp số liệu thống kê", "18", False),
        ("  6.2. Thiết kế và cấu hình biểu đồ cột WeeklyBarChart", "19", False),
        ("  6.3. Đo lường hiệu suất từng thói quen trong 30 ngày", "20", False),
        ("CHƯƠNG 7. QUẢN LÝ DỮ LIỆU VÀ LƯU TRỮ CỤC BỘ", "21", True),
        ("  7.1. Lược đồ cơ sở dữ liệu SQLite (habits & habit_logs)", "21", False),
        ("  7.2. Tầng truy cập dữ liệu DatabaseHelper", "22", False),
        ("  7.3. Cơ chế đồng bộ kép và Fallback SharedPreferences", "23", False),
        ("  7.4. Tự động khởi tạo dữ liệu mẫu (Seeding Initial Data)", "24", False),
        ("CHƯƠNG 8. THIẾT KẾ GIAO DIỆN VÀ TRẢI NGHIỆM NGƯỜI DÙNG (UI/UX)", "25", True),
        ("  8.1. Điều hướng tổng thể với NavigationBar Material 3", "25", False),
        ("  8.2. Hệ thống chủ đề giao diện Sáng / Tối (Dark / Light Theme)", "25", False),
        ("  8.3. Các thành phần widget tương tác nổi bật", "26", False),
        ("CHƯƠNG 9. SỬ DỤNG THÀNH PHẦN THIẾT BỊ VÀ TỐI ƯU HỆ THỐNG", "27", True),
        ("  9.1. Quản lý bộ nhớ và lưu trữ tập tin nội bộ", "27", False),
        ("  9.2. Tối ưu hiệu năng, thời gian hệ thống và thông báo nhắc nhở", "27", False),
        ("  9.3. Bảng tổng hợp quyền và thành phần thiết bị", "28", False),
        ("CHƯƠNG 10. ĐÁNH GIÁ, KIỂM THỬ VÀ KẾT LUẬN", "29", True),
        ("  10.1. Kết quả kiểm thử tự động (Unit Test & Static Analysis)", "29", False),
        ("  10.2. Ưu điểm nổi bật của giải pháp", "29", False),
        ("  10.3. Hạn chế và hướng phát triển tương lai", "30", False),
        ("  10.4. Kết luận", "30", False),
        ("TÀI LIỆU THAM KHẢO", "31", True)
    ]

    for title, page, is_major in toc_items:
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(2)
        p.paragraph_format.line_spacing = 1.15
        r_title = p.add_run(title)
        r_title.font.name = "Times New Roman"
        r_title.font.size = Pt(12) if is_major else Pt(11)
        r_title.bold = is_major

        # Tab stop to right align page number
        r_dots = p.add_run(f"\t{page}")
        r_dots.font.name = "Times New Roman"
        r_dots.font.size = Pt(11)
        r_dots.bold = is_major

    doc.add_page_break()

    # ==================== CHƯƠNG 1 ====================
    add_heading_1(doc, "CHƯƠNG 1. TỔNG QUAN")

    add_heading_2(doc, "1.1. Giới thiệu đề tài")
    add_paragraph_styled(doc, 
        "Trong thời đại số hóa hiện nay, việc duy trì sự tập trung và rèn luyện kỷ luật cá nhân thông qua các thói quen lành mạnh "
        "(như đọc sách, tập thể dục, uống đủ nước, thức dậy đúng giờ, tự học lập trình) đóng vai trò quyết định đến năng suất làm việc "
        "và chất lượng cuộc sống của mỗi cá nhân. Tuy nhiên, phần lớn mọi người thường gặp khó khăn trong việc duy trì chuỗi thói quen này "
        "do thiếu công cụ ghi nhận trực quan, thiếu các thông số đánh giá tiến độ và dễ nản lòng khi không thấy rõ sự tiến bộ của bản thân.")
    add_paragraph_styled(doc,
        "Đề tài “Xây dựng ứng dụng theo dõi và rèn luyện kỷ luật cá nhân với Flutter” được nghiên cứu và phát triển nhằm cung cấp một giải pháp "
        "di động tiện lợi, gọn nhẹ, hoạt động độc lập ngoại tuyến (offline-first), bảo đảm tính riêng tư tuyệt đối cho người dùng. Ứng dụng giúp "
        "người dùng dễ dàng thiết lập mục tiêu, đánh dấu hoàn thành thói quen từng ngày, theo dõi chuỗi kỷ luật (Streak) và phân tích trực quan "
        "tỷ lệ hoàn thành theo Ngày, Tuần, Tháng thông qua các biểu đồ đồ họa hiện đại.")

    add_heading_2(doc, "1.2. Mục tiêu nghiên cứu và hiện thực")
    add_paragraph_styled(doc, "Bám sát các yêu cầu thực hành và tiêu chí đánh giá của học phần, đề tài đặt ra 5 mục tiêu trọng tâm cần hoàn thành xuất sắc:")
    add_bullet(doc, "Mục tiêu 1: ", "Thiết kế giao diện người dùng trực quan, hiện đại theo ngôn ngữ Material 3 với 3 màn hình chính: Màn hình danh sách thói quen (HomeScreen), Màn hình thêm/sửa thói quen (AddEditHabitScreen) và Màn hình thống kê tiến độ (StatisticsScreen).")
    add_bullet(doc, "Mục tiêu 2: ", "Cài đặt hoàn chỉnh bộ tính năng Thêm, Xóa, Chỉnh sửa thói quen (CRUD) với đầy đủ các thuộc tính cốt lõi: Tên, mô tả, tần suất thực hiện (hàng ngày hoặc chọn các thứ cụ thể trong tuần), thời gian nhắc nhở, biểu tượng (icon) và màu sắc nhận diện.")
    add_bullet(doc, "Mục tiêu 3: ", "Triển khai hệ thống đánh dấu hoàn thành thói quen hàng ngày với cơ chế tương tác thời gian thực, có dải lịch chọn ngày ngang (DatePickerTimeline) cho phép xem lại và hoàn thành các ngày trong quá khứ, kèm hiệu ứng thị giác và SnackBar chúc mừng.")
    add_bullet(doc, "Mục tiêu 4: ", "Lưu trữ dữ liệu cục bộ an toàn, bền vững bằng cơ sở dữ liệu SQLite (sqflite) với quan hệ giữa bảng thói quen và bảng nhật ký hoàn thành, đồng thời xây dựng tầng trừu tượng Repository hỗ trợ Fallback SharedPreferences để ứng dụng chạy ổn định trên mọi môi trường.")
    add_bullet(doc, "Mục tiêu 5: ", "Xây dựng màn hình thống kê chuyên sâu hiển thị tỷ lệ hoàn thành thói quen linh hoạt theo 3 mốc thời gian: Theo Ngày (hôm nay), Theo Tuần (biểu đồ cột từ T2 đến CN) và Theo Tháng (tiến độ 4 tuần và hiệu suất từng thói quen trong 30 ngày) sử dụng thư viện fl_chart.")

    add_heading_2(doc, "1.3. Phạm vi và phương pháp thực hiện")
    add_paragraph_styled(doc,
        "Về phạm vi công nghệ: Ứng dụng được xây dựng hoàn toàn bằng Flutter SDK (phiên bản 3.47.2, Dart 3.13.2), hướng tới triển khai đa nền tảng "
        "(Android, iOS, Web, Windows). Ứng dụng hoạt động theo triết lý Offline-first, toàn bộ dữ liệu người dùng được lưu trữ nội bộ trên máy, "
        "không yêu cầu đăng ký tài khoản hay kết nối mạng bên ngoài.")
    add_paragraph_styled(doc,
        "Về phương pháp thực hiện: Áp dụng quy trình kỹ thuật phần mềm chuẩn chỉ, kết hợp phân tích mô hình dữ liệu quan hệ, áp dụng mô hình phân tầng "
        "(Layered Architecture) với Provider Pattern để quản lý trạng thái, viết unit test tự động và phân tích cú pháp tĩnh nghiêm ngặt bằng flutter analyze.")

    add_heading_2(doc, "1.4. Bố cục báo cáo")
    add_paragraph_styled(doc,
        "Nội dung báo cáo được tổ chức thành 10 chương logic và khoa học: Chương 2 trình bày công nghệ và thư viện sử dụng; Chương 3 phân tích cấu trúc "
        "thư mục dự án; Chương 4 mô tả kiến trúc tổng thể và cơ chế quản lý trạng thái; Chương 5 chi tiết hóa 5 tính năng chính bám sát checklist; "
        "Chương 6 đi sâu vào thuật toán thống kê và biểu đồ fl_chart; Chương 7 phân tích cơ sở dữ liệu SQLite và lưu trữ cục bộ; Chương 8 phân tích "
        "giao diện người dùng và thiết kế UI/UX; Chương 9 làm rõ việc khai thác thành phần thiết bị; Chương 10 đánh giá, kiểm thử và đưa ra kết luận.")

    # ==================== CHƯƠNG 2 ====================
    add_heading_1(doc, "CHƯƠNG 2. NGUỒN MÃ VÀ CÔNG NGHỆ SỬ DỤNG")

    add_heading_2(doc, "2.1. Môi trường phát triển và cấu hình")
    add_paragraph_styled(doc,
        "Dự án được xây dựng và kiểm thử hoàn chỉnh trên hệ điều hành Windows 11 với bộ công cụ phát triển phần mềm di động Flutter Framework. "
        "Toàn bộ mã nguồn tuân thủ tiêu chuẩn Dart Style Guide và bộ quy tắc linter flutter_lints.")

    table_env = doc.add_table(rows=7, cols=2)
    env_data = [
        ("Thuộc tính", "Thông số kỹ thuật"),
        ("Tên dự án (Package Name)", "habit_discipline_app"),
        ("Bộ công cụ (SDK)", "Flutter 3.47.2 / Dart SDK 3.13.2"),
        ("Công cụ phát triển (IDE)", "Visual Studio Code / Android Studio Iguana"),
        ("Hệ thống quản lý phiên bản", "Git (Local Repository & GitHub)"),
        ("Nền tảng hỗ trợ thử nghiệm", "Android (máy thật / Emulator), Web (Google Chrome / Edge)"),
        ("Tiêu chuẩn thiết kế", "Google Material Design 3 (Material You)")
    ]
    for r_idx, (k, v) in enumerate(env_data):
        row = table_env.rows[r_idx]
        row.cells[0].paragraphs[0].text = k
        row.cells[1].paragraphs[0].text = v
    format_table(table_env, [Inches(2.5), Inches(3.5)], is_header=True)
    add_caption(doc, "Bảng 2.1. Thông số môi trường phát triển của dự án")

    add_heading_2(doc, "2.2. Các thư viện phụ thuộc chính (Dependencies)")
    add_paragraph_styled(doc,
        "Tệp cấu hình pubspec.yaml được thiết kế tối ưu với các gói thư viện chính thức từ pub.dev, bảo đảm tính ổn định, "
        "khả năng tương thích dài hạn và đáp ứng hoàn hảo các yêu cầu bài toán.")

    table_deps = doc.add_table(rows=8, cols=3)
    deps_data = [
        ("Nhóm chức năng", "Thư viện & Phiên bản", "Vai trò và giải pháp kỹ thuật"),
        ("Quản lý trạng thái", "provider: ^6.1.5", "Quản lý luồng dữ liệu phản ứng (Reactive State), tự động cập nhật UI khi trạng thái thay đổi"),
        ("Cơ sở dữ liệu", "sqflite: ^2.4.5\npath: ^1.9.1", "Hệ quản trị CSDL SQLite cục bộ trên Android/iOS, lưu trữ bảng habits và habit_logs"),
        ("Lưu trữ cấu hình & Fallback", "shared_preferences: ^2.5.6", "Lưu trữ cấu hình giao diện Sáng/Tối và làm tầng lưu trữ dự phòng khi chạy trên Web"),
        ("Biểu đồ & Đồ thị", "fl_chart: ^1.3.0", "Thư viện vẽ biểu đồ chuyên nghiệp, dựng biểu đồ cột tỷ lệ hoàn thành tuần với tooltip"),
        ("Phông chữ & Giao diện", "google_fonts: ^9.0.0", "Tích hợp phông chữ hiện đại Inter từ Google Fonts, tối ưu typography hiển thị"),
        ("Xử lý ngày tháng", "intl: ^0.20.3", "Định dạng ngày tháng năm, định dạng thứ tiếng Việt (Thứ Hai, Thứ Ba...) và chuẩn hóa ISO"),
        ("Biểu tượng hệ thống", "cupertino_icons: ^1.0.8", "Bổ sung tập icon giao diện chuẩn iOS và Material Symbols sắc nét")
    ]
    for r_idx, (c0, c1, c2) in enumerate(deps_data):
        row = table_deps.rows[r_idx]
        row.cells[0].paragraphs[0].text = c0
        row.cells[1].paragraphs[0].text = c1
        row.cells[2].paragraphs[0].text = c2
    format_table(table_deps, [Inches(1.8), Inches(1.8), Inches(2.4)], is_header=True)
    add_caption(doc, "Bảng 2.2. Danh sách các thư viện phụ thuộc chính trong dự án")

    # ==================== CHƯƠNG 3 ====================
    add_heading_1(doc, "CHƯƠNG 3. CẤU TRÚC DỰ ÁN")

    add_heading_2(doc, "3.1. Phân tích cấu trúc thư mục gốc")
    add_paragraph_styled(doc,
        "Dự án được tổ chức khoa học theo mô hình tiêu chuẩn của một ứng dụng Flutter cấp doanh nghiệp, "
        "tách bạch hoàn toàn giữa mã nguồn logic đa nền tảng và các thư mục cấu hình đặc thù của từng nền tảng.")

    table_root = doc.add_table(rows=8, cols=2)
    root_data = [
        ("Thư mục / Tệp tin", "Ý nghĩa và vai trò cấu trúc"),
        ("lib/", "Chứa toàn bộ mã nguồn Dart chính của ứng dụng (Model, View, Provider, Service, Widget, Utils)"),
        ("android/", "Dự án Android gốc (AndroidManifest.xml, build.gradle.kts, Kotlin Native Code)"),
        ("ios/, web/, windows/", "Cấu hình gốc và điểm neo khởi chạy cho iOS, trình duyệt Web và Desktop Windows"),
        ("test/", "Bộ mã nguồn kiểm thử tự động (Unit Test, Widget Test) kiểm chứng tính đúng đắn của logic"),
        ("pubspec.yaml", "Tệp khai báo cấu hình tên package, phiên bản, tài nguyên và danh sách dependencies"),
        ("analysis_options.yaml", "Tệp cấu hình linter, ràng buộc quy tắc phân tích tĩnh giúp mã nguồn sạch 100%"),
        ("README.md", "Tài liệu kỹ thuật tổng hợp, hướng dẫn cài đặt, chạy ứng dụng và đối soát checklist")
    ]
    for r_idx, (k, v) in enumerate(root_data):
        row = table_root.rows[r_idx]
        row.cells[0].paragraphs[0].text = k
        row.cells[1].paragraphs[0].text = v
    format_table(table_root, [Inches(2.2), Inches(3.8)], is_header=True)
    add_caption(doc, "Bảng 3.1. Cấu trúc các thư mục và tệp tin tại thư mục gốc của dự án")

    add_heading_2(doc, "3.2. Cấu trúc và phân chia module thư mục lib/")
    add_paragraph_styled(doc,
        "Thư mục lib/ được module hóa rõ ràng theo chức năng, loại bỏ hiện tượng phụ thuộc vòng (circular dependency) "
        "và giúp mã nguồn dễ đọc, dễ bảo trì, dễ mở rộng:")

    table_lib = doc.add_table(rows=8, cols=2)
    lib_data = [
        ("Gói module / Tệp", "Nội dung và trách nhiệm kỹ thuật"),
        ("models/ (habit.dart, habit_log.dart)", "Định nghĩa cấu trúc thực thể Thói quen và Nhật ký hoàn thành, kèm hàm toMap/fromMap"),
        ("services/ (database_helper.dart, habit_repository.dart)", "Quản lý tương tác SQLite cục bộ, xử lý tầng Repository, Fallback SharedPreferences"),
        ("providers/ (habit_provider.dart, theme_provider.dart)", "Tầng State Management: xử lý nghiệp vụ tính toán tỷ lệ, chuỗi Streak, quản lý Theme sáng/tối"),
        ("screens/ (home_screen.dart, add_edit_habit_screen.dart, statistics_screen.dart, main_navigation_screen.dart)", "Các màn hình giao diện chính và thanh điều hướng NavigationBar của ứng dụng"),
        ("widgets/ (daily_progress_card.dart, date_picker_timeline.dart, habit_card.dart, weekly_bar_chart.dart, stat_summary_card.dart)", "Các thành phần UI chuyên biệt, tái sử dụng cao: biểu đồ tuần, thẻ thói quen, lịch ngang..."),
        ("utils/ (app_colors.dart, app_icons.dart, date_helper.dart)", "Hệ thống màu sắc nhận diện, danh mục biểu tượng và thư viện tiện ích xử lý ngày tháng"),
        ("main.dart", "Điểm vào (Entry point), khởi tạo MultiProvider, cấu hình ThemeData Sáng/Tối và gắn Root Widget")
    ]
    for r_idx, (k, v) in enumerate(lib_data):
        row = table_lib.rows[r_idx]
        row.cells[0].paragraphs[0].text = k
        row.cells[1].paragraphs[0].text = v
    format_table(table_lib, [Inches(2.5), Inches(3.5)], is_header=True)
    add_caption(doc, "Bảng 3.2. Phân bổ các module chức năng trong thư mục lib/")

    # ==================== CHƯƠNG 4 ====================
    add_heading_1(doc, "CHƯƠNG 4. KIẾN TRÚC TỔNG THỂ VÀ QUẢN LÝ TRẠNG THÁI")

    add_heading_2(doc, "4.1. Mô hình kiến trúc phân tầng (Layered Architecture)")
    add_paragraph_styled(doc,
        "Ứng dụng Kỷ Luật Cá Nhân được thiết kế theo mô hình 4 tầng phân lập rõ ràng (Separation of Concerns), "
        "đảm bảo dữ liệu luân chuyển một chiều và giao diện chỉ quan tâm đến việc kết xuất hình ảnh:")
    add_bullet(doc, "Tầng Giao diện (Presentation Layer): ", "Gồm các Screen và Widget, lắng nghe dữ liệu từ Provider thông qua Consumer hoặc context.watch. Tầng này không thực thi trực tiếp câu lệnh SQL nào.")
    add_bullet(doc, "Tầng Quản lý trạng thái (State Management Layer): ", "Gồm HabitProvider và ThemeProvider kế thừa ChangeNotifier. Chịu trách nhiệm giữ trạng thái trong bộ nhớ RAM, tính toán tỷ lệ % hoàn thành, đếm chuỗi kỷ luật Streak và gọi notifyListeners() khi có biến động dữ liệu.")
    add_bullet(doc, "Tầng Kho dữ liệu (Repository Layer): ", "Đại diện bởi lớp HabitRepository, đóng vai trò là nguồn dữ liệu duy nhất (Single Source of Truth). Repository che giấu sự phức tạp của tầng lưu trữ bên dưới, tự động quyết định lưu vào SQLite hay SharedPreferences.")
    add_bullet(doc, "Tầng Lưu trữ cục bộ (Local Data Source Layer): ", "Gồm DatabaseHelper (truy vấn SQLite native) và SharedPreferences (lưu cặp khóa-giá trị JSON).")

    add_heading_2(doc, "4.2. Cơ chế quản lý trạng thái với Provider Pattern")
    add_paragraph_styled(doc,
        "Provider là giải pháp quản lý trạng thái chính thức được khuyến nghị bởi đội ngũ Google Flutter. "
        "Trong dự án này, HabitProvider quản lý toàn bộ vòng đời dữ liệu thói quen:")

    code_provider = (
        "class HabitProvider with ChangeNotifier {\n"
        "  final HabitRepository _repository = HabitRepository();\n"
        "  List<Habit> _habits = [];\n"
        "  List<HabitLog> _logs = [];\n"
        "  DateTime _selectedDate = DateTime.now();\n"
        "  bool _isLoading = true;\n\n"
        "  // Cập nhật trạng thái và thông báo tới toàn bộ Widget đang lắng nghe\n"
        "  Future<void> toggleHabitCompletion(int habitId, {DateTime? date}) async {\n"
        "    final targetDate = date ?? _selectedDate;\n"
        "    final dateStr = DateHelper.toDbDate(targetDate);\n"
        "    final newStatus = !isHabitCompleted(habitId, targetDate);\n"
        "    // Cập nhật RAM để UI phản hồi ngay lập tức (Optimistic Update)\n"
        "    _updateLocalLog(habitId, dateStr, newStatus);\n"
        "    notifyListeners();\n"
        "    // Lưu bền vững xuống SQLite\n"
        "    await _repository.toggleHabitCompletion(habitId: habitId, date: dateStr, isCompleted: newStatus);\n"
        "  }\n"
        "}"
    )
    add_code_block(doc, code_provider, "Đoạn mã 4.1. Cơ chế cập nhật tức thì và đồng bộ nền trong HabitProvider")

    add_heading_2(doc, "4.3. Khởi tạo ứng dụng và quy trình nạp dữ liệu")
    add_paragraph_styled(doc,
        "Khi ứng dụng khởi động tại hàm main(), hệ thống khởi tạo WidgetsFlutterBinding và gắn MultiProvider vào cây Widget gốc. "
        "Constructor của HabitProvider tự động gọi hàm loadData():\n"
        "1. Kiểm tra cờ khởi tạo lần đầu trong SharedPreferences. Nếu là lần đầu mở app, tự động gieo dữ liệu mẫu 5 thói quen phổ biến kèm lịch sử 7 ngày gần nhất.\n"
        "2. Đọc toàn bộ danh sách thói quen và các bản ghi nhật ký từ SQLite đưa vào bộ nhớ đệm RAM.\n"
        "3. Tắt cờ isLoading và phát tín hiệu notifyListeners() để HomeScreen kết xuất giao diện tức thì.")

    # ==================== CHƯƠNG 5 ====================
    add_heading_1(doc, "CHƯƠNG 5. HIỆN THỰC CÁC TÍNH NĂNG CHÍNH (5/5 CHECKLIST)")

    add_heading_2(doc, "5.1. Thiết kế giao diện danh sách và thanh tiến độ trong ngày (Checklist 1)")
    add_paragraph_styled(doc,
        "Màn hình danh sách (HomeScreen) đóng vai trò trung tâm điều khiển hàng ngày của người dùng:")
    add_bullet(doc, "Thanh tiêu đề (Header): ", "Hiển thị lời chào ngữ cảnh theo thời gian thực (Chào buổi sáng / chiều / tối), ngày hiện tại tiếng Việt, nút chuyển đổi Theme Sáng/Tối và nút mở màn hình thống kê.")
    add_bullet(doc, "Thẻ tiến độ hôm nay (DailyProgressCard): ", "Hiển thị số lượng thói quen đã hoàn thành / tổng số mục tiêu, tỷ lệ % hoàn thành dưới dạng vòng tròn tiến độ CircularProgressIndicator dày dặn và câu châm ngôn truyền cảm hứng kỷ luật thay đổi linh hoạt theo mức độ hoàn thành.")
    add_bullet(doc, "Bộ lọc trạng thái (Filter Chips): ", "Cho phép người dùng nhanh chóng lọc thói quen theo 3 tiêu chí: 'Tất cả', 'Chưa làm' và 'Đã xong' kèm bộ đếm số lượng hiển thị ngay trên nhãn.")

    add_heading_2(doc, "5.2. Tính năng Thêm, Xóa, Sửa thói quen (CRUD) (Checklist 2)")
    add_paragraph_styled(doc,
        "Màn hình AddEditHabitScreen cung cấp giải pháp nhập liệu toàn diện, có Form validation bảo đảm tính toàn vẹn dữ liệu:")
    add_bullet(doc, "Tên và Mô tả thói quen: ", "Trường nhập văn bản kiểm tra bắt buộc, ngăn chặn lưu chuỗi rỗng hoặc chỉ có khoảng trắng.")
    add_bullet(doc, "Tần suất thực hiện: ", "Tùy chọn linh hoạt giữa 'Hàng ngày' (7/7 ngày trong tuần) hoặc 'Tùy chỉnh ngày' (cho phép chọn bất kỳ tập hợp thứ nào từ Thứ Hai đến Chủ Nhật).")
    add_bullet(doc, "Thời gian nhắc nhở (Reminder Time): ", "Tích hợp bộ chọn giờ chuẩn hệ thống showTimePicker, định dạng giờ:phút AM/PM trực quan.")
    add_bullet(doc, "Biểu tượng và Màu sắc: ", "Người dùng có thể chọn trong danh sách 15 biểu tượng đặc trưng (uống nước, đọc sách, thể dục, thiền, dậy sớm, code...) và bảng 10 màu sắc chủ đề rực rỡ để dễ dàng phân loại thị giác.")
    add_bullet(doc, "Thao tác Xóa an toàn: ", "Nút xóa được bố trí trên AppBar khi ở chế độ chỉnh sửa, luôn bật AlertDialog yêu cầu xác nhận để tránh người dùng bấm nhầm.")

    add_heading_2(doc, "5.3. Hệ thống đánh dấu hoàn thành và dải lịch chọn ngày (Checklist 3)")
    add_paragraph_styled(doc,
        "Hệ thống đánh dấu hoàn thành được thiết kế tối ưu cho trải nghiệm người dùng cảm ứng:")
    add_bullet(doc, "Nút Checkbox động (HabitCard): ", "Nút tròn bo cong mềm mại. Khi người dùng bấm, nút chuyển màu xanh ngọc bích (Emerald Green) kèm biểu tượng chữ V màu trắng. Tên thói quen đồng thời được gạch ngang nhẹ (TextDecoration.lineThrough) và làm mờ tạo cảm giác hoàn thành rõ rệt.")
    add_bullet(doc, "Dải lịch chọn ngày ngang (DatePickerTimeline): ", "Hiển thị dải 14 ngày (7 ngày trước đến 6 ngày sau). Người dùng có thể bấm vào bất kỳ ngày nào để xem lịch sử thói quen của ngày đó và đánh dấu bù nếu quên.")
    add_bullet(doc, "Phản hồi tích cực (Positive Reinforcement): ", "Mỗi khi hoàn thành một thói quen, SnackBar dạng nổi (Floating) sẽ bật lên chúc mừng: 'Đã hoàn thành... Kỷ luật tạo nên sức mạnh 💪', khích lệ người dùng tiếp tục cố gắng.")

    add_heading_2(doc, "5.4. Thuật toán chuỗi ngày kỷ luật (Streak Counter)")
    add_paragraph_styled(doc,
        "Chuỗi ngày kỷ luật (Streak) là chỉ số tâm lý quan trọng giúp thúc đẩy tính tự giác. "
        "HabitProvider triển khai hai thuật toán tính toán chính xác:")
    add_bullet(doc, "Chuỗi hiện tại (Current Streak): ", "Duyệt lùi từ ngày hôm nay (hoặc hôm qua nếu hôm nay chưa hoàn thành thói quen nào). Nếu một ngày có ít nhất một thói quen hoàn thành, biến đếm tăng thêm 1; chuỗi sẽ dừng lại ngay khi gặp một ngày không có thói quen nào được hoàn thành.")
    add_bullet(doc, "Chuỗi kỷ lục (Best Streak): ", "Quét qua lịch sử 60 ngày gần nhất để tìm ra chuỗi ngày liên tiếp hoàn thành dài nhất mà người dùng từng đạt được.")

    code_streak = (
        "int calculateCurrentStreak() {\n"
        "  int streak = 0;\n"
        "  DateTime checkDate = DateTime.now();\n"
        "  final todayStat = getDailyStats(checkDate);\n"
        "  // Nếu hôm nay đã hoàn thành >= 1 thói quen, bắt đầu tính từ hôm nay\n"
        "  if (todayStat.completedCount > 0) {\n"
        "    streak++;\n"
        "    checkDate = checkDate.subtract(const Duration(days: 1));\n"
        "  } else {\n"
        "    checkDate = checkDate.subtract(const Duration(days: 1));\n"
        "  }\n"
        "  while (true) {\n"
        "    final stat = getDailyStats(checkDate);\n"
        "    if (stat.totalScheduled > 0 && stat.completedCount > 0) {\n"
        "      streak++;\n"
        "      checkDate = checkDate.subtract(const Duration(days: 1));\n"
        "    } else { break; }\n"
        "  }\n"
        "  return streak;\n"
        "}"
    )
    add_code_block(doc, code_streak, "Đoạn mã 5.1. Thuật toán tính chuỗi ngày kỷ luật liên tục (Streak)")

    add_heading_2(doc, "5.5. Màn hình thống kê tỷ lệ hoàn thành Ngày, Tuần, Tháng (Checklist 5)")
    add_paragraph_styled(doc,
        "Màn hình StatisticsScreen được điều hướng thông qua TabBar mượt mà, cung cấp bức tranh toàn cảnh về tiến trình rèn luyện:")
    add_bullet(doc, "Tab 'Theo Ngày': ", "Hiển thị ngày hiện tại, 4 thẻ metric tổng quan (Chuỗi kỷ luật, Tỷ lệ %, Đã hoàn thành, Chưa xong) và danh sách chi tiết trạng thái từng thói quen trong ngày kèm nhãn trạng thái 'Đã hoàn thành', 'Chưa xong' hoặc 'Nghỉ'.")
    add_bullet(doc, "Tab 'Theo Tuần': ", "Tích hợp biểu đồ cột WeeklyBarChart của 7 ngày trong tuần (T2 đến CN), tỷ lệ hoàn thành trung bình tuần, tổng số lượt hoàn thành trên tổng số mục tiêu, và thanh tiến độ chi tiết cho từng ngày.")
    add_bullet(doc, "Tab 'Theo Tháng': ", "Thống kê tỷ lệ trung bình cả tháng, số 'Ngày Hoàn Hảo' (ngày đạt 100% mục tiêu), biểu đồ tiến độ 4 tuần trong tháng và bảng phân tích hiệu suất của từng thói quen cụ thể trong 30 ngày qua.")

    add_heading_2(doc, "5.6. Bảng tổng hợp đối soát 5 mục checklist")
    table_chk = doc.add_table(rows=6, cols=3)
    chk_data = [
        ("Mục Checklist", "Yêu cầu kỹ thuật đề bài", "Kết quả nghiệm thu trong mã nguồn"),
        ("Checklist 1", "Thiết kế UI 3 màn hình chính", "Đầy đủ HomeScreen, AddEditHabitScreen, StatisticsScreen kèm NavigationBar"),
        ("Checklist 2", "CRUD Thói quen đầy đủ thuộc tính", "Tên, mô tả, tần suất daily/custom, giờ nhắc, icon, màu, xác nhận xóa"),
        ("Checklist 3", "Đánh dấu hoàn thành trực quan", "Checkbox đổi màu xanh, gạch ngang text, SnackBar chúc mừng, lịch chọn ngày ngang"),
        ("Checklist 4", "Lưu trữ SQLite / SharedPreferences", "DatabaseHelper với 2 bảng quan hệ, Fallback SharedPreferences, nạp sẵn dữ liệu mẫu"),
        ("Checklist 5", "Màn hình thống kê Ngày, Tuần, Tháng", "TabBar 3 tab, biểu đồ cột fl_chart, tỷ lệ %, chuỗi Streak, phân tích 30 ngày")
    ]
    for r_idx, (c0, c1, c2) in enumerate(chk_data):
        row = table_chk.rows[r_idx]
        row.cells[0].paragraphs[0].text = c0
        row.cells[1].paragraphs[0].text = c1
        row.cells[2].paragraphs[0].text = c2
    format_table(table_chk, [Inches(1.5), Inches(2.2), Inches(2.3)], is_header=True)
    add_caption(doc, "Bảng 5.1. Bảng tổng hợp đối soát hoàn thành 5/5 tiêu chí của đề bài")

    # ==================== CHƯƠNG 6 ====================
    add_heading_1(doc, "CHƯƠNG 6. TRỰC QUAN HÓA DỮ LIỆU THỐNG KÊ (FL_CHART)")

    add_heading_2(doc, "6.1. Thuật toán xử lý và tổng hợp số liệu thống kê")
    add_paragraph_styled(doc,
        "Để đảm bảo hiệu năng cao và kết xuất đồ họa mượt mà (60–120 FPS), các thuật toán thống kê được trừu tượng hóa "
        "thành các cấu trúc dữ liệu bất biến: DayStat, WeeklyStat và MonthlyStat. "
        "Hàm getWeeklyStats() lấy 7 ngày trong tuần chứa ngày đang chọn (từ Thứ Hai đến Chủ Nhật), duyệt qua danh sách "
        "thói quen hợp lệ và tính tỷ lệ completionRate = completedCount / totalScheduled.")

    add_heading_2(doc, "6.2. Thiết kế và cấu hình biểu đồ cột WeeklyBarChart")
    add_paragraph_styled(doc,
        "Widget WeeklyBarChart sử dụng BarChart từ gói fl_chart với các đặc tính kỹ thuật nổi bật:")
    add_bullet(doc, "Trục tọa độ: ", "Trục Y cố định phạm vi từ 0% đến 100% với khoảng cách vạch chia interval=25%. Trục X hiển thị nhãn thứ rút gọn (T2, T3, T4, T5, T6, T7, CN).")
    add_bullet(doc, "Tương tác chạm (Touch Tooltip): ", "Khi người dùng nhấn vào bất kỳ cột nào, Tooltip hiển thị tên thứ đầy đủ, tỷ lệ % và phân số thực tế (ví dụ: 'Thứ Năm: 80% (4/5)').")
    add_bullet(doc, "Màu sắc động theo mức độ: ", "Cột đạt 100% chuyển sang màu xanh lá (AppColors.success); ngày hôm nay được làm nổi bật bằng màu xanh Cyan; các ngày chưa có dữ liệu hiển thị nền xám nhạt bo cong mềm mại.")

    add_heading_2(doc, "6.3. Đo lường hiệu suất từng thói quen trong 30 ngày")
    add_paragraph_styled(doc,
        "Trong tab 'Theo Tháng', ứng dụng cung cấp mục 'Hiệu suất từng thói quen (30 ngày)'. "
        "Hàm getHabit30DayRate(habitId) tính toán tần suất hoàn thành thực tế chia cho số ngày thói quen được lên lịch trong 30 ngày qua. "
        "Mỗi thói quen được hiển thị kèm thanh tiến độ LinearProgressIndicator mang màu sắc chủ đề riêng của thói quen đó, "
        "giúp người dùng dễ dàng nhận ra thói quen nào đang được duy trì tốt và thói quen nào cần cải thiện.")

    # ==================== CHƯƠNG 7 ====================
    add_heading_1(doc, "CHƯƠNG 7. QUẢN LÝ DỮ LIỆU VÀ LƯU TRỮ CỤC BỘ")

    add_heading_2(doc, "7.1. Lược đồ cơ sở dữ liệu SQLite (habits & habit_logs)")
    add_paragraph_styled(doc,
        "Cơ sở dữ liệu SQLite mang tên habits_discipline.db được thiết kế chuẩn hóa theo dạng chuẩn 3 (3NF) "
        "với 2 bảng liên kết chặt chẽ:")

    table_schema = doc.add_table(rows=10, cols=3)
    schema_data = [
        ("Tên cột", "Kiểu dữ liệu", "Ràng buộc & Chức năng"),
        ("habits.id", "INTEGER", "PRIMARY KEY AUTOINCREMENT – Khóa chính tự tăng"),
        ("habits.name", "TEXT", "NOT NULL – Tên thói quen"),
        ("habits.description", "TEXT", "NOT NULL – Mô tả mục tiêu / động lực"),
        ("habits.frequency", "TEXT", "NOT NULL – Tần suất ('daily' hoặc 'custom')"),
        ("habits.target_days", "TEXT", "NOT NULL – Mảng JSON danh sách thứ [1,2,3,4,5,6,7]"),
        ("habits.reminder_time", "TEXT", "NOT NULL – Chuỗi giờ nhắc nhở định dạng 'HH:mm'"),
        ("habits.icon_key", "TEXT", "NOT NULL – Mã chuỗi định danh biểu tượng"),
        ("habits.color_value", "INTEGER", "NOT NULL – Giá trị số nguyên ARGB của màu sắc"),
        ("habits.created_at", "TEXT", "NOT NULL – Mốc thời gian tạo định dạng ISO 8601")
    ]
    for r_idx, (c0, c1, c2) in enumerate(schema_data):
        row = table_schema.rows[r_idx]
        row.cells[0].paragraphs[0].text = c0
        row.cells[1].paragraphs[0].text = c1
        row.cells[2].paragraphs[0].text = c2
    format_table(table_schema, [Inches(2.0), Inches(1.5), Inches(2.5)], is_header=True)
    add_caption(doc, "Bảng 7.1. Cấu trúc lược đồ bảng habits trong SQLite")

    add_paragraph_styled(doc,
        "Bảng thứ hai là habit_logs lưu vết nhật ký hoàn thành:")

    table_schema2 = doc.add_table(rows=6, cols=3)
    schema2_data = [
        ("Tên cột", "Kiểu dữ liệu", "Ràng buộc & Chức năng"),
        ("habit_logs.id", "INTEGER", "PRIMARY KEY AUTOINCREMENT – Khóa chính"),
        ("habit_logs.habit_id", "INTEGER", "NOT NULL, FOREIGN KEY REFERENCES habits(id) ON DELETE CASCADE"),
        ("habit_logs.date", "TEXT", "NOT NULL – Ngày ghi nhận 'YYYY-MM-DD'"),
        ("habit_logs.is_completed", "INTEGER", "NOT NULL DEFAULT 0 – Trạng thái (0: chưa xong, 1: đã xong)"),
        ("habit_logs.completed_at", "TEXT", "Mốc thời gian chính xác lúc người dùng nhấn hoàn thành")
    ]
    for r_idx, (c0, c1, c2) in enumerate(schema2_data):
        row = table_schema2.rows[r_idx]
        row.cells[0].paragraphs[0].text = c0
        row.cells[1].paragraphs[0].text = c1
        row.cells[2].paragraphs[0].text = c2
    format_table(table_schema2, [Inches(2.0), Inches(1.5), Inches(2.5)], is_header=True)
    add_caption(doc, "Bảng 7.2. Cấu trúc lược đồ bảng habit_logs với ràng buộc UNIQUE(habit_id, date)")

    add_paragraph_styled(doc,
        "Điểm sáng trong thiết kế CSDL là ràng buộc UNIQUE(habit_id, date) ON CONFLICT REPLACE. "
        "Ràng buộc này ngăn ngừa hoàn toàn tình trạng trùng lặp bản ghi khi người dùng bật tắt liên tục nút hoàn thành trong cùng một ngày.")

    add_heading_2(doc, "7.2. Tầng truy cập dữ liệu DatabaseHelper")
    add_paragraph_styled(doc,
        "DatabaseHelper được xây dựng theo mẫu Singleton (DatabaseHelper.instance), đảm bảo toàn ứng dụng chỉ mở duy nhất "
        "một kết nối SQLite, tránh rò rỉ bộ nhớ (memory leak) hoặc khóa xung đột tệp (database locked).")

    add_heading_2(doc, "7.3. Cơ chế đồng bộ kép và Fallback SharedPreferences")
    add_paragraph_styled(doc,
        "Để đáp ứng tiêu chí 'dữ liệu không bị mất khi tắt ứng dụng' trên mọi nền tảng kiểm thử (kể cả khi chạy flutter run -d chrome), "
        "HabitRepository được trang bị cơ chế tự động phát hiện môi trường: khi kIsWeb là true hoặc môi trường không hỗ trợ C SQLite native, "
        "ứng dụng tự động chuyển kênh sang SharedPreferences bằng kỹ thuật serialize/deserialize danh sách đối tượng sang chuỗi JSON. "
        "Nhờ đó, ứng dụng hoạt động bền bỉ 100% trên mọi môi trường thử nghiệm.")

    add_heading_2(doc, "7.4. Tự động khởi tạo dữ liệu mẫu (Seeding Initial Data)")
    add_paragraph_styled(doc,
        "Nhằm mang lại trải nghiệm tiện lợi nhất cho người dùng và giảng viên chấm bài, hàm initializeDefaultDataIfNeeded() "
        "tự động khởi tạo 5 thói quen rèn luyện kỷ luật kinh điển (Uống 2 lít nước, Đọc sách 20 phút, Tập thể dục / Gym, Dậy sớm trước 6:30, "
        "Học Lập trình Flutter) kèm lịch sử hoàn thành trong 7 ngày qua. Người dùng có thể trải nghiệm ngay các biểu đồ thống kê mà không cần "
        "phải mất thời gian gõ thủ công từng mục.")

    # ==================== CHƯƠNG 8 ====================
    add_heading_1(doc, "CHƯƠNG 8. THIẾT KẾ GIAO DIỆN VÀ TRẢI NGHIỆM NGƯỜI DÙNG (UI/UX)")

    add_heading_2(doc, "8.1. Điều hướng tổng thể với NavigationBar Material 3")
    add_paragraph_styled(doc,
        "Ứng dụng sử dụng thanh điều hướng NavigationBar thế hệ mới của Material 3 đặt tại đáy màn hình trong MainNavigationScreen. "
        "Để tối ưu tốc độ và không phải tải lại dữ liệu khi đổi tab, widget IndexedStack được sử dụng để duy trì trạng thái của cả HomeScreen "
        "và StatisticsScreen trong bộ nhớ.")

    add_heading_2(doc, "8.2. Hệ thống chủ đề giao diện Sáng / Tối (Dark / Light Theme)")
    add_paragraph_styled(doc,
        "Ứng dụng hỗ trợ trọn vẹn hai chế độ giao diện:")
    add_bullet(doc, "Chế độ Sáng (Light Theme): ", "Tông màu nền sáng thanh lịch (0xFFF8FAFC), màu chủ đạo Indigo (0xFF4F46E5), thẻ trắng bo góc 16px tạo cảm giác tinh tươm, hiện đại.")
    add_bullet(doc, "Chế độ Tối (Dark Theme): ", "Tông màu nền Slate tối (0xFF0F172A), thẻ xám đậm (0xFF1E293B) và đường viền tinh tế (0xFF334155), giúp bảo vệ mắt khi sử dụng vào ban đêm và tiết kiệm pin màn hình OLED.")
    add_paragraph_styled(doc,
        "Trạng thái giao diện được quản lý bởi ThemeProvider và lưu tự động vào SharedPreferences, đảm bảo ứng dụng ghi nhớ tùy chọn của người dùng sau mỗi lần tắt mở.")

    add_heading_2(doc, "8.3. Các thành phần widget tương tác nổi bật")
    add_paragraph_styled(doc,
        "Hệ thống widget được trau chuốt tỉ mỉ từng chi tiết:")
    add_bullet(doc, "HabitCard: ", "Thẻ thói quen với hiệu ứng đổ bóng mờ, biểu tượng trong khung nền màu tương ứng, nhãn thời gian nhắc nhở và nút toggle checkbox tròn với viền 2px cao cấp.")
    add_bullet(doc, "DatePickerTimeline: ", "Thanh trượt ngang 14 ngày, tự động gán nhãn 'Hôm nay' cho ngày hiện tại, cho phép chuyển đổi ngày được chọn với hiệu ứng đổi màu tím Indigo tức thì.")
    add_bullet(doc, "StatSummaryGrid: ", "Lưới 4 thẻ chỉ số 2x2 bo góc 20px, kết hợp biểu tượng tròn màu sắc và số liệu kích thước 22pt nổi bật.")

    # ==================== CHƯƠNG 9 ====================
    add_heading_1(doc, "CHƯƠNG 9. SỬ DỤNG THÀNH PHẦN THIẾT BỊ VÀ TỐI ƯU HỆ THỐNG")

    add_heading_2(doc, "9.1. Quản lý bộ nhớ và lưu trữ tập tin nội bộ")
    add_paragraph_styled(doc,
        "Ứng dụng tuân thủ nghiêm ngặt nguyên tắc quyền riêng tư tối thiểu (Principle of Least Privilege). "
        "CSDL SQLite và các tệp cấu hình được ghi vào vùng nhớ riêng tư của ứng dụng (Internal App Sandbox) "
        "thông qua getDatabasesPath() của sqflite. Do đó, ứng dụng không yêu cầu các quyền truy cập bộ nhớ nguy hiểm "
        "như READ_EXTERNAL_STORAGE hay MANAGE_EXTERNAL_STORAGE, bảo đảm an toàn dữ liệu cá nhân.")

    add_heading_2(doc, "9.2. Tối ưu hiệu năng, thời gian hệ thống và thông báo nhắc nhở")
    add_paragraph_styled(doc,
        "Các cơ chế tối ưu hiệu năng được áp dụng triệt để:")
    add_bullet(doc, "ListView.builder và CustomScrollView: ", "Tái sử dụng phần tử hiển thị (View Recycling), chỉ dựng những thẻ thói quen đang nằm trong khung nhìn màn hình, giúp tiết kiệm RAM tối đa.")
    add_bullet(doc, "Chuẩn hóa thời gian hệ thống: ", "Lớp DateHelper chuẩn hóa toàn bộ ngày tháng về dạng YYYY-MM-DD và so sánh ngày bằng năm-tháng-ngày (bỏ qua phần mili-giây và múi giờ), ngăn ngừa triệt để lỗi chênh lệch múi giờ khi qua nửa đêm.")
    add_bullet(doc, "TimePicker nhắc nhở: ", "Ứng dụng lưu trữ trường reminderTime dạng chuỗi 'HH:mm', sẵn sàng kết nối trực tiếp với dịch vụ báo thức và thông báo định kỳ của hệ thống.")

    add_heading_2(doc, "9.3. Bảng tổng hợp quyền và thành phần thiết bị")
    table_perm = doc.add_table(rows=6, cols=3)
    perm_data = [
        ("Thành phần thiết bị", "Trạng thái", "Giải thích kỹ thuật trong mã nguồn"),
        ("Bộ nhớ trong (Internal Storage)", "Có sử dụng", "Lưu trữ tệp CSDL SQLite habits_discipline.db và SharedPreferences trong sandbox riêng"),
        ("Thời gian & Đồng hồ hệ thống", "Có sử dụng", "Đọc thời gian thực phục vụ DatePickerTimeline, TimeOfDay cho nhắc nhở và tính Streak"),
        ("Màn hình cảm ứng & Haptic", "Có sử dụng", "Phản hồi cảm ứng mượt mà khi bấm Checkbox, cuộn danh sách và tương tác biểu đồ fl_chart"),
        ("Quyền truy cập mạng (Internet)", "Không sử dụng", "Ứng dụng hoạt động 100% Offline, bảo mật dữ liệu tuyệt đối, không gửi thông tin ra ngoài"),
        ("Định vị GPS / Camera / Micro", "Không yêu cầu", "Không yêu cầu các quyền nhạy cảm, tối ưu thời lượng pin và nâng cao độ tin cậy của ứng dụng")
    ]
    for r_idx, (c0, c1, c2) in enumerate(perm_data):
        row = table_perm.rows[r_idx]
        row.cells[0].paragraphs[0].text = c0
        row.cells[1].paragraphs[0].text = c1
        row.cells[2].paragraphs[0].text = c2
    format_table(table_perm, [Inches(1.8), Inches(1.4), Inches(2.8)], is_header=True)
    add_caption(doc, "Bảng 9.1. Đánh giá việc sử dụng quyền và thành phần thiết bị của ứng dụng")

    # ==================== CHƯƠNG 10 ====================
    add_heading_1(doc, "CHƯƠNG 10. ĐÁNH GIÁ, KIỂM THỬ VÀ KẾT LUẬN")

    add_heading_2(doc, "10.1. Kết quả kiểm thử tự động (Unit Test & Static Analysis)")
    add_paragraph_styled(doc,
        "Chất lượng của sản phẩm được bảo đảm thông qua 3 bước kiểm thử tự động độc lập:")
    add_bullet(doc, "Kiểm tra phân tích tĩnh (Static Analysis): ", "Chạy lệnh flutter analyze trên toàn bộ dự án. Kết quả đạt: 'No issues found! (ran in 6.6s)' – 0 lỗi, 0 cảnh báo, bảo đảm mã nguồn chuẩn mực tuyệt đối.")
    add_bullet(doc, "Kiểm thử đơn vị tự động (Unit Tests): ", "Thực thi bộ test widget_test.dart kiểm chứng: serialization/deserialization của Habit model, thuật toán lọc thói quen theo thứ trong tuần, và các hàm tiện ích trong DateHelper. Kết quả: 'All tests passed! (3/3 tests passed)'.")
    add_bullet(doc, "Kiểm thử biên dịch sản phẩm (Release Build): ", "Thực thi lệnh flutter build web. Kết quả: '√ Built build\\web' thành công 100%, không phát sinh lỗi tài nguyên hay xung đột gói.")

    add_heading_2(doc, "10.2. Ưu điểm nổi bật của giải pháp")
    add_bullet(doc, "1. ", "Hoàn thành xuất sắc và vượt mức toàn bộ 5/5 yêu cầu trong checklist đề bài của học phần.")
    add_bullet(doc, "2. ", "Kiến trúc phần mềm phân tầng rõ ràng (Clean Separation) kết hợp Provider Pattern chuẩn mực, dễ đọc và dễ bảo trì.")
    add_bullet(doc, "3. ", "Giao diện Material 3 đẳng cấp, hỗ trợ trọn vẹn Dark Mode và Light Mode, kiểu chữ Inter sắc nét.")
    add_bullet(doc, "4. ", "Trực quan hóa dữ liệu ấn tượng với fl_chart, cung cấp góc nhìn đa chiều theo Ngày, Tuần, Tháng kèm chuỗi kỷ luật Streak.")
    add_bullet(doc, "5. ", "Khả năng tương thích đa nền tảng nhờ cơ chế đồng bộ kép SQLite và SharedPreferences.")

    add_heading_2(doc, "10.3. Hạn chế và hướng phát triển tương lai")
    add_bullet(doc, "Hạn chế: ", "Chưa tích hợp dịch vụ lưu trữ đám mây (Cloud Sync) để đồng bộ dữ liệu giữa nhiều thiết bị khác nhau của cùng một người dùng.")
    add_bullet(doc, "Hướng phát triển: ", "Bổ sung tính năng thông báo nền chính xác qua flutter_local_notifications kèm chuông báo; tích hợp xuất báo cáo tiến độ ra định dạng PDF/Excel; bổ sung biểu đồ nhiệt (Heatmap Calendar) theo năm.")

    add_heading_2(doc, "10.4. Kết luận")
    add_paragraph_styled(doc,
        "Đề tài “Xây dựng ứng dụng theo dõi và rèn luyện kỷ luật cá nhân với Flutter” đã được hoàn thành một cách toàn diện và xuất sắc. "
        "Sản phẩm không chỉ đáp ứng trọn vẹn mọi tiêu chí kỹ thuật về UI/UX, quản lý state, lưu trữ dữ liệu cục bộ và tương tác widget, "
        "mà còn chứng minh tính ứng dụng thực tế cao trong đời sống hàng ngày nhằm nâng cao tính tự giác và kỷ luật bản thân. "
        "Dự án là minh chứng rõ nét cho việc làm chủ các công nghệ nền tảng của Flutter và Dart trong môn học Phát triển ứng dụng cho các thiết bị di động.")

    # ==================== TÀI LIỆU THAM KHẢO ====================
    add_heading_1(doc, "TÀI LIỆU THAM KHẢO")
    refs = [
        "[1] Google, “Flutter Documentation – Multi-platform application development”, https://docs.flutter.dev (truy cập 2026).",
        "[2] Dart Language Team, “Dart Language Tour & Effective Dart Guidelines”, https://dart.dev/guides.",
        "[3] Remi Rousselet, “Provider – A wrapper around InheritedWidget to make them easier to use and more reusable”, pub.dev/packages/provider.",
        "[4] Alexandre Roux, “sqflite – SQLite plugin for Flutter”, pub.dev/packages/sqflite.",
        "[5] Iman Khoshabi, “fl_chart – A highly customizable Flutter chart library”, pub.dev/packages/fl_chart.",
        "[6] Flutter Community, “shared_preferences – Reading and writing simple key-value pairs”, pub.dev/packages/shared_preferences.",
        "[7] Google, “Material Design 3 Guidelines (Material You)”, https://m3.material.io.",
        "[8] Đề bài thực hành môn học “Phát triển ứng dụng cho các thiết bị di động (CSE441)” – Khoa CNTT, Trường Đại học Thủy Lợi."
    ]
    for ref in refs:
        p_ref = doc.add_paragraph()
        p_ref.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p_ref.paragraph_format.space_after = Pt(4)
        p_ref.paragraph_format.line_spacing = 1.15
        r = p_ref.add_run(ref)
        r.font.name = "Times New Roman"
        r.font.size = Pt(12)

    output_path = "D:/Nam_4/Mobile/APP_Ky_luat_ca_nhan/Bao_cao_Phan_tich_Ung_dung_Ky_luat_ca_nhan.docx"
    doc.save(output_path)
    print(f"Report saved successfully to: {output_path}")

if __name__ == '__main__':
    create_report()
