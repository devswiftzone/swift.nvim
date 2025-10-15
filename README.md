# swift.nvim

A comprehensive, modular Neovim plugin for Swift development with LSP, build tools, formatting, linting, and more.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Configuration](#-configuration)
- [Features Guide](#-features-guide)
  - [Project Detection](#1-project-detection)
  - [LSP Integration](#2-lsp-integration)
  - [Target Manager](#3-target-manager)
  - [Build Runner](#4-build-runner)
  - [Code Formatting](#5-code-formatting)
  - [Linting](#6-linting)
  - [Xcode Integration](#7-xcode-integration)
  - [Version Validation](#8-version-validation)
- [Commands Reference](#-commands-reference)
- [LuaLine Integration](#-lualine-integration)
- [Examples](#-examples)
- [Health Check](#-health-check)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

- **🔍 Smart Project Detection** - Auto-detects SPM, Xcode projects, and workspaces
- **🧠 LSP Integration** - Automatic sourcekit-lsp configuration with nvim-lspconfig
- **🎯 Target Management** - List, select, and display Swift targets in your statusline
- **🔨 Build System** - Build, run, and test Swift packages with live output
- **💅 Code Formatting** - Support for swift-format and swiftformat
- **🔍 Linting** - SwiftLint integration with auto-fix
- **🍎 Xcode Integration** - Build schemes, list targets, open in Xcode.app
- **✅ Version Validation** - Validate Swift versions and tool compatibility
- **📊 Health Checks** - Comprehensive :checkhealth integration

---

## 📦 Requirements

### Required

- **Neovim >= 0.8.0**
- **Swift toolchain** - For development, building, and LSP
- **nvim-lspconfig** - For LSP support

### Recommended

- **swiftly** - Swift version manager (highly recommended)
- **sourcekit-lsp** - Comes with Swift toolchain or Xcode

### Optional

- **Xcode Command Line Tools** - For Xcode project support (macOS)
- **swift-format** - Official Swift formatter from Apple
- **swiftformat** - Alternative Swift formatter
- **SwiftLint** - Swift linter for code quality
- **nvim-cmp** - For better code completions
- **LuaLine** - For statusline integration

### Quick Setup

```bash
# 1. Install swiftly (Swift version manager)
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash

# 2. Install Swift toolchain
swiftly install latest

# 3. Install formatters and linter (macOS)
brew install swift-format swiftformat swiftlint

# 4. Verify
swift --version
sourcekit-lsp --version
```

**📦 For detailed installation**, see [DEPENDENCIES.md](./DEPENDENCIES.md)

---

## 🚀 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (Recommended)

**For LazyVim users**, create `~/.config/nvim/lua/plugins/swift.lua`:

```lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {
      -- Your configuration here
    },
  },
}
```

**For other lazy.nvim setups:**

```lua
{
  "devswiftzone/swift.nvim",
  ft = "swift",
  config = function()
    require("swift").setup({
      -- Your configuration here
    })
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

### Local Development

```lua
{
  dir = "~/projects/nvim/swift.nvim",
  ft = "swift",
  config = function()
    require("swift").setup()
  end,
}
```

---

## 🎯 Quick Start

### 1. Install the plugin

Create `~/.config/nvim/lua/plugins/swift.lua`:

```lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {},  -- Uses default configuration
  },
}
```

### 2. Reload Neovim

```bash
# Restart Neovim or run:
:Lazy sync
```

### 3. Open a Swift project

```bash
cd your-swift-project
nvim Package.swift
# or
nvim Sources/main.swift
```

### 4. Verify installation

```vim
:checkhealth swift
```

You should see ✓ marks for loaded features.

---

## ⚙️ Configuration

### Default Configuration

```lua
require("swift").setup({
  enabled = true,

  features = {
    -- Project Detection
    project_detector = {
      enabled = true,
      auto_detect = true,          -- Auto-detect on buffer enter
      show_notification = true,    -- Show notification when project detected
      cache_results = true,        -- Cache detection results
    },

    -- LSP Integration
    lsp = {
      enabled = true,
      auto_setup = true,           -- Automatically setup LSP
      sourcekit_path = nil,        -- Auto-detect if nil
      inlay_hints = true,          -- Enable inlay hints
      semantic_tokens = true,      -- Enable semantic tokens
      on_attach = nil,             -- Custom on_attach function
      capabilities = nil,          -- Custom capabilities
      cmd = nil,                   -- Custom command
      root_dir = nil,              -- Custom root_dir function
      filetypes = { "swift" },
      settings = {},
    },

    -- Target Manager
    target_manager = {
      enabled = true,
      cache_timeout = 60,          -- Cache targets for 60 seconds
    },

    -- Build Runner
    build_runner = {
      enabled = true,
      auto_save = true,            -- Save all files before building
      show_output = true,          -- Show output in split window
      output_position = "botright", -- Position of output window
      output_height = 15,          -- Height of output window
      close_on_success = false,    -- Auto-close on successful build
      focus_on_open = false,       -- Focus output window when opened
    },

    -- Code Formatting
    formatter = {
      enabled = true,
      tool = nil,                  -- Auto-detect: "swift-format" | "swiftformat"
      format_on_save = false,      -- Format on save
      config_file = nil,           -- Auto-detect
    },

    -- Linting
    linter = {
      enabled = true,
      lint_on_save = true,         -- Lint on save
      auto_fix = false,            -- Auto-fix issues
      config_file = nil,           -- Auto-detect
    },

    -- Xcode Integration
    xcode = {
      enabled = true,
      default_scheme = nil,        -- Default scheme to build
      default_simulator = nil,     -- Default simulator
      show_output = true,          -- Show build output
      output_position = "botright",
      output_height = 15,
    },
  },

  log_level = "info",
})
```

### Common Configuration Examples

#### Minimal Setup (Recommended)

```lua
require("swift").setup()  -- Uses all defaults
```

#### Silent Mode

```lua
require("swift").setup({
  features = {
    project_detector = {
      show_notification = false,  -- Disable popup notifications
    },
  },
})
```

#### Format on Save

```lua
require("swift").setup({
  features = {
    formatter = {
      format_on_save = true,
      tool = "swift-format",  -- or "swiftformat"
    },
  },
})
```

#### Custom LSP Configuration

```lua
require("swift").setup({
  features = {
    lsp = {
      on_attach = function(client, bufnr)
        -- Your custom keybindings
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
      end,
    },
  },
})
```

---

## 📚 Features Guide

### 1. Project Detection

Automatically detects Swift projects in your workspace.

**Supports:**
- Swift Package Manager (Package.swift)
- Xcode Projects (*.xcodeproj)
- Xcode Workspaces (*.xcworkspace)

**Commands:**
```vim
:SwiftDetectProject    " Manually detect project type
:SwiftProjectInfo      " Show current project information
```

**API:**
```lua
local detector = require("swift.features.project_detector")

-- Check if we're in a Swift project
local is_project = detector.is_swift_project()

-- Get project root
local root = detector.get_project_root()

-- Get project type
local type = detector.get_project_type()  -- "spm" | "xcode_project" | "xcode_workspace" | "none"

-- Get full project info
local info = detector.get_project_info()
-- Returns: { type = "spm", root = "/path", manifest = "/path/Package.swift", ... }
```

**Configuration:**
```lua
features = {
  project_detector = {
    enabled = true,
    auto_detect = true,
    show_notification = true,
    cache_results = true,
  },
}
```

---

### 2. LSP Integration

Automatic configuration of sourcekit-lsp for full language server support.

**Features:**
- Auto-detection of sourcekit-lsp from Xcode or Swift toolchain
- Automatic LSP client setup with nvim-lspconfig
- Code completion, diagnostics, hover documentation
- Go to definition, find references, implementations
- Code actions and refactoring
- Inlay hints support
- Semantic tokens for better syntax highlighting

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

**Configuration:**
```lua
features = {
  lsp = {
    enabled = true,
    auto_setup = true,
    sourcekit_path = nil,        -- Auto-detect
    inlay_hints = true,
    semantic_tokens = true,
    on_attach = function(client, bufnr)
      -- Your custom logic
    end,
    capabilities = nil,
    settings = {},
  },
}
```

**Requirements:**
- nvim-lspconfig
- sourcekit-lsp (comes with Xcode or Swift toolchain)

---

### 3. Target Manager

Detect and manage Swift targets from Package.swift and Xcode projects.

**Features:**
- Parse targets from Package.swift (executable, library, test)
- Extract schemes and targets from Xcode projects
- Select active target with interactive picker
- Statusline integration (see LuaLine section)
- Cached results for performance

**Commands:**
```vim
:SwiftTargets          " List all available targets
:SwiftSelectTarget     " Select target with interactive picker
:SwiftCurrentTarget    " Show currently selected target
```

**API:**
```lua
local tm = require("swift.features.target_manager")

-- Get all targets
local targets = tm.get_targets()
-- Returns: { { name = "MyApp", type = "executable" }, ... }

-- Get target names only
local names = tm.get_target_names()
-- Returns: { "MyApp", "MyLibrary", "MyTests" }

-- Get executable targets only
local executables = tm.get_executable_targets()

-- Get/set current target
local current = tm.get_current_target()
tm.set_current_target("MyApp")

-- Get info for statusline
local info = tm.get_statusline_info()
-- Returns: { project_type = "spm", current_target = "MyApp", total_targets = 3 }

-- Get formatted parts for custom statusline
local parts = tm.get_lualine_parts()
-- Returns: { icon = "󰛥", target = "MyApp", project = "MyProject", count = 3, text = "..." }
```

**Configuration:**
```lua
features = {
  target_manager = {
    enabled = true,
    cache_timeout = 60,  -- Cache targets for 60 seconds
  },
}
```

---

### 4. Build Runner

Build, run, and test Swift Package Manager projects directly from Neovim.

**Features:**
- Build Swift packages with debug/release configurations
- Run Swift executables with custom arguments
- Execute tests with filtering support
- Clean build artifacts
- Live output in split window
- Auto-save before building

**Commands:**
```vim
:SwiftBuild [debug|release]   " Build the Swift package
:SwiftRun [args]              " Run the Swift package
:SwiftTest [args]             " Run Swift tests
:SwiftClean                   " Clean build artifacts
:SwiftBuildClose              " Close build output window
```

**Examples:**
```vim
:SwiftBuild              " Build in debug mode
:SwiftBuild release      " Build in release mode
:SwiftRun                " Run the executable
:SwiftRun --help         " Run with arguments
:SwiftTest               " Run all tests
:SwiftTest MyTestSuite   " Run specific test
```

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

**Keybindings Example:**
```lua
keys = {
  { "<leader>sb", "<cmd>SwiftBuild<cr>", desc = "Swift build" },
  { "<leader>sr", "<cmd>SwiftRun<cr>", desc = "Swift run" },
  { "<leader>st", "<cmd>SwiftTest<cr>", desc = "Swift test" },
  { "<leader>sc", "<cmd>SwiftClean<cr>", desc = "Swift clean" },
}
```

---

### 5. Code Formatting

Format Swift code using swift-format or swiftformat.

**Features:**
- Auto-detects swift-format and swiftformat
- Format on save option
- Format selection support
- Config file detection (.swift-format, .swiftformat)

**Commands:**
```vim
:SwiftFormat              " Format current file
:SwiftFormatSelection     " Format visual selection
```

**Configuration:**
```lua
features = {
  formatter = {
    enabled = true,
    tool = nil,              -- Auto-detect: "swift-format" | "swiftformat"
    format_on_save = false,  -- Enable to format on save
    config_file = nil,       -- Auto-detect .swift-format or .swiftformat
  },
}
```

**Format on Save:**
```lua
features = {
  formatter = {
    format_on_save = true,
    tool = "swift-format",  -- Force specific formatter
  },
}
```

---

### 6. Linting

SwiftLint integration with diagnostics and auto-fix.

**Features:**
- SwiftLint integration
- Lint on save with auto-fix option
- Diagnostic integration with LSP
- Config file detection (.swiftlint.yml)

**Commands:**
```vim
:SwiftLint        " Lint current file
:SwiftLintFix     " Auto-fix lint issues
```

**Configuration:**
```lua
features = {
  linter = {
    enabled = true,
    lint_on_save = true,   -- Lint automatically on save
    auto_fix = false,      -- Auto-fix issues on save
    config_file = nil,     -- Auto-detect .swiftlint.yml
  },
}
```

---

### 7. Xcode Integration

Build and manage Xcode projects from Neovim.

**Features:**
- Build Xcode projects with xcodebuild
- List and select schemes
- Open in Xcode.app
- Live build output

**Commands:**
```vim
:SwiftXcodeBuild [scheme]   " Build Xcode project
:SwiftXcodeSchemes          " List available schemes
:SwiftXcodeOpen             " Open project in Xcode.app
```

**Configuration:**
```lua
features = {
  xcode = {
    enabled = true,
    default_scheme = nil,        -- Default scheme to build
    default_simulator = nil,     -- Default simulator
    show_output = true,
    output_position = "botright",
    output_height = 15,
  },
}
```

**Note:** Xcode integration requires macOS and Xcode Command Line Tools.

---

### 8. Version Validation

Validate Swift versions and tool compatibility.

**Features:**
- Check .swift-version file against installed Swift
- List swiftly installed versions
- Validate swift-format compatibility with Swift toolchain
- Detailed validation reports

**Commands:**
```vim
:SwiftValidateEnvironment   " Full environment validation
:SwiftVersionInfo           " Quick version information
```

**Example Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Swift Environment Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ .swift-version file: /path/to/.swift-version
  Required version: 6.2

✓ Installed Swift: 6.2.0

✓ Version matches requirement

✓ swiftly is available
  Installed versions:
  → 6.2.0
    6.1.0

✓ swift-format is compatible
  Swift: 6.2.0
  swift-format: 6.2.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 📝 Commands Reference

### General
- `:SwiftInfo` - Show plugin information and configuration
- `:SwiftValidateEnvironment` - Validate Swift environment
- `:SwiftVersionInfo` - Show Swift version information

### Project
- `:SwiftDetectProject` - Detect and show Swift project type
- `:SwiftProjectInfo` - Show current project information

### Targets
- `:SwiftTargets` - List all Swift targets
- `:SwiftSelectTarget` - Select target with picker
- `:SwiftCurrentTarget` - Show current target

### Build/Run/Test
- `:SwiftBuild [debug|release]` - Build Swift package
- `:SwiftRun [args]` - Run Swift package
- `:SwiftTest [args]` - Run Swift tests
- `:SwiftClean` - Clean build artifacts
- `:SwiftBuildClose` - Close build output window

### Format/Lint
- `:SwiftFormat` - Format current file
- `:SwiftFormatSelection` - Format selection
- `:SwiftLint` - Lint current file
- `:SwiftLintFix` - Auto-fix lint issues

### Xcode (macOS only)
- `:SwiftXcodeBuild [scheme]` - Build Xcode project
- `:SwiftXcodeSchemes` - List available schemes
- `:SwiftXcodeOpen` - Open in Xcode.app

---

## 📊 LuaLine Integration

Display Swift targets in your statusline.

### Simple Integration

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      {
        function()
          local ok, tm = pcall(require, "swift.features.target_manager")
          if ok and vim.bo.filetype == "swift" then
            return tm.statusline_simple()
          end
          return ""
        end,
        icon = "󰛥",
        color = { fg = "#ff6b00" },  -- Swift orange
      },
      "encoding",
      "fileformat",
      "filetype",
    },
  },
})
```

### Detailed Integration

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      {
        function()
          local ok, tm = pcall(require, "swift.features.target_manager")
          if ok and vim.bo.filetype == "swift" then
            return tm.statusline_detailed()
          end
          return ""
        end,
        color = { fg = "#ff6b00" },
      },
      "encoding",
      "filetype",
    },
  },
})
```

### Custom Parts Integration

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      {
        function()
          local ok, tm = pcall(require, "swift.features.target_manager")
          if not ok or vim.bo.filetype ~= "swift" then
            return ""
          end

          local parts = tm.get_lualine_parts()
          if not parts then
            return ""
          end

          -- Customize how you display the parts
          return string.format("%s %s", parts.icon, parts.target)
        end,
        color = { fg = "#ff6b00" },
      },
      "filetype",
    },
  },
})
```

**For 10+ complete examples**, see [examples/lualine-integration.lua](./examples/lualine-integration.lua)

---

## 📖 Examples

See the `examples/` directory for complete configuration examples:

- **[minimal-config.lua](./examples/minimal-config.lua)** - Bare minimum setup
- **[lazyvim-config.lua](./examples/lazyvim-config.lua)** - Full LazyVim integration
- **[local-dev-config.lua](./examples/local-dev-config.lua)** - Plugin development setup
- **[advanced-config.lua](./examples/advanced-config.lua)** - Advanced usage with custom commands
- **[lualine-integration.lua](./examples/lualine-integration.lua)** - 10+ LuaLine statusline examples

---

## 🏥 Health Check

Run `:checkhealth swift` to verify the plugin is working correctly.

**Checks:**
- Plugin loaded successfully
- Configuration loaded
- All features status (enabled/disabled)
- Swift compiler installation
- Swift version and .swift-version file
- swiftly installation
- sourcekit-lsp availability
- swift-format/swiftformat compatibility
- SwiftLint installation
- Xcode tools (macOS)
- Target detection

**Example:**
```vim
:checkhealth swift
```

**Expected Output:**
```
swift.nvim
  ✓ Plugin loaded successfully
  ✓ Configuration loaded

Features
  ✓ Feature 'project_detector' is enabled
  ✓ Feature 'lsp' is enabled
  ✓ Feature 'target_manager' is enabled
  ...

Swift Compiler
  ✓ Swift compiler found
  ○ Version: 6.2.0

Target Manager
  ✓ Target manager available
  ✓ Found 2 target(s)
  ○ Current target: MyApp
  ○   executable: 1
  ○   test: 1
```

---

## 🔧 Troubleshooting

### Plugin not loading?

1. Check if installed:
   ```vim
   :Lazy
   ```

2. Check for errors:
   ```vim
   :messages
   ```

3. Reload plugin:
   ```vim
   :Lazy reload swift.nvim
   ```

### Project not detected?

1. Make sure you have one of these files:
   - `Package.swift`
   - `*.xcodeproj`
   - `*.xcworkspace`

2. Try manual detection:
   ```vim
   :SwiftDetectProject
   ```

3. Check filetype:
   ```vim
   :set filetype?
   ```
   Should show: `filetype=swift`

### Targets showing wrong names?

1. Clear cache and refresh:
   ```vim
   :lua vim.g.swift_current_target = nil
   :lua vim.b.swift_current_target = nil
   :SwiftTargets
   ```

2. Test `swift package dump-package`:
   ```bash
   cd your-project
   swift package dump-package
   ```

### LSP not working?

1. Check if sourcekit-lsp is available:
   ```bash
   which sourcekit-lsp
   sourcekit-lsp --version
   ```

2. Check LSP status:
   ```vim
   :LspInfo
   ```

3. Verify nvim-lspconfig is installed:
   ```vim
   :lua print(vim.inspect(require("lspconfig")))
   ```

### Version mismatch errors?

1. Run environment validation:
   ```vim
   :SwiftValidateEnvironment
   ```

2. Install required Swift version:
   ```bash
   swiftly install 6.2
   swiftly use 6.2
   ```

3. Update tools to match Swift version:
   ```bash
   brew upgrade swift-format
   ```

### Enable debug logging

```lua
require("swift").setup({
  log_level = "debug",
})
```

Then check messages:
```vim
:messages
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/devswiftzone/swift.nvim.git ~/projects/nvim/swift.nvim
   ```

2. Configure local plugin:
   ```lua
   {
     dir = "~/projects/nvim/swift.nvim",
     ft = "swift",
     config = function()
       require("swift").setup()
     end,
   }
   ```

3. Make changes and reload:
   ```vim
   :Lazy reload swift.nvim
   ```

### Adding a New Feature

1. Create feature file: `lua/swift/features/your_feature.lua`
2. Add configuration to `lua/swift/config.lua`
3. Load feature in `lua/swift/features/init.lua`
4. Add health check in `lua/swift/health.lua`
5. Update README and documentation

---

## 📄 License

MIT License - see [LICENSE](./LICENSE) file for details.

---

## 🔗 Links

- **Documentation**: [QUICKSTART.md](./QUICKSTART.md) | [DEPENDENCIES.md](./DEPENDENCIES.md) | [INSTALL.md](./INSTALL.md)
- **Repository**: https://github.com/devswiftzone/swift.nvim
- **Issues**: https://github.com/devswiftzone/swift.nvim/issues
- **Swift**: https://swift.org
- **swiftly**: https://github.com/swift-server/swiftly

---

**Made with ❤️ for the Swift community**
