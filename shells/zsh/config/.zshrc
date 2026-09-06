# Synced upstream environment (tools, shortcuts, and platform helpers)
[[ -r "$ZDOTDIR/config.d/omarchy.zsh" ]] && source "$ZDOTDIR/config.d/omarchy.zsh"

# Shell options, functions, aliases, and keybindings
[[ -r "$ZDOTDIR/config.d/options.zsh" ]] && source "$ZDOTDIR/config.d/options.zsh"
[[ -r "$ZDOTDIR/config.d/functions.zsh" ]] && source "$ZDOTDIR/config.d/functions.zsh"
[[ -r "$ZDOTDIR/config.d/aliases.zsh" ]] && source "$ZDOTDIR/config.d/aliases.zsh"
[[ -r "$ZDOTDIR/config.d/zimfw.zsh" ]] && source "$ZDOTDIR/config.d/zimfw.zsh"
[[ -r "$ZDOTDIR/config.d/atuin.zsh" ]] && source "$ZDOTDIR/config.d/atuin.zsh"
[[ -r "$ZDOTDIR/config.d/keybinds.zsh" ]] && source "$ZDOTDIR/config.d/keybinds.zsh"

# Prompt and language runtimes
[[ -r "$ZDOTDIR/config.d/starship.zsh" ]] && source "$ZDOTDIR/config.d/starship.zsh"
[[ -r "$ZDOTDIR/config.d/javascript.zsh" ]] && source "$ZDOTDIR/config.d/javascript.zsh"
[[ -r "$ZDOTDIR/config.d/go.zsh" ]] && source "$ZDOTDIR/config.d/go.zsh"
[[ -r "$ZDOTDIR/config.d/rust.zsh" ]] && source "$ZDOTDIR/config.d/rust.zsh"

# Environment and secrets activation
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v fnox >/dev/null 2>&1; then
  eval "$(fnox activate zsh)"
fi

if [[ -r "$ZDOTDIR/config.d/zoxide.zsh" ]]; then
  source "$ZDOTDIR/config.d/zoxide.zsh"
fi
