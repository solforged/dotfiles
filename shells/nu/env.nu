# Generate the installed tools' standard shell integrations.
mkdir $nu.cache-dir
mise activate nu --no-hook-env | save --force ($nu.cache-dir | path join "mise.nu")
fnox activate nu --no-hook-env | save --force ($nu.cache-dir | path join "fnox.nu")
zoxide init nushell | save --force ($nu.cache-dir | path join "zoxide.nu")
atuin init nu --disable-up-arrow | save --force ($nu.cache-dir | path join "atuin.nu")
starship init nu | save --force ($nu.cache-dir | path join "starship.nu")
