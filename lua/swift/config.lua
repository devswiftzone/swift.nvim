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
    build_runner = {
      enabled = true,
      auto_save = true,
      show_output = true,
      output_position = "botright",
      output_height = 15,
      close_on_success = false,
      focus_on_open = false,
    },
    lsp = {
      enabled = true,
      auto_setup = true,
      sourcekit_path = nil, -- Auto-detect
      inlay_hints = true,
      semantic_tokens = true,
      on_attach = nil,
      capabilities = nil,
      cmd = nil,
      root_dir = nil,
      filetypes = { "swift" },
      settings = {},
    },
    -- Add more features here as they are implemented
  },
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
