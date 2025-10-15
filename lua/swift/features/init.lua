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

  -- Load build_runner if enabled
  if config.is_feature_enabled("build_runner") then
    local ok, build_runner = pcall(require, "swift.features.build_runner")
    if ok then
      build_runner.setup(config.get_feature("build_runner"))
    else
      vim.notify("Failed to load build_runner: " .. tostring(build_runner), vim.log.levels.ERROR)
    end
  end

  -- Add more features here as they are implemented
  -- Example:
  -- if config.is_feature_enabled("your_feature") then
  --   local ok, your_feature = pcall(require, "swift.features.your_feature")
  --   if ok then
  --     your_feature.setup(config.get_feature("your_feature"))
  --   else
  --     vim.notify("Failed to load your_feature: " .. tostring(your_feature), vim.log.levels.ERROR)
  --   end
  -- end
end

return M
