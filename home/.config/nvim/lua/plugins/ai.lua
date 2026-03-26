return {
  -- Sidekick.nvim - AI pair programmer with Next Edit Suggestions
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    init = function()
      -- Create a command to list and kill dangling AI CLI sessions
      vim.api.nvim_create_user_command("SidekickKillSession", function(opts)
        local tool_name = opts.args
        if tool_name == "" then
          -- List all sessions
          local sessions = vim.fn.systemlist("tmux list-sessions 2>/dev/null | grep -E 'opencode|claude|copilot|gemini|aider|codex|grok|crush|qwen|cursor'")
          if #sessions == 0 then
            vim.notify("No AI CLI sessions found", vim.log.levels.INFO)
            return
          end
          
          vim.notify("Active AI CLI sessions:\n" .. table.concat(sessions, "\n") .. "\n\nUse :SidekickKillSession <name> to kill a session", vim.log.levels.INFO)
        else
          -- Kill specific session by finding matching tmux session
          local result = vim.fn.system(string.format("tmux list-sessions 2>/dev/null | grep '^%s ' | awk -F: '{print $1}'", tool_name))
          if result == "" then
            vim.notify("No tmux session found for: " .. tool_name, vim.log.levels.WARN)
            return
          end
          
          local session_name = vim.trim(result)
          vim.fn.system(string.format("tmux kill-session -t '%s' 2>/dev/null", session_name))
          vim.notify("Killed session: " .. session_name, vim.log.levels.INFO)
        end
      end, { 
        desc = "List or kill AI CLI sessions",
        nargs = "?",
        complete = function()
          return { "opencode", "claude", "copilot", "gemini", "aider", "codex", "grok", "crush", "qwen", "cursor" }
        end
      })
      
      -- Create a command to authenticate with Copilot
      vim.api.nvim_create_user_command("CopilotAuth", function()
        -- Get the copilot LSP client
        local clients = vim.lsp.get_clients({ name = "copilot" })
        if #clients == 0 then
          vim.notify("Copilot LSP not running. Open a file first.", vim.log.levels.WARN)
          return
        end

        local client = clients[1]

        -- First check status
        client.request("checkStatus", {}, function(err, result)
          if err then
            vim.notify("Error checking Copilot status: " .. vim.inspect(err), vim.log.levels.ERROR)
            return
          end

          if result.status == "OK" then
            vim.notify("✓ Already signed in to Copilot", vim.log.levels.INFO)
            return
          end

          -- Start sign-in flow
          client.request("signInInitiate", {}, function(err2, result2)
            if err2 then
              vim.notify("Error starting sign-in: " .. vim.inspect(err2), vim.log.levels.ERROR)
              return
            end
            local user_code = result2.userCode
            local verification_uri = result2.verificationUri

            -- Show the code to the user
            vim.notify(
              string.format(
                "GitHub Copilot Authentication\n\n"
                  .. "1. Visit: %s\n"
                  .. "2. Enter code: %s\n\n"
                  .. "Waiting for authentication...",
                verification_uri,
                user_code
              ),
              vim.log.levels.INFO
            )

            -- Open browser
            vim.fn.system(string.format('open "%s"', verification_uri))

            -- Confirm sign-in
            client.request("signInConfirm", { userCode = user_code }, function(err3, result3)
              if err3 then
                vim.notify("Authentication failed: " .. vim.inspect(err3), vim.log.levels.ERROR)
                return
              end

              if result3.status == "OK" then
                vim.notify("✓ Successfully authenticated with GitHub Copilot!", vim.log.levels.INFO)
              else
                vim.notify("Authentication status: " .. result3.status, vim.log.levels.WARN)
              end
            end, 1)
          end, 1)
        end, 1)
      end, { desc = "Authenticate with GitHub Copilot" })
    end,
    opts = {
      cli = {
        mux = {
          backend = "tmux",
          enabled = true,
        },
        tools = {
          opencode = {
            cmd = { "opencode", "--agent", "plan" },
            env = { OPENCODE_THEME = "system" },
          },
        },
      },
    },
    keys = {
      -- Note: Tab is handled in completion.lua to integrate with nvim-cmp
      {
        "<c-.>",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").select()
        end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = "Select CLI",
      },
      {
        "<leader>ar",
        function()
          -- Get all AI CLI sessions with details
          local sessions_raw = vim.fn.systemlist(
            "tmux list-sessions -F '#{session_name}|#{session_created}|#{session_attached}|#{session_windows}' 2>/dev/null | grep -E 'opencode|claude|copilot|gemini|aider|codex|grok|crush|qwen|cursor'"
          )
          
          if #sessions_raw == 0 then
            vim.notify("No AI CLI sessions found", vim.log.levels.INFO)
            return
          end
          
          -- Parse sessions into a table
          local sessions = {}
          for _, line in ipairs(sessions_raw) do
            local parts = vim.split(line, "|")
            local name = parts[1]
            local created = parts[2]
            local attached = parts[3]
            local windows = parts[4]
            
            -- Parse tool name from session name (e.g., "opencode fb01e63c" -> "opencode")
            local tool = vim.split(name, " ")[1]
            
            -- Format timestamp
            local time_str = os.date("%Y-%m-%d %H:%M:%S", tonumber(created))
            
            table.insert(sessions, {
              display = string.format(
                "%-10s | %s | %s | %s windows",
                tool,
                time_str,
                attached == "1" and "ATTACHED" or "detached",
                windows
              ),
              name = name,
              tool = tool,
              attached = attached == "1"
            })
          end
          
          -- Use vim.ui.select to pick a session
          vim.ui.select(sessions, {
            prompt = "Select AI CLI session to delete:",
            format_item = function(item)
              return item.display
            end,
          }, function(choice)
            if not choice then
              return
            end
            
            -- Confirm deletion
            local confirm = vim.fn.confirm(
              string.format("Delete session '%s'?", choice.name),
              "&Yes\n&No",
              2
            )
            
            if confirm == 1 then
              vim.fn.system(string.format("tmux kill-session -t '%s' 2>/dev/null", choice.name))
              vim.notify(string.format("Deleted session: %s", choice.name), vim.log.levels.INFO)
            end
          end)
        end,
        desc = "Delete AI CLI Session",
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").close()
        end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      -- Example of a keybinding to open Claude directly
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Sidekick Toggle Claude",
      },
    },
  },
}
