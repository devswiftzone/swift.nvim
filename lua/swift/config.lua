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
    formatter = {
      enabled = true,
      tool = nil, -- Auto-detect: "swift-format" | "swiftformat"
      format_on_save = false,
      config_file = nil, -- Auto-detect
    },
    linter = {
      enabled = true,
      lint_on_save = true,
      auto_fix = false,
      config_file = nil, -- Auto-detect
    },
    xcode = {
      enabled = true,
      default_scheme = nil,
      default_simulator = nil,
      show_output = true,
      output_position = "botright",
      output_height = 15,
    },
    target_manager = {
      enabled = true,
      cache_timeout = 60, -- Cache targets for 60 seconds
    },
    snippets = {
      enabled = true,
      notify_on_load = false,       -- Show notification when snippets are loaded
      warn_if_missing = false,      -- Warn if LuaSnip is not installed
    },
    debugger = {
      enabled = true,
      auto_setup = true,             -- Automatically setup DAP configurations
      lldb_path = nil,               -- Auto-detect lldb-dap/lldb-vscode
      stop_on_entry = false,         -- Stop at entry point
      show_console = true,           -- Show console output
      wait_for_debugger = false,     -- Wait for debugger to attach
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
