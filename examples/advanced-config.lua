-- Advanced configuration example with all features
-- Place this file in: ~/.config/nvim/lua/plugins/swift.lua

return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",

    opts = {
      enabled = true,
      features = {
        project_detector = {
          enabled = true,
          auto_detect = true,
          show_notification = true,
          cache_results = true,
        },
        -- Add more features here as they are implemented
      },
      log_level = "info",
    },

    keys = {
      -- Project detection
      { "<leader>si", "<cmd>SwiftProjectInfo<cr>", desc = "Swift project info" },
      { "<leader>sd", "<cmd>SwiftDetectProject<cr>", desc = "Detect Swift project" },

      -- Plugin info
      { "<leader>sI", "<cmd>SwiftInfo<cr>", desc = "Swift plugin info" },

      -- Health check
      { "<leader>sh", "<cmd>checkhealth swift<cr>", desc = "Swift health check" },

      -- Feature commands (examples)
      -- { "<leader>s1", "<cmd>SwiftFeature1<cr>", desc = "Feature 1" },
      -- { "<leader>s2", "<cmd>SwiftFeature2<cr>", desc = "Feature 2" },
    },

    -- Run after plugin is loaded
    config = function(_, opts)
      local swift = require("swift")
      swift.setup(opts)

      -- Custom autocommands
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.swift",
        callback = function()
          -- Your custom logic when entering a Swift file
          local detector = require("swift.features.project_detector")
          local info = detector.get_project_info()

          -- Set custom statusline, update UI, etc.
          if info.type ~= "none" then
            vim.b.swift_project_name = info.name or vim.fn.fnamemodify(info.root, ":t")
          end
        end,
      })

      -- Custom user commands
      vim.api.nvim_create_user_command("SwiftBuild", function()
        local detector = require("swift.features.project_detector")
        local info = detector.get_project_info()

        if info.type == "spm" then
          vim.cmd("!swift build")
        elseif info.type == "xcode_project" or info.type == "xcode_workspace" then
          print("Use xcodebuild for Xcode projects")
        else
          print("No Swift project detected")
        end
      end, { desc = "Build Swift project" })
    end,
  },
}
