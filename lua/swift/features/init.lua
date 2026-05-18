local M = {}

local config = require("swift.core.config")

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

  -- Load snippets if enabled
  if config.is_feature_enabled("snippets") then
    local ok, snippets = pcall(require, "swift.features.snippets")
    if ok then
      snippets.setup(config.get_feature("snippets"))
    else
      vim.notify("Failed to load snippets: " .. tostring(snippets), vim.log.levels.ERROR)
    end
  end

  -- Load debugger if enabled
  if config.is_feature_enabled("debugger") then
    local ok, debugger = pcall(require, "swift.features.debugger")
    if ok then
      debugger.setup(config.get_feature("debugger"))
    else
      vim.notify("Failed to load debugger: " .. tostring(debugger), vim.log.levels.ERROR)
    end
  end

  -- Load preview_panel if enabled
  if config.is_feature_enabled("preview_panel") then
    local ok, preview_panel = pcall(require, "swift.features.preview_panel")
    if ok then
      preview_panel.setup(config.get_feature("preview_panel"))
    else
      vim.notify("Failed to load preview_panel: " .. tostring(preview_panel), vim.log.levels.ERROR)
    end
  end
end

return M
