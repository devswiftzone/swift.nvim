-- Debugger configuration example
-- Place this file in: ~/.config/nvim/lua/plugins/swift.lua

return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {
      features = {
        debugger = {
          enabled = true,
          lldb_path = nil, -- Auto-detect lldb
          signs = {
            breakpoint = "●", -- Breakpoint sign
            current_line = "➤", -- Current line sign
          },
          colors = {
            breakpoint = "DiagnosticError", -- Breakpoint color
            current_line = "DiagnosticInfo", -- Current line color
          },
          window = {
            position = "bottom", -- "bottom", "right", or "float"
            size = 15, -- Height for bottom, width for right
          },
        },
      },
    },
    config = function(_, opts)
      require("swift").setup(opts)

      -- Debug keybindings
      local debugger = require("swift.features.debugger")

      -- Standard debug keys (F5-F12)
      vim.keymap.set("n", "<F5>", debugger.continue, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F9>", debugger.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<F10>", debugger.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", debugger.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", debugger.step_out, { desc = "Debug: Step Out" })

      -- Leader-based debug keys
      vim.keymap.set("n", "<leader>db", debugger.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", debugger.continue, { desc = "Continue" })
      vim.keymap.set("n", "<leader>ds", debugger.stop, { desc = "Stop Debugging" })
      vim.keymap.set("n", "<leader>dv", debugger.show_variables, { desc = "Show Variables" })
      vim.keymap.set("n", "<leader>dt", debugger.show_backtrace, { desc = "Show Backtrace" })
      vim.keymap.set("n", "<leader>du", ":SwiftDebugUI<CR>", { desc = "Toggle Debug UI" })

      -- Alternative: Using <leader>d prefix for all debug commands
      -- vim.keymap.set("n", "<leader>dr", debugger.run, { desc = "Debug: Run" })
      -- vim.keymap.set("n", "<leader>dso", debugger.step_over, { desc = "Debug: Step Over" })
      -- vim.keymap.set("n", "<leader>dsi", debugger.step_into, { desc = "Debug: Step Into" })
      -- vim.keymap.set("n", "<leader>dsO", debugger.step_out, { desc = "Debug: Step Out" })
    end,
  },
}
