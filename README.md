# CreOS

CreOS là một môi trường desktop với các ứng dụng riêng, hoạt động **bên trong Ubuntu**. Khung hệ thống, Dock và cửa sổ của tất cả ứng dụng đều do CreOS quản lý.

## CreOS 1.1.0 — Human Interface

CreOS được mở **toàn màn hình mặc định**. Nhấn **F11** (hoặc chọn **CreOS → Chế độ cửa sổ**) để trở lại cửa sổ Ubuntu có thể di chuyển/phóng to/thu nhỏ như bình thường.

- **Desktop toàn màn hình**: hình nền và không gian làm việc mở rộng tới cả mép dưới.
- **Dock nổi nhỏ gọn**: nằm trên một lớp giao diện riêng, **đè phía trên** cửa sổ thay vì giữ chỗ ở cuối màn hình. Bản 1.0.1 bỏ hiệu ứng blur không được bo góc ở phía sau Dock/Launchpad để tránh lộ ô vuông ở các mép.
- **Đa cửa sổ**: mở nhiều app, bấm để đưa lên trên, kéo thanh tiêu đề để di chuyển.
- **Điều khiển chuẩn CreOS**: đóng (đỏ), thu nhỏ (vàng), phóng to/khôi phục (xanh).
- **Kéo thay đổi kích thước** ở 4 cạnh và 4 góc khi cửa sổ chưa phóng to.
- **Chuyển động**: cửa sổ mở bằng fade + scale + dịch chuyển nhẹ; đóng và thu nhỏ có hiệu ứng riêng; dock icon phản hồi hover.
- **Icon CreOS mới**: sáu biểu tượng SVG vector có hình minh họa riêng; dùng chung ở Desktop, Dock, Launchpad và trong ứng dụng. Không sử dụng glyph font làm icon.
- **CreOS System UI**: ứng dụng có thể kế thừa giao diện hệ thống hoặc tự tùy chỉnh nội dung riêng.

### Bộ thiết kế CreOS Human Interface

**CreOS quy định UI toàn hệ thống.** App mới không tự thiết kế từ đầu: dùng `Theme.qml` để lấy màu, typography, spacing và animation, kết hợp `AppPage`, `SurfaceCard`, `SystemButton`, `SegmentedTabs`, `SectionLabel` và `SidebarItem`. CreOS tiếp tục quản lý khung cửa sổ, Dock và Launchpad; app chỉ quản lý nội dung và chức năng của mình.

Trong 1.1.0, toàn bộ app được chuyển sang phong cách sáng, ít lớp, tương tác rõ ràng lấy cảm hứng từ iOS:
- **Ghi chú:** split view, danh sách ghi chú, trình soạn thảo lớn, autosave 450 ms.
- **Máy tính:** màn hình kết quả và bàn phím bốn cột, tối ưu nút bấm.
- **Đồng hồ:** tab thời gian/bấm giờ, timer tiết kiệm CPU khi không chạy.
- **Trình duyệt:** thanh điều hướng gọn, URL/search, engine chỉ khởi tạo khi truy cập web.
- **Cài đặt:** thẻ nhóm chuẩn CreOS, đổi hình nền ngay.
- **CreOS:** thông tin hệ thống và danh sách ứng dụng có cùng bố cục.

**Hiệu năng:** ưu tiên nền đặc bo tròn và animation thời gian ngắn; không sử dụng blur GPU live ở các app. Chưa có số đo FPS trên máy Ubuntu của người dùng, nên chưa xác nhận được mức độ mượt trong thực tế.

Xem [quy chuẩn thiết kế và viết app](ui/system/APP_GUIDE.md).

### Ứng dụng tích hợp

| Ứng dụng | Chức năng |
|---|---|
| CreOS | Thông tin hệ thống, phiên bản và ứng dụng đã cài |
| Ghi chú | Tạo, chỉnh sửa, xóa; lưu tự động |
| Máy tính | Tính toán cơ bản |
| Đồng hồ | Giờ hiện tại, bấm giờ và vòng |
| Trình duyệt | Duyệt web bằng Qt WebEngine ngay trong CreOS |
| Cài đặt | Đổi hình nền desktop và lưu lựa chọn |

## Chạy trên Ubuntu

Yêu cầu Python 3.10+ và `python3-venv`. Mở repository trong VS Code rồi chạy:

```bash
bash run.sh
```

Lần đầu cần Internet để tải PySide6 và PySide6-WebEngine. Nếu Ubuntu báo lỗi Qt xcb:

```bash
sudo apt install libxcb-cursor0 libxkbcommon-x11-0
```

**Lấy mã mới từ GitHub**: đóng CreOS đang chạy, chọn **Fetch origin → Pull origin** trong GitHub Desktop hoặc chạy:

```bash
git pull
bash run.sh
```

Ghi chú và lựa chọn hình nền được lưu bên ngoài repo tại `$XDG_DATA_HOME/CreOS/state.json` (mặc định `~/.local/share/CreOS/state.json`), nên `git pull` không xóa chúng.

## Mã nguồn

- `ui/Main.qml`: desktop, quản lý đa cửa sổ, menu bar, dock và launchpad.
- `ui/components/AppWindow.qml`: một khung cửa sổ dùng chung, animation, các điều khiển.
- `ui/components/ResizeHandle.qml`: vùng resize 8 hướng.
- `ui/system/Theme.qml`: token thiết kế toàn hệ thống.
- `ui/system/Apps.qml`: registry ứng dụng.
- `ui/components/AppPage.qml`, `SurfaceCard.qml`, `SystemButton.qml`, `SegmentedTabs.qml`, `SectionLabel.qml`: các thành phần UI chuẩn.
- `ui/assets/icons/*.svg`: bộ icon vector chính thức, dùng qua `ui/components/AppIcon.qml`.
- `ui/apps/*App.qml`: nội dung từng ứng dụng.
- `state_store.py`: lưu dữ liệu cục bộ.
- `data/releases.json`: thông tin phiên bản.

Dữ liệu người dùng lưu tại máy và không được đưa lên GitHub. Trình duyệt tích hợp chỉ là chức năng tiện ích; không thay thế một trình duyệt chuyên dụng cho các tác vụ nhạy cảm. Các app cùng chạy trong một tiến trình, **chưa có sandbox riêng cho app bên thứ ba**.

### Kiểm thử

Repository có unit tests cho lưu trữ và GitHub Actions QML smoke test. Các hiệu ứng đồ họa cần được kiểm chứng thêm trên GPU, driver và phiên làm việc Ubuntu thực tế trước khi coi là ổn định trên mọi máy. Bản 1.0.1 thay các lớp blur chưa có mask bằng một bề mặt bo góc riêng để hạn chế lỗi hiển thị từ các GPU khác nhau.
