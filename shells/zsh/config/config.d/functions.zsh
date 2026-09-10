md() {
  mkdir -p "$1" && cd "$1"
}

# omp commit uses its own prompt and will not read AGENTS.md. Inject the
# global commit-msg policy unless the caller already passed --context.
omp() {
  if [[ "$1" == "commit" ]]; then
    shift
    local skip=0 arg
    for arg in "$@"; do
      case "$arg" in
        --context|-c|--help|-h) skip=1; break ;;
      esac
    done
    if (( skip )); then
      command omp commit "$@"
    else
      command omp commit --context "Commit messages must pass the global commit-msg policy: Conventional Commits, with a lowercase description after type(scope): and a past-tense subject at most 72 characters with no trailing period. Body is optional. If present, write one paragraph (at most three), hard-wrapped at 72 characters. Never use bullet or numbered lists, never start a line with -, *, +, or 1., and do not emit detail lines." "$@"
    fi
  else
    command omp "$@"
  fi
}

path_prepend() {
  [[ -d "$1" ]] && path=("$1" $path)
}

y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
  command rm -f "$tmp"
}
