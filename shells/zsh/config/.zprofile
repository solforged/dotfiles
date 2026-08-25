[[ -r "$HOME/.profile" ]] && source "$HOME/.profile"

if [[ "$OSTYPE" == darwin* ]]; then
  typeset -a _brew_paths
  [[ -d /opt/homebrew/bin ]] && _brew_paths+=(/opt/homebrew/bin)
  [[ -d /opt/homebrew/sbin ]] && _brew_paths+=(/opt/homebrew/sbin)
  path=($_brew_paths $path)
  unset _brew_paths
fi
