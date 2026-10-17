# BÀI THỰC HÀNH: LƯU TRỮ DỮ LIỆU TRÊN MOBILE & KIẾN TRÚC OFFLINE-FIRST
*(Module 8 & Module 9 – Remote Database • Local Storage • Offline-First)*

---

## 1. Mục tiêu bài lab (Objective)
Bài thực hành này giúp sinh viên củng cố và tích hợp toàn diện các kiến thức trọng tâm từ **Module 8 & Module 9 – Mobile Data Storage**, bao gồm: **Kiến trúc Cơ sở dữ liệu đám mây (Remote Database)**, **Các giải pháp Lưu trữ cục bộ (Local Storage)**, **Quản lý giao diện bất đồng bộ (Async UI)**, và **Kiến trúc Ứng dụng chạy mượt mà ngay cả khi mất mạng (Offline-First Architecture)**.

Sinh viên sẽ trực tiếp giải quyết 3 thách thức cốt lõi trên thiết bị di động: **Mạng không ổn định**, **Tài nguyên bộ nhớ/pin có giới hạn**, và **Yêu cầu phản hồi tức thì cho người dùng**. Sau khi hoàn thành bài lab, sinh viên có thể:
- Lưu trữ dữ liệu dạng Key-Value bằng `SharedPreferences` cho cài đặt ứng dụng (Theme, cấu hình người dùng) *(Slide 8, 9)*.
- Giao tiếp an toàn với Remote Database thông qua RESTful API và Typed Dart Model, hiểu lý do vì sao không kết nối trực tiếp Mobile tới MySQL/SQL Server *(Slide 3, 4)*.
- Quản lý giao diện bất đồng bộ với `FutureBuilder` xử lý trọn vẹn 3 trạng thái: **Đang tải (Loading)**, **Xảy ra lỗi (Error kèm nút Thử lại)**, và **Thành công (Success)** *(Slide 5)*.
- Thiết kế và thao tác CSDL quan hệ cục bộ SQLite (`sqflite`) hỗ trợ đầy đủ các thao tác CRUD và bảo đảm tính toàn vẹn dữ liệu ACID *(Slide 8, 9)*.
- Xây dựng kiến trúc **Offline-First** chuẩn với **Repository Pattern**: Ghi dữ liệu vào máy trước (Local-First), duy trì hàng đợi đồng bộ (Sync Queue) và đồng bộ ngầm khi có mạng *(Slide 10, 11)*.

Tất cả các bài tập có thể chạy trực tiếp trên **Android Studio**, **VS Code**, hoặc Giả lập / Thiết bị thật Flutter.

---

## 2. Yêu cầu bài lab (Requirements)
Sinh viên hoàn thành 5 bài tập thực hành theo từng cấp độ kỹ năng:
- **Bài tập 1 – Lưu trữ Key-Value với SharedPreferences:** Lưu trữ và khôi phục cài đặt người dùng (Theme Dark/Light mode, Tên, Cờ trạng thái) mà không cần dùng bảng CSDL phức tạp.
- **Bài tập 2 – Remote Database qua RESTful API & Typed Dart Model:** Gọi REST API qua gói `http`, giải mã JSON thành đối tượng Dart Model, tách biệt hoàn toàn tầng Networking khỏi giao diện.
- **Bài tập 3 – Quản lý Giao diện Bất đồng bộ với FutureBuilder:** Ràng buộc dữ liệu bất đồng bộ vào Widget bằng `FutureBuilder`, hiển thị rõ ràng 3 trạng thái giao diện không làm đứng màn hình.
- **Bài tập 4 – Cơ sở dữ liệu Cục bộ Quan hệ với SQLite (sqflite):** Khởi tạo CSDL SQLite bằng `sqflite` (Singleton pattern), tạo bảng `tasks` và thực hiện đầy đủ các thao tác CRUD cục bộ.
- **Bài tập 5 – Kiến trúc Offline-First & Mẫu thiết kế Repository:** Triển khai tầng Repository làm nguồn dữ liệu duy nhất, ghi cục bộ trước (Local-First), gắn cờ trạng thái `isSynced` và đồng bộ hóa ngầm lên Cloud.
- **Bài tập 6 (Điểm cộng tùy chọn) – Cloud NoSQL với Firebase Firestore:** Tìm hiểu mô hình Cloud NoSQL BaaS và Stream thời gian thực qua Firebase Firestore.

