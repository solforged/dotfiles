# AGENTS.md

Personal dotfiles for macOS and Omarchy, managed with `mise` for tool
versions and deployment and `fnox` for secrets, plus an optional work overlay in
`overlays/`. Deployment lives in the `[dotfiles]` tables of `cli/mise/*.toml`,
so a new file is not installed until it has an entry there.

Commit messages are enforced by `cli/hk/commit-message-policy.sh.tmpl`.
Conventional Commits scoped to the top directory, such as `fix(zsh)`.
Subject at most 72 characters, past tense, no trailing period. Body is
optional; if present, one paragraph hard-wrapped at 72 characters, never
a list. Split unrelated changes into separate commits.
