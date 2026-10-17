typeset -U path

# Keep Omarchy's exported paths and desktop CLI environment when zsh replaces
# its default bash login shell. User preferences below still take precedence.
if [[ -r /usr/share/omarchy/default/bash/env-bootstrap ]]; then
  source /usr/share/omarchy/default/bash/env-bootstrap
  [[ -r /usr/share/omarchy/default/bash/envs ]] && source /usr/share/omarchy/default/bash/envs
fi

base_paths=("$HOME/.local/bin" "$HOME/.local/share/mise/shims")
if [[ "$OSTYPE" == darwin* ]]; then
  [[ -d /opt/homebrew/bin ]] && base_paths+=(/opt/homebrew/bin)
  [[ -d /opt/homebrew/sbin ]] && base_paths+=(/opt/homebrew/sbin)
fi
path=($base_paths $path)
unset base_paths

export PATH
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

if [[ -z "${XDG_CONFIG_DIRS:-}" ]]; then
  xdg_dirs=(/etc/xdg)
  if [[ "$OSTYPE" == darwin* ]]; then
    [[ -d /usr/local/etc/xdg ]] && xdg_dirs=(/usr/local/etc/xdg $xdg_dirs)
    [[ -d /opt/homebrew/etc/xdg ]] && xdg_dirs=(/opt/homebrew/etc/xdg $xdg_dirs)
  fi
  export XDG_CONFIG_DIRS="${(j.:.)xdg_dirs}"
  unset xdg_dirs
fi

if [[ -z "${XDG_DATA_DIRS:-}" ]]; then
  xdg_dirs=(/usr/local/share /usr/share)
  if [[ "$OSTYPE" == darwin* ]]; then
    [[ -d /opt/homebrew/share ]] && xdg_dirs=(/opt/homebrew/share $xdg_dirs)
  fi
  export XDG_DATA_DIRS="${(j.:.)xdg_dirs}"
  unset xdg_dirs
fi


if command -v omarchy-launch-editor >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-omarchy-launch-editor --inline}"
else
  export EDITOR="${EDITOR:-nvim}"
fi
export SUDO_EDITOR="$EDITOR"
export PAGER="${PAGER:-moor}"
export MOOR="${MOOR:---no-linenumbers}"

export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export TASKRC="${TASKRC:-$XDG_CONFIG_HOME/task/taskrc}"
export TASKDATA="${TASKDATA:-$XDG_DATA_HOME/task}"

# Tool homes. They live here rather than in .zshrc so scripts and agents get
# them too; launchd-env.zsh copies them into launchd for GUI apps and agents.
export CARGO_HOME="${CARGO_HOME:-$XDG_DATA_HOME/cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$XDG_DATA_HOME/rustup}"
export GOPATH="${GOPATH:-$XDG_DATA_HOME/go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"
export BUN_INSTALL="${BUN_INSTALL:-$XDG_DATA_HOME/bun}"
export npm_config_cache="${npm_config_cache:-$XDG_CACHE_HOME/npm}"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$XDG_DATA_HOME/gradle}"
export PUB_CACHE="${PUB_CACHE:-$XDG_CACHE_HOME/pub-cache}"
export GEM_SPEC_CACHE="${GEM_SPEC_CACHE:-$XDG_CACHE_HOME/gem}"
export MPLCONFIGDIR="${MPLCONFIGDIR:-$XDG_CONFIG_HOME/matplotlib}"
# Codex keeps its login and history in CODEX_HOME, so a host opts in by moving
# ~/.codex to $XDG_DATA_HOME/codex.
if [[ -z "${CODEX_HOME:-}" && -d "$XDG_DATA_HOME/codex" ]]; then
  export CODEX_HOME="$XDG_DATA_HOME/codex"
fi

if [[ "$OSTYPE" == darwin* && -z "${NODE_OPTIONS:-}" ]]; then
  # macOS 27 aborts on a second process.title assignment.
  _node_title_shim="$XDG_CONFIG_HOME/node/no-process-title.cjs"
  [[ -r "$_node_title_shim" ]] && export NODE_OPTIONS="--require $_node_title_shim"
  unset _node_title_shim
fi

export HOMEBREW_NO_ENV_HINTS=1
export MISE_EXPERIMENTAL=1

export DOTFILES_DIR="$HOME/src/dotfiles"
export LLM_WIKI_DIR="$HOME/wiki"

# Source local env overrides (provided by overlay modules)
if [[ -r "$ZDOTDIR/env.local.zsh" ]]; then
  source "$ZDOTDIR/env.local.zsh"
fi
