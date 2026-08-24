# Synced from Omarchy's default bash environment
# (/usr/share/omarchy/default/bash/aliases and default/bash/fns/*).
# Sourced before the personal config.d files so local overrides win.
# Kept textually close to upstream to make future re-syncs easy;
# platform-specific pieces are guarded inline.

# --- Tools --------------------------------------------------------------------
[[ $OSTYPE == darwin* ]] || alias a='omarchy-agent --inline'
alias c='opencode --auto'
alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode auto'
alias cy='codex --approve-for-me'
command -v docker &>/dev/null && alias d='docker'
alias r='rails'
command -v tmux &>/dev/null && alias t='tmux attach || tmux new -s Work'
command -v herdr &>/dev/null && alias h='herdr'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
n() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }

# Fuzzy-find a file with an image-aware preview (kitty graphics protocol only).
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ff="fzf --preview 'case \$(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'"
else
  alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
fi
alias eff='$EDITOR "$(ff)"'
# GNU find only; macOS find lacks -printf.
[[ $OSTYPE != darwin* ]] && sff() { if [ $# -eq 0 ]; then echo "Usage: sff <destination> (e.g. sff host:/tmp/)"; return 1; fi; local file; file=$(find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff) && [ -n "$file" ] && scp "$file" "$1"; }

# Detach GUI opens from the shell. On macOS /usr/bin/open already does this.
[[ $OSTYPE != darwin* ]] && open() (
  xdg-open "$@" >/dev/null 2>&1 &
)

# --- Directories ---------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'

# Smart cd via zoxide: real paths go straight there, anything else jumps
# through zoxide's database.
if command -v zoxide &> /dev/null; then
  alias cd="zd"
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi

      print "\U000F17A9 $PWD"
    fi
  }
fi

# --- Listing (eza) --------------------------------------------------------------
_eza_defaults=(--color=auto --group-directories-first --classify=auto)
_eza_long_defaults=(-lh --time-style=long-iso)
[[ $OSTYPE == darwin* ]] && _eza_long_defaults+=(--extended)

ls() { command eza "${_eza_defaults[@]}" "${_eza_long_defaults[@]}" "$@"; }
lsa() { ls -a "$@"; }
lt() { command eza "${_eza_defaults[@]}" -l --time-style=long-iso --tree --level=2 --icons --git "$@"; }
lta() { lt -a "$@"; }

# --- Compression -----------------------------------------------------------------
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# --- Git shortcuts ----------------------------------------------------------------
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# --- Git worktrees ------------------------------------------------------------------
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
  mise trust "$wt_path"
  cd "$wt_path"
}

# Remove worktree and branch from within active worktree directory.
gd() {
  if gum confirm "Remove worktree and branch?"; then
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
    fi
  fi
}

# --- SSH ------------------------------------------------------------------------------
# Wrap ssh to clean up the terminal and reconnect when a connection drops.
#
# A remote tmux, herdr, or editor arms terminal modes over the SSH pipe (mouse
# tracking, focus reporting, the alternate screen) that only it can disarm. If
# the connection dies instead of exiting cleanly, those modes stay armed on the
# local terminal, and every mouse move floods the prompt with escape junk.
ssh() {
  local rc started

  started=$SECONDS
  command ssh "$@"
  rc=$?

  [[ -t 1 ]] || return $rc
  _ssh_disarm

  # Reconnect only when an interactive session drops: ssh exits 255 for
  # transport failures, but a fast 255 with no established session is a
  # connect/auth failure, a remote command's own 255 passes through
  # indistinguishably and must not replay its side effects, and redirected
  # stdin would feed the remaining piped input to a fresh remote shell.
  if (( rc != 255 )) || [[ ! -t 0 ]] || ! _ssh_interactive "$@" ||
    (( SECONDS - started < 30 )); then
    return $rc
  fi

  # Retry in a subshell: Ctrl-C reaches the whole foreground process group,
  # so it cancels both the in-flight attempt and the loop itself. Keep
  # retrying fast failures, since a rebooting server refuses connections too.
  (
    while true; do
      echo "Connection lost. Reconnecting (Ctrl-C to stop)..."
      sleep 2
      command ssh "$@"
      rc=$?
      _ssh_disarm
      (( rc != 255 )) && exit $rc
    done
  )
}

