# swift.nvim

A modular Neovim plugin for Swift development with automatic project detection and multiple features.

**⚡ Quick Start:** See [QUICKSTART.md](./QUICKSTART.md) for a 5-minute setup guide.

## Requirements

- Neovim >= 0.8.0
- Swift compiler (optional, for development)
- Xcode command line tools (optional, for Xcode project support on macOS)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (Recommended)

#### Option 1: Load on Swift files only (lazy loading)

```lua
{
  "devswiftzone/swift.nvim",
  ft = "swift",  -- Load when opening Swift files
  config = function()
    require("swift").setup({
      -- Your configuration here (optional)
    })
  end,
}
```

#### Option 2: Load on specific events (more flexible)

```lua
{
  "devswiftzone/swift.nvim",
  event = { "BufReadPre *.swift", "BufNewFile *.swift" },
  config = function()
    require("swift").setup()
  end,
}
```

#### Option 3: Load when entering a Swift project directory

```lua
{
  "devswiftzone/swift.nvim",
  event = "VeryLazy",  -- Load after UI is ready
  config = function()
    require("swift").setup({
      features = {
        project_detector = {
          enabled = true,
          auto_detect = true,
          show_notification = true,
        },
      },
    })
  end,
}
```

#### Option 4: Always load at startup (not recommended)

```lua
{
  "devswiftzone/swift.nvim",
  lazy = false,  -- Load immediately
  priority = 50, -- Load after default plugins
  config = function()
    require("swift").setup()
  end,
}
```

### For LazyVim Users

Create a file in `~/.config/nvim/lua/plugins/swift.lua`:

```lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
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
  },
}
```

### Local Development

If you're developing the plugin locally:

```lua
{
  dir = "~/projects/nvim/swift.nvim",  -- Path to your local plugin
  ft = "swift",
  config = function()
    require("swift").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "devswiftzone/swift.nvim",
  ft = "swift",
  config = function()
    require("swift").setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'devswiftzone/swift.nvim'

lua << EOF
require("swift").setup()
EOF
```

## Configuration

### Default Configuration

```lua
{
  enabled = true,
  features = {
    project_detector = {
      enabled = true,
      auto_detect = true,          -- Auto-detect on buffer enter
      show_notification = true,    -- Show notification when project detected
      cache_results = true,        -- Cache detection results
    },
    -- Add more features here as they are implemented
  },
  log_level = "info",
}
```

### Common Configuration Examples

#### Minimal setup (recommended)

```lua
require("swift").setup()  -- Uses all defaults
```

#### Silent mode (no notifications)

```lua
require("swift").setup({
  features = {
    project_detector = {
      show_notification = false,  -- Disable popup notifications
    },
  },
})
```

#### Manual detection only

```lua
require("swift").setup({
  features = {
    project_detector = {
      auto_detect = false,  -- Don't auto-detect, use :SwiftDetectProject instead
    },
  },
})
```

#### Disable project detection

```lua
require("swift").setup({
  features = {
    project_detector = {
      enabled = false,  -- Completely disable the feature
    },
  },
})
```

### Integration with Other Plugins

#### With nvim-lspconfig

```lua
{
  "devswiftzone/swift.nvim",
  ft = "swift",
  config = function()
    require("swift").setup()
  end,
}

-- In your LSP configuration
require("lspconfig").sourcekit.setup({
  root_dir = function()
    local detector = require("swift.features.project_detector")
    return detector.get_project_root() or vim.fn.getcwd()
  end,
})
```

#### With which-key.nvim

```lua
{
  "folke/which-key.nvim",
  opts = function(_, opts)
    opts.defaults["<leader>s"] = { name = "+swift" }
  end,
}
```

#### Complete LazyVim Example

Create `~/.config/nvim/lua/plugins/swift.lua`:

```lua
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

  -- Optional: Configure LSP for Swift
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          root_dir = function(fname)
            local detector = require("swift.features.project_detector")
            local root = detector.get_project_root()
            return root or vim.fn.fnamemodify(fname, ":h")
          end,
        },
      },
    },
  },
}
```

## Features

### Project Detector
Automatically detects Swift projects in your workspace. Supports:
- **Swift Package Manager** (Package.swift)
- **Xcode Projects** (*.xcodeproj)
- **Xcode Workspaces** (*.xcworkspace)

The detector searches upwards from the current file to find project markers.

**Commands:**
- `:SwiftDetectProject` - Manually detect project type
- `:SwiftProjectInfo` - Show current project information

**Buffer Variables:**
- `vim.b.swift_project_type` - Type of project detected
- `vim.b.swift_project_root` - Root directory of the project

**API:**
```lua
local detector = require("swift.features.project_detector")

-- Check if we're in a Swift project
local is_project = detector.is_swift_project()

-- Get project root
local root = detector.get_project_root()

-- Get project type
local type = detector.get_project_type()

-- Get full project info
local info = detector.get_project_info()
-- Returns: { type = "spm"|"xcode_project"|"xcode_workspace"|"none", root = "/path", ... }
```

## Commands

- `:SwiftInfo` - Show plugin information and current configuration
- `:SwiftDetectProject` - Detect and show Swift project type
- `:SwiftProjectInfo` - Show current Swift project information

## Health Check

Run `:checkhealth swift` to verify the plugin is working correctly.

## Quick Start

### 1. Install the plugin

For LazyVim, create `~/.config/nvim/lua/plugins/swift.lua`:

```lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {},
  },
}
```

### 2. Reload Neovim

Restart Neovim or run `:Lazy sync`

### 3. Open a Swift file

```bash
cd your-swift-project
nvim Package.swift
# or
nvim Sources/main.swift
```

The plugin will automatically detect your project type and notify you.

### 4. Try the commands

- `:SwiftProjectInfo` - See detected project information
- `:SwiftDetectProject` - Manually trigger project detection
- `:checkhealth swift` - Verify installation

## Usage Examples

### Check current project

```vim
:SwiftProjectInfo
```

Output:
```
Swift Project Information:
  Type: spm
  Root: /Users/you/projects/myapp
  Manifest: /Users/you/projects/myapp/Package.swift
```

### Use in Lua scripts

```lua
local detector = require("swift.features.project_detector")

if detector.is_swift_project() then
  local root = detector.get_project_root()
  local type = detector.get_project_type()

  print("Working in a " .. type .. " project at " .. root)
end
```

### Custom statusline integration

```lua
-- In your statusline configuration
local function swift_project_status()
  if vim.bo.filetype ~= "swift" then
    return ""
  end

  local ok, detector = pcall(require, "swift.features.project_detector")
  if not ok then
    return ""
  end

  local info = detector.get_project_info()
  if info.type == "none" then
    return ""
  end

  local icons = {
    spm = "󰛥 ",
    xcode_project = " ",
    xcode_workspace = " ",
  }

  local icon = icons[info.type] or ""
  local name = info.name or vim.fn.fnamemodify(info.root, ":t")

  return icon .. name
end
```

## Configuration Files

See the `examples/` directory for complete configuration examples:

- `minimal-config.lua` - Bare minimum setup
- `lazyvim-config.lua` - Full LazyVim integration with LSP, Treesitter, etc.
- `local-dev-config.lua` - Setup for plugin development
- `advanced-config.lua` - Advanced usage with custom commands and autocommands

## Development

### Adding a New Feature

1. Create a new file in `lua/swift/features/your_feature.lua`
2. Add the feature configuration to `lua/swift/config.lua` defaults
3. Load the feature in `lua/swift/features/init.lua`

Example feature structure:

```lua
local M = {}

function M.setup(opts)
  -- Initialize your feature
end

return M
```

## License

MIT
