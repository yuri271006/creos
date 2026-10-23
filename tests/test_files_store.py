"""Tests for CreOS virtual sys/data file manager, without real user files."""
import tempfile
import unittest
from pathlib import Path

from files_store import CreosFiles


class CreosFilesTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.system = self.root / "installed-system"
        self.system.mkdir()
        (self.system / "main.py").write_text("print('CreOS')\n", encoding="utf-8")
        (self.system / "ui").mkdir()
        (self.system / ".git").mkdir()
        self.user_root = self.root / "my-user-data"
        self.files = CreosFiles(self.system, self.user_root)

    def test_data_crud_and_persistence(self):
        self.assertEqual(self.files.area, "data")
        self.assertTrue(self.files.createFolder("Tài liệu"))
        self.files.enter("Tài liệu")
        self.assertTrue(self.files.createTextFile("Xin chào.txt"))
        self.assertTrue(self.files.saveText("Xin chào.txt", "Chào CreOS!"))
        self.assertEqual(self.files.readText("Xin chào.txt"), "Chào CreOS!")
        self.assertTrue(self.files.renameEntry("Xin chào.txt", "Nhật ký.txt"))
        self.assertEqual(self.files.readText("Nhật ký.txt"), "Chào CreOS!")
        self.assertTrue(self.files.deleteEntry("Nhật ký.txt"))
        self.files.goUp()
        self.assertTrue(self.files.deleteEntry("Tài liệu"))
        self.assertEqual(self.files.entries, [])

    def test_sys_is_read_only_and_hidden_dirs_not_listed(self):
        self.files.selectArea("sys")
        self.assertTrue(self.files.readOnly)
        self.assertEqual(self.files.readText("main.py"), "print('CreOS')\n")
        self.assertTrue(any(row["name"] == "ui" for row in self.files.entries))
        self.assertFalse(any(row["name"] == ".git" for row in self.files.entries))
        self.assertFalse(self.files.createTextFile("hack.py"))
        self.assertFalse(self.files.createFolder("core"))
        self.assertFalse(self.files.deleteEntry("main.py"))
        self.assertFalse(self.files.renameEntry("main.py", "changed.py"))
        self.assertFalse(self.files.saveText("main.py", "bad"))
        self.assertEqual((self.system / "main.py").read_text(encoding="utf-8"), "print('CreOS')\n")

    def test_path_traversal_is_blocked(self):
        for name in ["..", "../outside.txt", "/tmp/evil.txt", ".hidden", "nested/file.txt"]:
            with self.subTest(name=name):
                self.assertFalse(self.files.createTextFile(name))
                self.assertFalse(self.files.createFolder(name))
        self.assertFalse((self.root / "outside.txt").exists())

    def test_symlinks_cannot_escape_data_root(self):
        outside = self.root / "outside.txt"
        outside.write_text("private", encoding="utf-8")
        (self.user_root / "link.txt").symlink_to(outside)
        self.files.refresh()
        self.assertFalse(any(row["name"] == "link.txt" for row in self.files.entries))
        self.assertEqual(self.files.readText("link.txt"), "")
        self.assertFalse(self.files.deleteEntry("link.txt"))
        self.assertEqual(outside.read_text(), "private")

    def test_delete_non_empty_folder_is_refused(self):
        self.assertTrue(self.files.createFolder("Documents"))
        self.files.enter("Documents")
        self.assertTrue(self.files.createTextFile("hello.txt"))
        self.files.goUp()
        self.assertFalse(self.files.deleteEntry("Documents"))
        self.assertTrue((self.user_root / "Documents" / "hello.txt").exists())

    def test_file_size_limit_and_binary_are_safe(self):
        self.assertFalse(self.files.createTextFile("binary.exe"))
        self.assertTrue(self.files.createTextFile("log.txt"))
        self.assertFalse(self.files.saveText("log.txt", "x" * (512 * 1024 + 1)))
        self.assertEqual(self.files.readText("log.txt"), "")


if __name__ == "__main__":
    unittest.main()
