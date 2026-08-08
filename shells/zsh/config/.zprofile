[[ -r "$HOME/.profile" ]] && source "$HOME/.profile"

if [[ "$OSTYPE" == darwin* ]]; then
  [[ -d /opt/homebrew/sbin ]] && path=(/opt/homebrew/sbin $path)
  [[ -d /opt/homebrew/bin ]] && path=(/opt/homebrew/bin $path)
fi
