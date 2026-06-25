if command -v atuin >/dev/null 2>&1; then
  _atuin_init="$(atuin init zsh --disable-up-arrow --disable-ai 2>/dev/null)"
  [[ -n "$_atuin_init" ]] && eval "$_atuin_init"
  unset _atuin_init
fi
