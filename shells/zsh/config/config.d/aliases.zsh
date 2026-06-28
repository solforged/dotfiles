alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
_gls_defaults=(--color=auto --group-directories-first --classify=auto)

ls() { command gls "${_gls_defaults[@]}" "$@"; }
l() { ll --all "$@"; }
la() { command gls "${_gls_defaults[@]}" --almost-all "$@"; }
ll() { command gls "${_gls_defaults[@]}" -l --human-readable --time-style=long-iso "$@"; }
le() { ll --almost-all "$@"; }

alias e='nvim'

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
