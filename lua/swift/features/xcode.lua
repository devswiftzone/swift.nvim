local M = {}

local config = {}
local build_bufnr = nil
local build_winnr = nil

function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    enabled = true,
    default_scheme = nil, -- Auto-detect or prompt
    default_simulator = nil, -- Auto-detect or prompt
    show_output = true,
    output_position = "botright",
    output_height = 15,
    focus_on_open = false,
  }, opts or {})

  M.setup_commands()
end

-- Check if we're in an Xcode project
function M.is_xcode_project()
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if not detector_ok then
    return false
  end

  local info = detector.get_project_info()
  return info.type == "xcode_project" or info.type == "xcode_workspace"
end

-- Get Xcode project info
function M.get_project_info()
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if not detector_ok then
    return nil
  end

  local info = detector.get_project_info()
  if info.type == "xcode_project" or info.type == "xcode_workspace" then
    return info
  end
  return nil
end

-- Get build output buffer
function M.get_output_buffer()
  if build_bufnr and vim.api.nvim_buf_is_valid(build_bufnr) then
    return build_bufnr
  end

  build_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(build_bufnr, "Xcode Build Output")

  vim.api.nvim_buf_set_option(build_bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(build_bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(build_bufnr, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(build_bufnr, "filetype", "xcode-build")

  vim.api.nvim_buf_set_keymap(build_bufnr, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })

  return build_bufnr
end

-- Show output window
function M.show_output()
  if not config.show_output then
    return
  end

  local bufnr = M.get_output_buffer()

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      build_winnr = win
      if config.focus_on_open then
        vim.api.nvim_set_current_win(win)
      end
      return
    end
  end

  vim.cmd(string.format("%s %d split", config.output_position, config.output_height))
  build_winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(build_winnr, bufnr)

  vim.api.nvim_win_set_option(build_winnr, "number", false)
  vim.api.nvim_win_set_option(build_winnr, "relativenumber", false)
  vim.api.nvim_win_set_option(build_winnr, "signcolumn", "no")

  if not config.focus_on_open then
    vim.cmd("wincmd p")
  end
end

-- Append output
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

  if build_winnr and vim.api.nvim_win_is_valid(build_winnr) then
    local new_line_count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_win_set_cursor(build_winnr, { new_line_count, 0 })
  end
end

-- Clear output
function M.clear_output()
  local bufnr = M.get_output_buffer()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

-- List schemes
function M.list_schemes()
  if not M.is_xcode_project() then
    vim.notify("Not in an Xcode project", vim.log.levels.WARN, { title = "swift.nvim" })
    return {}
  end

  local info = M.get_project_info()
  if not info then
    return {}
  end

  local project_file
  if info.type == "xcode_workspace" then
    project_file = info.workspace
  else
    project_file = info.project
  end

  local cmd = string.format(
    "xcodebuild -list -workspace %s 2>/dev/null || xcodebuild -list -project %s 2>/dev/null",
    vim.fn.shellescape(project_file),
    vim.fn.shellescape(project_file)
  )

  local output = vim.fn.system(cmd)
  local schemes = {}
  local in_schemes = false

  for line in output:gmatch("[^\r\n]+") do
    if line:match("^%s*Schemes:") then
      in_schemes = true
    elseif in_schemes and line:match("^%s+%S") then
      local scheme = line:match("^%s+(.+)$")
      if scheme then
        table.insert(schemes, scheme)
      end
    elseif in_schemes and line:match("^%S") then
      break
    end
  end

  return schemes
end

-- Build with xcodebuild
function M.build(scheme)
  if not M.is_xcode_project() then
    vim.notify("Not in an Xcode project", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  local info = M.get_project_info()
  if not info then
    return
  end

  if not scheme then
    scheme = config.default_scheme
  end

  if not scheme then
    local schemes = M.list_schemes()
    if #schemes == 0 then
      vim.notify("No schemes found", vim.log.levels.ERROR, { title = "swift.nvim" })
      return
    elseif #schemes == 1 then
      scheme = schemes[1]
    else
      vim.ui.select(schemes, {
        prompt = "Select scheme:",
      }, function(choice)
        if choice then
          M.build(choice)
        end
      end)
      return
    end
  end

  M.show_output()
  M.clear_output()

  local project_flag
  if info.type == "xcode_workspace" then
    project_flag = "-workspace " .. vim.fn.shellescape(info.workspace)
  else
    project_flag = "-project " .. vim.fn.shellescape(info.project)
  end

  local cmd = string.format("xcodebuild %s -scheme %s clean build", project_flag, vim.fn.shellescape(scheme))

  M.append_output({ "$ " .. cmd, "Building scheme: " .. scheme, "" })

  vim.fn.jobstart(cmd, {
    cwd = info.root,
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
      M.append_output({
        "",
        "────────────────────────────────────",
      })
      if exit_code == 0 then
        M.append_output({ "✓ Build succeeded" })
        vim.notify("Build succeeded", vim.log.levels.INFO, { title = "swift.nvim" })
      else
        M.append_output({ string.format("✗ Build failed with exit code: %d", exit_code) })
        vim.notify("Build failed", vim.log.levels.ERROR, { title = "swift.nvim" })
      end
    end,
  })
end

-- Open in Xcode
function M.open_in_xcode()
  if not M.is_xcode_project() then
    vim.notify("Not in an Xcode project", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  local info = M.get_project_info()
  if not info then
    return
  end

  local file_to_open
  if info.type == "xcode_workspace" then
    file_to_open = info.workspace
  else
    file_to_open = info.project
  end

  vim.fn.system("open " .. vim.fn.shellescape(file_to_open))
  vim.notify("Opening in Xcode.app", vim.log.levels.INFO, { title = "swift.nvim" })
end

-- Setup commands
function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftXcodeBuild", function(opts)
    M.build(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    desc = "Build Xcode project",
    complete = function()
      return M.list_schemes()
    end,
  })

  vim.api.nvim_create_user_command("SwiftXcodeSchemes", function()
    local schemes = M.list_schemes()
    if #schemes == 0 then
      vim.notify("No schemes found", vim.log.levels.INFO, { title = "swift.nvim" })
      return
    end
    print("Available schemes:")
    for _, scheme in ipairs(schemes) do
      print("  " .. scheme)
    end
  end, { desc = "List Xcode schemes" })

  vim.api.nvim_create_user_command("SwiftXcodeOpen", function()
    M.open_in_xcode()
  end, { desc = "Open project in Xcode" })
end

-- Get info
function M.get_info()
  return {
    is_xcode_project = M.is_xcode_project(),
    project_info = M.get_project_info(),
    schemes = M.list_schemes(),
  }
end

return M
