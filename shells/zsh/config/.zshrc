[[ -r "$ZDOTDIR/config.d/options.zsh" ]] && source "$ZDOTDIR/config.d/options.zsh"
[[ -r "$ZDOTDIR/config.d/functions.zsh" ]] && source "$ZDOTDIR/config.d/functions.zsh"
[[ -r "$ZDOTDIR/config.d/aliases.zsh" ]] && source "$ZDOTDIR/config.d/aliases.zsh"
[[ -r "$ZDOTDIR/config.d/zimfw.zsh" ]] && source "$ZDOTDIR/config.d/zimfw.zsh"
[[ -r "$ZDOTDIR/config.d/atuin.zsh" ]] && source "$ZDOTDIR/config.d/atuin.zsh"
[[ -r "$ZDOTDIR/config.d/keybinds.zsh" ]] && source "$ZDOTDIR/config.d/keybinds.zsh"

[[ -r "$ZDOTDIR/config.d/starship.zsh" ]] && source "$ZDOTDIR/config.d/starship.zsh"
[[ -r "$ZDOTDIR/config.d/javascript.zsh" ]] && source "$ZDOTDIR/config.d/javascript.zsh"
[[ -r "$ZDOTDIR/config.d/go.zsh" ]] && source "$ZDOTDIR/config.d/go.zsh"
[[ -r "$ZDOTDIR/config.d/rust.zsh" ]] && source "$ZDOTDIR/config.d/rust.zsh"

if command -v "mise" >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v "fnox" >/dev/null 2>&1; then
  eval "$(fnox activate zsh)"
fi

[[ -r "$ZDOTDIR/zoxide.zsh" ]] && source "$ZDOTDIR/zoxide.zsh"
