"""Tests for local CreOS app state. Does not touch the user's data."""
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from state_store import CreosData


class CreosDataTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.environment = patch.dict(os.environ, {"XDG_DATA_HOME": self.directory.name})
        self.environment.start()
        self.addCleanup(self.environment.stop)

    def test_notes_persist_and_can_be_deleted(self):
        store = CreosData()
        note_id = store.createNote()
        self.assertTrue(note_id)
        store.saveNote(note_id, "Một ý tưởng", "Nội dung CreOS")
        other = CreosData()
        self.assertEqual(other.getNote(note_id)["title"], "Một ý tưởng")
        self.assertEqual(other.getNote(note_id)["body"], "Nội dung CreOS")
        other.deleteNote(note_id)
        self.assertEqual(CreosData().notes, [])

    def test_wallpaper_persists_and_rejects_invalid_values(self):
        store = CreosData()
        store.setWallpaper("peach")
        self.assertEqual(CreosData().wallpaper, "peach")
        store.setWallpaper("not-a-theme")
        self.assertEqual(store.wallpaper, "peach")

    def test_unknown_note_is_not_created_by_save(self):
        store = CreosData()
        store.saveNote("missing", "title", "body")
        self.assertEqual(store.notes, [])

    def test_corrupted_data_uses_defaults(self):
        path = Path(self.directory.name) / "CreOS" / "state.json"
        path.parent.mkdir(parents=True)
        path.write_text("{bad-json", encoding="utf-8")
        store = CreosData()
        self.assertEqual(store.notes, [])
        self.assertEqual(store.wallpaper, "aurora")


if __name__ == "__main__":
    unittest.main()
