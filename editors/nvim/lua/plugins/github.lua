-- Omarchy owns Neovim's colorscheme on Linux through plugins/theme.lua.
-- On macOS, follow the system appearance directly instead.
if vim.fn.has("mac") ~= 1 then
  return {}
end

local function sync_macos_appearance()
  local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }):wait()
  local background = result.code == 0 and vim.trim(result.stdout or "") == "Dark" and "dark" or "light"

  if vim.o.background ~= background then
    local github_active = vim.g.colors_name == "github_dark_default" or vim.g.colors_name == "github_light_default"
    vim.o.background = background
    if github_active then
      vim.cmd.colorscheme("github_" .. background .. "_default")
    end
  end
end

return {
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.cmd.colorscheme("github_" .. vim.o.background .. "_default")
      end,
    },
    init = function()
      sync_macos_appearance()

      vim.api.nvim_create_autocmd("FocusGained", {
        group = vim.api.nvim_create_augroup("GitHubSystemAppearance", { clear = true }),
        callback = sync_macos_appearance,
      })
    end,
  },
}
