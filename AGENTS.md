# AGENTS.md

Personal dotfiles for macOS and Omarchy, managed with `mise` for tool
versions and deployment and `fnox` for secrets. Deployment lives in the
`[dotfiles]` tables of `cli/mise/*.toml`, so a new file is not installed until
it has an entry there.

Each `cli/mise/mise.<name>.toml` deploys as `~/.config/mise/config.<name>.toml`
and loads when `<name>` is in the host's `env` list. `auto_env` also loads
`mise.macos.toml` or `mise.linux.toml`, always below every listed name, so
`mise.toml` must not set values those files provide. Modules such as
`mise.omp.toml`, `mise.hermes.toml`, `mise.pi.toml`, `mise.claude.toml`, and
`mise.beets.toml` hold one app's packages, tools, dotfiles, and first-run
seed hooks. `cli/mise/miserc.toml.tmpl` is the only host-to-module map;
`bootstrap` renders it first. Hyperion, amarna, and sigil are personal; atlas
is the work machine and gets no personal agents. To retire a module, drop it
from the map and run `mise bootstrap unapply <name>` before deleting its file.
Write into a layer with `mise -C ~/src/dotfiles/cli/mise use -e <name> <tool>`;
plain `mise use -g` writes to `mise.macos.toml` on macOS and to Omarchy's own
`config.toml` on Linux.

Every machine decrypts with `~/.config/fnox/age-identity.txt`. On a new
machine, `bootstrap` creates it by unlocking `cli/fnox/setup-identity.age`
with its passphrase. Private files that are not fnox secrets, such as the
gitleaks policy in `cli/hk/*.age`, are age-encrypted to the recipients in
`cli/fnox/config.toml`; write them with `mise run age:encrypt <in> <out>`.
After changing recipients, run `fnox reencrypt` and re-encrypt every `*.age`.

Commit messages are enforced by `cli/hk/commit-message-policy.sh.tmpl`.
Conventional Commits scoped to the top directory, such as `fix(zsh)`.
Subject at most 72 characters, past tense, no trailing period. Body is
optional; if present, one paragraph hard-wrapped at 72 characters, never
a list. Split unrelated changes into separate commits.
