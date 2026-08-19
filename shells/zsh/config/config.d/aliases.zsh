alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
_eza_defaults=(--color=auto --group-directories-first --classify=auto)
_eza_long_defaults=(-l --time-style=long-iso)
[[ $OSTYPE == darwin* ]] && _eza_long_defaults+=(--extended)

ls() { command eza "${_eza_defaults[@]}" "$@"; }
l() { ll --all "$@"; }
la() { command eza "${_eza_defaults[@]}" --almost-all "$@"; }
ll() { command eza "${_eza_defaults[@]}" "${_eza_long_defaults[@]}" "$@"; }
le() { ll --almost-all "$@"; }

alias e='nvim'
alias gg='lazygit'

alias b='brew'
alias bi='brew install'
alias bz='brew uninstall --zap'
alias bs='brew search'
alias ci='brew install --cask'

alias cdd="cd $DOTFILES_DIR"
alias cdw="cd $LLM_WIKI_DIR"

alias eal="cd $DOTFILES_DIR && $EDITOR $DOTFILES_DIR/shells/zsh/config/aliases.zsh"

alias gl="glow -t"

alias omr="omp --resume"

hash -d df="${DOTFILES_DIR:-$HOME/src/dotfiles}"
hash -d an="$HOME/work/analysis"
hash -d lst="${XDG_STATE_HOME:-$HOME/.local/state}"
hash -d lsh="${XDG_DATA_HOME:-$HOME/.local/share}"
