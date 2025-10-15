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
