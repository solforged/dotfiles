export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}"

if [[ "${TERM:-}" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
