local M = {}

local utils = require("swift.utils")
local config = {}

-- Check if nvim-dap is installed
function M.has_dap()
  local ok, _ = pcall(require, "dap")
  return ok
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    enabled = true,
    auto_setup = true, -- Automatically setup DAP configurations
    lldb_path = nil, -- Auto-detect lldb-dap/lldb-vscode
    stop_on_entry = false, -- Stop at entry point
    show_console = true, -- Show console output
    wait_for_debugger = false, -- Wait for debugger to attach
  }, opts or {})

  if not config.enabled then
    return
  end

  if config.auto_setup then
    M.setup_dap()
  end

  M.setup_commands()
end

-- Find lldb-dap or lldb-vscode
function M.find_lldb()
  if config.lldb_path then
    return config.lldb_path
  end

  -- Try lldb-dap first (newer name)
  local lldb_dap = vim.fn.exepath("lldb-dap")
  if lldb_dap ~= "" then
    return lldb_dap
  end

  -- Try lldb-vscode (older name)
  local lldb_vscode = vim.fn.exepath("lldb-vscode")
  if lldb_vscode ~= "" then
    return lldb_vscode
  end

  -- Try Xcode's lldb-dap (macOS)
  if vim.fn.has("mac") == 1 then
    local xcode_lldb = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb-dap"
    if vim.fn.executable(xcode_lldb) == 1 then
      return xcode_lldb
    end
  end

  return nil
end

-- Setup DAP configurations for Swift
function M.setup_dap()
  if not M.has_dap() then
    utils.log("nvim-dap not found. Please install it to use debugging features.", "warn")
    return false
  end

  local dap = require("dap")
  local lldb_path = M.find_lldb()

  if not lldb_path then
    utils.log("lldb-dap/lldb-vscode not found. Cannot setup Swift debugging.", "warn")
    return false
  end

  -- Setup lldb adapter
  dap.adapters.lldb = {
    type = "executable",
    command = lldb_path,
    name = "lldb",
  }

  -- Setup Swift configurations
  dap.configurations.swift = {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = function()
        return M.get_debug_executable()
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = config.stop_on_entry,
      args = function()
        return M.get_program_args()
      end,
      runInTerminal = config.show_console,
    },
    {
      name = "Launch (with arguments)",
      type = "lldb",
      request = "launch",
      program = function()
        return M.get_debug_executable()
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = config.stop_on_entry,
      args = function()
        local args = vim.fn.input("Program arguments: ")
        return vim.split(args, " ")
      end,
      runInTerminal = config.show_console,
    },
    {
      name = "Attach to Process",
      type = "lldb",
      request = "attach",
      pid = function()
        return require("dap.utils").pick_process()
      end,
      cwd = "${workspaceFolder}",
    },
    {
      name = "Attach by Name",
      type = "lldb",
      request = "attach",
      program = function()
        return M.get_debug_executable()
      end,
      waitFor = config.wait_for_debugger,
      cwd = "${workspaceFolder}",
    },
  }

  utils.log("Swift debugger configured successfully", "info")
  return true
end

-- Get the executable to debug
function M.get_debug_executable()
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if not detector_ok then
    utils.log("Project detector not available", "error")
    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  end

  local info = detector.get_project_info()

  -- For SPM projects
  if info.type == "spm" then
    local target_ok, target_manager = pcall(require, "swift.features.target_manager")
    if target_ok then
      local current_target = target_manager.get_current_target()
      if current_target then
        -- Try to find the built executable
        local build_dir = info.root .. "/.build/debug"
        local executable = build_dir .. "/" .. current_target

        if vim.fn.filereadable(executable) == 1 then
          return executable
        end
      end
    end

    -- If target not found, try to build first
    utils.log("Executable not found. Please build the project first with :SwiftBuild", "warn")
    return vim.fn.input("Path to executable: ", info.root .. "/.build/debug/", "file")
  end

  -- For Xcode projects, prompt for path
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

-- Get program arguments
function M.get_program_args()
  -- Check if there are saved arguments
  if vim.g.swift_debug_args then
    return vim.g.swift_debug_args
  end
  return {}
end

-- Set program arguments
function M.set_program_args(args)
  vim.g.swift_debug_args = args
end

-- Clear program arguments
function M.clear_program_args()
  vim.g.swift_debug_args = nil
end

-- Build and debug
function M.build_and_debug()
  if not M.has_dap() then
    vim.notify("nvim-dap is not installed", vim.log.levels.ERROR, { title = "swift.nvim" })
    return
  end

  -- Check if we're in an SPM project
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if not detector_ok then
    vim.notify("Cannot detect project type", vim.log.levels.ERROR, { title = "swift.nvim" })
    return
  end

  local info = detector.get_project_info()
  if info.type ~= "spm" then
    vim.notify("Build and debug is only supported for SPM projects", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  -- Build first
  local build_ok, build_runner = pcall(require, "swift.features.build_runner")
  if not build_ok then
    vim.notify("Build runner not available", vim.log.levels.ERROR, { title = "swift.nvim" })
    return
  end

  vim.notify("Building project...", vim.log.levels.INFO, { title = "swift.nvim" })

  -- Build in debug mode
  local root = info.root
  local cmd = "swift build -c debug"

  build_runner.execute_command(cmd, root, function()
    vim.notify("Build successful. Starting debugger...", vim.log.levels.INFO, { title = "swift.nvim" })
    vim.defer_fn(function()
      M.start_debugging()
    end, 500)
  end, function(exit_code)
    vim.notify("Build failed. Cannot start debugger.", vim.log.levels.ERROR, { title = "swift.nvim" })
  end)
end

-- Start debugging session
function M.start_debugging(config_name)
  if not M.has_dap() then
    vim.notify("nvim-dap is not installed", vim.log.levels.ERROR, { title = "swift.nvim" })
    return
  end

  local dap = require("dap")

  if config_name then
    dap.run(dap.configurations.swift[config_name])
  else
    dap.continue()
  end
end

-- Setup user commands
function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftDebug", function()
    M.start_debugging()
  end, {
    desc = "Start Swift debugging session",
  })

  vim.api.nvim_create_user_command("SwiftBuildAndDebug", function()
    M.build_and_debug()
  end, {
    desc = "Build and start Swift debugging session",
  })

  vim.api.nvim_create_user_command("SwiftDebugArgs", function(opts)
    local args = vim.split(opts.args, " ")
    M.set_program_args(args)
    vim.notify("Debug arguments set: " .. opts.args, vim.log.levels.INFO, { title = "swift.nvim" })
  end, {
    nargs = "*",
    desc = "Set Swift debug program arguments",
  })

  vim.api.nvim_create_user_command("SwiftDebugClearArgs", function()
    M.clear_program_args()
    vim.notify("Debug arguments cleared", vim.log.levels.INFO, { title = "swift.nvim" })
  end, {
    desc = "Clear Swift debug program arguments",
  })

  -- Setup DAP UI commands if nvim-dap-ui is available
  if pcall(require, "dapui") then
    vim.api.nvim_create_user_command("SwiftDebugUI", function()
      require("dapui").toggle()
    end, {
      desc = "Toggle Swift debug UI",
    })
  end
end

-- Get info for health check
function M.get_health_info()
  return {
    has_dap = M.has_dap(),
    lldb_path = M.find_lldb(),
    configured = config.enabled and config.auto_setup,
  }
end

return M
