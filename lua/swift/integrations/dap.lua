local M = {}

function M.setup()
  local ok, dap = pcall(require, "dap")
  if not ok then
    return
  end

  -- Auto-register LLDB adapter if not already registered
  if not dap.adapters.lldb then
    -- Try to find lldb-dap or lldb-vscode
    local command = "/usr/bin/lldb-dap"
    if vim.fn.executable("lldb-vscode") == 1 then
      command = "lldb-vscode"
    elseif vim.fn.executable("lldb-dap") == 1 then
      command = "lldb-dap"
    end

    dap.adapters.lldb = {
      type = "executable",
      command = command,
      name = "lldb",
    }
  end

  -- Auto-register basic Swift configuration if not present
  if not dap.configurations.swift then
    dap.configurations.swift = {
      {
        name = "Debug Swift Executable",
        type = "lldb",
        request = "launch",
        program = function()
          local target_manager = require("swift.features.target_manager")
          local current = target_manager.get_current_target()
          local detector = require("swift.features.project_detector")
          local info = detector.get_project_info()

          if current and info.root and info.type == "spm" then
            -- Guess the build path for SPM
            local path = info.root .. "/.build/debug/" .. current
            if vim.fn.executable(path) == 1 then
              return path
            end
          end

          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
  end
end

return M
