local M = {}

local utils = require("swift.utils")
local config = {}

-- Build output buffer
local build_bufnr = nil
local build_winnr = nil

function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    auto_save = true, -- Save all files before building
    show_output = true, -- Show build output in split
    output_position = "botright", -- Position of output window (botright, belowright, etc)
    output_height = 15, -- Height of output window
    close_on_success = false, -- Auto-close output window on successful build
    focus_on_open = false, -- Focus output window when opened
  }, opts or {})

  M.setup_commands()
  M.setup_keymaps()
end

function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftBuild", function(opts)
    local args = opts.args
    M.build(args ~= "" and args or nil)
  end, {
    nargs = "?",
    desc = "Build Swift package",
    complete = function()
      return { "debug", "release" }
    end,
  })

  vim.api.nvim_create_user_command("SwiftRun", function(opts)
    local args = opts.args
    M.run(args)
  end, {
    nargs = "*",
    desc = "Run Swift package",
  })

  vim.api.nvim_create_user_command("SwiftTest", function(opts)
    local args = opts.args
    M.test(args)
  end, {
    nargs = "*",
    desc = "Run Swift tests",
  })

  vim.api.nvim_create_user_command("SwiftClean", function()
    M.clean()
  end, {
    desc = "Clean Swift build artifacts",
  })

  vim.api.nvim_create_user_command("SwiftBuildClose", function()
    M.close_output()
  end, {
    desc = "Close Swift build output window",
  })
end

function M.setup_keymaps()
  -- Users can override these in their config
  -- vim.keymap.set("n", "<leader>sb", M.build, { desc = "Swift build" })
  -- vim.keymap.set("n", "<leader>sr", M.run, { desc = "Swift run" })
  -- vim.keymap.set("n", "<leader>st", M.test, { desc = "Swift test" })
end

-- Check if we're in a Swift Package
function M.is_swift_package()
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if not detector_ok then
    return false
  end

  local info = detector.get_project_info()
  return info.type == "spm"
end

-- Get Swift package root
function M.get_package_root()
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if not detector_ok then
    return nil
  end

  local info = detector.get_project_info()
  if info.type == "spm" then
    return info.root
  end
  return nil
end

-- Save all modified buffers
function M.save_all()
  if config.auto_save then
    vim.cmd("silent! wall")
  end
end

-- Create or get build output buffer
function M.get_output_buffer()
  if build_bufnr and vim.api.nvim_buf_is_valid(build_bufnr) then
    return build_bufnr
  end

  build_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(build_bufnr, "Swift Build Output")

  -- Set buffer options
  vim.api.nvim_buf_set_option(build_bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(build_bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(build_bufnr, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(build_bufnr, "filetype", "swift-build")

  -- Set buffer keymaps
  vim.api.nvim_buf_set_keymap(build_bufnr, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })

  return build_bufnr
end

-- Show output window
function M.show_output()
  if not config.show_output then
    return
  end

  local bufnr = M.get_output_buffer()

  -- Check if window is already open
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      build_winnr = win
      if config.focus_on_open then
        vim.api.nvim_set_current_win(win)
      end
      return
    end
  end

  -- Create new window
  vim.cmd(string.format("%s %d split", config.output_position, config.output_height))
  build_winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(build_winnr, bufnr)

  -- Set window options
  vim.api.nvim_win_set_option(build_winnr, "number", false)
  vim.api.nvim_win_set_option(build_winnr, "relativenumber", false)
  vim.api.nvim_win_set_option(build_winnr, "signcolumn", "no")

  if not config.focus_on_open then
    vim.cmd("wincmd p") -- Go back to previous window
  end
end

-- Close output window
function M.close_output()
  if build_winnr and vim.api.nvim_win_is_valid(build_winnr) then
    vim.api.nvim_win_close(build_winnr, true)
    build_winnr = nil
  end
end

-- Append output to buffer
function M.append_output(lines)
  local bufnr = M.get_output_buffer()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)

  if type(lines) == "string" then
    lines = vim.split(lines, "\n")
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, line_count, -1, false, lines)

  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

  -- Auto-scroll to bottom
  if build_winnr and vim.api.nvim_win_is_valid(build_winnr) then
    local new_line_count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_win_set_cursor(build_winnr, { new_line_count, 0 })
  end
