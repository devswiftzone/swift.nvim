-- Example configuration for local development
-- Use this when developing the plugin locally
-- Place this file in: ~/.config/nvim/lua/plugins/swift-dev.lua

return {
  {
    -- Point to your local plugin directory
    dir = "~/projects/nvim/swift.nvim",

    -- For local development, load immediately to test changes
    -- You can also use ft = "swift" for lazy loading
    lazy = false,

    -- Configuration
    config = function()
      require("swift").setup({
        features = {
          project_detector = {
            enabled = true,
            auto_detect = true,
            show_notification = true,
            cache_results = true,
          },
        },
        log_level = "info",
      })
    end,

    -- Keymaps for testing
    keys = {
      { "<leader>si", "<cmd>SwiftProjectInfo<cr>", desc = "Swift project info" },
      { "<leader>sd", "<cmd>SwiftDetectProject<cr>", desc = "Detect Swift project" },
      { "<leader>sI", "<cmd>SwiftInfo<cr>", desc = "Swift plugin info" },
      { "<leader>sh", "<cmd>checkhealth swift<cr>", desc = "Swift health check" },
    },
  },
}
