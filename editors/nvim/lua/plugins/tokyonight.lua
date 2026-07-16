local function sync_macos_appearance()
  if vim.fn.has("mac") ~= 1 then
    return
  end

  local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }):wait()
  local background = result.code == 0 and vim.trim(result.stdout or "") == "Dark" and "dark" or "light"

  if vim.o.background ~= background then
    vim.o.background = background
  end
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm",
      light_style = "day",
    },
    init = function()
      sync_macos_appearance()

      vim.api.nvim_create_autocmd("FocusGained", {
        group = vim.api.nvim_create_augroup("TokyoNightSystemAppearance", { clear = true }),
        callback = sync_macos_appearance,
      })
    end,
  },
}
