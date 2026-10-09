#!/usr/bin/env python3
"""Check the local Nord ports without fetching upstream themes or schemas."""

import json
import re
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load_json(path):
    return json.loads((ROOT / path).read_text())


def luminance(color):
    channels = [int(color[i : i + 2], 16) / 255 for i in (1, 3, 5)]
    linear = [
        c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
        for c in channels
    ]
    return sum(c * weight for c, weight in zip(linear, (0.2126, 0.7152, 0.0722)))


def contrast(foreground, background):
    low, high = sorted((luminance(foreground), luminance(background)))
    return (high + 0.05) / (low + 0.05)


def main():
    herdr = tomllib.loads((ROOT / "cli/herdr/config.toml").read_text())["theme"]
    omarchy = tomllib.loads((ROOT / "cli/herdr/config.omarchy.toml").read_text())["theme"]
    assert herdr == omarchy, "Herdr theme configurations differ"
    # Keep the existing local OMP role contract, including optional status roles.
    omp_roles = load_json("agents/omp/themes/reticle-dark.json")["colors"].keys()
    mappings = {
        "accent": "cyan",
        "text": "fg",
        "subtext0": "muted",
        "overlay0": "comment",
        "mauve": "purple",
        "peach": "orange",
        "panel_bg": "bg",
        **{color: color for color in ("blue", "red", "green", "yellow", "teal")},
    }
    for variant in ("dark", "light"):
        theme = load_json(f"agents/omp/themes/nord-{variant}.json")
        colors = theme["vars"]
        assert theme["name"] == f"nord-{variant}"
        assert theme["colors"].keys() == omp_roles, "OMP role contract changed"
        assert all(re.fullmatch(r"#[0-9a-f]{6}", c) for c in colors.values())
        assert all(c in colors for c in theme["colors"].values()), "Unknown OMP variable"
        nu = load_json(f"shells/nu/themes/nord-{variant}.json")
        for role, variable in {
            "header": "cyan",
            "hints": "comment",
            "shape_string": "green",
            "shape_keyword": "blue",
            "shape_int": "purple",
            "shape_variable": "fg",
        }.items():
            assert nu[role] == colors[variable], f"Nushell {variant}: {role} drifted"
        ui = herdr["custom"] if variant == "dark" else herdr["custom"]["light"]
        for role, variable in mappings.items():
            assert ui[role] == colors[variable], f"Herdr {variant}: {role} drifted"
        body_contrast = contrast(colors["fg"], colors["bg"])
        assert body_contrast >= 4.5
        print(f"Nord {variant}: body text {body_contrast:.2f}:1")
        if variant == "light":
            foregrounds = (
                "fg", "bright", "muted", "comment", "teal", "cyan", "blue",
                "red", "orange", "yellow", "green", "purple",
            )
            backgrounds = ("bg", "panel", "surface", "diff_add", "diff_delete")
            minimum = min(
                contrast(colors[fg], colors[bg])
                for fg in foregrounds for bg in backgrounds
            )
            assert minimum >= 4.5, f"Nord light text contrast {minimum:.2f}:1"
            print(f"Nord light: custom text minimum {minimum:.2f}:1")
    print("Checked local Nord OMP, Nushell, and Herdr palette consistency.")


if __name__ == "__main__":
    main()
