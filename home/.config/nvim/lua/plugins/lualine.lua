return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "echasnovski/mini.icons" },
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    local harpoon = require("harpoon")

    local icons = {
      diagnostics = {
        Error = " ",
        Warn = " ",
        Info = " ",
        Hint = " ",
      },
    }

    -- Cached color values to avoid repeated API calls
    local color_cache = {}
    local cache_valid = false

    -- Helper to get hex color from highlight group with caching
    local function get_hl_hex(hl_name, attr)
      local cache_key = hl_name .. "_" .. attr
      if cache_valid and color_cache[cache_key] then
        return color_cache[cache_key]
      end

      local hl = vim.api.nvim_get_hl(0, { name = hl_name })
      if not hl or not hl[attr] then
        color_cache[cache_key] = nil
        return nil
      end

      local color = string.format("#%06x", hl[attr])
      color_cache[cache_key] = color
      cache_valid = true
      return color
    end

    -- Invalidate cache on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        cache_valid = false
        color_cache = {}
      end,
    })

    -- Root folder component (shows project root name)
    local function root_folder()
      local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      return "" .. root .. " "
    end

    -- Modified indicator (green dot)
    local function modified_indicator()
      if vim.bo.modified then
        return "●"
      end
      return ""
    end

    -- Harpoon component for statusline
    local function harpoon_component()
      local list = harpoon:list()
      local total = list:length()
      if total == 0 then
        return " 󱡅 -/-"
      end

      local current_file = vim.fn.expand("%:p:.")
      local current_idx = nil
      for i = 1, total do
        local item = list:get(i)
        if item and item.value == current_file then
          current_idx = i
          break
        end
      end

      if current_idx then
        return string.format(" 󱡅 %d/%d", current_idx, total)
      else
        return string.format(" 󱡅 -/%d", total)
      end
    end

    vim.o.laststatus = vim.g.lualine_laststatus

    local opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            root_folder,
            icon = "\u{ea83}",
            color = function()
              return { fg = get_hl_hex("Directory", "fg"), bg = get_hl_hex("lualine_c_normal", "bg") }
            end,
          },
        },
        lualine_c = {
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 1, right = 0 },
            color = function()
              return { bg = get_hl_hex("lualine_c_normal", "bg") }
            end,
          },
          {
            "filename",
            path = 4,
            file_status = false,
            color = function()
              return { bg = get_hl_hex("lualine_c_normal", "bg") }
            end,
            separator = "",
          },
          {
            modified_indicator,
            color = function()
              return { fg = get_hl_hex("MoreMsg", "fg"), bg = get_hl_hex("lualine_c_normal", "bg") }
            end,
            separator = "",
            padding = { left = 1, right = 0 },
          },
        },
        lualine_x = {
          -- Lazy updates
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            separator = {
              left = "",
              right = "\u{e0b3}", -- Separator after updates (same color as updates)
            },
            color = function()
              return { fg = get_hl_hex("DiagnosticWarn", "fg"), bg = get_hl_hex("lualine_c_normal", "bg") }
            end,
          },
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
            separator = {
              left = "",
              right = "\u{e0b3}", -- Separator after diagnostics (inherits diagnostics colors)
            },
            color = function()
              return { bg = get_hl_hex("lualine_c_normal", "bg") }
            end,
          },
          -- Harpoon indicator
          {
            harpoon_component,
            separator = {
              left = "\u{e0b3}",
            },
            color = function()
              return { fg = get_hl_hex("TSRainbowOrange", "fg"), bg = get_hl_hex("lualine_c_normal", "bg") }
            end,
          },
        },
        lualine_y = {
          "branch",
        },
        lualine_z = {
          { "progress", separator = " ", padding = { left = 1, right = 1 } },
        },
      },
      extensions = { "lazy", "fzf" },
    }

    return opts
  end,
}
