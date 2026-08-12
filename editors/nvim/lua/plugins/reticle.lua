-- Omarchy owns Neovim's colorscheme on Linux through plugins/theme.lua.
-- On macOS, follow the system appearance directly instead.
if vim.fn.has("mac") ~= 1 then
  return {}
end

local function sync_macos_appearance()
  local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }):wait()
  local background = result.code == 0 and vim.trim(result.stdout or "") == "Dark" and "dark" or "light"

  if vim.o.background ~= background then
    vim.o.background = background
    if vim.g.colors_name == "reticle" then
      vim.cmd.colorscheme("reticle")
    end
  end
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "reticle",
    },
    init = function()
      sync_macos_appearance()

      vim.api.nvim_create_autocmd("FocusGained", {
        group = vim.api.nvim_create_augroup("ReticleSystemAppearance", { clear = true }),
        callback = sync_macos_appearance,
      })
    end,
  },
}
