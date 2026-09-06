"""Behavior checks for shared places and workspace selection; no live UI calls."""
import json
import os
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import places


class PlacesTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="ws-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.project = self.root / "project with spaces"
        self.project.mkdir()
        (self.project / "nested").mkdir()
        self.registry = self.root / "places.toml"
        self.registry.write_text(
            f'[df]\npath = {json.dumps(str(self.project))}\ndescription = "Project"\n'
            f'[sub]\npath = {json.dumps(str(self.project / "nested"))}\ndescription = "Nested"\n'
            f'[missing]\npath = {json.dumps(str(self.root / "missing"))}\ndescription = "Missing"\n'
        )
        self.env = patch.dict(os.environ, {"PLACES_CONFIG": str(self.registry), "HERDR_TAB_ID": "", "CMUX_WORKSPACE_ID": "window-workspace", "CMUX_SURFACE_ID": "surface-current"})
        self.env.start()
        self.addCleanup(self.env.stop)

    def test_longest_match_and_path_boundary(self):
        self.assertEqual(places.label(str(self.project / "nested/file.txt")), "~sub/file.txt")
        self.assertEqual(places.label(str(self.project / "other")), "~df/other")
        self.assertNotIn("~df", places.label(str(self.project) + "-copy"))

    def test_missing_and_unknown_never_create_directories(self):
        for name in ("missing", "unknown"):
            with self.assertRaises(ValueError):
                places.place(name)
        self.assertFalse((self.root / "missing").exists())

    def test_environment_override(self):
        self.registry.write_text('[df]\npath = "/unused"\nenv = "WS_TEST_PROJECT"\ndescription = "Project"\n')
        with patch.dict(os.environ, {"WS_TEST_PROJECT": str(self.project)}):
            self.assertEqual(places.place("df")["path"], str(self.project))

    def test_control_characters_rejected(self):
        self.registry.write_text('[bad]\npath = "/tmp/a\\nb"\ndescription = "Invalid"\n')
        with self.assertRaises(ValueError):
            places.places()

    def test_cmux_reuses_named_local_project(self):
        listing = {"workspaces": [{"id": "existing", "custom_title": "df", "current_directory": "/elsewhere", "remote": {"enabled": False}}]}
        with patch.object(places, "run", return_value=SimpleNamespace(stdout=json.dumps(listing))) as run:
            places.workspace("df")
        self.assertEqual(run.call_args.args[0], ["cmux", "workspace", "select", "--workspace", "existing"])
        self.assertEqual(run.call_count, 2)

    def test_cmux_does_not_reuse_remote_or_similar_title(self):
        listing = {"workspaces": [
            {"id": "remote", "custom_title": "df", "current_directory": str(self.project), "remote": {"enabled": True}},
            {"id": "sibling", "custom_title": "df-copy", "current_directory": str(self.project)},
        ]}
        with patch.object(places, "run", return_value=SimpleNamespace(stdout=json.dumps(listing))) as run:
            places.workspace("df")
        self.assertIn("new-workspace", run.call_args.args[0])
        self.assertIn(str(self.project), run.call_args.args[0])

    def test_cmux_ambiguity_does_not_create_or_focus(self):
        item = {"id": "a", "custom_title": "df", "current_directory": str(self.project)}
        with patch.object(places, "run", return_value=SimpleNamespace(stdout=json.dumps({"workspaces": [item, item]}))) as run:
            with self.assertRaises(ValueError):
                places.workspace("df")
        self.assertEqual(run.call_count, 1)

    def test_role_targets_own_surface(self):
        with patch.object(places, "run") as run:
            places.role("edit")
        self.assertEqual(run.call_args.args[0], ["cmux", "rename-tab", "--workspace", "window-workspace", "--surface", "surface-current", "edit"])

    def test_herdr_uses_inner_workspace(self):
        replies = [
            SimpleNamespace(stdout=json.dumps({"result": {"workspaces": [{"label": "df", "workspace_id": "herdr-df"}]}})),
            SimpleNamespace(stdout=""),
        ]
        with patch.dict(os.environ, {"HERDR_TAB_ID": "inner-tab"}), patch.object(places, "run", side_effect=replies) as run:
            places.workspace("df")
        self.assertEqual(run.call_args.args[0], ["herdr", "workspace", "focus", "herdr-df"])


if __name__ == "__main__":
    unittest.main()
