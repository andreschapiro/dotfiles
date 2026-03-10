-- Try to load omarchy theme first, fallback to onedark if not available
local omarchy_theme_path = (os.getenv("HOME") or "") .. "/.config/omarchy/current/theme/neovim.lua"
local file = io.open(omarchy_theme_path, "r")
if file then
  file:close()
  local ok, omarchy_config = pcall(dofile, omarchy_theme_path)
  if ok and omarchy_config then
    return omarchy_config
  end
end

-- Fallback to onedarkpro configuration
return {
  "olimorris/onedarkpro.nvim",
  name = "onedarkpro",
  lazy = false, -- Load immediately
  priority = 1000, -- Load before other plugins
  config = function()
    require("onedarkpro").setup({
      colors = {
        bg = "#282c34",
        vaporwave = {
          codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'vaporwave')",
          statusline_bg = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
          statuscolumn_border = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
          ellipsis = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
          picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark_vivid')",
          picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark_vivid')",
          picker_input = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark_vivid')",
          copilot = "require('onedarkpro.helpers').darken('gray', 8, 'vaporwave')",
          breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'vaporwave')",
          light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'vaporwave')",
        },
        onedark = {
          codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'onedark')",
          statusline_bg = "#2e323b", -- gray
          statuscolumn_border = "#4b5160", -- gray
          ellipsis = "#808080", -- gray
          picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark')",
          picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark')",
          picker_input = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark_vivid')",
          copilot = "require('onedarkpro.helpers').darken('gray', 8, 'onedark')",
          breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'onedark')",
          light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'onedark')",
        },
        onedark_vivid = {
          codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'onedark_vivid')",
          statusline_bg = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark_vivid')",
          statuscolumn_border = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark_vivid')",
          ellipsis = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark_vivid')",
          picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark_vivid')",
          picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark_vivid')",
          picker_input = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark_vivid')",
          copilot = "require('onedarkpro.helpers').darken('gray', 8, 'onedark_vivid')",
          breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'onedark_vivid')",
          light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'onedark_vivid')",
        },
        onedark_dark = {
          codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'onedark_dark')",
          statusline_bg = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark_dark')",
          statuscolumn_border = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark_dark')",
          ellipsis = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark_dark')",
          picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark_dark')",
          picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark_dark')",
          copilot = "require('onedarkpro.helpers').darken('gray', 8, 'onedark_dark')",
          breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'onedark_dark')",
          light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'onedark_dark')",
        },
        onelight = {
          codeblock = "require('onedarkpro.helpers').darken('bg', 3, 'onelight')",
          statusline_bg = "#f0f0f0",
          statuscolumn_border = "#e7e7e7",
          ellipsis = "#808080",
          picker_results = "require('onedarkpro.helpers').darken('bg', 5, 'onelight')",
          picker_selection = "require('onedarkpro.helpers').darken('bg', 9, 'onelight')",
          copilot = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
          breadcrumbs = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
          light_gray = "require('onedarkpro.helpers').lighten('gray', 10, 'onelight')",
        },
        rainbow = {
          "${green}",
          "${blue}",
          "${purple}",
          "${red}",
          "${orange}",
          "${yellow}",
          "${cyan}",
        },
      },
      highlights = {
        -- Match OneDark Pro++ VSCode theme mappings (vivid variant)
        ["@variable"] = { fg = "${red}" }, -- variables like authClient, toast
        ["@variable.builtin"] = { fg = "${yellow}" }, -- this, super, etc
        ["@variable.member"] = { fg = "${red}" }, -- object.property (value.email)
        ["@variable.parameter"] = { fg = "${red}" }, -- function parameters (value)
        ["@constant"] = { fg = "${yellow}" }, -- CONSTANTS
        ["@constant.builtin"] = { fg = "${orange}" }, -- true, false, nil
        ["@property"] = { fg = "${red}" }, -- property names (email:)
        ["@function"] = { fg = "${blue}" }, -- function names
        ["@function.builtin"] = { fg = "${cyan}" }, -- built-in functions
        ["@function.method"] = { fg = "${blue}" }, -- method names
        ["@type"] = { fg = "${yellow}" }, -- type names
        ["@type.builtin"] = { fg = "${yellow}" }, -- built-in types
        ["@keyword"] = { fg = "${purple}" }, -- keywords
        ["@string"] = { fg = "${green}" }, -- strings
        ["@number"] = { fg = "${orange}" }, -- numbers

        -- Zig syntax highlighting
        ["@keyword.zig"] = { fg = "${purple}" },
        ["@type.zig"] = { fg = "${yellow}" },
        ["@function.zig"] = { fg = "${blue}" },
        ["@constant.zig"] = { fg = "${orange}" },
        ["@variable.builtin.zig"] = { fg = "${cyan}" },
        ["@string.zig"] = { fg = "${green}" },
        ["@number.zig"] = { fg = "${orange}" },
        CodeCompanionChatIcon = { fg = "${green}" },
        CodeCompanionChatToolFailure = { fg = "${gray}", italic = true },
        CodeCompanionChatToolSuccess = { fg = "${gray}", bg = "NONE", italic = true },
        CodeCompanionTokens = { fg = "${gray}", italic = true },
        CodeCompanionVirtualText = { fg = "${gray}", italic = true },

        ["@markup.raw.block.markdown"] = { bg = "${codeblock}" },
        ["@markup.quote.markdown"] = { italic = true, extend = true },

        EdgyNormal = { bg = "${bg}" },
        EdgyTitle = { fg = "${purple}", bold = true },

        NormalFloat = { bg = "${bg}" }, -- Set the terminal background to be the same as the editor
        FloatBorder = { fg = "${blue}", bg = "${bg}" },

        CursorLineNr = { bg = "${bg}", fg = "${fg}", italic = true },
        MatchParen = { fg = "${cyan}" },
        ModeMsg = { fg = "${gray}" }, -- Make command line text lighter
        Search = { bg = "${selection}", fg = "${yellow}", underline = true },
        VimLogo = { fg = { dark = "#81b766", light = "#029632" } },

        -- Dashboard
        SnacksDashboardDesc = { fg = "${blue}", bold = true },
        SnacksDashboardKey = { fg = "${orange}", bold = true, italic = true },
        SnacksDashboardIcon = { fg = "${blue}" },
        SnacksDashboardFooterText = { fg = "${green}" },
        SnacksDashboardFooterEmphasis = { fg = "${blue}" },
        SnacksDashboardFooterVersion = { fg = "${gray}" },

        -- Snacks picker - Input section (lighter background)
        SnacksPickerInput = { bg = "${picker_input}" },
        SnacksPickerInputBorder = { fg = "${picker_input}", bg = "${picker_input}" },
        SnacksPickerInputTitle = { bg = "${picker_input}", fg = "${blue}", bold = true },
        SnacksPickerPrompt = { bg = "${picker_input}", fg = "${blue}", bold = true },

        -- Snacks picker - Results/List section (darker background)
        SnacksPicker = { bg = "${picker_results}" },
        SnacksPickerList = { bg = "${picker_results}" },
        SnacksPickerBorder = { fg = "${picker_results}", bg = "${picker_results}" },
        SnacksPickerListBorder = { fg = "${picker_results}", bg = "${picker_results}" },
        SnacksPickerDir = { fg = "${gray}", italic = true },
        SnacksPickerListCursorLine = { bg = "${picker_selection}" },
        SnacksPickerSelected = { bg = "${picker_results}", fg = "${orange}" },
        SnacksPickerTitle = { bg = "${purple}", fg = "${bg}", bold = true },
        SnacksPickerToggle = { bg = "${purple}", fg = "${bg}", italic = true },
        SnacksPickerTotals = { bg = "${picker_input}", fg = "${purple}", bold = true },
        SnacksPickerUnselected = { bg = "${picker_results}" },
        SnacksPickerMatch = { fg = "${orange}", bold = true },

        -- Snacks picker - Preview section (editor background)
        SnacksPickerPreview = { bg = "${bg}" },
        SnacksPickerPreviewBorder = { fg = "${bg}", bg = "${bg}" },
        SnacksPickerPreviewTitle = { bg = "${green}", fg = "${bg}", bold = true },
      },

      styles = {
        tags = "italic",
        methods = "bold",
        functions = "bold",
        keywords = "italic",
        comments = "italic",
        parameters = "italic",
        conditionals = "italic",
        virtual_text = "italic",
      },

      options = {
        cursorline = true,
      },
    })
    vim.cmd.colorscheme("vaporwave")
  end,
}
