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


export EDITOR="${EDITOR:-nvim}"
export PAGER="${PAGER:-less}"

export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export npm_config_cache="${npm_config_cache:-$XDG_CACHE_HOME/npm}"
export TASKRC="${TASKRC:-$XDG_CONFIG_HOME/task/taskrc}"
export TASKDATA="${TASKDATA:-$XDG_DATA_HOME/task}"

if [[ "$(uname -s)" == Darwin && -z "${NODE_OPTIONS:-}" ]]; then
  # macOS 27 aborts on a second process.title assignment.
  _node_title_shim="$XDG_CONFIG_HOME/node/no-process-title.cjs"
  [[ -r "$_node_title_shim" ]] && export NODE_OPTIONS="--require $_node_title_shim"
  unset _node_title_shim
fi

export HOMEBREW_NO_ENV_HINTS=1
export MISE_EXPERIMENTAL=1

export DOTFILES_DIR="$HOME/src/dotfiles"
export LLM_WIKI_DIR="$HOME/wiki"

if [[ -z "${SSH_AUTH_SOCK:-}" && -S "$XDG_STATE_HOME/1password/agent.sock" ]]; then
  export SSH_AUTH_SOCK="$XDG_STATE_HOME/1password/agent.sock"
fi

# Source local env overrides (provided by overlay modules)
[[ -r "$ZDOTDIR/env.local.zsh" ]] && source "$ZDOTDIR/env.local.zsh"
