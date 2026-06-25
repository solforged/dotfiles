mkcd() {
  mkdir -p "$1" && cd "$1"
}

path_prepend() {
  [[ -d "$1" ]] && path=("$1" $path)
}