# Disarm mouse tracking (1000/1002/1003, 1006 encoding), focus reporting
# (1004), and the alternate screen (1049), and show the cursor again.
_ssh_disarm() {
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[?1049l\e[?25h'
}

# True for an interactive session: a destination and no remote command. The
# letters are the ssh(1) options that consume a value, so their arguments are
# not mistaken for the destination.
_ssh_interactive() {
  local value_opts="BbcDEeFIiJLlmOoPpQRSWw"
  local -a argv
  argv=("$@")
  local arg letters i dest="" opts_done=""

  while (($#)); do
    arg="$1"
    shift

    if [[ -z $opts_done && $arg == "--" ]]; then
      opts_done=1
    elif [[ -z $opts_done && $arg == -?* ]]; then
      letters="${arg#-}"
      for ((i = 0; i < ${#letters}; i++)); do
        if [[ $value_opts == *"${letters:i:1}"* ]]; then
          # The value is glued to the letter (-p2222) unless the letter ends
          # the argument, in which case it consumes the next one (-p 2222).
          (( i == ${#letters} - 1 )) && shift
          break
        fi
      done
    elif [[ -z $dest ]]; then
      dest="$arg"
    else
      return 1
    fi
  done

  [[ -n $dest ]] || return 1

  # A RemoteCommand from ssh_config or -o replays on reconnect just like a
  # positional command; ssh -G resolves the effective configuration for this
  # exact invocation without connecting. Fail closed when it cannot resolve,
  # since an undetected RemoteCommand must not replay. The explicit "none"
  # cancels a configured command, and some versions emit it when unset.
  local resolved
  resolved=$(command ssh -G "${argv[@]}" 2>/dev/null) || return 1
  ! grep -i '^remotecommand ' <<<"$resolved" | grep -qvi '^remotecommand none$'
}

# SSH port forwarding: fip forwards ports, dip stops them, lip lists them.
fip() {
  (( $# < 2 )) && echo "Usage: fip <host> <port1> [port2] ..." && return 1
  local host="$1"
  shift
  local port
  for port in "$@"; do
    ssh -f -N -L "${port}:localhost:${port}" "$host" && echo "Forwarding localhost:$port -> $host:$port"
  done
}

dip() {
  (( $# == 0 )) && echo "Usage: dip <port1> [port2] ..." && return 1
  local port
  for port in "$@"; do
    pkill -f "ssh.*-L ${port}:localhost:${port}" && echo "Stopped forwarding port $port" || echo "No forwarding on port $port"
  done
}

lip() {
  pgrep -af "ssh.*-L [0-9]+:localhost:[0-9]+" || echo "No active forwards"
}

# --- Tmux layouts ------------------------------------------------------------------------
# Create a Tmux Dev Layout with editor, ai, and terminal
# Usage: tdl <c|cx|codex|other_ai> [<second_ai>]
tdl() {
  [[ -z $1 ]] && { echo "Usage: tdl <c|cx|codex|other_ai> [<second_ai>]"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tdl."; return 1; }

  local current_dir="${PWD}"
  local editor_pane ai_pane ai2_pane
  local ai="$1"
  local ai2="$2"

  # Use TMUX_PANE for the pane we're running in (stable even if active window changes)
  editor_pane="$TMUX_PANE"

  # Name the current window after the base directory name
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"

  # Split window vertically - top 85%, bottom 15% (target editor pane explicitly)
  tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"

  # Split editor pane horizontally - AI on right 30% (capture new pane ID directly)
  ai_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

  # If second AI provided, split the AI pane vertically
  if [[ -n $ai2 ]]; then
    ai2_pane=$(tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
    tmux send-keys -t "$ai2_pane" "$ai2" C-m
  fi

  # Run ai in the right pane
  tmux send-keys -t "$ai_pane" "$ai" C-m

  # Run nvim in the left pane
  tmux send-keys -t "$editor_pane" "$EDITOR ." C-m

  # Select the nvim pane for focus
  tmux select-pane -t "$opencode_pane"
}

# Create a Tmux Dev Square layout with editor, diff watch, terminal, and opencode
# Usage: tds
tds() {
  [[ -n $1 ]] && { echo "Usage: tds"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tds."; return 1; }

  local current_dir="${PWD}"
  local editor_pane diff_pane terminal_pane opencode_pane

  editor_pane="$TMUX_PANE"

  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"

  terminal_pane=$(tmux split-window -v -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  diff_pane=$(tmux split-window -h -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  opencode_pane=$(tmux split-window -h -p 50 -t "$terminal_pane" -c "$current_dir" -P -F '#{pane_id}')

  tmux send-keys -t "$editor_pane" -l "nvim ."
  tmux send-keys -t "$editor_pane" C-m
  tmux send-keys -t "$diff_pane" -l "hunk diff --watch"
  tmux send-keys -t "$diff_pane" C-m
  tmux send-keys -t "$opencode_pane" -l "opencode"
  tmux send-keys -t "$opencode_pane" C-m

  tmux select-pane -t "$editor_pane"
}

# Create multiple tdl windows with one per subdirectory in the current directory
# Usage: tdlm <c|cx|codex|other_ai> [<second_ai>]
tdlm() {
  [[ -z $1 ]] && { echo "Usage: tdlm <c|cx|codex|other_ai> [<second_ai>]"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tdlm."; return 1; }

  local ai="$1"
  local ai2="$2"
  local base_dir="$PWD"
  local first=true
  local dir dirpath pane_id

  # Rename the session to the current directory name (replace dots/colons which tmux disallows)
  tmux rename-session "$(basename "$base_dir" | tr '.:' '--')"

  for dir in "$base_dir"/*/; do
    [[ -d $dir ]] || continue
    dirpath="${dir%/}"

    if $first; then
      # Reuse the current window for the first project
      tmux send-keys -t "$TMUX_PANE" "cd '$dirpath' && tdl $ai $ai2" C-m
      first=false
    else
      pane_id=$(tmux new-window -c "$dirpath" -P -F '#{pane_id}')
      tmux send-keys -t "$pane_id" "tdl $ai $ai2" C-m
    fi
  done
}

# Create a multi-pane swarm layout with the same command started in each pane (great for AI)
# Usage: tsl <pane_count> <command>
tsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: tsl <pane_count> <command>"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tsl."; return 1; }

  local count="$1"
  local cmd="$2"
  local current_dir="${PWD}"
  local -a panes
  local new_pane split_target pane

  tmux rename-window -t "$TMUX_PANE" "$(basename "$current_dir")"

  panes+=("$TMUX_PANE")

  while (( ${#panes[@]} < count )); do
    split_target="${panes[-1]}"
    new_pane=$(tmux split-window -h -t "$split_target" -c "$current_dir" -P -F '#{pane_id}')
    panes+=("$new_pane")
    tmux select-layout -t "${panes[1]}" tiled
  done

  for pane in "${panes[@]}"; do
    tmux send-keys -t "$pane" "$cmd" C-m
  done

  tmux select-pane -t "${panes[1]}"
}

# --- Herdr layouts --------------------------------------------------------------------------
# Echo a split ratio as a float
# Usage: _herdr_ratio <numerator> <denominator>
_herdr_ratio() {
  awk -v a="$1" -v b="$2" 'BEGIN { printf "%.4f", a / b }'
}

# Split a herdr pane and echo the id of the new pane
# Usage: _herdr_split <pane_id> <right|down> <ratio> <cwd>
_herdr_split() {
  herdr pane split "$1" --direction "$2" --ratio "$3" --cwd "$4" --no-focus |
    jq -r '.result.pane.pane_id'
}

# Create a Herdr Dev Layout with editor, ai, and terminal
# Usage: hdl <c|cx|codex|other_ai> [<second_ai>]
hdl() {
  [[ -z $1 ]] && { echo "Usage: hdl <c|cx|codex|other_ai> [<second_ai>]"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hdl."; return 1; }

  local current_dir="${PWD}"
  local editor_pane ai_pane ai2_pane
  local ai="$1"
  local ai2="${2:-}"

  # Use HERDR_PANE_ID for the pane we're running in (stable even if focus moves)
  editor_pane="$HERDR_PANE_ID"

  # Name the current tab after the base directory name
  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  # Split tab vertically - top 85%, bottom 15%
  _herdr_split "$editor_pane" down 0.85 "$current_dir" >/dev/null

  # Split editor pane horizontally - AI on right 30%
  ai_pane=$(_herdr_split "$editor_pane" right 0.7 "$current_dir")

  # If second AI provided, split the AI pane vertically
  if [[ -n $ai2 ]]; then
    ai2_pane=$(_herdr_split "$ai_pane" down 0.5 "$current_dir")
    herdr pane run "$ai2_pane" "$ai2" >/dev/null
  fi

  # Run ai in the right pane
  herdr pane run "$ai_pane" "$ai" >/dev/null

  # Run nvim in the left pane
  herdr pane run "$editor_pane" "$EDITOR ." >/dev/null
}

# Create a Herdr Dev Square layout with editor, diff watch, terminal, and opencode
# Usage: hds
hds() {
  [[ -n $1 ]] && { echo "Usage: hds"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hds."; return 1; }

  local current_dir="${PWD}"
  local editor_pane diff_pane terminal_pane opencode_pane

  editor_pane="$HERDR_PANE_ID"

  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  terminal_pane=$(_herdr_split "$editor_pane" down 0.5 "$current_dir")
  diff_pane=$(_herdr_split "$editor_pane" right 0.5 "$current_dir")
  opencode_pane=$(_herdr_split "$terminal_pane" right 0.5 "$current_dir")

  herdr pane run "$editor_pane" "nvim ." >/dev/null
  herdr pane run "$diff_pane" "hunk diff --watch" >/dev/null
  herdr pane run "$opencode_pane" "opencode" >/dev/null
}

# Create multiple hdl tabs with one per subdirectory in the current directory
# Usage: hdlm <c|cx|codex|other_ai> [<second_ai>]
hdlm() {
  [[ -z $1 ]] && { echo "Usage: hdlm <c|cx|codex|other_ai> [<second_ai>]"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hdlm."; return 1; }

  local ai="$1"
  local ai2="${2:-}"
  local base_dir="$PWD"
  local first=true
  local hdl_command dir dirpath pane_id

  # Rename the workspace to the current directory name
  herdr workspace rename "$HERDR_WORKSPACE_ID" "$(basename "$base_dir")" >/dev/null

  for dir in "$base_dir"/*/; do
    [[ -d $dir ]] || continue
    dirpath="${dir%/}"

    hdl_command="hdl ${(q)ai}"
    [[ -n $ai2 ]] && hdl_command+=" ${(q)ai2}"

    if $first; then
      # Reuse the current tab for the first project
      hdl_command="cd ${(q)dirpath} && $hdl_command"
      herdr pane run "$HERDR_PANE_ID" "$hdl_command" >/dev/null
      first=false
    else
      pane_id=$(herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$dirpath" --no-focus |
        jq -r '.result.root_pane.pane_id')
      herdr pane run "$pane_id" "$hdl_command" >/dev/null
    fi
  done
}

# Create a multi-pane swarm layout with the same command started in each pane (great for AI)
# Usage: hsl <pane_count> <command>
hsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: hsl <pane_count> <command>"; return 1; }
  [[ -z $HERDR_PANE_ID ]] && { echo "You must start herdr to use hsl."; return 1; }

  local count="$1"
  local cmd="$2"
  local current_dir="${PWD}"
  local -a columns panes
  local cols k col index rows j last pane

  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null

  # Tile into a grid: ceil(sqrt(count)) columns, rows spread across them
  cols=1
  while (( cols * cols < count )); do ((cols++)); done

  # Even columns come from splitting the rightmost one off at 1/(n-k+1) each time,
  # which keeps the array in left-to-right order
  columns=("$HERDR_PANE_ID")
  for (( k = 1; k < cols; k++ )); do
    columns+=("$(_herdr_split "${columns[-1]}" right "$(_herdr_ratio 1 $((cols - k + 1)))" "$current_dir")")
  done

  # Split each column into its share of rows, again evenly and top-to-bottom
  for (( index = 1; index <= cols; index++ )); do
    col="${columns[index]}"
    rows=$(( count / cols ))
    (( index <= count % cols )) && (( rows++ ))
    panes+=("$col")
    last="$col"
    for (( j = 1; j < rows; j++ )); do
      last=$(_herdr_split "$last" down "$(_herdr_ratio 1 $((rows - j + 1)))" "$current_dir")
      panes+=("$last")
    done
  done

  for pane in "${panes[@]}"; do
    herdr pane run "$pane" "$cmd" >/dev/null
  done
}

# --- Drive imaging (Linux only: lsblk/parted/mkfs.exfat) --------------------------------------
if [[ $OSTYPE == linux* ]]; then
  # Write iso file to sd card
  iso2sd() {
    if (( $# < 1 )); then
      echo "Usage: iso2sd <input_file> [output_device]"
      echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
      return 1
    fi

    local iso="$1"
    local drive="$2"

    if [[ -z $drive ]]; then
      local available_sds=$(lsblk -dpno NAME | grep -E '/dev/sd')

      if [[ -z $available_sds ]]; then
        echo "No SD drives found and no drive specified"
        return 1
      fi

      drive=$(omarchy-drive-select "$available_sds")

      if [[ -z $drive ]]; then
        echo "No drive selected"
        return 1
      fi
    fi

    sudo dd bs=4M status=progress oflag=sync if="$iso" of="$drive"
    sudo eject "$drive"
  }

  # Format an entire drive for a single partition using exFAT
  format-drive() {
    if (( $# != 2 )); then
      echo "Usage: format-drive <device> <name>"
      echo "Example: format-drive /dev/sda 'My Stuff'"
      print -P "\n%BAvailable drives:%b"
      lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
    else
      echo "WARNING: This will completely erase all data on $1 and label it '$2'."
      read -r "confirm?Are you sure you want to continue? (y/N): "

      if [[ $confirm == [Yy] ]]; then
        sudo wipefs -a "$1"
        sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
        sudo parted -s "$1" mklabel gpt
        sudo parted -s "$1" mkpart primary 1MiB 100%
        sudo parted -s "$1" set 1 msftdata on
        sudo partprobe "$1" || true
        sudo udevadm settle || true

        sudo mkfs.exfat -n "$2" "$partition"

        echo "Drive $1 formatted as exFAT and labeled '$2'."
      fi
    fi
  }
fi

# --- Rsync-on-change watchers (Linux only: inotifywait/setsid) ---------------------------------
# rsw starts one in the background, lsw lists, dsw stops
if [[ $OSTYPE == linux* ]]; then
  rsw() {
    (( $# != 2 )) && echo "Usage: rsw <source> <destination>" && return 1
    local src="${1%/}" dest="$2"
    # Reuse one SSH connection per login, so 1Password only prompts once.
    local sockets="${XDG_RUNTIME_DIR:-$HOME/.ssh/sockets}"
    mkdir -p "$sockets"
    local rsh="ssh -o ControlMaster=auto -o ControlPath=$sockets/rsw-%r@%h:%p -o ControlPersist=yes"
    setsid --fork env RSYNC_RSH="$rsh" bash -c 'rsync -a "$1/" "$2"; while inotifywait -r -q -e modify,create,delete,move "$1"; do rsync -a "$1/" "$2"; done' rsw-watch "$src" "$dest" >/dev/null 2>&1
    echo "Watching $src -> $dest"
  }

  lsw() {
    local pid cmd rest found=0
    while read -r pid cmd; do
      rest="${cmd##*rsw-watch }"
      echo "$pid: ${rest% *} -> ${rest##* }"
      found=1
    done < <(pgrep -af 'rsw-watch ')
    (( found )) || echo "No active watches"
  }

  dsw() {
    local pid found=0
    for pid in $(pgrep -f 'rsw-watch '); do
      kill -- -"$pid" 2>/dev/null && echo "Stopped watch (pid $pid)" && found=1
    done
    (( found )) || echo "No active watches"
  }
fi
