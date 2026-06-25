ZIM_CONFIG_FILE="${ZIM_CONFIG_FILE:-${ZDOTDIR:-$HOME}/.zimrc}"
ZIM_HOME="${ZIM_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/zim}"
export ZIM_CONFIG_FILE ZIM_HOME

typeset -a _zimfw_candidates
_zimfw_candidates=(
  /opt/homebrew/opt/zimfw/share/zimfw.zsh
  /usr/local/opt/zimfw/share/zimfw.zsh
  /home/linuxbrew/.linuxbrew/opt/zimfw/share/zimfw.zsh
  "${ZIM_HOME}/zimfw.zsh"
)
[[ -n "${HOMEBREW_PREFIX:-}" ]] && _zimfw_candidates=("${HOMEBREW_PREFIX}/opt/zimfw/share/zimfw.zsh" $_zimfw_candidates)

_zimfw_script=
for _zimfw_candidate in $_zimfw_candidates; do
  if [[ -r "$_zimfw_candidate" ]]; then
    _zimfw_script="$_zimfw_candidate"
    break
  fi
done

if [[ -n "$_zimfw_script" && ! "${ZIM_HOME}/init.zsh" -nt "$ZIM_CONFIG_FILE" ]]; then
  source "$_zimfw_script" init
fi

if [[ -r "${ZIM_HOME}/init.zsh" ]]; then
  source "${ZIM_HOME}/init.zsh"
else
  autoload -Uz compinit
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
fi

unset _zimfw_candidate _zimfw_candidates _zimfw_script
