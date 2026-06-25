export BUN_INSTALL="${BUN_INSTALL:-${XDG_DATA_HOME:-$HOME/.local/share}/bun}"

path=("$BUN_INSTALL/bin" $path)
typeset -U path
export PATH
