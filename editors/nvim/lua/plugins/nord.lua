-- Omarchy owns Neovim's colorscheme on Linux through plugins/theme.lua.
-- On macOS, follow the system appearance directly instead.
if vim.fn.has("mac") ~= 1 then
  return {}
end

local function sync_macos_appearance()
  local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }):wait()
  local background = result.code == 0 and vim.trim(result.stdout or "") == "Dark" and "dark" or "light"

  if vim.o.background ~= background then
    local nord_active = vim.g.colors_name == "nord"
    vim.o.background = background
    if nord_active then
      vim.cmd.colorscheme("nord")
    end
  end
end

return {
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = true
      vim.g.nord_disable_background = false
      vim.g.nord_italic = false
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.cmd.colorscheme("nord")
      end,
    },
    init = function()
      sync_macos_appearance()

      vim.api.nvim_create_autocmd("FocusGained", {
        group = vim.api.nvim_create_augroup("NordSystemAppearance", { clear = true }),
        callback = sync_macos_appearance,
      })
    end,
  },
}
