$env.config.show_banner = false
$env.config.edit_mode = "vi"
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = "[N] "
$env.config.buffer_editor = "hx"
$env.config.table.mode = "basic"
$env.config.table.index_mode = "never"
$env.config.use_kitty_protocol = true
$env.config.history.file_format = "sqlite"
$env.config.color_config = (open ($nu.default-config-dir | path join "themes"
    $"($env.RETICLE_THEME? | default 'reticle-dimmed').json"))
$env.config.ls.use_ls_colors = false

alias e = nvim
alias gg = lazygit

# omp commit uses its own prompt and will not read AGENTS.md.
def --wrapped omp [...args: string] {
    if not ($args | is-empty) and ($args | first) == "commit" and not ($args | any {|a| $a in ["--context" "-c" "--help" "-h"]}) {
        ^omp commit --context "Commit messages must pass the global commit-msg policy: Conventional Commits, past-tense subject at most 72 characters with no trailing period. Body is optional. If present, write one paragraph (at most three), hard-wrapped at 72 characters. Never use bullet or numbered lists, never start a line with -, *, +, or 1., and do not emit detail lines." ...($args | skip 1)
    } else {
        ^omp ...$args
    }
}

# Yazi returns its directory to this shell, just as the Zsh y command does.
def --env --wrapped y [...args: string] {
    let temporary = ^mktemp -t yazi-cwd.XXXXXX | str trim
    ^yazi ...$args --cwd-file $temporary
    let destination = open --raw $temporary | str trim
    rm $temporary
    if $destination != "" and ($destination | path exists) { cd $destination }
}

source ($nu.cache-dir | path join "mise.nu")
source ($nu.cache-dir | path join "fnox.nu")
source ($nu.cache-dir | path join "zoxide.nu")
source ($nu.cache-dir | path join "atuin.nu")
source ($nu.cache-dir | path join "starship.nu")
