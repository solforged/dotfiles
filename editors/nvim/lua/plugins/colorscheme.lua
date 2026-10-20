-- Omarchy owns Neovim's colorscheme on Linux through plugins/theme.lua.
-- On macOS, use Solforge where the solforge module links it, else Nord, and
-- follow the system appearance.
if vim.fn.has("mac") ~= 1 then
  return {}
end

local function preferred_colorscheme()
  local solforge = vim.api.nvim_get_runtime_file("colors/solforge.lua", false)
  return #solforge > 0 and "solforge" or "nord"
end

local function sync_macos_appearance()
  local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }):wait()
  local background = result.code == 0 and vim.trim(result.stdout or "") == "Dark" and "dark" or "light"

  if vim.o.background ~= background then
    local active = vim.g.colors_name
    vim.o.background = background
    if active == "solforge" or active == "nord" then
      vim.cmd.colorscheme(active)
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
        vim.cmd.colorscheme(preferred_colorscheme())
      end,
    },
    init = function()
      sync_macos_appearance()

      vim.api.nvim_create_autocmd("FocusGained", {
        group = vim.api.nvim_create_augroup("SystemAppearance", { clear = true }),
        callback = sync_macos_appearance,
      })
    end,
  },
}
