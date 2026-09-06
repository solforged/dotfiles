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
