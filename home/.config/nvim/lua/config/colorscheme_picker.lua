local M = {}

local state_file = vim.fn.stdpath("state") .. "/colorscheme.txt"

local function read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local content = file:read("*l")
  file:close()
  if not content or content == "" then
    return nil
  end

  return vim.trim(content)
end

local function write_file(path, value)
  vim.fn.mkdir(vim.fn.stdpath("state"), "p")
  local file = io.open(path, "w")
  if not file then
    return false
  end

  file:write(value .. "\n")
  file:close()
  return true
end

function M.get_saved()
  return read_file(state_file)
end

function M.save(name)
  if not name or name == "" then
    return false
  end
  return write_file(state_file, name)
end

function M.apply(name)
  if not name or name == "" then
    return false
  end

  local ok = pcall(vim.cmd.colorscheme, name)
  return ok
end

function M.apply_saved()
  local saved = M.get_saved()
  if not saved then
    return false
  end

  local ok = M.apply(saved)
  if not ok then
    vim.schedule(function()
      vim.notify(string.format("Saved colorscheme '%s' is not available", saved), vim.log.levels.WARN)
    end)
  end
  return ok
end

function M.apply_saved_or(fallback)
  if M.apply_saved() then
    return true
  end
  return M.apply(fallback)
end

function M.pick()
  require("snacks").picker.colorschemes({
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end

      if picker.preview and picker.preview.state then
        picker.preview.state.colorscheme = nil
      end

      vim.schedule(function()
        local ok = M.apply(item.text)
        if not ok then
          vim.notify(string.format("Could not load colorscheme '%s'", item.text), vim.log.levels.ERROR)
          return
        end

        local saved = M.save(item.text)
        if not saved then
          vim.notify("Could not persist selected colorscheme", vim.log.levels.WARN)
        end
      end)
    end,
  })
end

return M
