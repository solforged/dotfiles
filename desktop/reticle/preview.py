#!/usr/bin/env python3
"""Inspect Reticle colors in a disposable terminal; q restores its palette."""

import shutil
import sys
import termios
import tty

from generate import PALETTES, contrast

ESC = "\033["
VARIANTS = ("dark", "dimmed", "light", "polyimide")


def rgb(color):
    return ";".join(str(int(color[i : i + 2], 16)) for i in (1, 3, 5))


def paint(text, fg, bg, bold=False):
    return f"{ESC}{1 if bold else 22};38;2;{rgb(fg)};48;2;{rgb(bg)}m{text}"


def draw(variant):
    p = PALETTES[variant]
    width = max(30, shutil.get_terminal_size().columns - 4)
    sys.stdout.write(f"\033]10;{p['fg']}\007\033]11;{p['bg']}\007")
    for i, color in enumerate(p["terminal"]):
        sys.stdout.write(f"\033]4;{i};{color}\007")
    sys.stdout.write(ESC + "0m" + ESC + "2J" + ESC + "H")

    def row(text="", role="fg", bg="bg", bold=False):
        sys.stdout.write(paint("  " + text.ljust(width) + "  ", p[role], p[bg], bold) + "\r\n")

    row(p["name"].upper(), "amber", bold=True)
    row("1 Dark   2 Dimmed   3 Light   4 Polyimide   q Quit", "comment")
    row()
    row("Readable text, symbols, and code under the same light.")
    row("Readable text, symbols, and code under the same light.", bold=True)
    row("Comments / secondary labels / 0123456789 / Il1 O0 {} []", "comment")
    row(f"Text {contrast(p['fg'], p['bg']):.2f}:1   Comments {contrast(p['comment'], p['bg']):.2f}:1", "comment")
    row()
    for text, role in (("+ Success / added / clean", "green"),
                       ("! Warning / modified / pending", "amber"),
                       ("x Error / removed / failed", "red"),
                       ("> Path / link / information", "blue"),
                       ("~ Secondary information", "cyan")):
        row(text, role)
    row()
    row("# Syntax specimen", "comment")
    parts = [("def ", "pink"), ("collect", "blue"), ("(paths: ", "gray"),
             ("list", "purple"), ("):", "gray")]
    sys.stdout.write("  " + "".join(paint(s, p[c], p["bg"]) for s, c in parts) + ESC + "K\r\n")
    parts = [("    return ", "pink"), ('"ready"', "amber"), (", ", "gray"), ("42", "orange")]
    sys.stdout.write("  " + "".join(paint(s, p[c], p["bg"]) for s, c in parts) + ESC + "K\r\n")
    row()
    row("Popup / selected row: useful text stays readable", "fg", "ui_sel")
    row("Selected secondary label", "comment", "ui_sel")
    row("+ added line", "green", "diff_add")
    row("- removed line", "red", "diff_delete")
    row("ANSI: red green yellow blue magenta cyan", "comment")
    sys.stdout.write("  " + " ".join(f"{ESC}{30+i}m{label}" for i, label in enumerate(
        ("black", "error", "success", "warning", "info", "keyword", "secondary", "bright"))) + ESC + "0m\r\n")
    sys.stdout.flush()


def main():
    if not sys.stdin.isatty():
        raise SystemExit("Run in a terminal, preferably a fresh cmux workspace.")
    settings = termios.tcgetattr(sys.stdin)
    try:
        tty.setcbreak(sys.stdin)
        sys.stdout.write(ESC + "?1049h" + ESC + "?25l")
        draw("dimmed")
        while True:
            key = sys.stdin.read(1)
            if key in ("q", "\033", ""):
                break
            if key in "1234":
                draw(VARIANTS[int(key) - 1])
    finally:
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, settings)
        sys.stdout.write("\033]104\007\033]110\007\033]111\007" + ESC + "0m" + ESC + "?25h" + ESC + "?1049l")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
