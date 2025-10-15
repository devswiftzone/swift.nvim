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
    build_runner = {
      enabled = true,
      auto_save = true,            -- Save all files before building
      show_output = true,          -- Show output in split window
      output_position = "botright", -- Position of output window
      output_height = 15,          -- Height of output window
      close_on_success = false,    -- Auto-close on successful build
      focus_on_open = false,       -- Focus output window when opened
    },
    lsp = {
      enabled = true,
      auto_setup = true,           -- Automatically setup LSP
      sourcekit_path = nil,        -- Auto-detect
      inlay_hints = true,          -- Enable inlay hints
      semantic_tokens = true,      -- Enable semantic tokens
      on_attach = nil,             -- Custom on_attach
      capabilities = nil,          -- Custom capabilities
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

### Build Runner

Build, run, and test Swift Package Manager projects directly from Neovim.

**Features:**
- Build Swift packages with debug/release configurations
- Run Swift executables with custom arguments
- Execute tests with filtering support
- Clean build artifacts
- Live output in split window
- Auto-save before building

**Commands:**
- `:SwiftBuild [debug|release]` - Build the Swift package
- `:SwiftRun [args]` - Run the Swift package
- `:SwiftTest [args]` - Run Swift tests
- `:SwiftClean` - Clean build artifacts
- `:SwiftBuildClose` - Close build output window

**Configuration:**
```lua
features = {
  build_runner = {
    enabled = true,
    auto_save = true,              -- Save all files before building
    show_output = true,            -- Show output in split window
    output_position = "botright",  -- Position: botright, belowright, etc
    output_height = 15,            -- Height of output window
    close_on_success = false,      -- Auto-close on successful build
    focus_on_open = false,         -- Focus output window when opened
  },
}
```

**Keybindings (example):**
```lua
keys = {
  { "<leader>sb", "<cmd>SwiftBuild<cr>", desc = "Swift build" },
  { "<leader>sr", "<cmd>SwiftRun<cr>", desc = "Swift run" },
  { "<leader>st", "<cmd>SwiftTest<cr>", desc = "Swift test" },
  { "<leader>sc", "<cmd>SwiftClean<cr>", desc = "Swift clean" },
}
```

### LSP Integration

Automatic configuration of sourcekit-lsp for full language server support.

**Features:**
- Auto-detection of sourcekit-lsp from Xcode or Swift toolchain
- Automatic LSP client setup with nvim-lspconfig
- Code completion, diagnostics, hover documentation
- Go to definition, find references, implementations
- Code actions and refactoring
- Inlay hints support
- Semantic tokens for better syntax highlighting
- Integration with nvim-cmp for completions

**Configuration:**
```lua
features = {
  lsp = {
    enabled = true,
    auto_setup = true,              -- Automatically setup LSP
    sourcekit_path = nil,           -- Auto-detect if nil
    inlay_hints = true,             -- Enable inlay hints
    semantic_tokens = true,         -- Enable semantic highlighting
    on_attach = nil,                -- Custom on_attach function
    capabilities = nil,             -- Custom capabilities
    cmd = nil,                      -- Custom command
    root_dir = nil,                 -- Custom root_dir function
    filetypes = { "swift" },
    settings = {},
  },
}
```

**Default Keybindings:**
- `gd` - Go to definition
- `gD` - Go to declaration
- `K` - Hover documentation
- `gi` - Go to implementation
- `gr` - Find references
- `<C-k>` - Signature help
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>f` - Format document
- `[d` / `]d` - Previous/next diagnostic
- `<leader>e` - Show diagnostic float
- `<leader>q` - Diagnostics quickfix list

**Customization:**
```lua
features = {
  lsp = {
    enabled = true,
    on_attach = function(client, bufnr)
      -- Your custom on_attach logic
      print("LSP attached to buffer " .. bufnr)
    end,
  },
}
```

**Requirements:**
- `nvim-lspconfig` - LSP configuration
- `sourcekit-lsp` - Swift LSP server (comes with Xcode or Swift toolchain)
- `nvim-cmp` (optional) - For better completions

## Commands

- `:SwiftInfo` - Show plugin information and current configuration
- `:SwiftDetectProject` - Detect and show Swift project type
- `:SwiftProjectInfo` - Show current Swift project information
- `:SwiftBuild [debug|release]` - Build Swift package
- `:SwiftRun [args]` - Run Swift package
- `:SwiftTest [args]` - Run Swift tests
- `:SwiftClean` - Clean build artifacts
- `:SwiftBuildClose` - Close build output window

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
