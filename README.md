# CreOS — The Inner Universe

CreOS là một không gian ứng dụng chạy trong **một cửa sổ Ubuntu**, lấy cảm hứng từ trải nghiệm macOS/iOS nhưng có ngôn ngữ thiết kế riêng.

## Glass Reborn — 0.1.1-dev

**Đây là bản developer preview** để đánh giá UI, chưa phải bản phát hành ổn định hoặc một hệ điều hành riêng.

- Desktop CreOS với hình nền màu pastel, menu bar và dock nổi.
- Dock và thanh menu lấy mẫu hình nền, sử dụng GPU blur từ Qt Quick Effects.
- Khung cửa sổ ứng dụng con có **bo góc thật bằng alpha-mask**, bóng đổ và đường viền.
- Animation: mở cửa sổ (scale + fade), đóng, thu nhỏ, dock hover, chuyển trang, launcher.
- Cửa sổ con có thể kéo, thay đổi kích thước và maximize / restore.
- Ứng dụng Giới thiệu CreOS gồm tổng quan, bản phát hành, giao diện hệ thống.
- CreOS System UI là nguồn chung cho theme, window chrome, dock, launcher và chuyển động.
- App bên trong có thể chọn System Style hoặc tự sáng tạo nội dung với Custom Style.

**Giới hạn hiện tại:** Chỉ một app window được hiển thị tại một thời điểm; việc mở rộng sang đa cửa sổ là kế hoạch sau này. Hiệu ứng là **frosted/backdrop blur**, không phải mô phỏng đầy đủ khúc xạ Liquid Glass độc quyền. Khung ngoài cùng do trình quản lý cửa sổ Ubuntu trang trí; góc bo alpha-mask áp dụng cho **cửa sổ con trong CreOS**. Hiệu suất phụ thuộc GPU và driver của Ubuntu.

## Chạy trên Ubuntu / VS Code

Cần Python 3.10+ (đã thử chuẩn bị cho Python 3.12) và `python3-venv`. Trong thư mục repository:

```bash
bash run.sh
```

Tập lệnh tạo `.venv`, cài PySide6 mới tương thích và chạy CreOS. Lần đầu cần Internet.

Nếu chưa có venv: `sudo apt install python3-venv`.
Nếu Ubuntu báo lỗi plugin Qt xcb: `sudo apt install libxcb-cursor0 libxkbcommon-x11-0`.

## Lấy phiên bản mới trên GitHub

Trong GitHub Desktop: **Fetch origin → Pull origin**. Hoặc trong Terminal:

```bash
git pull
bash run.sh
```

Đóng app trước khi chạy bản mới; mã nguồn kéo về không tự thay đổi ứng dụng đang mở.

## Kiến trúc

- `main.py`: điểm khởi động PySide6, dữ liệu phát hành.
- `data/releases.json`: trạng thái phiên bản, nội dung release notes.
- `ui/Main.qml`: hệ điều hành con (wallpaper, menu bar, dock, launcher).
- `ui/components/AppWindow.qml`: khung cửa sổ con, blur, mask, maximize, drag, resize.
- `ui/apps/CreosApp.qml`: nội dung ứng dụng Giới thiệu CreOS.
- `ui/system/Theme.qml`: design tokens.
- `ui/system/Apps.qml`: đăng ký các ứng dụng.
- `ui/system/APP_GUIDE.md`: hợp đồng giao diện giữa CreOS và các ứng dụng.

Phiên bản `0.2.0` / `0.3.0` trong app là **dự kiến, chưa phát hành**.

### Kiểm thử

Đã kiểm tra cấu trúc tệp và cú pháp ngoặc/bản ghi dữ liệu khi cập nhật từ ChatGPT. Chưa kiểm thử giao diện Qt thực tế trong môi trường Ubuntu có GPU; nếu có lỗi QML khi chạy, hãy gửi toàn bộ log terminal để điều chỉnh.
