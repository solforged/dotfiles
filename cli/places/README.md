# Shared places

`places.toml` defines the existing `df`, `an`, `lst`, and `lsh` directory names.
Environment overrides for dotfiles and XDG directories still apply.

| Command | Action |
| --- | --- |
| `p` | List places; records in Nushell |
| `p df` | Change to dotfiles |
| `work df` | Focus the named local workspace, or create it at that place |
| `role edit` | Label the current tab; also accepts `agent`, `check`, and `shell` |
| Yazi: `g p`, then `df` | Choose a shared place |

Zsh exposes the same names as directory hashes, such as `~df`; both prompts use
them for matching paths. Open a fresh shell after changing the registry.
Missing directories are reported and never created by navigation.

`work` uses cmux or Herdr and matches workspace names exactly; duplicate names
produce an error. Existing workspaces retain their running programs and location.
`role` only labels the tab. This helper does not launch or configure applications.

Run `mise run places:check` to check path matching and workspace selection.
cmux navigation and the Yazi chooser were checked live on macOS; Herdr command
routing has isolated tests.
