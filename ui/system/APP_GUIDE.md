# CreOS Human Interface · v2

CreOS quyết định ngôn ngữ giao diện và hành vi của mọi ứng dụng tích hợp, lấy cảm hứng từ tính nhất quán và sự rõ ràng của iOS/macOS nhưng không sao chép nội dung/nhận diện Apple.

## 1. Kiến trúc bắt buộc

**System-owned:** `ui/Main.qml` quản lý desktop, top bar, Dock, Launchpad, cửa sổ, focus và z-order. `ui/components/AppWindow.qml` quản lý thanh tiêu đề và kéo/phóng to/thu nhỏ/đóng. Không ứng dụng nào tự vẽ hệ thống cửa sổ.

**App-owned:** Mỗi ứng dụng chỉ cung cấp QML bên trong `ui/apps/*App.qml`, lưu trạng thái và xử lý logic nghiệp vụ.

**Single source of truth:** `ui/system/Theme.qml` là nguồn duy nhất định nghĩa màu, typography, spacing, radius, kích cỡ tương tác và duration. Các app không tự lựa chọn màu/nút/card mới trừ khi có lý do sản phẩm và được đăng ký thành component CreOS.

## 2. Thành phần CreOS UI được cung cấp

| Component | Mục đích |
|---|---|
| `AppPage.qml` | Bố cục trang, tiêu đề lớn, caption, vùng nội dung |
| `SurfaceCard.qml` | Thẻ/nhóm nội dung với một đường viền bo tròn |
| `SystemButton.qml` | Button chuẩn: primary, destructive, quiet |
| `SegmentedTabs.qml` | Chuyển tab trong app |
| `SectionLabel.qml` | Nhãn nhóm theo hệ thống |
| `SidebarItem.qml` | Điều hướng sidebar chuẩn |
| `AppIcon.qml` | Icon vector SVG theo id đăng ký app |
| `AppWindow.qml` | System chrome (không import/vẽ trong nội dung app) |

## 3. Ví dụ app đúng chuẩn

Tạo `ui/apps/TasksApp.qml`:

```qml
import QtQuick
import "../components"
import "../system" as System

Item {
    AppPage {
        heading: "Công việc"
        caption: "Những điều quan trọng trong ngày."
        SurfaceCard {
            anchors.fill: parent
            SystemButton {
                anchors.centerIn: parent
                text: "Thêm công việc"
                primary: true
                onClicked: console.log("New task")
            }
        }
    }
}
```

Đăng ký trong `ui/system/Apps.qml`:

```js
{
    "id": "tasks",
    "name": "Công việc",
    "subtitle": "Quản lý danh sách việc làm",
    "component": "TasksApp.qml",
    "appearance": "system"
}
```

Thêm icon vector ở `ui/assets/icons/tasks.svg`. Không dùng ký tự Unicode làm icon hệ thống.

## 4. Quy tắc tương tác

- Chữ chính rõ ràng trên nền `Theme.canvas`; nhóm nội dung vào `SurfaceCard`.
- Các nút nên có chiều cao tối thiểu `Theme.minimumTarget` (42 px).
- Dùng `primary` cho hành động chính, `destructive` cho hành động xóa.
- Không đặt nhiều lớp bo góc/mask/blur chồng nhau.
- Sidebar/segmented tabs phải giữ trạng thái chọn rõ ràng.
- Tách trạng thái UI và dữ liệu: Notes/Settings dùng `state_store.py` trong thư mục XDG; không ghi trực tiếp vào repo.

## 5. Motion & Performance — ưu tiên số một

- Hover/press 120 ms; chuyển nội dung 220 ms; chuyển động lớn 320 ms (`Theme.durationQuick/Normal/Slow`).
- Ưu tiên `opacity`, `scale`, translate cho các animation ngắn. Không gắn `Behavior on x/y` vào cửa sổ đang drag vì tạo độ trễ dưới chuột.
- **Không** chạy animation vô hạn hoặc blur live trên các danh sách/thẻ nội dung.
- App muốn cập nhật theo thời gian phải dùng Timer chạy đúng khi cần (đồng hồ thường 1 Hz; stopwatch chỉ 20 Hz khi đang chạy).
- List dài phải dùng `ListView`/lazy delegates; tránh tạo tất cả phần tử bằng `Repeater` nếu dữ liệu lớn.
- Qt WebEngine chỉ được khởi tạo khi người dùng thực sự mở website (lazy Loader).
- Không hy sinh thao tác nhập liệu hay chức năng thực tế để lấy hiệu ứng hình ảnh.
- Các cấu hình GPU/driver trên Ubuntu phải được kiểm thử, không cam kết 60 FPS trước khi đo thực tế.

## 6. Phạm vi hiện có

Các app chuẩn: CreOS, Notes, Calculator, Clock, Browser, Settings. Cửa sổ dùng chung hệ thống; app có thể lựa chọn `appearance: "custom"` cho **nội dung**, nhưng Dock/chrome vẫn thuộc CreOS. Chưa có sandbox độc lập cho ứng dụng bên thứ ba.
