local M = {}

-- Default configuration
local defaults = {
  enabled = true,
  features = {
    project_detector = {
      enabled = true,
      auto_detect = true,
      show_notification = true,
      cache_results = true,
    },
    feature1 = {
      enabled = false,
    },
    feature2 = {
      enabled = false,
    },
  },
  -- Add your default options here
  log_level = "info",
}

-- Current configuration
local config = vim.deepcopy(defaults)

function M.setup(opts)
  config = vim.tbl_deep_extend("force", defaults, opts or {})
end

function M.get()
  return config
end

function M.get_feature(name)
  return config.features[name] or {}
end

function M.is_feature_enabled(name)
  local feature = config.features[name]
  return feature and feature.enabled ~= false
end

return M
