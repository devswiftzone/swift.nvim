# Configuration Templates

Quick copy-paste templates for different use cases.

## Basic Templates

### LazyVim - Minimal (Recommended)

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {},
  },
}
```

### LazyVim - With Keybindings

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {},
    keys = {
      { "<leader>si", "<cmd>SwiftProjectInfo<cr>", desc = "Swift project info" },
      { "<leader>sd", "<cmd>SwiftDetectProject<cr>", desc = "Detect Swift project" },
    },
  },
}
```

### LazyVim - Silent Mode (No Notifications)

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {
      features = {
        project_detector = {
          show_notification = false,
        },
      },
    },
  },
}
```

## Integration Templates

### With LSP (sourcekit-lsp)

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  -- Swift plugin
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {},
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          root_dir = function(fname)
            local has_swift, detector = pcall(require, "swift.features.project_detector")
            if has_swift then
              local root = detector.get_project_root()
              if root then return root end
            end
            return vim.fn.fnamemodify(fname, ":h")
          end,
        },
      },
    },
  },
}
```

### Complete LazyVim Setup

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  -- Swift plugin
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {
      features = {
        project_detector = {
          enabled = true,
          auto_detect = true,
          show_notification = true,
        },
      },
    },
    keys = {
      { "<leader>si", "<cmd>SwiftProjectInfo<cr>", desc = "Swift project info" },
      { "<leader>sd", "<cmd>SwiftDetectProject<cr>", desc = "Detect Swift project" },
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {},
      },
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { "swift" })
    end,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },

  -- Linting
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
```

## Loading Strategies

### Load on Swift Files (Lazy - Recommended)

```lua
{
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = {},
}
```

### Load on Events

```lua
{
  "devswiftzone/swift.nvim",
  event = { "BufReadPre *.swift", "BufNewFile *.swift" },
  opts = {},
}
```

### Load After UI

```lua
{
  "devswiftzone/swift.nvim",
  event = "VeryLazy",
  opts = {},
}
```

### Load Immediately (Not Recommended)

```lua
{
  "devswiftzone/swift.nvim",
  lazy = false,
  priority = 50,
  opts = {},
}
```

## Development Templates

### Local Development

```lua
-- ~/.config/nvim/lua/plugins/swift-dev.lua
return {
  {
    dir = "~/projects/nvim/swift.nvim",
    lazy = false,
    config = function()
      require("swift").setup()
    end,
    keys = {
      { "<leader>sh", "<cmd>checkhealth swift<cr>", desc = "Swift health" },
    },
  },
}
```

### With Debug Logging

```lua
{
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = {
    log_level = "debug",
  },
  config = function(_, opts)
    require("swift").setup(opts)
    vim.notify("swift.nvim loaded", vim.log.levels.INFO)
  end,
}
```

## Other Plugin Managers

### Packer

```lua
use {
  "devswiftzone/swift.nvim",
  ft = "swift",
  config = function()
    require("swift").setup()
  end,
}
```

### Vim-Plug

```vim
Plug 'devswiftzone/swift.nvim'

lua << EOF
require("swift").setup()
EOF
```

## Feature-Specific Templates

### Manual Detection Only

```lua
{
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = {
    features = {
      project_detector = {
        auto_detect = false,
      },
    },
  },
}
```

### Disable Caching

```lua
{
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = {
    features = {
      project_detector = {
        cache_results = false,
      },
    },
  },
}
```

### Disable All Features

```lua
{
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = {
    features = {
      project_detector = { enabled = false },
      feature1 = { enabled = false },
      feature2 = { enabled = false },
    },
  },
}
```

## Tips

1. **Start minimal**: Use the basic template and add features as needed
2. **Use lazy loading**: Load on `ft = "swift"` for better startup time
3. **Check health**: Run `:checkhealth swift` after setup
4. **Customize keybindings**: Change `<leader>s*` to your preference
5. **Read examples**: Check the `examples/` directory for more ideas