### Yêu cầu kỹ thuật đối với mỗi bài tập:
1. Chương trình biên dịch và chạy thành công trên Android Studio, VS Code, hoặc Thiết bị/Giả lập Flutter.
2. Tuân thủ kiến trúc phân tầng rõ ràng (tách biệt UI Widget, Repository, và Data Services).
3. Mã nguồn có chú thích (comments) giải thích các quyết định thiết kế và xử lý ngoại lệ.

---

## 3. Các bước thực hiện chi tiết (Guided Steps)

### Bài tập 1 – Lưu trữ Key-Value với SharedPreferences
**Mục tiêu:** Lưu trữ và duy trì các thông tin cài đặt giao diện, cấu hình nhẹ của người dùng.  
**Các bước thực hiện:**
1. Thêm thư viện `shared_preferences` vào file `pubspec.yaml`.
2. Xây dựng lớp `SettingsService` với các hàm tĩnh (static) để lưu/đọc cờ giao diện tối (`isDarkMode`), tên người dùng, và mốc thời gian đồng bộ gần nhất.
3. Trên giao diện, thiết kế nút chuyển đổi (Switch) cho phép bật/tắt chế độ Dark Mode.
4. Kiểm tra: Khi người dùng gạt đổi Theme và khởi động lại ứng dụng, Theme đã chọn vẫn được giữ nguyên.

---

### Bài tập 2 – Remote Database qua RESTful API & Typed Dart Model
**Mục tiêu:** Hiện thực hóa kết nối máy chủ an toàn qua REST API và chuyển đổi dữ liệu JSON sang Dart Model.  
**Các bước thực hiện:**
1. **Ôn tập Slide 3:** Hiểu vì sao kết nối trực tiếp từ Mobile tới MySQL/SQL Server là sai kiến trúc (nguy cơ lộ mật khẩu root khi app bị dịch ngược, làm cạn kiệt pool kết nối máy chủ, thiếu kiểm soát nghiệp vụ).
2. Định nghĩa lớp mô hình `TaskItem` với các thuộc tính định kiểu rõ ràng: `id` (int?), `title` (String), `content` (String), `isSynced` (int).
3. Xây dựng hàm chuyển đổi `factory TaskItem.fromJson(Map<String, dynamic> json)` và `Map<String, dynamic> toJson()`.
4. Tạo lớp `ApiService` độc lập sử dụng thư viện `http` để gửi yêu cầu GET lấy danh sách bài viết từ endpoint công khai (ví dụ: `https://jsonplaceholder.typicode.com/posts?_limit=5`) và yêu cầu POST để thêm mới bài viết.
5. Cấu hình thời gian chờ kết nối (timeout khoảng 4-5 giây) và bắt các lỗi mạng thường gặp.

---

### Bài tập 3 – Quản lý Giao diện Bất đồng bộ với FutureBuilder
**Mục tiêu:** Trình bày dữ liệu mạng bất đồng bộ mượt mà qua 3 trạng thái giao diện mà không làm đơ ứng dụng.  
**Các bước thực hiện:**
1. **Ôn tập Slide 5:** Quy tắc "Một Future, ba trạng thái giao diện: Loading -> Error (Thử lại) -> Success".
2. Sử dụng Widget `FutureBuilder<List<TaskItem>>` gắn kết với Future lấy dữ liệu từ `ApiService`.
3. **Trạng thái 1 (Loading):** Khi `snapshot.connectionState == ConnectionState.waiting`, hiển thị vòng tròn tải dữ liệu (`CircularProgressIndicator`) kèm văn bản thông báo.
4. **Trạng thái 2 (Error):** Khi `snapshot.hasError == true`, hiển thị biểu tượng cảnh báo lỗi, thông báo lỗi thân thiện và nút **[Thử lại] (Retry)** gọi `setState()` để kích hoạt lại Future.
5. **Trạng thái 3 (Success):** Khi `snapshot.hasData == true`, kết xuất danh sách dữ liệu bằng `ListView.builder` kết hợp `Card` và `ListTile`.

