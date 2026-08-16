-- reattach new terminal windows to the persistent herdr session.
hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "herdr", { omarchy = "terminal-herdr" })

-- SUPER+SHIFT+ALT+M was Music TUI (bare cliamp → radio).
hl.unbind("SUPER + SHIFT + ALT + M")
o.bind("SUPER + SHIFT + ALT + M", "Music TUI", "omarchy-launch-or-focus-tui cliamp /home/sol/Music/beets")
