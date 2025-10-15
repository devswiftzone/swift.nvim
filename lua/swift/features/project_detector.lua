local M = {}

local utils = require("swift.utils")
local config = {}

-- Cache for detected projects
local project_cache = {}

M.ProjectType = {
  NONE = "none",
  SPM = "spm", -- Swift Package Manager
  XCODE_PROJECT = "xcode_project",
  XCODE_WORKSPACE = "xcode_workspace",
}

function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    auto_detect = true,
    show_notification = true,
    cache_results = true,
  }, opts or {})

  if config.auto_detect then
    M.setup_autocmds()
  end

  M.setup_commands()
end

function M.setup_autocmds()
  local augroup = vim.api.nvim_create_augroup("SwiftProjectDetector", { clear = true })

  -- Detect on entering a buffer
  vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
    group = augroup,
    pattern = "*.swift",
    callback = function()
      M.detect_project()
    end,
  })

  -- Detect on directory change
  vim.api.nvim_create_autocmd("DirChanged", {
    group = augroup,
    callback = function()
      M.clear_cache()
      M.detect_project()
    end,
  })
end

function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftDetectProject", function()
    M.clear_cache()
    local info = M.detect_project(true)
    M.show_project_info(info)
  end, { desc = "Detect Swift project type" })

  vim.api.nvim_create_user_command("SwiftProjectInfo", function()
    local info = M.get_project_info()
    M.show_project_info(info)
  end, { desc = "Show Swift project information" })
end

-- Detect Swift Package Manager project
function M.detect_spm(start_path)
  local package_swift = utils.find_file_upwards("Package.swift", start_path)
  if package_swift then
    local root = vim.fn.fnamemodify(package_swift, ":h")
    local name = nil

    -- Try to extract package name from Package.swift
    local file = io.open(package_swift, "r")
    if file then
      local content = file:read("*a")
      file:close()

      -- Parse: let package = Package(name: "MyPackage", ...)
      -- or: Package(name: "MyPackage", ...)
      name = content:match('Package%s*%(.-name%s*:%s*"([^"]+)"')
    end

    -- Fallback: use directory name
    if not name then
      name = vim.fn.fnamemodify(root, ":t")
    end

    return {
      type = M.ProjectType.SPM,
      root = root,
      manifest = package_swift,
      name = name,
    }
  end
  return nil
end

-- Detect Xcode workspace
function M.detect_xcode_workspace(start_path)
  local workspaces = utils.find_pattern_upwards("*.xcworkspace", start_path)
  if #workspaces > 0 then
    local workspace = workspaces[1]
    return {
      type = M.ProjectType.XCODE_WORKSPACE,
      root = vim.fn.fnamemodify(workspace, ":h"),
      workspace = workspace,
      name = vim.fn.fnamemodify(workspace, ":t:r"),
    }
  end
  return nil
end

-- Detect Xcode project
function M.detect_xcode_project(start_path)
  local projects = utils.find_pattern_upwards("*.xcodeproj", start_path)
  if #projects > 0 then
    local project = projects[1]
    return {
      type = M.ProjectType.XCODE_PROJECT,
      root = vim.fn.fnamemodify(project, ":h"),
      project = project,
      name = vim.fn.fnamemodify(project, ":t:r"),
    }
  end
  return nil
end

-- Main detection function
function M.detect_project(force)
  local start_path = utils.get_buffer_dir()
  local cache_key = start_path

  -- Return cached result if available
  if not force and config.cache_results and project_cache[cache_key] then
    return project_cache[cache_key]
  end

  local project_info = {
    type = M.ProjectType.NONE,
    root = nil,
  }

  -- Priority order: workspace > project > spm
  -- Xcode workspace (highest priority)
  local workspace_info = M.detect_xcode_workspace(start_path)
  if workspace_info then
    project_info = workspace_info
  else
    -- Xcode project
    local project = M.detect_xcode_project(start_path)
    if project then
      project_info = project
    else
      -- Swift Package Manager
      local spm = M.detect_spm(start_path)
      if spm then
        project_info = spm
      end
    end
  end

  -- Cache the result
  if config.cache_results then
    project_cache[cache_key] = project_info
  end

  -- Set buffer variable
  vim.b.swift_project_type = project_info.type
  vim.b.swift_project_root = project_info.root

  -- Show notification if configured
  if config.show_notification and project_info.type ~= M.ProjectType.NONE then
    M.notify_project_detected(project_info)
  end

  return project_info
end

-- Get current project info
function M.get_project_info()
  local info = M.detect_project()
  return info
end

-- Check if we're in a Swift project
function M.is_swift_project()
  local info = M.get_project_info()
  return info.type ~= M.ProjectType.NONE
end

-- Get project root
function M.get_project_root()
  local info = M.get_project_info()
  return info.root
end

-- Get project type
function M.get_project_type()
  local info = M.get_project_info()
  return info.type
end

-- Clear cache
function M.clear_cache()
  project_cache = {}
end

-- Notify when project is detected
function M.notify_project_detected(info)
  local msg = ""
  if info.type == M.ProjectType.SPM then
    msg = string.format("Swift Package detected: %s", info.name or info.root)
  elseif info.type == M.ProjectType.XCODE_WORKSPACE then
    msg = string.format("Xcode Workspace detected: %s", info.name)
  elseif info.type == M.ProjectType.XCODE_PROJECT then
    msg = string.format("Xcode Project detected: %s", info.name)
  end

  if msg ~= "" then
    vim.notify(msg, vim.log.levels.INFO, { title = "swift.nvim" })
  end
end

-- Show detailed project information
function M.show_project_info(info)
  if info.type == M.ProjectType.NONE then
    print("No Swift project detected")
    return
  end

  print("Swift Project Information:")
  print("  Type: " .. info.type)
  print("  Root: " .. (info.root or "N/A"))

  if info.type == M.ProjectType.SPM then
    print("  Manifest: " .. info.manifest)
    print("  Name: " .. (info.name or "N/A"))
  elseif info.type == M.ProjectType.XCODE_WORKSPACE then
    print("  Workspace: " .. info.workspace)
    print("  Name: " .. info.name)
  elseif info.type == M.ProjectType.XCODE_PROJECT then
    print("  Project: " .. info.project)
    print("  Name: " .. info.name)
  end
end

return M
