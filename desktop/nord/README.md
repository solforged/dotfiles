# Nord defaults

Nord dark and Nord-inspired light palettes are the application defaults.

| Application     | Dark                       | Light                           |
| --------------- | -------------------------- | ------------------------------- |
| Ghostty         | `Nord`                     | `Nord Light`                    |
| Herdr           | Nord custom palette        | Snow Storm custom light palette |
| Neovim on macOS | `nord` (`background=dark`) | `nord` (`background=light`)     |
| OMP             | `nord-dark`                | `nord-light`                    |
| Zed             | `Nord Dark`                | `Nord Light`                    |
| Helix           | `nord`                     | `nord_light`                    |
| Nushell         | `nord-dark`                | `nord-light`                    |

Ghostty, Herdr, macOS Neovim, OMP, and Zed follow system or terminal
appearance. Helix and Nushell default to dark; use `:theme nord_light` in Helix
or set `NU_THEME=nord-light` before launching Nushell for light terminals.
Lazygit and Yazi inherit the terminal palette; Lazygit's ordinary text uses the
terminal's default foreground.

Zed's `nord` extension installs automatically. Neovim uses
`shaunsingh/nord.nvim` with opaque backgrounds, contrasting popups, and no
syntax italics. Linux Neovim remains owned by Omarchy's selected theme rather
than the macOS appearance hook.

The local Herdr, OMP, and Nushell ports share Frost blue/cyan accents, green
strings and success states, and purple numbers. OMP and Herdr use neutral slate
selected rows rather than saturated blue fills. Dark secondary text is brighter
than Nord's original low-contrast comment gray. Their light adaptations use Snow
Storm surfaces and darker Frost/Aurora text accents; Nord itself is a dark
palette, so upstream light ports are not exact matches. Built-in Ghostty and
editor ports keep their own Nord mappings.

`mise run themes:check` checks the local OMP, Nushell, and Herdr Nord palettes
for role consistency and light text contrast (at least 4.5:1 on base, panel,
selection, and diff surfaces). Native app ports and Nord dark syntax accents are
not covered by that light contrast guarantee. The local JSON assets are
hand-maintained.

## Custom themes

Reticle and Polyimide live in
[solforged/reticle](https://github.com/solforged/reticle). Add `reticle` to a
host's modules in `cli/mise/miserc.toml.tmpl` and run `mise bootstrap`; the
`mise.reticle.toml` module clones the repository to `~/src/reticle` and links
its Ghostty, OMP, Helix, Nushell, and Neovim ports beside the Nord files. The
defaults above stay selected. Omarchy variants install on their own with
`omarchy theme install`; the Reticle README lists their URLs.

## Interface conventions

The prompt separates context from command entry. Its first line has three parts:
host, path, and branch with compact Git symbols, such as
`hyperion ~/src/dotfiles [main +!?]`. The second begins with `>`, which turns
red after a failed command. Git status counts, stash indicators, and command
durations are omitted. Detached commits use `@hash`; an active merge or rebase
appears inside the branch brackets. Starship uses green/red command results,
blue paths and branches, and compact Git symbols: green staged changes, amber
modifications and new files, red deletions and conflicts, and cyan renames.

Yazi uses flat separators and file-kind markers: `d` directory, `l` link, `x`
executable, `-` ordinary file, and `!` broken link. The active row is amber.
Lazygit and Yazi inherit terminal colors and use reverse video for selection
without assuming a dark background. Lazygit uses neutral text so unchanged diff
context stays distinct from green additions.

Neovim uses square floating-window borders, a flat status line, and letter-based
file icons; Lazygit uses square borders without file icons. OMP uses Unicode
symbols with text shimmer disabled. Berkeley Mono stays at its 12-point
setting.

Nushell and Helix use normal application configurations and mise tool entries.
Zsh remains the login shell and Neovim remains the default editor. Zsh's native
directory hashes provide the existing `~df`, `~an`, `~lst`, and `~lsh`
shortcuts; Starship renders the current directory directly.

Apps with their own hard-coded RGB palettes can still differ. Yazi's syntax
previews, and tools such as bat, fzf, and Atuin, have no custom theme ports. ANSI
output follows the terminal, but that does not make every built-in app color
part of the palette.

## Sources

- [Nord colors and palettes](https://www.nordtheme.com/docs/colors-and-palettes/).
- [Nord Neovim port](https://github.com/shaunsingh/nord.nvim), supporting both
  `background` values with the `nord` colorscheme.
- [Zed Nord Themes](https://github.com/mikasius/zed-nord-theme).
- [Nushell community Nord port](https://github.com/nushell/nu_scripts/blob/main/themes/nu-themes/nord.nu).
  The local JSON ports use static values, conventional Nord syntax roles, and
  readable secondary text without changing terminal colors or adding dynamic
  value coloring.
- [Lazygit selection settings](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md#highlighting-the-selected-line).
- [Yazi theme format](https://github.com/sxyazi/yazi/blob/main/yazi-config/preset/theme-dark.toml).
- [Starship prompt configuration](https://starship.rs/config/).
