local M = {}

local utils = require("swift.utils")
local config = require("swift.config")

-- Cache for targets
M._cache = {
  targets = nil,
  project_root = nil,
  last_check = 0,
}

-- Parse Package.swift to extract targets using swift package dump-package
function M.parse_spm_targets()
  local detector = require("swift.features.project_detector")
  local project_info = detector.get_project_info()

  if project_info.type ~= "spm" or not project_info.root then
    return nil
  end

  -- First, try using swift package dump-package (most reliable)
  local cmd = string.format('cd "%s" && swift package dump-package 2>/dev/null', project_info.root)
  local output = vim.fn.system(cmd)

  if vim.v.shell_error == 0 and output ~= "" then
    -- Parse JSON output
    local ok, package_data = pcall(vim.json.decode, output)
    if ok and package_data and package_data.targets then
      local targets = {}

      for _, target in ipairs(package_data.targets) do
        local target_type = "library" -- default

        -- Determine type from target.type field
        if target.type then
          if target.type == "executable" then
            target_type = "executable"
          elseif target.type == "test" then
            target_type = "test"
          elseif target.type == "regular" or target.type == "library" then
            target_type = "library"
          end
        end

        table.insert(targets, {
          name = target.name,
          type = target_type,
        })
      end

      return targets
    end
  end

  -- Fallback: manual parsing of Package.swift
  if not project_info.manifest then
    return nil
  end

  local file = io.open(project_info.manifest, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  local targets = {}

  -- Simple but effective: find each target definition and extract just its name
  -- We look for lines that start a target definition
  local lines = {}
  for line in content:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  local i = 1
  while i <= #lines do
    local line = lines[i]

    -- Check if this line starts a target definition
    local target_type_match = line:match("%.(%w+Target)%s*%(")

    if target_type_match then
      local target_type = "library"

      if target_type_match == "executableTarget" then
        target_type = "executable"
      elseif target_type_match == "testTarget" then
        target_type = "test"
      end

      -- Look for name in the next few lines (usually within 3 lines)
      local target_name = nil

      -- First check current line
      target_name = line:match('name%s*:%s*"([^"]+)"')

      -- If not found, check next few lines
      if not target_name then
        for j = i + 1, math.min(i + 5, #lines) do
          local next_line = lines[j]
          -- Only match if it's the parameter name (starts with whitespace + name:)
          target_name = next_line:match('^%s+name%s*:%s*"([^"]+)"')
          if target_name then
            break
          end
        end
      end

      if target_name then
        table.insert(targets, {
          name = target_name,
          type = target_type,
        })
      end
    end

    i = i + 1
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


-- Devuelve partes para lualine cuando es SPM
function M.get_lualine_parts()
  local info = M.get_statusline_info()
  if not info then return nil end

  -- icono para SPM (puedes cambiarlo)
  local spm_icon = " " -- o "󰛥 "

  print(info.project_name)

  if info.project_type == "spm" then
    return {
      icon    = spm_icon,
      target  = info.current_target or "default",
      project = info.project_name or "Swift",
      count   = info.total_targets or 0,
      text    = string.format("%s%s - %s - (%d)", spm_icon, info.current_target or "default", info.project_name or "Swift", info.total_targets or 0),
    }
  end

  -- Fallback (Xcode, etc.)
  local icon = (info.project_type == "xcode_project" or info.project_type == "xcode_workspace") and " " or " "
  local txt = info.current_target
      and string.format("%s%s - %s (%d)", icon, info.current_target, info.project_name or "Swift", info.total_targets or 0)
      or string.format("%s%s", icon, info.project_name or "Swift")
  return {
    icon    = icon,
    target  = info.current_target or "",
    project = info.project_name or "Swift",
    count   = info.total_targets or 0,
    text    = txt,
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
  local p = M.get_lualine_parts()
  return p and p.text or ""
end

-- function M.statusline_detailed()
--   local info = M.get_statusline_info()

--   if not info then
--     return ""
--   end

--   local icon = "󰛥 "
--   if info.project_type == "xcode_project" or info.project_type == "xcode_workspace" then
--     icon = " "
--   end

--   if info.current_target then
--     return string.format("%s%s - %s (%d)", icon, info.current_target, info.project_name, info.total_targets or 0)
--   end

--   return string.format("%s%s", icon, info.project_name or "Swift")
-- end

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
