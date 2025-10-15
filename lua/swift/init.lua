local M = {}

local config = require("swift.config")

function M.setup(opts)
  opts = opts or {}

  -- Merge user config with defaults
  config.setup(opts)

  -- Load features
  local features = require("swift.features")
  features.load()

  -- Setup commands
  M.setup_commands()

  -- Setup autocommands if needed
  M.setup_autocmds()
end

function M.setup_commands()
  -- Create user commands
  vim.api.nvim_create_user_command("SwiftInfo", function()
    print("Swift.nvim is running!")
    print("Config: " .. vim.inspect(config.get()))
  end, { desc = "Show Swift.nvim info" })

  vim.api.nvim_create_user_command("SwiftValidateEnvironment", function()
    local validator = require("swift.version_validator")
    validator.show_validation_results()
  end, { desc = "Validate Swift environment and versions" })

  vim.api.nvim_create_user_command("SwiftVersionInfo", function()
    local validator = require("swift.version_validator")

    print("Swift Version Information")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    local installed = validator.get_installed_swift_version()
    if installed then
      print("Installed: " .. installed.string)
    else
      print("Installed: Not found")
    end

    local required = validator.get_required_swift_version()
    if required then
      print("Required (.swift-version): " .. required.string)
      print("File: " .. required.file)
    else
      print("Required: No .swift-version file")
    end

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  end, { desc = "Show Swift version info" })
end

function M.setup_autocmds()
  -- Create autocommands group
  local augroup = vim.api.nvim_create_augroup("SwiftNvim", { clear = true })

  -- Example: autocmd for specific filetypes
  -- vim.api.nvim_create_autocmd("FileType", {
  --   group = augroup,
  --   pattern = "swift",
  --   callback = function()
  --     -- Your logic here
  --   end,
  -- })
end

return M