end

-- Clear output buffer
function M.clear_output()
  local bufnr = M.get_output_buffer()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

-- Execute command and show output
function M.execute_command(cmd, cwd, on_success, on_error)
  M.save_all()
  M.show_output()
  M.clear_output()

  M.append_output({ "$ " .. cmd, "Running in: " .. cwd, "" })

  local start_time = vim.loop.hrtime()

  vim.fn.jobstart(cmd, {
    cwd = cwd,
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if data then
        M.append_output(data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        M.append_output(data)
      end
    end,
    on_exit = function(_, exit_code)
      local elapsed = (vim.loop.hrtime() - start_time) / 1e9
      local elapsed_str = string.format("%.2f", elapsed)

      M.append_output({ "", "────────────────────────────────────" })

      if exit_code == 0 then
        M.append_output({
          "✓ Command completed successfully",
          string.format("  Time: %ss", elapsed_str),
        })

        if config.close_on_success then
          vim.defer_fn(function()
            M.close_output()
          end, 1000)
        end

        if on_success then
          on_success()
        end
      else
        M.append_output({
          string.format("✗ Command failed with exit code: %d", exit_code),
          string.format("  Time: %ss", elapsed_str),
        })

        if on_error then
          on_error(exit_code)
        end
      end
    end,
  })
end

-- Build Swift package
function M.build(configuration)
  if not M.is_swift_package() then
    vim.notify("Not in a Swift Package project", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  local root = M.get_package_root()
  if not root then
    vim.notify("Could not find Swift Package root", vim.log.levels.ERROR, { title = "swift.nvim" })
    return
  end

  local config_flag = ""
  if configuration == "release" then
    config_flag = " -c release"
  elseif configuration == "debug" or not configuration then
    config_flag = " -c debug"
  else
    config_flag = " " .. configuration
  end

  local cmd = "swift build" .. config_flag

  M.execute_command(cmd, root, function()
    vim.notify("Build completed successfully", vim.log.levels.INFO, { title = "swift.nvim" })
  end, function(exit_code)
    vim.notify("Build failed with exit code: " .. exit_code, vim.log.levels.ERROR, { title = "swift.nvim" })
  end)
end

-- Run Swift package
function M.run(args)
  if not M.is_swift_package() then
    vim.notify("Not in a Swift Package project", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  local root = M.get_package_root()
  if not root then
    vim.notify("Could not find Swift Package root", vim.log.levels.ERROR, { title = "swift.nvim" })
    return
  end

  local cmd = "swift run"
  if args and args ~= "" then
    cmd = cmd .. " " .. args
  end

  M.execute_command(cmd, root)
end

-- Test Swift package
function M.test(args)
  if not M.is_swift_package() then
    vim.notify("Not in a Swift Package project", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  local root = M.get_package_root()
  if not root then
    vim.notify("Could not find Swift Package root", vim.log.levels.ERROR, { title = "swift.nvim" })
    return
  end

  local cmd = "swift test"
  if args and args ~= "" then
    cmd = cmd .. " " .. args
  end

  M.execute_command(cmd, root, function()
    vim.notify("Tests passed", vim.log.levels.INFO, { title = "swift.nvim" })
  end, function(exit_code)
    vim.notify("Tests failed with exit code: " .. exit_code, vim.log.levels.ERROR, { title = "swift.nvim" })
  end)
end

-- Clean Swift package
function M.clean()
  if not M.is_swift_package() then
    vim.notify("Not in a Swift Package project", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  local root = M.get_package_root()
  if not root then
    vim.notify("Could not find Swift Package root", vim.log.levels.ERROR, { title = "swift.nvim" })
    return
  end

  M.execute_command("swift package clean", root, function()
    vim.notify("Build artifacts cleaned", vim.log.levels.INFO, { title = "swift.nvim" })
  end)
end

return M
