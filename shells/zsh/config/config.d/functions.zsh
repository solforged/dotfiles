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

# Open nvim on the current directory, or on the given files.
n() {
  if (( $# == 0 )); then
    command nvim .
  else
    command nvim "$@"
  fi
}

# Fuzzy-find a file with a preview; eff opens the pick in $EDITOR.
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ff="fzf --preview 'case \$(file --mime-type -b -- {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 -- {} ;; *) bat --style=numbers --color=always --theme=ansi --paging=never -- {} ;; esac'"
else
  alias ff="fzf --preview 'bat --style=numbers --color=always --theme=ansi --paging=never -- {}'"
fi
eff() {
  local selected
  selected=$(ff "$@") || return
  [[ -n "$selected" ]] || return
  local -a editor=( ${(z)${EDITOR:-nvim}} )
  "${(@Q)editor}" -- "$selected"
}

compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }

# --- Listing (eza) ---
if command -v eza >/dev/null 2>&1; then
  _eza_defaults=(--color=auto --group-directories-first --classify=auto)
  _eza_long_defaults=(-l --time-style=long-iso)

  ls() { command eza "${_eza_defaults[@]}" "$@"; }
  ll() { command eza "${_eza_defaults[@]}" "${_eza_long_defaults[@]}" "$@"; }
  la() { ll -a "$@"; }
  lt() { command eza "${_eza_defaults[@]}" -l --time-style=long-iso --tree --level=2 --icons --git "$@"; }
  lta() { lt -a "$@"; }
fi

# --- Git worktrees ---
# Create a new worktree and branch from within current git directory.
ga() {
  if [[ -z "$1" ]]; then
    echo "Usage: ga [branch name]"
    return 1
  fi

  local branch="$1"
  local base="$(basename "$PWD")"
  local wt_path="../${base}--${branch}"

  git worktree add -b "$branch" "$wt_path"
  command -v mise >/dev/null 2>&1 && mise trust "$wt_path"
  cd "$wt_path"
}

# Remove worktree and branch from within active worktree directory.
gd() {
  local confirm=n
  if command -v gum >/dev/null 2>&1; then
    gum confirm "Remove worktree and branch?" || return 0
  else
    read -r "confirm?Remove worktree and branch? (y/N): "
    [[ "$confirm" != [Yy] ]] && return 0
  fi

  local cwd base branch root worktree

  cwd="$(pwd)"
  worktree="$(basename "$cwd")"

  # split on first `--`
  root="${worktree%%--*}"
  branch="${worktree#*--}"

  # Protect against accidentally nuking a non-worktree directory
  if [[ "$root" != "$worktree" ]]; then
    cd "../$root"
    git worktree remove "$cwd" --force || return 1
    git branch -D "$branch"
  else
    echo "Current directory is not a worktree (does not match <root>--<branch> pattern)"
    return 1
  fi
}