---

### Bài tập 4 – Cơ sở dữ liệu Cục bộ Quan hệ với SQLite (sqflite)
**Mục tiêu:** Lưu trữ dữ liệu có cấu trúc trên bộ nhớ thiết bị, bảo đảm tính toàn vẹn dữ liệu ACID và thao tác CRUD nhanh chóng.  
**Các bước thực hiện:**
1. Thêm thư viện `sqflite` và `path` vào file `pubspec.yaml`.
2. Tạo lớp `DatabaseHelper` theo mẫu thiết kế Singleton (chỉ có duy nhất một kết nối CSDL trong toàn app).
3. Tạo bảng `tasks` với các cột: `id INTEGER PRIMARY KEY AUTOINCREMENT`, `title TEXT`, `content TEXT`, `isSynced INTEGER`.
4. Viết các hàm thao tác CSDL: `insertTask()`, `getAllTasks()`, `updateTask()`, và `deleteTask()`.
5. Bổ sung các phương thức chuyển đổi `fromMap()` và `toMap()` trong `TaskItem` để tương thích với SQLite.
6. Kiểm thử: Bật chế độ máy bay (ngắt hoàn toàn mạng), thêm mới và xóa sửa task xem dữ liệu có lưu bền vững không.

---

### Bài tập 5 – Kiến trúc Offline-First & Mẫu thiết kế Repository
**Mục tiêu:** Hợp nhất nguồn dữ liệu Cục bộ và Đám mây bằng Repository Pattern, mang lại trải nghiệm ứng dụng luôn hoạt động tức thì.  
**Các bước thực hiện:**
1. **Ôn tập Slide 10 & 11:** Mô hình `UI -> Repository -> [ SQLite Cục bộ / Remote API Đám mây ]`.
2. Tạo lớp `TaskRepository` đóng vai trò trung gian che giấu chi tiết của `DatabaseHelper` và `ApiService` đối với UI.
3. **Luồng Đọc Local-First:** Hàm `getTasks()` luôn đọc từ SQLite trước để hiển thị tức thì. Nếu CSDL cục bộ đang rỗng thì mới gọi Remote API để tải dữ liệu mẫu về nạp vào SQLite.
4. **Luồng Ghi Local-First:** Khi người dùng bấm Lưu, hàm `addTask(title, content)` ghi ngay lập tức vào SQLite với cờ `isSynced = 0`. Giao diện được cập nhật mới ngay lập tức mà không cần chờ mạng.
5. **Hàng đợi Đồng bộ (Sync Queue):** Sau khi lưu local, ứng dụng thử gửi ngầm dữ liệu lên Remote API. Nếu thành công, cập nhật cờ `isSynced = 1`. Nếu mất mạng, giữ nguyên cờ `0` trong hàng đợi để đồng bộ sau.
6. Hiển thị chỉ báo trạng thái trực quan trên mỗi thẻ task: Icon đám mây xanh khi đã đồng bộ, Icon đám mây cam khi đang chờ đồng bộ (offline).

---

