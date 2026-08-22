md() {
  mkdir -p "$1" && cd "$1"
}

path_prepend() {
  [[ -d "$1" ]] && path=("$1" $path)
}

y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command trash -- "$tmp"
}
