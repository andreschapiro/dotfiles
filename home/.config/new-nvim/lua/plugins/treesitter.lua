return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall" },
    config = function()
      -- Prefer git for installing parsers
      require("nvim-treesitter.install").prefer_git = true

      -- Helper to get language for a buffer
      local function get_lang(bufnr)
        bufnr = bufnr or 0
        local ft = vim.bo[bufnr].filetype
        -- Map filetype to treesitter language
        local lang = vim.treesitter.language.get_lang(ft)
        return lang or ft
      end

      -- Helper to check if parser is available
      local function has_parser(lang)
        local ok = pcall(vim.treesitter.language.inspect, lang)
        return ok
      end

      -- Enable treesitter highlighting for buffers
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = get_lang(args.buf)
          if lang and has_parser(lang) then
            pcall(vim.treesitter.start, args.buf, lang)
          end
        end,
      })

      -- Install common parsers on first load
      local ensure_installed = {
        "bash", "css", "c", "diff", "go", "html", "javascript", "json",
        "lua", "luadoc", "markdown", "markdown_inline", "python", "query",
        "rust", "terraform", "tsx", "typescript", "vim", "vimdoc", "yaml",
      }
      for _, lang in ipairs(ensure_installed) do
        if not has_parser(lang) then
          pcall(vim.cmd, "TSInstall " .. lang)
        end
      end
    end,
  },
  -- Textobjects via mini.ai (modern replacement for nvim-treesitter-textobjects)
  {
    "echasnovski/mini.ai",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      n_lines = 500,
      custom_textobjects = {
        -- Function textobject
        f = function()
          local ok, spec = pcall(require, "mini.ai")
          if ok then
            return spec.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" })
          end
        end,
        -- Class textobject
        c = function()
          local ok, spec = pcall(require, "mini.ai")
          if ok then
            return spec.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" })
          end
        end,
        -- Parameter/argument textobject
        a = function()
          local ok, spec = pcall(require, "mini.ai")
          if ok then
            return spec.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" })
          end
        end,
      },
    },
  },
}
