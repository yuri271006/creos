# CreOS — Developer Preview

**CreOS** là ý tưởng về một “hệ điều hành bên trong hệ điều hành”: một cửa sổ Ubuntu có không gian và các ứng dụng riêng. Đây là **bản dựng thử nghiệm giao diện**, chưa phải hệ điều hành đầy đủ.

## Chạy lần đầu trên Ubuntu

Yêu cầu: Python 3.10+, `python3-venv`.

Mở thư mục project trong VS Code, rồi vào **Terminal → New Terminal** và chạy:

```bash
bash run.sh
```

Script tạo môi trường Python, cài PySide6 và mở cửa sổ CreOS. Cần Internet ở lần đầu.

Nếu gặp lỗi Qt plugin xcb, thử: `sudo apt install libxcb-cursor0 libxkbcommon-x11-0`.

## Cập nhật từ GitHub

Trong GitHub Desktop dùng **Fetch origin → Pull origin**, hoặc mở Terminal trong repo:

```bash
git pull
bash run.sh
```

Ứng dụng đang mở cần đóng/mở lại. Chưa có tự cập nhật trong app.

## Dự án

- `main.py`: khởi động Qt Quick và cung cấp dữ liệu phiên bản.
- `ui/Main.qml`: giao diện, hiệu ứng và các mục trong ứng dụng.
- `data/releases.json`: phiên bản hiện tại, lịch sử và kế hoạch.
- `run.sh`: chạy trên Ubuntu.

`0.1.0-dev` là bản **developer preview**; các phiên bản `0.2.0`, `0.3.0` chỉ là mốc **dự kiến**, không phải bản đã phát hành. Giao diện lấy cảm hứng từ kính mờ/liquid glass, không sao chép giao diện iOS.
