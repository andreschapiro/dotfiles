-- Languages to ensure are installed
local ensure_installed = {
  "bash",
  "css",
  "diff",
  "go",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "mdx",
  "python",
  "query",
  "rust",
  "terraform",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- Plugin does not support lazy-loading per README
    priority = 1000,
    build = ":TSUpdate",
    config = function()
      -- Setup only accepts install_dir on main branch
      require("nvim-treesitter").setup({})

      -- Install missing parsers asynchronously
      local installed = {}
      for _, lang in ipairs(require("nvim-treesitter").get_installed() or {}) do
        installed[lang] = true
      end

      local to_install = vim.tbl_filter(function(lang)
        return not installed[lang]
      end, ensure_installed)

      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end

      -- Setup autocmds for highlighting and indentation
      local ts_group = vim.api.nvim_create_augroup("treesitter_start", { clear = true })

      --- Start treesitter for a buffer
      ---@param buf number buffer handle
      ---@param ft string? filetype (optional, will be detected if not provided)
      local function start_treesitter(buf, ft)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        ft = ft or vim.bo[buf].filetype
        if not ft or ft == "" then
          return
        end

        local lang = vim.treesitter.language.get_lang(ft) or ft

        -- Try to start treesitter highlighting
        local ok = pcall(vim.treesitter.start, buf, lang)
        if ok then
          -- Enable treesitter-based indentation
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      -- Start on FileType event (handles new buffers and filetype changes)
      vim.api.nvim_create_autocmd("FileType", {
        group = ts_group,
        callback = function(ev)
          start_treesitter(ev.buf, ev.match)
        end,
      })

      -- Also start for any existing buffers (e.g., files opened via command line)
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          start_treesitter(buf)
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
