local M = {}

local utils = require("swift.utils")
local config = {}

-- State
local state = {
  lldb_job = nil,
  lldb_channel = nil,
  current_file = nil,
  current_line = nil,
  breakpoints = {}, -- { file: { line: true } }
  is_running = false,
  output_buf = nil,
  output_win = nil,
  variables_buf = nil,
  variables_win = nil,
  executable = nil,
  cwd = nil,
  is_test = false,
}

-- Sign configuration
local SIGN_BREAKPOINT = "SwiftBreakpoint"
local SIGN_CURRENT = "SwiftCurrentLine"

function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    enabled = true,
    lldb_path = nil, -- Auto-detect lldb
    signs = {
      breakpoint = "●",
      current_line = "➤",
    },
    colors = {
      breakpoint = "DiagnosticError",
      current_line = "DiagnosticInfo",
    },
    window = {
      position = "bottom", -- bottom, right, float
      size = 15, -- height for bottom, width for right
    },
  }, opts or {})

  if not config.enabled then
    return
  end

  M.setup_signs()
  M.setup_commands()
  M.setup_keymaps()
end

-- Setup signs for breakpoints and current line
function M.setup_signs()
  vim.fn.sign_define(SIGN_BREAKPOINT, {
    text = config.signs.breakpoint,
    texthl = config.colors.breakpoint,
    linehl = "",
    numhl = config.colors.breakpoint,
  })

  vim.fn.sign_define(SIGN_CURRENT, {
    text = config.signs.current_line,
    texthl = config.colors.current_line,
    linehl = "CursorLine",
    numhl = config.colors.current_line,
  })
end

-- Find lldb executable
function M.find_lldb()
  if config.lldb_path then
    return config.lldb_path
  end

  -- Try lldb
  local lldb = vim.fn.exepath("lldb")
  if lldb ~= "" then
    return lldb
  end

  -- Try Xcode's lldb (macOS)
  if vim.fn.has("mac") == 1 then
    local xcode_lldb = "/Applications/Xcode.app/Contents/Developer/usr/bin/lldb"
    if vim.fn.executable(xcode_lldb) == 1 then
      return xcode_lldb
    end
  end

  return nil
end

-- Get package name from Package.swift
function M.get_package_name(project_root)
  local package_file = project_root .. "/Package.swift"
  if vim.fn.filereadable(package_file) == 0 then
    return nil
  end

  -- Read Package.swift and extract package name
  local content = vim.fn.readfile(package_file)
  for _, line in ipairs(content) do
    local name = line:match('name:%s*"([^"]+)"')
    if name then
      return name
    end
  end
  return nil
end

-- Detect if target is a test target
function M.is_test_target(target_name)
  return target_name:match("Tests?$") ~= nil
end

-- Get the executable to debug
-- Returns: { executable = path, cwd = working_dir, is_test = boolean }
function M.get_debug_executable()
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if not detector_ok then
    local exe = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    return { executable = exe, cwd = vim.fn.getcwd(), is_test = false }
  end

  local info = detector.get_project_info()

  -- For SPM projects
  if info.type == "spm" then
    local target_ok, target_manager = pcall(require, "swift.features.target_manager")
    if target_ok then
      local current_target = target_manager.get_current_target()
      if current_target then
        local build_dir = ".build/debug"
        local is_test = M.is_test_target(current_target)
        local executable

        if is_test then
          -- For tests, use .xctest bundle
          local package_name = M.get_package_name(info.root)
          if package_name then
            executable = build_dir .. "/" .. package_name .. "PackageTests.xctest"
          else
            -- Fallback: try with target name
            executable = build_dir .. "/" .. current_target .. ".xctest"
          end
        else
          -- For executables, use the target name directly
          executable = build_dir .. "/" .. current_target
        end

        local full_path = info.root .. "/" .. executable
        if vim.fn.filereadable(full_path) == 1 or vim.fn.isdirectory(full_path) == 1 then
          return {
            executable = executable,
            cwd = info.root,
            is_test = is_test,
            target = current_target,
          }
        end
      end
    end

    utils.log("Executable not found. Please build the project first with :SwiftBuild", "warn")
    local exe = vim.fn.input("Path to executable: ", info.root .. "/.build/debug/", "file")
    return { executable = exe, cwd = info.root, is_test = false }
  end

  local exe = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  return { executable = exe, cwd = vim.fn.getcwd(), is_test = false }
