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

  -- Load lsp if enabled
  if config.is_feature_enabled("lsp") then
    local ok, lsp = pcall(require, "swift.features.lsp")
    if ok then
      lsp.setup(config.get_feature("lsp"))
    else
      vim.notify("Failed to load lsp: " .. tostring(lsp), vim.log.levels.ERROR)
    end
  end

  -- Load formatter if enabled
  if config.is_feature_enabled("formatter") then
    local ok, formatter = pcall(require, "swift.features.formatter")
    if ok then
      formatter.setup(config.get_feature("formatter"))
    else
      vim.notify("Failed to load formatter: " .. tostring(formatter), vim.log.levels.ERROR)
    end
  end

  -- Load linter if enabled
  if config.is_feature_enabled("linter") then
    local ok, linter = pcall(require, "swift.features.linter")
    if ok then
      linter.setup(config.get_feature("linter"))
    else
      vim.notify("Failed to load linter: " .. tostring(linter), vim.log.levels.ERROR)
    end
  end

  -- Load xcode if enabled
  if config.is_feature_enabled("xcode") then
    local ok, xcode = pcall(require, "swift.features.xcode")
    if ok then
      xcode.setup(config.get_feature("xcode"))
    else
      vim.notify("Failed to load xcode: " .. tostring(xcode), vim.log.levels.ERROR)
    end
  end

  -- Load target_manager if enabled
  if config.is_feature_enabled("target_manager") then
    local ok, target_manager = pcall(require, "swift.features.target_manager")
    if ok then
      target_manager.setup(config.get_feature("target_manager"))
    else
      vim.notify("Failed to load target_manager: " .. tostring(target_manager), vim.log.levels.ERROR)
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
