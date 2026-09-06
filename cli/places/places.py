#!/usr/bin/env python3
"""Shared places and named terminal workspaces."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tomllib

HERE = Path(__file__).resolve().parent
ROLES = ("edit", "agent", "check", "shell")


def places():
    source = Path(os.environ.get("PLACES_CONFIG", HERE / "places.toml"))
    rows = []
    for name, item in tomllib.loads(source.read_text()).items():
        if not re.fullmatch(r"[a-z][a-z0-9_-]*", name):
            raise ValueError(f"Invalid place name: {name}")
        value = os.environ.get(item.get("env", "")) or item["path"]
        path = os.path.abspath(os.path.expanduser(value))
        if any(c in path + item["description"] for c in "\t\r\n\x1b"):
            raise ValueError(f"Control characters in place: {name}")
        rows.append(dict(name=name, path=path, description=item["description"], exists=Path(path).is_dir()))
    return rows


def place(name):
    found = next((r for r in places() if r["name"] == name), None)
    if not found:
        raise ValueError(f"Unknown place {name!r}; run p to list places")
    if not found["exists"]:
        raise ValueError(f"{name}: directory does not exist: {found['path']}")
    return found


def label(path):
    path = os.path.abspath(os.path.expanduser(path))
    for row in sorted(places(), key=lambda r: len(r["path"]), reverse=True):
        if path == row["path"] or path.startswith(row["path"] + os.sep):
            return "~" + row["name"] + path[len(row["path"]):]
    home = str(Path.home())
    return "~" + path[len(home):] if path == home or path.startswith(home + os.sep) else path


def run(args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def backend():
    if os.environ.get("HERDR_TAB_ID"):
        return "herdr"
    if os.environ.get("CMUX_WORKSPACE_ID"):
        return "cmux"
    return None


def workspace(name):
    row = place(name)
    manager = backend()
    if manager == "cmux":
        listing = json.loads(run(["cmux", "--json", "list-workspaces"], capture_output=True, text=True).stdout)
        # A named workspace keeps its identity while its panes browse elsewhere.
        matches = [w for w in listing["workspaces"] if w.get("custom_title") == name
                   and not (w.get("remote") or {}).get("enabled")]
        if len(matches) == 1:
            run(["cmux", "workspace", "select", "--workspace", matches[0]["id"]])
            return
        if len(matches) > 1:
            raise ValueError(f"Several workspaces match {name}; select one in the sidebar")
        run(["cmux", "new-workspace", "--name", name, "--cwd", row["path"], "--focus", "true"])
    elif manager == "herdr":
        listing = json.loads(run(["herdr", "workspace", "list"], capture_output=True, text=True).stdout)
        matches = [item for item in listing["result"]["workspaces"] if item["label"] == name]
        if len(matches) == 1:
            run(["herdr", "workspace", "focus", matches[0]["workspace_id"]])
            return
        if len(matches) > 1:
            raise ValueError(f"Several workspaces match {name}; select one in the sidebar")
        run(["herdr", "workspace", "create", "--label", name, "--cwd", row["path"], "--focus"])
    else:
        raise ValueError("Run work inside cmux or Herdr; use p to change directory in a plain terminal")


def role(name):
    manager = backend()
    if manager == "cmux":
        surface = os.environ.get("CMUX_SURFACE_ID") or os.environ.get("CMUX_PANEL_ID")
        if not surface:
            raise ValueError("This shell does not identify its cmux surface")
        run(["cmux", "rename-tab", "--workspace", os.environ["CMUX_WORKSPACE_ID"], "--surface", surface, name])
    elif manager == "herdr":
        run(["herdr", "tab", "rename", os.environ["HERDR_TAB_ID"], name])
    elif sys.stdout.isatty():
        print(f"\033]2;{label(os.getcwd())} / {name}\007", end="", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    listing = sub.add_parser("list", help="List the shared places")
    formats = listing.add_mutually_exclusive_group()
    formats.add_argument("--json", action="store_true")
    formats.add_argument("--tsv", action="store_true")
    for action in ("path", "workspace"):
        sub.add_parser(action).add_argument("name")
    sub.add_parser("label").add_argument("path", nargs="?", default=os.environ.get("PWD", os.getcwd()))
    sub.add_parser("role").add_argument("name", choices=ROLES)
    args = parser.parse_args()
    if args.action == "list":
        rows = places()
        if args.json:
            print(json.dumps(rows))
        elif args.tsv:
            for r in rows:
                print(f"{r['name']}\t{r['path']}\t{r['description']}\t{int(r['exists'])}")
        else:
            for r in rows:
                print(f"{r['name']:<5} {label(r['path']):<6} {r['path']}" + ("  [missing]" if not r["exists"] else ""))
    elif args.action == "path":
        print(place(args.name)["path"])
    elif args.action == "label":
        print(label(args.path))
    elif args.action == "workspace":
        workspace(args.name)
    elif args.action == "role":
        role(args.name)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"places: {error}", file=sys.stderr)
        sys.exit(1)
