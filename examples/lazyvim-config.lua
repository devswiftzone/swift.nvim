-- Example configuration for LazyVim
-- Place this file in: ~/.config/nvim/lua/plugins/swift.lua

return {
  -- Swift.nvim plugin
  {
    "devswiftzone/swift.nvim",

    -- Lazy loading strategies (choose one):

    -- Option 1: Load when opening Swift files (recommended)
    ft = "swift",

    -- Option 2: Load on specific events
    -- event = { "BufReadPre *.swift", "BufNewFile *.swift" },

    -- Option 3: Load after UI is ready
    -- event = "VeryLazy",

    -- Configuration
    opts = {
      features = {
        project_detector = {
          enabled = true,
          auto_detect = true,
          show_notification = true,
          cache_results = true,
        },
      },
    },

    -- Keymaps (optional)
    keys = {
      { "<leader>si", "<cmd>SwiftProjectInfo<cr>", desc = "Swift project info" },
      { "<leader>sd", "<cmd>SwiftDetectProject<cr>", desc = "Detect Swift project" },
      { "<leader>sI", "<cmd>SwiftInfo<cr>", desc = "Swift plugin info" },
    },
  },

  -- Optional: Configure which-key for Swift keybindings
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>s", group = "swift" },
      },
    },
  },

  -- Optional: Configure LSP for Swift with project detection
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.sourcekit = {
        cmd = { "sourcekit-lsp" },
        filetypes = { "swift", "objective-c", "objective-cpp" },
        root_dir = function(fname)
          local util = require("lspconfig.util")

          -- Try to get root from swift.nvim first
          local has_swift, detector = pcall(require, "swift.features.project_detector")
          if has_swift then
            local root = detector.get_project_root()
            if root then
              return root
            end
          end

          -- Fallback to default root detection
          return util.root_pattern("Package.swift", "*.xcodeproj", "*.xcworkspace")(fname)
            or util.find_git_ancestor(fname)
            or vim.fn.fnamemodify(fname, ":h")
        end,
      }
    end,
  },

  -- Optional: Configure nvim-treesitter for Swift
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "swift" })
      end
    end,
  },

  -- Optional: Configure conform.nvim for Swift formatting
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },

  -- Optional: Configure nvim-lint for Swift
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },
}
