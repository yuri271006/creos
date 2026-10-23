# Cài đặt CreOS trên Ubuntu và Windows

## Hai bộ cài

| Hệ điều hành | Gói | Cách cài |
|---|---|---|
| Ubuntu 24.04+ (x86_64) | `creos_1.3.0_amd64.deb` | Mở bằng App Center / Software Install và nhấn Install |
| Windows 10/11 (64-bit) | `CreOS-Setup-1.3.0.exe` | Nhấp đúp, Next / Install, sau đó Launch CreOS |

Các gói là **bản xuất từ GitHub Actions**; chỉ tải được sau khi quy trình build hoàn tất. Trước khi có gói phát hành, CreOS vẫn chạy trực tiếp từ mã nguồn với `bash run.sh` (Ubuntu).

**Tải từ:** https://github.com/yuri271006/creos/releases

### Thiết lập lần đầu

Khi mở CreOS lần đầu:
1. Nhập tên hiển thị từ 2 đến 40 ký tự.
2. Đặt và xác nhận mật khẩu ít nhất 8 ký tự.
3. Chọn dung lượng **2–8 GB** cho khu vực `CreOS/data` (mặc định 4 GB).
4. Nhấn **Tạo không gian**. Desktop sẽ mở sau khi tạo.

Lần mở sau chỉ cần nhập mật khẩu. Mật khẩu được lưu dạng scrypt + muối trong `profile.json`, không lưu bản rõ. **Đây là khóa truy cập giao diện, không mã hóa dữ liệu trên đĩa** và không thay thế cơ chế bảo vệ của tài khoản Ubuntu/Windows.

**Dung lượng đã cấp là quota**, không phải phân vùng ảo hay ổ đĩa vật lý; không format ổ đĩa, không tự chiếm sẵn 2–8 GB. Files kiểm tra quota khi ghi tệp trong `CreOS/data`; hiện chưa hạn chế ghi từ những ứng dụng ngoài CreOS.

### Nơi lưu trữ bền vững

- Ubuntu: `~/.local/share/CreOS/` (hoặc `$XDG_DATA_HOME/CreOS/`).
- Windows: `%LOCALAPPDATA%\CreOS\`.
- `profile.json`: tên, dung lượng, mã băm mật khẩu.
- `state.json`: ghi chú và hình nền.
- `data/`: tài liệu trong Files.
- `updates/`: gói cài đã tải xuống, độc lập quota `data/`.

**Gỡ rồi cài lại không mặc định xóa dữ liệu người dùng.** Không sửa/xóa `profile.json` nếu chưa sao lưu. Hiện CreOS chưa có tính năng khôi phục mật khẩu.

## Cập nhật tự động bằng GitHub Releases

CreOS kiểm tra **bản Release mới nhất** sau khi mở khoảng 9 giây và sau đó mỗi 6 giờ. Khi có bản mới hơn:
1. Tìm gói đúng hệ điều hành trên GitHub Releases.
2. Tự tải về `updates/`, kiểm tra kích thước và SHA-256 từ GitHub API.
3. Mở **Cài đặt → Cập nhật phần mềm** để xem trạng thái.
4. Nhấn **Cài đặt bản mới** để mở trình cài của Ubuntu/Windows; xác nhận theo hướng dẫn của hệ điều hành, lưu công việc và thoát CreOS cũ.

Không tự cài trong khi CreOS đang chạy, không tự thực thi git pull hoặc commit chưa được phát hành. Nếu mạng lỗi hoặc release chưa có gói phù hợp, bản đang chạy vẫn nguyên vẹn. Không có rollback tự động. Kiểm tra SHA-256 đảm bảo tính toàn vẹn so với GitHub Releases; hiện installer **chưa có chữ ký mã**, Windows SmartScreen hoặc Ubuntu có thể hiển thị cảnh báo.

## Xuất hai installer từ GitHub

Workflow `.github/workflows/build-installers.yml` **tự build hai bộ cài khi nhánh `main` thay đổi**, nhưng chưa tự công bố bản thử nghiệm. Có thể sử dụng như sau:

**1. Thử dựng mà chưa công bố:** mở GitHub → Actions → **Build CreOS Installers** → Run workflow. Sau khi cả hai job thành công, tải hai artifacts `CreOS-Ubuntu` và `CreOS-Windows` (GitHub tải xuống dưới dạng ZIP, giải nén để lấy `.deb` / `.exe`).

**2. Phát hành bản cập nhật chính thức:** phiên bản trong `data/releases.json` phải khớp tag. Tại repository local (sau khi pull main):

```bash
git tag v1.3.0
git push origin v1.3.0
```

Workflow build Ubuntu + Windows và tạo Release với hai gói theo tag. Mọi phiên bản sau tăng lên `1.3.1`, `1.3.2`... và gắn tag tương ứng. **Không tạo cùng tag nếu workflow lỗi và chưa xác định nguyên nhân**.

### Giới hạn xác minh

PyInstaller/PySide6-WebEngine và Inno Setup cần chạy trên môi trường CI thực. Việc có workflow trong GitHub **không có nghĩa các gói đã được build hay kiểm thử thành công**. Cần kiểm tra log GitHub Actions, thử cài trên Ubuntu và Windows thực tế, và thử nâng cấp từ phiên bản thấp hơn trước khi công bố đại trà.