### Bài tập 6 (Điểm cộng tùy chọn) – Cloud NoSQL với Firebase Firestore
**Mục tiêu:** Tìm hiểu giải pháp đám mây thời gian thực (BaaS) với Firebase Firestore.  
**Các bước thực hiện:**
1. **Ôn tập Slide 6 & 7:** Cấu trúc `Collection -> Document -> Fields -> Realtime Stream -> Flutter UI`.
2. Trình bày cách `StreamBuilder` thay thế `FutureBuilder` để tự động cập nhật giao diện ngay khi dữ liệu trên Cloud thay đổi.
3. Nêu vai trò của Firestore Security Rules trong việc bảo mật và phân quyền đọc/ghi trên đám mây.

---

## 4. Kết quả kỳ vọng (Expected Results)
- Ứng dụng khởi động nhanh, hiển thị ngay danh sách task đã lưu mà không bị đơ màn hình chờ mạng (**Local-First**).
- Tùy chọn Dark/Light Mode và tên người dùng được giữ nguyên sau khi tắt hẳn ứng dụng và mở lại.
- Khi bật chế độ Máy bay (mất mạng), người dùng vẫn có thể thêm, sửa, xóa task bình thường; task mới tạo có biểu tượng chờ đồng bộ.
- Khi có mạng trở lại và bấm nút Đồng bộ, các task đang chờ được đẩy lên Cloud và chuyển trạng thái sang đã đồng bộ.
- `FutureBuilder` hiển thị rõ ràng cả 3 trạng thái (Tải dữ liệu, Báo lỗi có nút thử lại, và Danh sách thành công).
- Cấu trúc mã nguồn đạt chuẩn kiến trúc phân tầng, tách biệt rõ ràng giữa Giao diện (UI) và Tầng Dữ liệu.

---

## 5. Tiêu chuẩn nộp bài & Đánh giá (Submission & Evaluation Criteria)

### Sản phẩm nộp (Deliverables):
1. Thư mục dự án Flutter nén (file `.zip`) chứa toàn bộ mã nguồn trong thư mục `lib/` (các file `ex1` đến `ex5` và `main.dart`), file `pubspec.yaml`, hoặc đường link kho lưu trữ GitHub.
2. Ảnh chụp màn hình (Screenshots) minh chứng:
   - (1) Đổi Theme với `SharedPreferences`.
   - (2) `FutureBuilder` trạng thái Loading & Error có nút Thử lại.
   - (3) Thao tác CRUD trong `SQLite`.
   - (4) Thêm task khi mất mạng thành công với biểu tượng Offline-First.

### Bảng tiêu chí đánh giá (Thang điểm 100%):

| Tiêu chí đánh giá | Trọng số | Mô tả chi tiết |
| :--- | :---: | :--- |
| **Lưu trữ Key-Value (Bài 1)** | **15%** | Sử dụng đúng `SharedPreferences` để lưu và khôi phục cài đặt Theme/User sau khi khởi động lại app. |
| **Remote API & Dart Model (Bài 2)** | **20%** | Gọi REST API bằng gói `http` đúng kiến trúc, chuyển đổi JSON sang Dart Model chính xác, có bắt lỗi. |
| **Giao diện Bất đồng bộ (Bài 3)** | **20%** | Hiện thực hóa trọn vẹn 3 trạng thái với `FutureBuilder`: Loading spinner, Error có nút Thử lại hoạt động được, Success list. |
| **CSDL Cục bộ SQLite (Bài 4)** | **20%** | Cấu hình `sqflite` chuẩn Singleton, tạo bảng đúng cấu trúc, thực hiện đầy đủ các thao tác CRUD cục bộ. |
| **Offline-First & Repository (Bài 5)**| **15%** | Ứng dụng Repository Pattern, ghi local trước, quản lý cờ trạng thái `isSynced` và hàng đợi Sync Queue mượt mà. |
| **Chất lượng mã nguồn & UX** | **10%** | Code sạch đẹp, có comment giải thích, giao diện thân thiện, không bị văng ứng dụng (crash). |
| **Điểm cộng (Bonus Firestore/Auto-Sync)** | **+10%** | Tích hợp Firebase Firestore Stream thời gian thực hoặc tự động phát hiện mạng để đồng bộ. |
