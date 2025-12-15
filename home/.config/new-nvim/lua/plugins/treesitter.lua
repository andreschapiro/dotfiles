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
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- Textobjects keymaps using the select module
      local ok, select = pcall(require, "nvim-treesitter.textobjects.select")
      if ok then
        vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end, { desc = "Select outer function" })
        vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end, { desc = "Select inner function" })
        vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end, { desc = "Select outer class" })
        vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end, { desc = "Select inner class" })
        vim.keymap.set({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer", "textobjects") end, { desc = "Select outer parameter" })
        vim.keymap.set({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner", "textobjects") end, { desc = "Select inner parameter" })
      end

      -- Repeat movement with ; and ,
      local ok2, ts_repeat_move = pcall(require, "nvim-treesitter.textobjects.repeatable_move")
      if ok2 then
        vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
        vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
      end
    end,
  },
}
