# Reticle theme audit

Reticle Dimmed is the default dark appearance; Reticle Light follows the system
light appearance. Polyimide and Reticle Dark remain selectable.

## Findings and changes

The original terminal palette put amber in ANSI green, purple in ANSI blue, and
orange in bright blue. That reproduced upstream iTerm colors, but made a green
success prompt amber and a blue path purple. The ports now give ANSI colors
their conventional meanings. Purple types and orange numbers remain distinct RGB
syntax colors in Neovim and OMP.

Light mode's original `#8f8d88` secondary gray measured only 3.32:1 against
white; line numbers at `#b8b6b0` measured 2.03:1. Secondary text now uses
`#615e59` (6.45:1), with darker gray punctuation. Amber, orange, and pink were
also darkened enough for shaded popups and selected rows. The white background
and green body text remain.

Dark red and purple originally measured 3.61:1 and 3.57:1 against black. Both
are brighter now. Dimmed keeps its `#1c1c1c` background and raises green text
from `#6fa886` to `#8ac69e`. Diff highlights were adjusted so text does not
disappear against the tinted background. Structural borders remain quieter than
text.

| Variant        | Background | Body text | Text contrast | Comment contrast |
| -------------- | ---------- | --------- | ------------- | ---------------- |
| Reticle Dark   | `#000000`  | `#64b580` | 8.46:1        | 6.86:1           |
| Reticle Dimmed | `#1c1c1c`  | `#8ac69e` | 8.64:1        | 7.04:1           |
| Reticle Light  | `#ffffff`  | `#0b6b39` | 6.61:1        | 6.45:1           |
| Polyimide      | `#000000`  | `#ffbf00` | 12.70:1       | 6.86:1           |

## Sunlight and typography

Polyimide's upstream foreground is bright amber on **pure black**. It improves
foreground luminance, but retains the black background that is troublesome on a
reflective screen. Light mode is the first option to try with sun behind you;
Dimmed is a compromise when keeping dark mode. A screenshot or calculated color
ratio cannot reproduce your display's reflections or room lighting.

Brighter text is what changed here. A thinner font weight is a different change;
it reduces the visible stroke area and is not the first adjustment to try for
glare. Berkeley Mono stays at the existing 12-point setting. Compare regular and
bold in the specimen, then try a modest size increase if needed. Ghostty also
offers `font-variation = wght=450` for variable fonts and macOS `font-thicken`;
neither is enabled by this audit.

Ghostty's `minimum-contrast = 4.5` provides a fallback for hard-coded app
colors. It can change their displayed colors and does not correct reflections.
The palette itself passes without relying on this setting.

## Shared color meanings

| Meaning                           | Color          | Terminal slot |
| --------------------------------- | -------------- | ------------- |
| Success, added, clean             | Green          | 2 / 10        |
| Warning, attention, modified      | Amber          | 3 / 11        |
| Error, removed, failed            | Red            | 1 / 9         |
| Path, link, information, function | Blue           | 4 / 12        |
| Keyword                           | Pink / magenta | 5 / 13        |
| Secondary information             | Cyan / teal    | 6 / 14        |
| Comment, secondary label          | Gray           | 8             |
| Type                              | Purple         | RGB only      |
| Number                            | Orange         | RGB only      |

Starship uses green/red command results, blue paths and branches, and amber
dirty Git status. Lazygit and Yazi inherit terminal colors and use reverse video
for selection without assuming a dark background. Herdr uses the same named
roles on macOS and Omarchy. Herdr 0.8.2 cannot apply separate custom light/dark
overrides, so it uses its built-in adaptive panel surfaces with shared ANSI
foregrounds; it is not an exact Reticle background port. Neovim and OMP share syntax, diagnostic, and Git
roles; OMP now selects the Reticle themes instead of its built-in Titanium/Light
pair. OMP uses a neutral selected-row background because selected rows can
contain multiple foreground colors; terminal text selection has an explicit
foreground.

## Ports and maintenance

`palettes.json` holds the colors; `omp-roles.json` holds OMP's semantic mapping.
`generate.py` renders Ghostty, OMP, Neovim palettes, and Omarchy's Ghostty,
Alacritty, Foot, Kitty, and shell colors, plus the marked theme blocks in both
Herdr configurations. All four variants have the same ports.
Generated files are committed so application startup does not need Python.

```sh
mise run themes:generate
mise run themes:check
python3 desktop/reticle/preview.py
```

Run the preview in a fresh terminal, preferably a cmux workspace. Keys 1–4
switch variants; q restores the terminal's configured colors. The preview is a
palette specimen, not a substitute for checking the real apps.

The check fails on stale generated files or contrast below 4.5:1 for text on the
base, popup, selected-row, and diff backgrounds, plus selection and cursor
pairs. ANSI slots 1–15 are checked against the base. Slot 0 remains a dark
surface on dark themes; decorative borders are deliberately excluded. These are
sRGB relative-luminance checks, not a claim of complete application
accessibility.

The existing `symlink-each` entries in `cli/mise/mise.toml`,
`mise.personal.toml`, and `mise.amarna.toml` cover the new files. On another
host, apply the relevant dotfile targets with `mise bootstrap dotfiles apply`;
Omarchy themes are deployed by the Amarna configuration. Only the macOS
applications are available for live inspection here; Linux terminal ports
receive format and palette consistency checks.

## Selecting a variant

- Ghostty/cmux: change the dark half of `theme` to `POLYIMIDE-GH`,
  `RETICLE-DARK-GH`, or `RETICLE-DIMMED-GH`, then reload configuration.
- OMP: use `/settings` to select `polyimide`, `reticle-dark`, `reticle-dimmed`,
  or `reticle-light`; its configured automatic pair is Dimmed/Light.
- Neovim: `:colorscheme polyimide` or `:colorscheme reticle-dimmed` selects a
  variant; `:colorscheme reticle` restores automatic Dimmed/Light selection. Set
  `vim.g.usgc_reticle_dark = "polyimide"` before loading `reticle` to pair
  Polyimide with the automatic light variant.
- Omarchy: select the installed theme by its directory name.

Apps with their own hard-coded RGB palettes can still differ. In particular,
Yazi's file icons and syntax previews, and tools such as bat, fzf, and Atuin
have not received complete custom theme ports in this pass. ANSI output follows
the terminal, but that does not make every built-in app color part of this
palette.

## Sources

These are local semantic adaptations, not exact upstream reproductions. Upstream
describes its Sublime themes as text-oriented, with no programming syntax rules.
Reticle Light is a local adaptation on a HIGHK-like white background; it is not
an upstream theme or part number. Polyimide preserves upstream's black, amber
foreground, green caret, and blue/cyan text selection, with local TUI accents.

- [USGC themes](https://github.com/usgraphics/usgc-themes/tree/14f74251d91e364c0d90844f0bd52feb43b08c60),
  audited 2026-09-05; see the retained [BSD license](LICENSE).
- [Polyimide source](https://github.com/usgraphics/usgc-themes/blob/14f74251d91e364c0d90844f0bd52feb43b08c60/themes/sublime-text/USGC-POLYIMIDE-ST.sublime-color-scheme).
- [Ghostty configuration](https://ghostty.org/docs/config/reference#minimum-contrast),
  also checked against the installed binary's configuration documentation.
- [Contrast definition](https://www.w3.org/TR/WCAG22/#dfn-contrast-ratio).
- [Lazygit selection settings](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md#highlighting-the-selected-line).
- [Yazi theme format](https://github.com/sxyazi/yazi/blob/main/yazi-config/preset/theme-dark.toml).
