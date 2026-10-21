# CreOS System UI — quy tắc phát triển ứng dụng

CreOS là một không gian ứng dụng chạy **trong một cửa sổ Ubuntu**. CreOS quản lý toàn bộ **khung và hành vi hệ thống**: wallpaper, menu bar, dock, launcher, cửa sổ, close/minimize/maximize, di chuyển/thay đổi kích thước và animation.

## 1. Nguồn thống nhất của giao diện

- `ui/system/Theme.qml`: màu, vật liệu glass, viền, bo góc, khoảng cách, typography và thời gian animation.
- `ui/components/AppWindow.qml`: cửa sổ ứng dụng và điều khiển do CreOS quản lý.
- `ui/components/GlassPanel.qml`, `SidebarItem.qml`, `SystemButton.qml`, `CreosMark.qml`: các thành phần dùng chung.
- `ui/system/Apps.qml`: registry của ứng dụng.
- `ui/Main.qml`: desktop, menu bar, app launcher, dock và quản lý app.

**Không copy-paste lại khung cửa sổ vào mỗi app.** Mọi app được CreOS mở trong cùng một AppWindow.

## 2. Hai phong cách app

- `appearance: "system"` (mặc định): app dùng màu, bo góc và thành phần của `System.Theme`.
- `appearance: "custom"`: app có quyền sáng tạo giao diện **bên trong vùng nội dung**; CreOS vẫn chịu trách nhiệm window chrome, dock, phím điều khiển và an toàn vòng đời.

Chưa có cơ chế sandbox cho ứng dụng bên thứ ba. Chỉ chạy code của nguồn đáng tin cậy.

## 3. Tạo ứng dụng mới

1. Tạo `ui/apps/MyApp.qml` với root `Item`.
2. Nếu dùng System UI, thêm:

```qml
import QtQuick
import "../components"
import "../system" as System

Item {
    Rectangle {
        anchors.fill: parent
        color: System.Theme.surface
        GlassPanel {
            anchors.centerIn: parent
            width: 320
            height: 160
        }
    }
}
```

3. Đăng ký trong mảng `applications` của `ui/system/Apps.qml`:

```js
{
    "id": "my-app",
    "name": "Ứng dụng của tôi",
    "subtitle": "Một app nhỏ",
    "component": "MyApp.qml",
    "appearance": "system"
}
```

4. App sẽ xuất hiện trong launcher. CreOS tải component được đăng ký vào khung cửa sổ chung.

## 4. Hướng phát triển

Bản 0.1.0-dev là **giao diện thử nghiệm** (một ứng dụng đang hiển thị tại một thời điểm). Kế tiếp: nhiều cửa sổ chạy đồng thời, quản lý z-order, quản lý focus và animation chuyển cửa sổ. Hiệu ứng kính hiện sử dụng **lớp trong mờ và gradient**; nền mờ phản chiếu thực (backdrop blur/liquid refraction) sẽ được xem xét khi kiểm thử hiệu suất Qt Quick trên Ubuntu.

Không gắn nhãn tính năng chưa làm xong là đã phát hành.
