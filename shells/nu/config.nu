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

# Shared names are records in Nu, and ~name directory hashes in Zsh.
$env.PLACE_ROWS = (^places list --json | from json)

def --env update-place-label [] {
    let cwd = $env.PWD
    let matches = ($env.PLACE_ROWS | where {|p|
        $cwd == $p.path or ($cwd | str starts-with ($p.path + "/"))
    } | sort-by {|p| $p.path | str length } --reverse)
    $env.PLACE_PATH = if ($matches | is-not-empty) {
        let p = $matches | first
        "~" + $p.name + ($cwd | str substring ($p.path | str length)..)
    } else if $cwd == $env.HOME {
        "~"
    } else if ($cwd | str starts-with ($env.HOME + "/")) {
        "~" + ($cwd | str substring ($env.HOME | str length)..)
    } else { $cwd }
}
$env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD? | default [] | append {|| update-place-label }
)
update-place-label

# --env allows directory changes to persist after this command returns.
def --env p [name?: string] {
    if $name == null {
        ^places list --json | from json
    } else {
        let result = (^places path $name | complete)
        if $result.exit_code != 0 { error make { msg: ($result.stderr | str trim) } }
        cd ($result.stdout | str trim)
        update-place-label
    }
}
def --wrapped work [...args: string] { ^places workspace ...$args }
def --wrapped role [...args: string] { ^places role ...$args }
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
