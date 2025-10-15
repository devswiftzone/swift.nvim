local M = {}

local config = {}

function M.setup(opts)
  config = opts or {}

  -- Initialize feature1
  M.init()
end

function M.init()
  -- Setup keymaps
  M.setup_keymaps()

  -- Setup commands
  M.setup_commands()
end

function M.setup_keymaps()
  -- Example keymap
  -- vim.keymap.set("n", "<leader>sf1", M.do_something, { desc = "Swift: Feature 1 action" })
end

function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftFeature1", function()
    M.do_something()
  end, { desc = "Execute Feature 1 action" })
end

function M.do_something()
  print("Feature 1 is working!")
  -- Your feature logic here
end

return M
