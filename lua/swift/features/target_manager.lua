local M = {}

local utils = require("swift.utils")
local config = require("swift.config")

-- Cache for targets
M._cache = {
  targets = nil,
  project_root = nil,
  last_check = 0,
}

-- Parse Package.swift to extract targets
function M.parse_spm_targets()
  local detector = require("swift.features.project_detector")
  local project_info = detector.get_project_info()

  if project_info.type ~= "spm" or not project_info.manifest then
    return nil
  end

  local file = io.open(project_info.manifest, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  local targets = {}
  local in_targets_block = false
  local current_target = nil

  -- Parse targets from Package.swift
  for line in content:gmatch("[^\r\n]+") do
    -- Look for .target( or .executableTarget( or .testTarget(
    if line:match("%.target%s*%(") or line:match("%.executableTarget%s*%(") or line:match("%.testTarget%s*%(") then
      in_targets_block = true
      current_target = {}

      -- Determine type
      if line:match("%.executableTarget") then
        current_target.type = "executable"
      elseif line:match("%.testTarget") then
        current_target.type = "test"
      else
        current_target.type = "library"
      end
    end

    if in_targets_block and current_target then
      -- Extract target name
      local name = line:match('name%s*:%s*"([^"]+)"')
      if name then
        current_target.name = name
      end

      -- Extract dependencies
      if line:match("dependencies%s*:") then
        current_target.dependencies = {}
      end

      -- Check for end of target definition
      if line:match("%)%s*,?%s*$") and current_target.name then
        table.insert(targets, current_target)
        current_target = nil
        in_targets_block = false
      end
    end
  end

  return targets
end

-- Get schemes from Xcode project
function M.parse_xcode_targets()
  local detector = require("swift.features.project_detector")
  local project_info = detector.get_project_info()

  if project_info.type ~= "xcode_project" and project_info.type ~= "xcode_workspace" then
    return nil
  end

  local project_file = project_info.xcode_project or project_info.xcode_workspace

  if not project_file then
    return nil
  end

  -- Use xcodebuild to list schemes (which correspond to targets)
  local cmd = string.format('cd "%s" && xcodebuild -list -json 2>/dev/null', vim.fn.fnamemodify(project_file, ":h"))
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Parse JSON output
  local ok, result = pcall(vim.json.decode, output)
  if not ok then
    return nil
  end

  local targets = {}

  -- Get targets from project
  if result.project and result.project.targets then
    for _, target_name in ipairs(result.project.targets) do
      table.insert(targets, {
        name = target_name,
        type = "xcode_target",
      })
    end
  end

  -- Get schemes (often more useful than raw targets)
  if result.project and result.project.schemes then
    for _, scheme_name in ipairs(result.project.schemes) do
      -- Check if not already added as target
      local exists = false
      for _, t in ipairs(targets) do
        if t.name == scheme_name then
          exists = true
          break
        end
      end

      if not exists then
        table.insert(targets, {
          name = scheme_name,
          type = "xcode_scheme",
        })
      end
    end
  end

  return targets
end

-- Get all targets for current project
function M.get_targets(force_refresh)
  force_refresh = force_refresh or false

  local detector = require("swift.features.project_detector")
  local project_info = detector.get_project_info()

  if project_info.type == "none" then
    return {}
  end

  -- Check cache
  local current_time = os.time()
  if
    not force_refresh
    and M._cache.targets
    and M._cache.project_root == project_info.root
    and (current_time - M._cache.last_check) < 60
  then
    return M._cache.targets
  end

  local targets = {}

  if project_info.type == "spm" then
    targets = M.parse_spm_targets() or {}
  elseif project_info.type == "xcode_project" or project_info.type == "xcode_workspace" then
    targets = M.parse_xcode_targets() or {}
  end

  -- Update cache
  M._cache.targets = targets
  M._cache.project_root = project_info.root
  M._cache.last_check = current_time

  return targets
end

-- Get target names only (for simple lists)
function M.get_target_names()
  local targets = M.get_targets()
  local names = {}

  for _, target in ipairs(targets) do
    table.insert(names, target.name)
  end

  return names
end

-- Get executable targets only
function M.get_executable_targets()
  local targets = M.get_targets()
  local executables = {}

  for _, target in ipairs(targets) do
    if target.type == "executable" or target.type == "xcode_scheme" or target.type == "xcode_target" then
      table.insert(executables, target)
    end
  end

  return executables
end

-- Get test targets only
function M.get_test_targets()
  local targets = M.get_targets()
  local tests = {}

  for _, target in ipairs(targets) do
    if target.type == "test" then
      table.insert(tests, target)
    end
  end

  return tests
end

-- Get current/selected target
function M.get_current_target()
  -- Check buffer-local variable
  if vim.b.swift_current_target then
    return vim.b.swift_current_target
  end

  -- Check global variable
  if vim.g.swift_current_target then
    return vim.g.swift_current_target
  end

  -- Return first executable target as default
  local executables = M.get_executable_targets()
  if #executables > 0 then
    return executables[1].name
  end

  -- Return first target if any
  local targets = M.get_targets()
  if #targets > 0 then
    return targets[1].name
  end

  return nil
end

-- Set current target
function M.set_current_target(target_name)
  -- Set both buffer-local and global
  vim.b.swift_current_target = target_name
  vim.g.swift_current_target = target_name

  vim.notify("Swift target set to: " .. target_name, vim.log.levels.INFO)
end

-- Select target with vim.ui.select
function M.select_target(callback)
  local targets = M.get_targets()

  if #targets == 0 then
    vim.notify("No targets found in current project", vim.log.levels.WARN)
    return
  end

  local target_names = {}
  for _, target in ipairs(targets) do
    local type_icon = ""
    if target.type == "executable" then
      type_icon = "󰘧 "
    elseif target.type == "test" then
      type_icon = "󰙨 "
    elseif target.type == "library" then
      type_icon = "󰴋 "
    elseif target.type == "xcode_scheme" then
      type_icon = " "
    elseif target.type == "xcode_target" then
      type_icon = " "
    end

    table.insert(target_names, type_icon .. target.name)
  end

  vim.ui.select(target_names, {
    prompt = "Select Swift target:",
  }, function(choice, idx)
    if choice and idx then
      local selected_target = targets[idx]
      M.set_current_target(selected_target.name)

      if callback then
        callback(selected_target)
      end
    end
  end)
end

-- Get target info for statusline
function M.get_statusline_info()
  local detector = require("swift.features.project_detector")
  local project_info = detector.get_project_info()

  if project_info.type == "none" then
    return nil
  end

  local current_target = M.get_current_target()
  local targets = M.get_targets()

  return {
    project_type = project_info.type,
    project_name = project_info.name,
    current_target = current_target,
    total_targets = #targets,
  }
end

-- Format for statusline (simple)
function M.statusline_simple()
  local info = M.get_statusline_info()

  if not info then
    return ""
  end

  if info.current_target then
    return string.format("󰛥 %s", info.current_target)
  end

  return ""
end

-- Format for statusline (detailed)
function M.statusline_detailed()
  local info = M.get_statusline_info()

  if not info then
    return ""
  end

  local icon = "󰛥 "
  if info.project_type == "xcode_project" or info.project_type == "xcode_workspace" then
    icon = " "
  end

  if info.current_target then
    return string.format("%s%s (%d)", icon, info.current_target, info.total_targets)
  end

  return string.format("%s%s", icon, info.project_name or "Swift")
end

-- Setup commands
function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftTargets", function()
    local targets = M.get_targets(true)

    if #targets == 0 then
      print("No targets found in current project")
      return
    end

    print("Swift Targets:")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    for _, target in ipairs(targets) do
      local type_label = target.type:upper()
      local current_marker = ""

      if target.name == M.get_current_target() then
        current_marker = " (current)"
      end

      print(string.format("  %s: %s%s", type_label, target.name, current_marker))
    end

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  end, { desc = "List all Swift targets" })

  vim.api.nvim_create_user_command("SwiftSelectTarget", function()
    M.select_target()
  end, { desc = "Select Swift target" })

  vim.api.nvim_create_user_command("SwiftCurrentTarget", function()
    local current = M.get_current_target()

    if current then
      print("Current Swift target: " .. current)
    else
      print("No Swift target selected")
    end
  end, { desc = "Show current Swift target" })
end

-- Setup
function M.setup(opts)
  opts = opts or {}

  if opts.enabled == false then
    return
  end

  M.setup_commands()
end

return M
