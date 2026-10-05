# dotfiles

Personal configuration for macOS (Apple silicon) and
[Omarchy](https://omarchy.org) Linux. [mise](https://mise.jdx.dev) installs
tools, deploys dotfiles, and applies system settings;
[fnox](https://github.com/jdx/fnox) and [age](https://age-encryption.org) handle
secrets.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/solforged/dotfiles/main/bootstrap | /bin/bash
```

`bootstrap` must run from an interactive terminal. It:

1. Installs the Xcode Command Line Tools on macOS, or checks for Omarchy, `git`,
   and `curl` on Linux.
2. Clones this repository to `~/src/dotfiles`, or verifies an existing checkout.
3. Installs mise to `~/.local/bin/mise` if it is missing.
4. Creates `~/.config/fnox/age-identity.txt` by decrypting
   `cli/fnox/setup-identity.age`, which asks for its passphrase.
5. Renders `~/.config/mise/miserc.toml` to select this host's modules.
6. Hands off to `mise bootstrap`, passing through any arguments.

The setup passphrase is private, so a fresh install only completes on my own
machines. Run `bootstrap` again at any time; each step skips work already done.

## How it works

Deployment lives in the `[dotfiles]` tables of `cli/mise/*.toml`. A file in this
repository is not installed until one of those tables names it. Most entries are
symlinks; files ending in `.tmpl` are rendered as templates using the `[vars]`
of the active modules.

### Modules

Each `cli/mise/mise.<name>.toml` deploys as `~/.config/mise/config.<name>.toml`
and loads only when `<name>` appears in the host's `env` list. `mise.toml` is
the shared base and deploys as `config.base.toml`, which leaves
`~/.config/mise/config.toml` free for tools that edit it themselves.

| Module                                 | Contents                                                 |
| -------------------------------------- | -------------------------------------------------------- |
| `base` (`mise.toml`)                   | Shared CLI tools, runtimes, dotfiles, and tasks          |
| `macos`                                | Homebrew packages and macOS defaults                     |
| `personal`                             | Settings for personally owned machines                   |
| `omp`                                  | Oh My Pi coding agent                                    |
| `pi`                                   | Pi coding agent                                          |
| `claude`                               | Claude Code CLI                                          |
| `beets`                                | Beets music library and chromaprint                      |
| `hyperion`, `amarna`, `atlas`          | Per-host packages, services, and overrides               |

`auto_env` also loads the operating system module (`mise.macos.toml` on macOS)
below every listed name, so `mise.toml` must not set a value that module
provides. The `.lock` files beside the modules pin the versions that `latest`
resolved to.

### Hosts

`cli/mise/miserc.toml.tmpl` is the only map from hostname to modules. Later
names override earlier ones, and the host module comes last.

| Host             | Modules                                 |
| ---------------- | --------------------------------------- |
| hyperion (macOS) | base, personal, agents, beets, hyperion |
| amarna (Omarchy) | base, personal, agents, beets, amarna   |
| atlas (work)     | base, atlas                             |
| any other        | base, personal, agents                  |

"Agents" means `omp`, `pi`, and `claude`. Atlas is the work machine and gets no
personal agents.

### Work overlay

Work configuration lives in a private repository cloned to `overlays/work`,
which `.gitignore` excludes. On atlas, a hook links it to
`~/.config/mise/conf.d/work` when it contains a `mise.toml`. Run
`mise bootstrap` once more after the first link so its tools and dotfiles load.
Nothing work-internal belongs in this repository.

### SSH keys

Each personal host has its own `~/.ssh/id_ed25519` for GitHub push, commit
signing, and SSH between hosts. Keys never leave their host and have no
passphrase, so agents can push and sign while nobody is at the keyboard. On a
new host, run `mise run ssh:enroll`: it creates the key, registers it on GitHub
for authentication and signing, and prints the line to add to `ssh_public_keys`
in `cli/mise/mise.toml`. Then set `ssh_key = "~/.ssh/id_ed25519"` in the host
module to turn on signing. To retire a host, delete its two GitHub keys and mark
its line in `ssh_public_keys` as retired so old signatures still verify.

## Layout

| Path                   | Contents                                                        |
| ---------------------- | --------------------------------------------------------------- |
| `bootstrap`            | First-run installer                                             |
| `cli/mise/`            | Modules, lockfiles, and the host map                            |
| `cli/fnox/`            | fnox config, age recipients, and the wrapped setup identity     |
| `cli/hk/`              | Git hook scripts and the encrypted gitleaks policy              |
| `cli/git/`, `cli/ssh/` | Git config templates and SSH config                             |
| `cli/*`                | Other CLI configs, including lazygit, yazi, gh, herdr, and task |
| `shells/`              | zsh, Nushell, and Starship                                      |
| `editors/`             | Neovim, Helix, and Zed                                          |
| `desktop/`             | Ghostty, cmux, Omarchy, fontconfig, and the Reticle themes      |
| `agents/`              | omp configuration                                               |
| `assets/fonts/`        | Encrypted Berkeley Mono font                                    |

## Common tasks

| Goal                             | Command                                                  |
| -------------------------------- | -------------------------------------------------------- |
| Re-apply everything              | `mise bootstrap`                                         |
| Re-apply dotfiles only           | `mise bootstrap dotfiles apply`                          |
| Add a tool to a module           | `mise -C ~/src/dotfiles/cli/mise use -e <module> <tool>` |
| Update locked tool versions      | `mise run tools:bump`                                    |
| Encrypt a file for every machine | `mise run age:encrypt <input> <output>`                  |
| Install Berkeley Mono            | `mise run fonts:install-berkeley`                        |
| Regenerate Reticle themes        | `mise run themes:generate`                               |
| Check theme contrast             | `mise run themes:check`                                  |
| Enroll this host's SSH key       | `mise run ssh:enroll`                                    |

Plain `mise use -g` writes to `mise.macos.toml` on macOS and to Omarchy's own
`config.toml` on Linux, so use `-e` to target a module.

### Adding a module

1. Create `cli/mise/mise.<name>.toml` with its tools, packages, and `[dotfiles]`
   entries.
2. Add `<name>` to the relevant hosts in `cli/mise/miserc.toml.tmpl`.
3. Run `mise bootstrap`.

To retire a module, remove it from the host map and run
`mise bootstrap unapply <name>` before deleting its file.

## Secrets

Every machine decrypts with `~/.config/fnox/age-identity.txt`. fnox stores
secrets; other private files, such as the gitleaks policy and the font, are
age-encrypted to the recipients in `cli/fnox/config.toml`. After changing
recipients, run `fnox reencrypt` and re-encrypt every `*.age` file with
`mise run age:encrypt`.

## Commit hooks

`cli/git/config.tmpl` registers global Git hooks for every repository on the
machine:

- `commit-message-policy.sh` enforces Conventional Commits with a subject of at
  most 72 characters.
- `gitleaks-fnox.sh` scans the staged diff and the commit message for secrets.

Commits here use the top-level directory as scope, such as `fix(zsh)`.

## Themes

Applications currently default to the GitHub dark and light palettes. The
Reticle and Polyimide ports remain available; see
[`desktop/reticle/README.md`](desktop/reticle/README.md) for the palette, the
generator, and how to select a variant.
