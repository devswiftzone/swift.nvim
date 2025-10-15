local M = {}

local health = vim.health or require("health")

function M.check()
  health.start("swift.nvim")

  -- Check if plugin is loaded
  local ok, swift = pcall(require, "swift")
  if ok then
    health.ok("Plugin loaded successfully")
  else
    health.error("Failed to load plugin")
    return
  end

  -- Check configuration
  local config = require("swift.config")
  if config.get() then
    health.ok("Configuration loaded")
  else
    health.error("Configuration not found")
  end

  -- Check features
  health.start("Features")
  local features = config.get().features
  for name, feature_config in pairs(features) do
    if feature_config.enabled then
      health.ok(string.format("Feature '%s' is enabled", name))
    else
      health.info(string.format("Feature '%s' is disabled", name))
    end
  end

  -- Check Swift compiler
  if vim.fn.executable("swift") == 1 then
    health.ok("Swift compiler found")
    local version = vim.fn.system("swift --version 2>&1 | head -n 1")
    health.info("Version: " .. vim.trim(version))
  else
    health.warn("Swift compiler not found in PATH")
  end

  -- Check Xcode (macOS only)
  if vim.fn.has("mac") == 1 then
    if vim.fn.executable("xcodebuild") == 1 then
      health.ok("Xcode command line tools found")
    else
      health.info("Xcode command line tools not found (optional)")
    end
  end

  -- Check for project detection
  health.start("Project Detection")
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if detector_ok and config.is_feature_enabled("project_detector") then
    local project_info = detector.get_project_info()
    if project_info.type ~= "none" then
      health.ok(string.format("Detected %s project", project_info.type))
      health.info("Root: " .. (project_info.root or "N/A"))
    else
      health.info("No Swift project detected in current directory")
    end
  end
end

return M
