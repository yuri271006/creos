"""Offline tests for CreOS setup, virtual volume limits and release selection."""
from pathlib import Path
from tempfile import TemporaryDirectory
import json
import unittest

from creos_profile import (
    create_profile, load_profile, verify_password, validate_quota,
    volume_usage, within_quota, GIB,
)
from creos_updater import appropriate_asset, newer_version


class SetupTests(unittest.TestCase):
    def test_profile_hash_and_quota(self):
        with TemporaryDirectory() as folder:
            path = Path(folder) / "profile.json"
            create_profile("CreOS User", "testing-password-2026", 4, path=path)
            data = load_profile(path=path)
            self.assertEqual(data["name"], "CreOS User")
            self.assertEqual(data["quota_gib"], 4)
            self.assertNotIn("testing-password-2026", path.read_text(encoding="utf-8"))
            self.assertTrue(verify_password("testing-password-2026", path=path))
            self.assertFalse(verify_password("wrong-password", path=path))
            with self.assertRaises(FileExistsError):
                create_profile("Other", "another-password", 2, path=path)

    def test_volume_range_and_real_usage(self):
        for n in (2, 3, 4, 5, 6, 7, 8):
            self.assertEqual(validate_quota(n), n)
        for n in (0, 1, 9, 16, True, 2.5):
            with self.assertRaises(ValueError):
                validate_quota(n)
        with TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "test.txt").write_bytes(b"a" * 11)
            self.assertEqual(volume_usage(root), 11)
            self.assertTrue(within_quota(root, 0, 2, maximum=16))
            self.assertFalse(within_quota(root, 0, 6, maximum=16))
            self.assertTrue(within_quota(root, 11, 16, maximum=16))

    def test_release_asset_verification(self):
        self.assertTrue(newer_version("1.3.1", "1.3.0"))
        self.assertFalse(newer_version("1.2.9", "1.3.0"))
        self.assertFalse(newer_version("1.3.0", "1.3.0"))
        asset = {
            "name": "CreOS-Setup-1.3.1.exe",
            "browser_download_url": "https://github.com/yuri271006/creos/releases/download/v1.3.1/CreOS-Setup-1.3.1.exe",
            "size": 150_000,
            "digest": "sha256:" + "a" * 64,
        }
        self.assertEqual(appropriate_asset([asset], "1.3.1", "Windows"), asset)
        self.assertIsNone(appropriate_asset([{**asset, "digest": ""}], "1.3.1", "Windows"))
        self.assertIsNone(appropriate_asset([{**asset, "browser_download_url": "https://evil.example/d"}], "1.3.1", "Windows"))


if __name__ == "__main__":
    unittest.main()
