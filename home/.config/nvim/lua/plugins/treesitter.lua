return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    priority = 500,
    build = ":TSUpdate",
    config = function()
      -- Just enable highlighting - no auto-install
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
        callback = function(args)
          -- Small delay to ensure parser is ready
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
              pcall(vim.treesitter.start, args.buf)
            end
          end, 0)
        end,
      })
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
