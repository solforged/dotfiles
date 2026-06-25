typeset -U path

path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" $path)

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

export HOMEBREW_NO_ENV_HINTS=1
export MISE_EXPERIMENTAL=1

export DOTFILES_DIR="$HOME/src/dotfiles"
export LLM_WIKI_DIR="$HOME/wiki"

if [[ -z "${MISE_ENV:-}" ]]; then
  _mise_host="${HOST%%.*}"
  [[ -z "$_mise_host" ]] && _mise_host="$(hostname -s 2>/dev/null)"
  case "$_mise_host" in
    atlas) export MISE_ENV=work ;;
    *) export MISE_ENV=personal ;;
  esac
  unset _mise_host
fi

# Source local env overrides (provided by overlay modules)
[[ -r "$ZDOTDIR/env.local.zsh" ]] && source "$ZDOTDIR/env.local.zsh"