end

-- Create output window
function M.create_output_window()
  if state.output_win and vim.api.nvim_win_is_valid(state.output_win) then
    return
  end

  -- Create buffer if it doesn't exist
  if not state.output_buf or not vim.api.nvim_buf_is_valid(state.output_buf) then
    state.output_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(state.output_buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(state.output_buf, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(state.output_buf, "swapfile", false)
    vim.api.nvim_buf_set_name(state.output_buf, "LLDB Output")
  end

  -- Create window based on config
  if config.window.position == "float" then
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    state.output_win = vim.api.nvim_open_win(state.output_buf, false, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
      title = " LLDB Debugger ",
      title_pos = "center",
    })
  else
    -- Split window
    vim.cmd(config.window.position == "bottom" and "botright split" or "vertical botright split")
    state.output_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(state.output_win, state.output_buf)

    local size = config.window.size or 15
    if config.window.position == "bottom" then
      vim.api.nvim_win_set_height(state.output_win, size)
    else
      vim.api.nvim_win_set_width(state.output_win, size)
    end

    -- Return to previous window
    vim.cmd("wincmd p")
  end

  -- Set window options
  vim.api.nvim_win_set_option(state.output_win, "number", false)
  vim.api.nvim_win_set_option(state.output_win, "relativenumber", false)
  vim.api.nvim_win_set_option(state.output_win, "wrap", false)

  -- Setup buffer mappings
  local opts = { buffer = state.output_buf, noremap = true, silent = true }
  vim.keymap.set("n", "q", function()
    M.close_output_window()
  end, opts)
end

-- Close output window
function M.close_output_window()
  if state.output_win and vim.api.nvim_win_is_valid(state.output_win) then
    vim.api.nvim_win_close(state.output_win, true)
    state.output_win = nil
  end
end

-- Append output to buffer
function M.append_output(text)
  if not state.output_buf or not vim.api.nvim_buf_is_valid(state.output_buf) then
    return
  end

  local lines = vim.split(text, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(state.output_buf, -1, -1, false, lines)

  -- Auto-scroll to bottom if window is visible
  if state.output_win and vim.api.nvim_win_is_valid(state.output_win) then
    local line_count = vim.api.nvim_buf_line_count(state.output_buf)
    vim.api.nvim_win_set_cursor(state.output_win, { line_count, 0 })
  end
end

-- Toggle breakpoint at current line
function M.toggle_breakpoint()
  local file = vim.fn.expand("%:p")
  local line = vim.fn.line(".")

  if not state.breakpoints[file] then
    state.breakpoints[file] = {}
  end

  if state.breakpoints[file][line] then
    -- Remove breakpoint
    state.breakpoints[file][line] = nil
    vim.fn.sign_unplace("swift_breakpoints", { buffer = vim.fn.bufnr("%"), id = line })

    -- Remove from lldb if running
    if state.is_running and state.lldb_channel then
      vim.fn.chansend(state.lldb_channel, string.format("breakpoint delete %s:%d\n", file, line))
    end

    utils.log("Breakpoint removed", "info")
  else
    -- Add breakpoint
    state.breakpoints[file][line] = true
    vim.fn.sign_place(line, "swift_breakpoints", SIGN_BREAKPOINT, vim.fn.bufnr("%"), { lnum = line })

    -- Add to lldb if running
    if state.is_running and state.lldb_channel then
      vim.fn.chansend(state.lldb_channel, string.format("breakpoint set -f %s -l %d\n", file, line))
    end

    utils.log("Breakpoint set", "info")
  end
end

-- Clear all breakpoints
function M.clear_breakpoints()
  for file, lines in pairs(state.breakpoints) do
    local bufnr = vim.fn.bufnr(file)
    if bufnr ~= -1 then
      for line, _ in pairs(lines) do
        vim.fn.sign_unplace("swift_breakpoints", { buffer = bufnr, id = line })
      end
    end
  end

  state.breakpoints = {}

  if state.is_running and state.lldb_channel then
    vim.fn.chansend(state.lldb_channel, "breakpoint delete\n")
  end

  utils.log("All breakpoints cleared", "info")
end

-- Update current line indicator
function M.update_current_line(file, line)
  -- Remove old current line sign
  if state.current_file and state.current_line then
    local old_bufnr = vim.fn.bufnr(state.current_file)
    if old_bufnr ~= -1 then
      vim.fn.sign_unplace("swift_current_line", { buffer = old_bufnr })
    end
  end

  state.current_file = file
  state.current_line = line

  if file and line then
    -- Open file if not already open
    local bufnr = vim.fn.bufnr(file)
    if bufnr == -1 then
      vim.cmd("edit " .. file)
      bufnr = vim.fn.bufnr(file)
    end

    -- Place new current line sign
    vim.fn.sign_place(line, "swift_current_line", SIGN_CURRENT, bufnr, { lnum = line })

    -- Jump to file and line
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        vim.api.nvim_set_current_win(win)
        vim.api.nvim_win_set_cursor(win, { line, 0 })
        vim.cmd("normal! zz")
        return
      end
    end

    -- If buffer not visible, open it
    vim.cmd("edit " .. file)
    vim.api.nvim_win_set_cursor(0, { line, 0 })
    vim.cmd("normal! zz")
  end
end

-- Start debugging session
function M.start_debug()
  if state.is_running then
    utils.log("Debug session already running", "warn")
    return
  end

  local lldb_path = M.find_lldb()
  if not lldb_path then
    utils.log("LLDB not found", "error")
    return
  end

  -- Get executable info
  local exe_info = M.get_debug_executable()
  if not exe_info or not exe_info.executable or exe_info.executable == "" then
    utils.log("No executable selected", "error")
    return
  end

  state.executable = exe_info.executable
  state.cwd = exe_info.cwd
  state.is_test = exe_info.is_test

  -- Create output window
  M.create_output_window()
  M.append_output("=== Starting LLDB ===\n")
  M.append_output("Working Directory: " .. exe_info.cwd .. "\n")
  M.append_output("Executable: " .. exe_info.executable .. "\n")
  if exe_info.is_test then
    M.append_output("Type: Test Target (.xctest)\n")
  else
    M.append_output("Type: Executable Target\n")
  end
  if exe_info.target then
    M.append_output("Target: " .. exe_info.target .. "\n")
  end
  M.append_output("\n")

  -- Start lldb with working directory set to project root
  state.lldb_job = vim.fn.jobstart({ lldb_path, exe_info.executable }, {
    cwd = exe_info.cwd,
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            M.append_output(line .. "\n")
            M.parse_lldb_output(line)
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            M.append_output("[ERROR] " .. line .. "\n")
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      state.is_running = false
      state.lldb_job = nil
      state.lldb_channel = nil
      M.append_output("\n=== LLDB exited with code " .. exit_code .. " ===\n")
    end,
    pty = true,
  })

  if state.lldb_job <= 0 then
    utils.log("Failed to start LLDB", "error")
    return
  end

  state.lldb_channel = state.lldb_job
  state.is_running = true

  -- Wait a bit for lldb to start
  vim.defer_fn(function()
    -- Set existing breakpoints
    for file, lines in pairs(state.breakpoints) do
      for line, _ in pairs(lines) do
        vim.fn.chansend(state.lldb_channel, string.format("breakpoint set -f %s -l %d\n", file, line))
      end
    end
  end, 500)

  utils.log("LLDB started", "info")
end

-- Parse LLDB output to detect stops
function M.parse_lldb_output(line)
  -- Look for stop patterns like "at filename.swift:42"
  local file, line_num = line:match("at%s+([^:]+):(%d+)")
  if file and line_num then
    M.update_current_line(file, tonumber(line_num))
  end
end

-- Send command to LLDB
function M.send_command(cmd)
  if not state.is_running or not state.lldb_channel then
    utils.log("No active debug session", "warn")
    return
  end

  M.append_output("\n(lldb) " .. cmd .. "\n")
  vim.fn.chansend(state.lldb_channel, cmd .. "\n")
end

-- Debug commands
function M.run()
  M.send_command("run")
end

function M.continue()
  M.send_command("continue")
end

function M.step_over()
  M.send_command("next")
end

function M.step_into()
  M.send_command("step")
end

function M.step_out()
  M.send_command("finish")
end

function M.stop()
  if state.is_running and state.lldb_job then
    vim.fn.jobstop(state.lldb_job)
    state.is_running = false
    state.lldb_job = nil
    state.lldb_channel = nil
    utils.log("Debug session stopped", "info")
  end
end

function M.show_variables()
  M.send_command("frame variable")
end

function M.show_backtrace()
  M.send_command("bt")
end

-- Build and debug
function M.build_and_debug(is_test)
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

  local build_ok, build_runner = pcall(require, "swift.features.build_runner")
  if not build_ok then
    vim.notify("Build runner not available", vim.log.levels.ERROR, { title = "swift.nvim" })
    return
  end

  local build_type = is_test and "tests" or "project"
  vim.notify("Building " .. build_type .. "...", vim.log.levels.INFO, { title = "swift.nvim" })

  local root = info.root
  local cmd = is_test and "swift build --build-tests -c debug" or "swift build -c debug"

  build_runner.execute_command(cmd, root, function()
    vim.notify("Build successful. Starting debugger...", vim.log.levels.INFO, { title = "swift.nvim" })
    vim.defer_fn(function()
      M.start_debug()
    end, 500)
  end, function(exit_code)
    vim.notify("Build failed. Cannot start debugger.", vim.log.levels.ERROR, { title = "swift.nvim" })
  end)
end

-- Setup keymaps
function M.setup_keymaps()
  -- These are just defaults, users can override them
  -- vim.keymap.set("n", "<F5>", M.continue, { desc = "Debug: Continue" })
  -- vim.keymap.set("n", "<F9>", M.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
  -- vim.keymap.set("n", "<F10>", M.step_over, { desc = "Debug: Step Over" })
  -- vim.keymap.set("n", "<F11>", M.step_into, { desc = "Debug: Step Into" })
end

-- Setup user commands
function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftDebug", function()
    M.start_debug()
  end, { desc = "Start Swift debugging session" })

  vim.api.nvim_create_user_command("SwiftBuildAndDebug", function()
    M.build_and_debug(false)
  end, { desc = "Build and start Swift debugging session" })

  vim.api.nvim_create_user_command("SwiftBuildAndDebugTests", function()
    M.build_and_debug(true)
  end, { desc = "Build tests and start Swift debugging session" })

  vim.api.nvim_create_user_command("SwiftDebugStop", function()
    M.stop()
  end, { desc = "Stop Swift debugging session" })

  vim.api.nvim_create_user_command("SwiftDebugContinue", function()
    M.continue()
  end, { desc = "Continue execution" })

  vim.api.nvim_create_user_command("SwiftDebugStepOver", function()
    M.step_over()
  end, { desc = "Step over" })

  vim.api.nvim_create_user_command("SwiftDebugStepInto", function()
    M.step_into()
  end, { desc = "Step into" })

  vim.api.nvim_create_user_command("SwiftDebugStepOut", function()
    M.step_out()
  end, { desc = "Step out" })

  vim.api.nvim_create_user_command("SwiftBreakpointToggle", function()
    M.toggle_breakpoint()
  end, { desc = "Toggle breakpoint at current line" })

  vim.api.nvim_create_user_command("SwiftBreakpointClear", function()
    M.clear_breakpoints()
  end, { desc = "Clear all breakpoints" })

  vim.api.nvim_create_user_command("SwiftDebugVariables", function()
    M.show_variables()
  end, { desc = "Show local variables" })

  vim.api.nvim_create_user_command("SwiftDebugBacktrace", function()
    M.show_backtrace()
  end, { desc = "Show call stack" })

  vim.api.nvim_create_user_command("SwiftDebugCommand", function(opts)
    M.send_command(opts.args)
  end, {
    nargs = "+",
    desc = "Send custom LLDB command",
  })

  vim.api.nvim_create_user_command("SwiftDebugUI", function()
    if state.output_win and vim.api.nvim_win_is_valid(state.output_win) then
      M.close_output_window()
    else
      M.create_output_window()
    end
  end, { desc = "Toggle debug UI" })
end

-- Get info for health check
function M.get_health_info()
  return {
    lldb_path = M.find_lldb(),
    configured = config.enabled,
    is_running = state.is_running,
  }
end

return M
