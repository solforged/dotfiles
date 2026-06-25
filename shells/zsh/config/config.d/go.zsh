export GOPATH="${GOPATH:-${XDG_DATA_HOME:-$HOME/.local/share}/go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"

path=("$GOBIN" $path)
typeset -U path
export PATH
