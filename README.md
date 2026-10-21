# CreOS — The Inner Universe

**CreOS** là một ý tưởng “hệ điều hành bên trong hệ điều hành”: mở thành một cửa sổ trên Ubuntu, với desktop, dock, launcher và các app riêng.

## Developer Preview 0.1.0-dev

Bản đang phát triển với giao diện lấy cảm hứng từ **macOS + iOS** (cửa sổ sáng, dock nổi, kính mờ, chuyển động êm), nhưng thiết kế và thương hiệu CreOS là độc lập. Đã có:

- Desktop CreOS, wallpaper pastel, menu bar, dock, launcher.
- Ứng dụng **CreOS** gồm tổng quan, các bản phát hành, và hệ thống thiết kế.
- Cửa sổ CreOS có thể kéo, thu nhỏ, phóng to, đóng và mở lại.
- Thiết kế hệ thống dùng chung trong `ui/system/Theme.qml`.
- Registry ứng dụng trong `ui/system/Apps.qml`, hỗ trợ app theo theme hệ thống hoặc sáng tạo riêng phần nội dung.

**Giới hạn:** Hiện mới có một ứng dụng tích hợp và một cửa sổ ứng dụng được hiển thị tại một thời điểm. Hiệu ứng glass là mô phỏng bằng lớp trong mờ và gradient, chưa phải khúc xạ/blur nền chính xác như iOS. Bản này chưa phải hệ điều hành thực hoặc bản phát hành ổn định.

## Chạy trên Ubuntu

Yêu cầu: Python 3.10+ (Python 3.12.3 phù hợp), `python3-venv`, Internet để cài thư viện lần đầu.

Mở thư mục repo trong VS Code, vào **Terminal → New Terminal**:

```bash
bash run.sh
```

Script tự tạo `.venv` và cài PySide6. Nếu Ubuntu báo thiếu `venv`: `sudo apt install python3-venv`. Nếu có lỗi thư viện `xcb`, thử `sudo apt install libxcb-cursor0 libxkbcommon-x11-0`.

Khi chạy: nhấp icon CreOS trên desktop hoặc dock; bấm icon thư viện ở dock để xem ứng dụng. Ba nút đỏ, vàng, xanh điều khiển cửa sổ **bên trong CreOS**.

## Cập nhật

Trong GitHub Desktop chọn **Fetch origin → Pull origin**, hoặc Terminal:

```bash
git pull
bash run.sh
```

Cần mở lại app để nạp mã mới. Tự cập nhật tự động chưa được xây dựng.

## Cấu trúc

| Đường dẫn | Mục đích |
|---|---|
| `main.py` | Điểm chạy PySide6/Qt Quick và dữ liệu phiên bản |
| `data/releases.json` | Phiên bản và kế hoạch phát hành |
| `ui/Main.qml` | CreOS Desktop và Shell |
| `ui/apps/CreosApp.qml` | Ứng dụng CreOS / phiên bản |
| `ui/system/Theme.qml` | Design tokens dùng chung |
| `ui/system/Apps.qml` | Registry các app |
| `ui/components/` | UI components dùng chung |
| `ui/system/APP_GUIDE.md` | Quy ước viết ứng dụng cho CreOS |

**Lưu ý:** 0.2.0 và 0.3.0 trong Release Notes là **lộ trình, chưa phát hành**.
