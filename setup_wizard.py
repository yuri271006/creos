"""CreOS first-launch setup and local sign-in dialogs (Qt Widgets).

Runs BEFORE the QML desktop is loaded, so setup is not a fake app window.
"""
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QDialog, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit, QPushButton,
    QSpinBox, QWidget, QMessageBox, QFrame,
)
from creos_profile import create_profile, load_profile, verify_password


_STYLE = """
QDialog { background: #F4F6FA; color: #1B2A40; }
QLabel { color: #46576F; font-family: 'Noto Sans', 'Segoe UI', sans-serif; }
QLineEdit, QSpinBox {
    min-height: 37px; border-radius: 12px; border: 1px solid #D9E2ED;
    background: white; color: #17243B; padding: 4px 12px; font-size: 13px;
}
QPushButton { min-height: 41px; border: 0; border-radius: 13px;
              padding: 0 18px; background: #E4EAF5; color: #284064; }
QPushButton#primary { background: #3479F5; color: white; font-weight: 600; }
QPushButton:hover { background: #D7E3F5; }
QPushButton#primary:hover { background: #2468DC; }
"""


class ProfileDialog(QDialog):
    def __init__(self, setup: bool, parent=None):
        super().__init__(parent)
        self._setup = setup
        self.setWindowTitle("Thiết lập CreOS" if setup else "Đăng nhập CreOS")
        self.setMinimumWidth(460)
        self.setStyleSheet(_STYLE)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(35, 28, 35, 30)
        layout.setSpacing(13)

        brand = QLabel("CreOS")
        brand.setStyleSheet("font-size: 35px; font-weight: bold; color: #26468D;")
        layout.addWidget(brand)
        subtitle = QLabel(
            "Thiết lập không gian của bạn" if setup else "Chào mừng trở lại"
        )
        subtitle.setStyleSheet("font-size: 16px; font-weight: 600; color: #20324F;")
        layout.addWidget(subtitle)
        detail = QLabel(
            "Đặt tên, mật khẩu và giới hạn lưu trữ. Có thể chọn từ 2 đến 8 GB."
            if setup else "Nhập mật khẩu để mở CreOS."
        )
        detail.setWordWrap(True)
        layout.addWidget(detail)

        self.name = None
        if setup:
            layout.addWidget(QLabel("Tên người dùng"))
            self.name = QLineEdit()
            self.name.setPlaceholderText("Tên hiển thị")
            self.name.setMaxLength(40)
            layout.addWidget(self.name)
        else:
            profile = load_profile()
            who = QLabel(profile["name"])
            who.setStyleSheet("font-size: 20px; font-weight: 600; color: #26468D;")
            layout.addWidget(who)

        layout.addWidget(QLabel("Mật khẩu"))
        self.password = QLineEdit()
        self.password.setEchoMode(QLineEdit.Password)
        self.password.setPlaceholderText("Tối thiểu 8 ký tự" if setup else "Mật khẩu CreOS")
        layout.addWidget(self.password)

        self.confirm = None
        self.quota = None
        if setup:
            layout.addWidget(QLabel("Xác nhận mật khẩu"))
            self.confirm = QLineEdit()
            self.confirm.setEchoMode(QLineEdit.Password)
            self.confirm.setPlaceholderText("Nhập lại mật khẩu")
            layout.addWidget(self.confirm)
            layout.addWidget(QLabel("Dung lượng cấp cho CreOS/data"))
            self.quota = QSpinBox()
            self.quota.setRange(2, 8)
            self.quota.setValue(4)
            self.quota.setSuffix(" GB")
            layout.addWidget(self.quota)
            explain = QLabel(
                "Đây là hạn mức lưu trữ, không chia ổ cứng hoặc chiếm sẵn 4 GB. "
                "Mật khẩu khóa giao diện CreOS, không mã hóa các tệp trên ổ."
            )
            explain.setWordWrap(True)
            explain.setStyleSheet("font-size: 11px; color: #718099;")
            layout.addWidget(explain)

        self.error = QLabel("")
        self.error.setWordWrap(True)
        self.error.setStyleSheet("color: #C44157; font-size: 12px;")
        layout.addWidget(self.error)

        actions = QHBoxLayout()
        actions.addStretch()
        cancel = QPushButton("Thoát")
        cancel.clicked.connect(self.reject)
        actions.addWidget(cancel)
        go = QPushButton("Tạo không gian" if setup else "Mở CreOS")
        go.setObjectName("primary")
        go.clicked.connect(self.submit)
        actions.addWidget(go)
        layout.addLayout(actions)
        self.password.returnPressed.connect(self.submit)
        if setup:
            self.confirm.returnPressed.connect(self.submit)

    def submit(self):
        try:
            if self._setup:
                if self.password.text() != self.confirm.text():
                    raise ValueError("Mật khẩu xác nhận chưa khớp.")
                create_profile(self.name.text(), self.password.text(), self.quota.value())
            elif not verify_password(self.password.text()):
                raise ValueError("Mật khẩu chưa đúng.")
        except (OSError, ValueError, KeyError) as exc:
            self.error.setText(str(exc))
            self.password.clear()
            if self.confirm:
                self.confirm.clear()
            return
        self.accept()


def authenticate_desktop() -> bool:
    from creos_profile import profile_exists
    return ProfileDialog(setup=not profile_exists()).exec() == QDialog.Accepted
