-- Keep Omarchy's remote/OSC52 clipboard provider when it is installed.
local has_remote_clipboard, remote_clipboard = pcall(require, "config.remote_clipboard")
if has_remote_clipboard then
  remote_clipboard.setup()
end

-- Keep the baseline quiet; diagnostics and spell checking are opt-in.
vim.opt.relativenumber = false
vim.opt.spell = false
vim.g.autoformat = false
vim.diagnostic.enable(false)
