# CreOS Human Interface — App Contract

## System shell là tài sản của CreOS

CreOS quản lý wallpaper, top menu, dock, launcher, khung cửa sổ, close/minimize/maximize, kéo và thay đổi kích thước, animation nhập/xuất. App không tự vẽ lại khung cửa sổ hệ thống.

Mỗi app chỉ triển khai nội dung bên trong `ui/apps/<AppName>.qml` với root `Item`.

## Tokens và thành phần

- `ui/system/Theme.qml`: màu, bán kính, khoảng cách, typography, thời lượng animation.
- `ui/components/AppWindow.qml`: window chrome, GPU blur qua ShaderEffectSource/MultiEffect, alpha-mask tròn, resize.
- `ui/components/CreosMark.qml`: nhận diện CreOS.
- `ui/components/SidebarItem.qml` và `SystemButton.qml`: điều hướng và button.
- `ui/components/GlassPanel.qml`: container glass cơ bản.
- `ui/system/Apps.qml`: danh sách app, id, tên, đường dẫn QML, appearance.

## Hai phong cách

**System Style**: kế thừa màu, khoảng cách, chất liệu và component UI chuẩn.

**Custom Style**: tự thiết kế bên trong ứng dụng, vẫn dùng shell/window controls CreOS. Trường `appearance` ở registry cho phép chọn `"system"` hoặc `"custom"`.

## Đăng ký app

Tạo `ui/apps/NotesApp.qml`:

```qml
import QtQuick
import "../system" as System

Item {
    Rectangle {
        anchors.fill: parent
        color: System.Theme.surface
    }
}
```

Sau đó thêm vào mảng `applications` trong `ui/system/Apps.qml`:

```js
{ "id": "notes", "name": "Notes", "subtitle": "Ghi chú",
  "component": "NotesApp.qml", "appearance": "system" }
```

App xuất hiện trong launcher và được nạp vào AppWindow. Hiện tại một app window hiển thị cùng lúc; chưa hỗ trợ đa cửa sổ thực hoặc sandbox cho các app của bên thứ ba.

## Motion standards

- Hover/focus: 120–220ms.
- Chuyển nội dung: 260–340ms (OutCubic).
- Mở/thu nhỏ cửa sổ: scale/opacity 250–450ms (OutBack hoặc InCubic).
- Không áp đặt `Behavior on x/y` cho cửa sổ đang kéo, tránh cảm giác trễ theo chuột.
- Blur sử dụng trên các vùng có giới hạn; tránh hiệu ứng nặng với toàn bộ màn hình.

Các app tùy biến có thể sáng tạo nội dung, nhưng phải tôn trọng khả năng sử dụng, focus, contrast và chính sách chuyển động của CreOS.
