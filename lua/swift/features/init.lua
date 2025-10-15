local M = {}

local config = require("swift.config")

function M.load()
  -- Load project_detector if enabled
  if config.is_feature_enabled("project_detector") then
    local ok, project_detector = pcall(require, "swift.features.project_detector")
    if ok then
      project_detector.setup(config.get_feature("project_detector"))
    else
      vim.notify("Failed to load project_detector: " .. tostring(project_detector), vim.log.levels.ERROR)
    end
  end

  -- Load feature1 if enabled
  if config.is_feature_enabled("feature1") then
    local ok, feature1 = pcall(require, "swift.features.feature1")
    if ok then
      feature1.setup(config.get_feature("feature1"))
    else
      vim.notify("Failed to load feature1: " .. tostring(feature1), vim.log.levels.ERROR)
    end
  end

  -- Load feature2 if enabled
  if config.is_feature_enabled("feature2") then
    local ok, feature2 = pcall(require, "swift.features.feature2")
    if ok then
      feature2.setup(config.get_feature("feature2"))
    else
      vim.notify("Failed to load feature2: " .. tostring(feature2), vim.log.levels.ERROR)
    end
  end
end

return M
