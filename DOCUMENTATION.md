# 📘 Swift.nvim - Complete Documentation

> A comprehensive, dependency-free Neovim plugin for Swift development with integrated LLDB debugger, LSP, build tools, formatting, and more.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📋 Table of Contents

1. [Overview](#-overview)
2. [Key Features](#-key-features)
3. [Requirements](#-requirements)
4. [Quick Start](#-quick-start)
5. [Installation](#-installation)
6. [Configuration](#-configuration)
7. [Features Guide](#-features-guide)
8. [Commands Reference](#-commands-reference)
9. [Keybindings](#-keybindings)
10. [Workflows](#-workflows)
11. [Troubleshooting](#-troubleshooting)
12. [FAQ](#-faq)
13. [Advanced Topics](#-advanced-topics)

---

## 🎯 Overview

**swift.nvim** is a complete Swift development environment for Neovim that requires **zero external dependencies** for debugging. Unlike other solutions, it integrates directly with LLDB (included with Swift toolchain), eliminating the need for nvim-dap and complex plugin setups.

### What Makes It Different?

- ✅ **Direct LLDB Integration** - No nvim-dap required
- ✅ **Zero Debug Dependencies** - Just Swift toolchain + Neovim
- ✅ **Visual Debugging** - Breakpoint indicators (●) and current line markers (➤)
- ✅ **Test Support** - Debug both executables and .xctest bundles
- ✅ **All-in-One** - LSP, formatter, linter, build system, and debugger in one plugin

### Philosophy

This plugin follows these principles:
- **Simplicity** - Minimal configuration for maximum functionality
- **Integration** - Works seamlessly with existing Neovim plugins
- **No Overhead** - Only loads what you need
- **Swift-First** - Built specifically for Swift development

---

## ✨ Key Features

### 🐛 Debugger (Direct LLDB Integration)
- Interactive debugging with breakpoints, stepping, and variable inspection
- **No nvim-dap dependency** - Direct LLDB integration
- Visual breakpoint indicators and current line highlighting
- Debug executables and test targets (.xctest bundles)
- Configurable debug output window (bottom, right, or floating)
- Custom LLDB command support
- Runs from project root with correct working directory

### 🔍 Project Detection
- Auto-detects Swift Package Manager (SPM) projects
- Auto-detects Xcode projects and workspaces
- Project-aware commands and features

### 🧠 LSP Integration
- Automatic sourcekit-lsp configuration
- Works with nvim-lspconfig
- Code completion, go-to-definition, hover, and more
- Integration with nvim-cmp for enhanced completions

### 🎯 Target Manager
- List and select executable and test targets
- Display current target in statusline
- Auto-detect target types (executable, library, test)

### 🔨 Build System
- Build, run, and test Swift packages
- Live build output in separate window
- Support for debug and release configurations
- Clean build artifacts

### 💅 Code Formatting
- Support for swift-format (Apple's official formatter)
- Support for swiftformat (community formatter)
- Format entire files or selections
- Auto-format on save (optional)

### 🔍 Linting
- SwiftLint integration
- Auto-lint on save
- Quick fix support
- Configurable severity levels

### 📝 Snippets
- 50+ built-in Swift snippets
- Works with LuaSnip
- Categories: structures, functions, control flow, SwiftUI, testing

### 🍎 Xcode Integration (macOS)
- Build Xcode projects with xcodebuild
- List and select schemes
- Open project in Xcode.app

### ✅ Version Validation
- Validate Swift toolchain version
- Check .swift-version compatibility
- Validate formatter and tool versions

---

## 📦 Requirements

### Required

| Tool | Minimum Version | Purpose | Install |
|------|----------------|---------|---------|
| **Neovim** | >= 0.8.0 | Editor | [neovim.io](https://neovim.io) |
| **Swift** | Any version | Development & LLDB | See below |

### Optional (Recommended)

| Tool | Purpose | Install |
|------|---------|---------|
| **nvim-lspconfig** | LSP auto-configuration | Plugin manager |
| **nvim-cmp** | Better completions | Plugin manager |
| **LuaSnip** | Snippets engine | Plugin manager |
| **swift-format** | Code formatting | `brew install swift-format` |
| **swiftformat** | Alternative formatter | `brew install swiftformat` |
| **SwiftLint** | Linting | `brew install swiftlint` |
| **lualine.nvim** | Statusline integration | Plugin manager |

### Installing Swift Toolchain

#### macOS
```bash
# Option 1: Xcode (includes everything)
xcode-select --install

# Option 2: Swift toolchain only
# Download from: https://swift.org/download/

# Option 3: swiftly (version manager - recommended)
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash
swiftly install latest
```

#### Linux
```bash
# Using swiftly (recommended)
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash
swiftly install latest

# Or download from: https://swift.org/download/
```

### Verify Installation

```bash
swift --version              # Swift compiler
lldb --version              # Debugger (comes with Swift)
sourcekit-lsp --version     # LSP (comes with Swift)
```

---

## ⚡ Quick Start

Get up and running in 3 steps:

### Step 1: Install Plugin

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = {},  -- Use defaults
}
```

### Step 2: Restart Neovim

```bash
nvim  # Plugin will auto-install on first Swift file
```

### Step 3: Verify Installation

```vim
:checkhealth swift
```

You should see:
- ✓ LLDB found
- ✓ Swift debugging is configured
- ✓ Plugin loaded successfully

### Try It Out (30 seconds)

```vim
" 1. Open a Swift file
nvim main.swift

" 2. Set a breakpoint
:10        " Go to line 10
<F9>       " Toggle breakpoint (you'll see ●)

" 3. Build and debug
:SwiftBuildAndDebug

" 4. Navigate
<F10>      " Step over
<F11>      " Step into
<F5>       " Continue
:SwiftDebugVariables  " Show variables
```

---

## 🚀 Installation

### Minimal Configuration (Recommended for Beginners)

Just the essentials - everything works with defaults:

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  "devswiftzone/swift.nvim",
  ft = "swift",  -- Load only for Swift files
  opts = {},     -- Use all defaults
  config = function(_, opts)
    require("swift").setup(opts)

    -- Essential keybindings
    local debugger = require("swift.features.debugger")

    -- Debugger (F keys)
    vim.keymap.set("n", "<F5>", debugger.continue, { desc = "Debug: Continue" })
    vim.keymap.set("n", "<F9>", debugger.toggle_breakpoint, { desc = "Debug: Breakpoint" })
    vim.keymap.set("n", "<F10>", debugger.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<F11>", debugger.step_into, { desc = "Debug: Step Into" })

    -- Build
    vim.keymap.set("n", "<leader>bb", ":SwiftBuild<CR>", { desc = "Build" })
    vim.keymap.set("n", "<leader>br", ":SwiftRun<CR>", { desc = "Run" })
    vim.keymap.set("n", "<leader>bt", ":SwiftTest<CR>", { desc = "Test" })

    -- Format & Lint
    vim.keymap.set("n", "<leader>sf", ":SwiftFormat<CR>", { desc = "Format" })
    vim.keymap.set("n", "<leader>sl", ":SwiftLint<CR>", { desc = "Lint" })
  end,
}
```

### Full Configuration (Advanced Users)

Complete control over all features:

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = {
    features = {
      -- LSP Configuration
      lsp = {
        enabled = true,
        auto_setup = true,
        sourcekit_path = nil,  -- Auto-detect
        on_attach = function(client, bufnr)
          -- Custom LSP keybindings
          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      },

      -- Formatter Configuration
      formatter = {
        enabled = true,
        auto_format = false,  -- Set to true for format on save
        tool = "swift-format",  -- or "swiftformat"
        swift_format = {
          path = nil,  -- Auto-detect
          args = {},
          config_file = nil,  -- Auto-find .swift-format
        },
      },

      -- Linter Configuration
      linter = {
        enabled = true,
        auto_lint = true,  -- Lint on save
        swiftlint_path = nil,  -- Auto-detect
        config_file = nil,  -- Auto-find .swiftlint.yml
        severity = "warning",
      },

      -- Build Runner Configuration
      build_runner = {
        enabled = true,
        show_output = true,
        output_position = "botright",
        output_height = 15,
        auto_close_on_success = false,
      },

      -- Target Manager Configuration
      target_manager = {
        enabled = true,
        auto_select = true,  -- Auto-select first executable target
        show_type = true,    -- Show target type
      },

      -- Debugger Configuration (No nvim-dap needed!)
      debugger = {
        enabled = true,
        lldb_path = nil,  -- Auto-detect LLDB

        -- Visual indicators
        signs = {
          breakpoint = "●",      -- Breakpoint symbol
          current_line = "➤",    -- Current line symbol
        },

        -- Colors (using Neovim highlight groups)
        colors = {
          breakpoint = "DiagnosticError",    -- Red
          current_line = "DiagnosticInfo",   -- Blue
        },

        -- Debug output window
        window = {
          position = "bottom",  -- "bottom", "right", or "float"
          size = 15,           -- Height for bottom, width for right
        },
      },

      -- Snippets Configuration
      snippets = {
        enabled = true,  -- Requires LuaSnip
      },

      -- Xcode Integration (macOS only)
      xcode = {
        enabled = vim.fn.has("mac") == 1,
        default_scheme = nil,
        default_simulator = nil,
        show_output = true,
        output_position = "botright",
        output_height = 15,
      },

      -- Project Detection
      project_detector = {
        enabled = true,
      },

      -- Version Validation
      version_validator = {
        enabled = true,
        show_warnings = true,
      },
    },

    -- Logging
    log_level = "info",  -- "debug", "info", "warn", "error"
  },

  config = function(_, opts)
    require("swift").setup(opts)

    -- ============================================================================
    -- DEBUGGER KEYBINDINGS
    -- ============================================================================

    local debugger = require("swift.features.debugger")

    -- F keys (standard debugger keys)
    vim.keymap.set("n", "<F5>", debugger.continue, { desc = "Debug: Continue" })
    vim.keymap.set("n", "<F9>", debugger.toggle_breakpoint, { desc = "Debug: Breakpoint" })
    vim.keymap.set("n", "<F10>", debugger.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<F11>", debugger.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set("n", "<F12>", debugger.step_out, { desc = "Debug: Step Out" })

    -- <leader>d for debug commands
    vim.keymap.set("n", "<leader>db", debugger.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>dB", debugger.clear_breakpoints, { desc = "Debug: Clear All" })
    vim.keymap.set("n", "<leader>dc", debugger.continue, { desc = "Debug: Continue" })
    vim.keymap.set("n", "<leader>ds", debugger.stop, { desc = "Debug: Stop" })
    vim.keymap.set("n", "<leader>dr", debugger.run, { desc = "Debug: Run" })
    vim.keymap.set("n", "<leader>dv", debugger.show_variables, { desc = "Debug: Variables" })
    vim.keymap.set("n", "<leader>dt", debugger.show_backtrace, { desc = "Debug: Backtrace" })
    vim.keymap.set("n", "<leader>du", ":SwiftDebugUI<CR>", { desc = "Debug: Toggle UI" })

    -- ============================================================================
    -- BUILD KEYBINDINGS
    -- ============================================================================

    vim.keymap.set("n", "<leader>bb", ":SwiftBuild<CR>", { desc = "Swift: Build" })
    vim.keymap.set("n", "<leader>br", ":SwiftRun<CR>", { desc = "Swift: Run" })
    vim.keymap.set("n", "<leader>bt", ":SwiftTest<CR>", { desc = "Swift: Test" })
    vim.keymap.set("n", "<leader>bc", ":SwiftClean<CR>", { desc = "Swift: Clean" })

    -- ============================================================================
    -- FORMAT & LINT KEYBINDINGS
    -- ============================================================================

    vim.keymap.set("n", "<leader>sf", ":SwiftFormat<CR>", { desc = "Swift: Format" })
    vim.keymap.set("v", "<leader>sf", ":SwiftFormatSelection<CR>", { desc = "Swift: Format Selection" })
    vim.keymap.set("n", "<leader>sl", ":SwiftLint<CR>", { desc = "Swift: Lint" })
    vim.keymap.set("n", "<leader>sL", ":SwiftLintFix<CR>", { desc = "Swift: Lint Fix" })

    -- ============================================================================
    -- TARGET KEYBINDINGS
    -- ============================================================================

    vim.keymap.set("n", "<leader>st", ":SwiftTarget<CR>", { desc = "Swift: Select Target" })
    vim.keymap.set("n", "<leader>sT", ":SwiftTargetList<CR>", { desc = "Swift: List Targets" })

    -- ============================================================================
    -- SNIPPETS KEYBINDINGS
    -- ============================================================================

    vim.keymap.set("n", "<leader>ss", ":SwiftSnippets<CR>", { desc = "Swift: Snippets" })

    -- ============================================================================
    -- XCODE KEYBINDINGS (macOS only)
    -- ============================================================================

    if vim.fn.has("mac") == 1 then
      vim.keymap.set("n", "<leader>xb", ":SwiftXcodeBuild<CR>", { desc = "Xcode: Build" })
      vim.keymap.set("n", "<leader>xs", ":SwiftXcodeSchemes<CR>", { desc = "Xcode: Schemes" })
      vim.keymap.set("n", "<leader>xo", ":SwiftXcodeOpen<CR>", { desc = "Xcode: Open" })
    end

    -- ============================================================================
    -- INFO & UTILS KEYBINDINGS
    -- ============================================================================

    vim.keymap.set("n", "<leader>si", ":SwiftInfo<CR>", { desc = "Swift: Info" })
    vim.keymap.set("n", "<leader>sv", ":SwiftVersionInfo<CR>", { desc = "Swift: Version" })
    vim.keymap.set("n", "<leader>sh", ":checkhealth swift<CR>", { desc = "Swift: Health" })

    -- ============================================================================
    -- AUTOCOMMANDS (Optional)
    -- ============================================================================

    local augroup = vim.api.nvim_create_augroup("SwiftNvim", { clear = true })

    -- Auto-format on save (uncomment to enable)
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   group = augroup,
    --   pattern = "*.swift",
    --   callback = function()
    --     vim.cmd("SwiftFormat")
    --   end,
    --   desc = "Auto-format Swift files on save",
    -- })

    -- ============================================================================
    -- STATUSLINE INTEGRATION (lualine example)
    -- ============================================================================

    -- If you use lualine, add this to show current target:
    -- require('lualine').setup({
    --   sections = {
    --     lualine_x = {
    --       function()
    --         local ok, target_manager = pcall(require, "swift.features.target_manager")
    --         if ok then
    --           local target = target_manager.get_current_target()
    --           if target then
    --             return "🎯 " .. target
    --           end
    --         end
    --         return ""
    --       end,
    --     },
    --   },
    -- })
  end,
}
```

---

## ⚙️ Configuration

### Feature Configuration

Each feature can be individually enabled/disabled and configured:

#### LSP Configuration

```lua
features = {
  lsp = {
    enabled = true,
    auto_setup = true,              -- Auto-configure sourcekit-lsp
    sourcekit_path = nil,            -- nil = auto-detect
    capabilities = nil,              -- Auto-configured if nvim-cmp is present
    on_attach = function(client, bufnr)
      -- Your custom LSP keybindings here
    end,
  },
}
```

#### Formatter Configuration

```lua
features = {
  formatter = {
    enabled = true,
    auto_format = false,             -- true = format on save
    tool = "swift-format",           -- "swift-format" or "swiftformat"

    swift_format = {
      path = nil,                    -- nil = auto-detect
      args = {},                     -- Additional arguments
      config_file = nil,             -- nil = auto-find .swift-format
    },

    swiftformat = {
      path = nil,
      args = {},
      config_file = nil,             -- nil = auto-find .swiftformat
    },
  },
}
```

#### Linter Configuration

```lua
features = {
  linter = {
    enabled = true,
    auto_lint = true,                -- Lint on save
    swiftlint_path = nil,            -- nil = auto-detect
    config_file = nil,               -- nil = auto-find .swiftlint.yml
    severity = "warning",            -- "error" or "warning"
  },
}
```

#### Debugger Configuration

```lua
features = {
  debugger = {
    enabled = true,
    lldb_path = nil,                 -- nil = auto-detect

    -- Visual indicators
    signs = {
      breakpoint = "●",              -- Breakpoint symbol
      current_line = "➤",            -- Current line symbol
    },

    -- Colors (Neovim highlight groups)
    colors = {
      breakpoint = "DiagnosticError",
      current_line = "DiagnosticInfo",
    },

    -- Debug output window
    window = {
      position = "bottom",           -- "bottom", "right", "float"
      size = 15,                     -- Height/width depending on position
    },
  },
}
```

#### Build Runner Configuration

```lua
features = {
  build_runner = {
    enabled = true,
    show_output = true,
    output_position = "botright",    -- Window position
    output_height = 15,              -- Window height
    auto_close_on_success = false,   -- Auto-close on successful build
  },
}
```

#### Target Manager Configuration

```lua
features = {
  target_manager = {
    enabled = true,
    auto_select = true,              -- Auto-select first executable
    show_type = true,                -- Show target type
  },
}
```

### Global Configuration

```lua
opts = {
  log_level = "info",  -- "debug", "info", "warn", "error"
  -- log_file = vim.fn.stdpath("cache") .. "/swift.nvim.log",  -- Custom log file
}
```

---

## 🎯 Features Guide

### 1. Debugger (Direct LLDB Integration)

The debugger integrates directly with LLDB without requiring nvim-dap or any other plugins.

#### Key Features

- ✅ **Zero Dependencies** - Just LLDB (included with Swift toolchain)
- ✅ **Visual Indicators** - Breakpoints (●) and current line (➤)
- ✅ **Test Support** - Debug .xctest bundles
- ✅ **Correct Working Directory** - LLDB runs from project root
- ✅ **Custom Commands** - Send any LLDB command

#### Basic Usage

**Starting a Debug Session:**

```vim
" 1. Select target (if multiple)
:SwiftTarget

" 2. Set breakpoints
:10        " Go to line 10
<F9>       " Toggle breakpoint (shows ●)

" 3. Build and debug
:SwiftBuildAndDebug

" When stopped at breakpoint:
<F10>      " Step over
<F11>      " Step into
<F12>      " Step out
<F5>       " Continue
```

**Debugging Tests:**

```vim
" 1. Select test target
:SwiftTarget    " Select MyAppTests

" 2. Set breakpoints in test file
<F9>           " Toggle breakpoint

" 3. Build and debug tests
:SwiftBuildAndDebugTests

" Navigate through test
<F10>          " Step through test
```

#### Debug Commands

| Command | Description | Keybinding |
|---------|-------------|------------|
| `:SwiftDebug` | Start debug session | - |
| `:SwiftBuildAndDebug` | Build and debug executable | - |
| `:SwiftBuildAndDebugTests` | Build and debug tests | - |
| `:SwiftDebugStop` | Stop debugging | `<leader>ds` |
| `:SwiftDebugContinue` | Continue execution | `<F5>` |
| `:SwiftDebugStepOver` | Step over | `<F10>` |
| `:SwiftDebugStepInto` | Step into | `<F11>` |
| `:SwiftDebugStepOut` | Step out | `<F12>` |
| `:SwiftBreakpointToggle` | Toggle breakpoint | `<F9>` |
| `:SwiftBreakpointClear` | Clear all breakpoints | `<leader>dB` |
| `:SwiftDebugVariables` | Show variables | `<leader>dv` |
| `:SwiftDebugBacktrace` | Show call stack | `<leader>dt` |
| `:SwiftDebugCommand <cmd>` | Send LLDB command | - |
| `:SwiftDebugUI` | Toggle debug window | `<leader>du` |

#### Custom LLDB Commands

You can send any LLDB command during a debug session:

```vim
" Print variable
:SwiftDebugCommand p myVariable

" Print object description
:SwiftDebugCommand po myObject

" View all local variables
:SwiftDebugCommand frame variable

" Backtrace
:SwiftDebugCommand bt

" Thread list
:SwiftDebugCommand thread list

" Evaluate expression
:SwiftDebugCommand expr myVar = 42
```

#### Visual Indicators

- **●** (Red) - Active breakpoint
- **➤** (Blue) - Current execution line
- **Highlighted line** - Current line during debugging

#### Debug Window Positions

```lua
-- Bottom (default)
window = { position = "bottom", size = 15 }

-- Right side
window = { position = "right", size = 50 }

-- Floating window
window = { position = "float", size = 20 }
```

### 2. LSP Integration

Automatic configuration of sourcekit-lsp with nvim-lspconfig.

#### Features

- Auto-detect sourcekit-lsp
- Code completion
- Go to definition/implementation/references
- Hover documentation
- Rename symbol
- Code actions
- Integration with nvim-cmp

#### Usage

LSP starts automatically when you open a Swift file. No configuration needed if nvim-lspconfig is installed.

**Default LSP Keybindings (if using Full Config):**

```
gd          - Go to definition
K           - Hover documentation
gi          - Go to implementation
gr          - Go to references
<leader>rn  - Rename symbol
<leader>ca  - Code actions
```

### 3. Build System

Build, run, test, and clean Swift packages.

#### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `:SwiftBuild` | Build in debug mode | `:SwiftBuild` |
| `:SwiftBuild release` | Build in release mode | `:SwiftBuild release` |
| `:SwiftRun` | Run executable | `:SwiftRun` |
| `:SwiftTest` | Run all tests | `:SwiftTest` |
| `:SwiftTest <name>` | Run specific test | `:SwiftTest MyTest` |
| `:SwiftClean` | Clean build artifacts | `:SwiftClean` |

#### Output Window

Build output appears in a separate window at the bottom (configurable).

```lua
build_runner = {
  show_output = true,           -- Show output window
  output_position = "botright", -- Position
  output_height = 15,           -- Height
  auto_close_on_success = false,-- Auto-close on success
}
```

### 4. Code Formatting

Support for both swift-format (Apple's official) and swiftformat (community).

#### Commands

| Command | Description |
|---------|-------------|
| `:SwiftFormat` | Format current file |
| `:SwiftFormatSelection` | Format visual selection |

#### Auto-format on Save

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.swift",
  callback = function()
    vim.cmd("SwiftFormat")
  end,
})
```

#### Choosing Formatter

```lua
formatter = {
  tool = "swift-format",  -- or "swiftformat"
}
```

### 5. Linting (SwiftLint)

SwiftLint integration with auto-fix support.

#### Commands

| Command | Description |
|---------|-------------|
| `:SwiftLint` | Lint current file |
| `:SwiftLintFix` | Lint and auto-fix |

#### Configuration

```lua
linter = {
  auto_lint = true,      -- Lint on save
  severity = "warning",  -- Show warnings (or "error")
}
```

### 6. Target Manager

List and select executable and test targets.

#### Commands

| Command | Description |
|---------|-------------|
| `:SwiftTarget` | Interactive target selector |
| `:SwiftTargetList` | List all targets |

#### Usage

```vim
:SwiftTarget
" Opens selector:
" > MyApp (executable)
"   MyLibrary (library)
"   MyAppTests (test)
```

#### Statusline Integration

Show current target in your statusline (lualine example):

```lua
require('lualine').setup({
  sections = {
    lualine_x = {
      function()
        local ok, tm = pcall(require, "swift.features.target_manager")
        if ok then
          local target = tm.get_current_target()
          return target and ("🎯 " .. target) or ""
        end
        return ""
      end,
    },
  },
})
```

### 7. Snippets

50+ built-in Swift snippets for common patterns.

#### Categories

- **Structures**: struct, class, enum, protocol, extension
- **Functions**: func, init, deinit, async, throws
- **Control Flow**: if, guard, switch, for, while
- **SwiftUI**: View, State, Binding, ObservableObject
- **Testing**: test, testCase, setUp, tearDown
- **And more...**

#### Usage

Requires LuaSnip installed. Snippets trigger automatically as you type.

```vim
:SwiftSnippets  " List all available snippets
```

### 8. Xcode Integration (macOS)

Build and manage Xcode projects from Neovim.

#### Commands

| Command | Description |
|---------|-------------|
| `:SwiftXcodeBuild` | Build with default scheme |
| `:SwiftXcodeBuild <scheme>` | Build with specific scheme |
| `:SwiftXcodeSchemes` | List/select schemes |
| `:SwiftXcodeOpen` | Open in Xcode.app |

### 9. Project Detection

Auto-detects project type and root directory.

Supported project types:
- Swift Package Manager (Package.swift)
- Xcode Projects (.xcodeproj)
- Xcode Workspaces (.xcworkspace)

No configuration needed - works automatically.

### 10. Version Validation

Validates Swift toolchain and tool versions.

#### Commands

```vim
:SwiftVersionInfo           " Show Swift version info
:SwiftValidateEnvironment   " Validate all tools
:checkhealth swift          " Complete health check
```

---

## 📝 Commands Reference

### Complete Command List

#### Build & Run

```vim
:SwiftBuild              " Build in debug mode
:SwiftBuild release      " Build in release mode
:SwiftRun                " Run executable
:SwiftTest               " Run all tests
:SwiftTest <name>        " Run specific test
:SwiftClean              " Clean build artifacts
```

#### Debugger

```vim
:SwiftDebug                 " Start debug session
:SwiftBuildAndDebug         " Build and debug executable
:SwiftBuildAndDebugTests    " Build and debug tests
:SwiftDebugStop             " Stop debugging
:SwiftDebugContinue         " Continue execution
:SwiftDebugStepOver         " Step over
:SwiftDebugStepInto         " Step into
:SwiftDebugStepOut          " Step out
:SwiftBreakpointToggle      " Toggle breakpoint at current line
:SwiftBreakpointClear       " Clear all breakpoints
:SwiftDebugVariables        " Show local variables
:SwiftDebugBacktrace        " Show call stack
:SwiftDebugCommand <cmd>    " Send custom LLDB command
:SwiftDebugUI               " Toggle debug output window
```

#### Format & Lint

```vim
:SwiftFormat             " Format current file
:SwiftFormatSelection    " Format visual selection
:SwiftLint               " Lint current file
:SwiftLintFix            " Lint and auto-fix
```

#### Targets

```vim
:SwiftTarget             " Select target interactively
:SwiftTargetList         " List all targets
```

#### Snippets

```vim
:SwiftSnippets           " List all available snippets
```

#### Xcode (macOS)

```vim
:SwiftXcodeBuild [scheme]   " Build Xcode project
:SwiftXcodeSchemes          " List/select schemes
:SwiftXcodeOpen             " Open in Xcode.app
```

#### Info & Utils

```vim
:SwiftInfo                  " Plugin information
:SwiftVersionInfo           " Swift version information
:SwiftValidateEnvironment   " Validate environment
```

---

## ⌨️ Keybindings

### Default Keybindings (Full Configuration)

#### Debugger (F keys)

```
F5   →  Continue/Run
F9   →  Toggle Breakpoint
F10  →  Step Over
F11  →  Step Into
F12  →  Step Out
```

#### Debugger (<leader>d)

```
<leader>db  →  Toggle Breakpoint
<leader>dB  →  Clear All Breakpoints
<leader>dc  →  Continue
<leader>ds  →  Stop Debugging
<leader>dr  →  Run
<leader>dv  →  Show Variables
<leader>dt  →  Show Backtrace
<leader>du  →  Toggle Debug UI
```

#### Build (<leader>b)

```
<leader>bb  →  Build
<leader>br  →  Run
<leader>bt  →  Test
<leader>bc  →  Clean
```

#### Format & Lint (<leader>s)

```
<leader>sf  →  Format File (or selection in visual mode)
<leader>sl  →  Lint
<leader>sL  →  Lint and Fix
```

#### Targets (<leader>st)

```
<leader>st  →  Select Target
<leader>sT  →  List Targets
```

#### Snippets

```
<leader>ss  →  List Snippets
```

#### Xcode (<leader>x) - macOS only

```
<leader>xb  →  Build with Xcode
<leader>xs  →  Select Scheme
<leader>xo  →  Open in Xcode.app
```

#### Info (<leader>s)

```
<leader>si  →  Plugin Info
<leader>sv  →  Version Info
<leader>sh  →  Health Check
```

### Custom Keybindings

You can customize all keybindings in your config:

```lua
config = function(_, opts)
  require("swift").setup(opts)

  local debugger = require("swift.features.debugger")

  -- Use your preferred keys
  vim.keymap.set("n", "<C-b>", debugger.toggle_breakpoint)
  vim.keymap.set("n", "<C-n>", debugger.step_over)
  -- etc...
end
```

---

## 🔄 Workflows

### Workflow 1: Basic Development

```vim
" 1. Build project
:SwiftBuild

" 2. Check for lint issues
:SwiftLint

" 3. Format code
:SwiftFormat

" 4. Run
:SwiftRun
```

### Workflow 2: Debugging an Executable

```vim
" 1. Select target (if multiple)
:SwiftTarget

" 2. Set breakpoints
<F9>  " On important lines

" 3. Build and debug
:SwiftBuildAndDebug

" 4. Navigate through code
<F10>         " Step over
<F11>         " Step into function
<leader>dv    " Inspect variables
<F5>          " Continue to next breakpoint

" 5. Stop when done
<leader>ds
```

### Workflow 3: Debugging Tests

```vim
" 1. Open test file
nvim Tests/MyAppTests.swift

" 2. Select test target
:SwiftTarget
" Choose: MyAppTests

" 3. Set breakpoint in test
<F9>

" 4. Build and debug tests
:SwiftBuildAndDebugTests

" 5. Step through test
<F10>  " Step over each line
```

### Workflow 4: Refactoring

```vim
" 1. Check current issues
:SwiftLint

" 2. Auto-fix what you can
:SwiftLintFix

" 3. Format code
:SwiftFormat

" 4. Run tests to verify
:SwiftTest

" 5. Build to confirm
:SwiftBuild
```

### Workflow 5: Release Build

```vim
" 1. Run tests
:SwiftTest

" 2. Check lint
:SwiftLint

" 3. Build release
:SwiftBuild release

" 4. Test release build manually
" (deploy/distribute)
```

---

## 🔧 Troubleshooting

### Common Issues

#### "Executable not found"

**Problem:** Can't find executable to debug

**Solution:**
```vim
" Build first
:SwiftBuild

" Make sure you selected the right target
:SwiftTarget
```

#### "LLDB not found"

**Problem:** LLDB debugger not detected

**Solution:**
```bash
# macOS - Install Xcode Command Line Tools
xcode-select --install

# Linux/macOS - Install Swift toolchain
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash
swiftly install latest

# Verify
lldb --version
```

#### Breakpoints Not Working

**Problem:** Breakpoints don't stop execution

**Possible causes:**
1. Not built in debug mode
2. Code not executed
3. LLDB not properly attached

**Solution:**
```vim
" 1. Build in debug mode
:SwiftBuild

" 2. Check breakpoint is set (you should see ●)
<F9>

" 3. Restart debug session
:SwiftDebugStop
:SwiftBuildAndDebug
```

#### LSP Not Working

**Problem:** No code completion or LSP features

**Solution:**
```bash
# 1. Check if sourcekit-lsp is installed
sourcekit-lsp --version

# 2. Check health
:checkhealth swift

# 3. Make sure nvim-lspconfig is installed
:Lazy  # Check if nvim-lspconfig is listed
```

#### Formatter Not Working

**Problem:** `:SwiftFormat` doesn't work

**Solution:**
```bash
# Install swift-format
brew install swift-format

# Or install swiftformat
brew install swiftformat

# Verify
swift-format --version
# or
swiftformat --version

# Check health
:checkhealth swift
```

#### Linter Not Working

**Problem:** `:SwiftLint` doesn't work

**Solution:**
```bash
# Install SwiftLint
brew install swiftlint

# Verify
swiftlint version

# Check health
:checkhealth swift
```

### Debug Logs

Enable debug logging to troubleshoot:

```lua
opts = {
  log_level = "debug",
}
```

Then check the log:
```vim
:SwiftInfo  " Shows log file location
```

### Health Check

Always run health check first:

```vim
:checkhealth swift
```

This will tell you:
- ✓ What's working
- ⚠ What needs attention
- ✗ What's broken

---

## ❓ FAQ

### General

**Q: Do I need nvim-dap for debugging?**
A: No! Swift.nvim uses LLDB directly. No nvim-dap needed.

**Q: Does it work on Linux?**
A: Yes! Just install the Swift toolchain.

**Q: What's the minimum Neovim version?**
A: Neovim >= 0.8.0

**Q: Do I need plenary.nvim?**
A: No, it's not required.

### Configuration

**Q: Can I use only some features?**
A: Yes! Disable features you don't want:

```lua
opts = {
  features = {
    debugger = { enabled = true },
    linter = { enabled = false },  -- Disable linter
    xcode = { enabled = false },   -- Disable Xcode integration
  },
}
```

**Q: Can I customize keybindings?**
A: Absolutely! Just modify the `config` function in your setup.

**Q: How do I change the debug window position?**
A: In your config:

```lua
debugger = {
  window = {
    position = "float",  -- "bottom", "right", or "float"
    size = 20,
  },
}
```

### Debugging

**Q: How do I debug tests?**
A:
```vim
:SwiftTarget              " Select test target (e.g., MyAppTests)
<F9>                      " Set breakpoints
:SwiftBuildAndDebugTests  " Build and debug
```

**Q: Can I send custom LLDB commands?**
A: Yes!
```vim
:SwiftDebugCommand p myVariable
:SwiftDebugCommand bt
:SwiftDebugCommand thread list
```

**Q: How do I see variables?**
A:
```vim
:SwiftDebugVariables
" Or
<leader>dv
```

**Q: Debug window doesn't close automatically**
A: Press `q` in the debug window, or use `:SwiftDebugUI` to toggle it.

### Building

**Q: How do I build for release?**
A: `:SwiftBuild release`

**Q: Can I run specific tests?**
A: Yes! `:SwiftTest MyTestName`

**Q: Build output window is too small**
A: Adjust in config:

```lua
build_runner = {
  output_height = 25,  -- Increase height
}
```

### LSP

**Q: Code completion doesn't work**
A: Make sure you have:
1. nvim-lspconfig installed
2. sourcekit-lsp installed (`swift --version`)
3. Run `:checkhealth swift`

**Q: How do I customize LSP keybindings?**
A: Use the `on_attach` callback:

```lua
lsp = {
  on_attach = function(client, bufnr)
    -- Your custom keybindings
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
  end,
}
```

### Integration

**Q: How do I show current target in statusline?**
A: See [Target Manager](#6-target-manager) section for lualine example.

**Q: Auto-format on save?**
A: Uncomment this in your config:

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.swift",
  callback = function()
    vim.cmd("SwiftFormat")
  end,
})
```

**Q: Can I use it with other Swift plugins?**
A: Yes! swift.nvim is designed to work alongside other plugins.

---

## 🚀 Advanced Topics

### Custom Debug Commands

Create aliases for frequently used LLDB commands:

```lua
vim.api.nvim_create_user_command("PrintSelf", function()
  vim.cmd("SwiftDebugCommand po self")
end, {})

vim.api.nvim_create_user_command("ListThreads", function()
  vim.cmd("SwiftDebugCommand thread list")
end, {})
```

### Conditional Breakpoints

While debugging:
```vim
:SwiftDebugCommand breakpoint modify -c 'myVar > 10'
```

### Debug Expression Evaluation

During debug session:
```vim
:SwiftDebugCommand expr myArray.count
:SwiftDebugCommand expr let newVar = 42
```

### Custom Formatter Configuration

Create `.swift-format` in project root:

```json
{
  "version": 1,
  "lineLength": 120,
  "indentation": {
    "spaces": 2
  },
  "respectsExistingLineBreaks": true
}
```

### Custom Linter Configuration

Create `.swiftlint.yml` in project root:

```yaml
disabled_rules:
  - line_length
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - force_unwrapping

line_length: 120

excluded:
  - Pods
  - .build
```

### Multiple Configurations

Different configs for different projects:

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = function()
    -- Check project type
    local cwd = vim.fn.getcwd()

    if cwd:match("MyiOSApp") then
      return {
        features = {
          xcode = { enabled = true },
          debugger = { window = { position = "float" } },
        },
      }
    else
      return {
        features = {
          xcode = { enabled = false },
        },
      }
    end
  end,
}
```

### Integration with Other Tools

#### With nvim-notify

```lua
-- In your config
vim.notify = require("notify")

-- swift.nvim will automatically use fancy notifications
```

#### With Telescope

```lua
-- Create custom picker for targets
local function pick_swift_target()
  local tm = require("swift.features.target_manager")
  local targets = tm.get_targets()

  require('telescope.pickers').new({}, {
    prompt_title = 'Swift Targets',
    finder = require('telescope.finders').new_table({
      results = targets,
      entry_maker = function(target)
        return {
          value = target,
          display = target.name .. " (" .. target.type .. ")",
          ordinal = target.name,
        }
      end,
    }),
    sorter = require('telescope.config').values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local actions = require('telescope.actions')
      actions.select_default:replace(function()
        local selection = require('telescope.actions.state').get_selected_entry()
        actions.close(prompt_bufnr)
        tm.set_target(selection.value.name)
      end)
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<leader>st', pick_swift_target)
```

### Performance Optimization

For large projects:

```lua
opts = {
  features = {
    lsp = {
      enabled = true,
      -- Limit LSP to current buffer for large projects
      flags = {
        debounce_text_changes = 150,
      },
    },
    linter = {
      auto_lint = false,  -- Manual lint only
    },
  },
}
```

---

## 📚 Additional Resources

### Documentation Files

This repository includes several configuration examples:

- **MINIMAL_CONFIG.lua** - Minimal setup (~30 lines)
- **FULL_CONFIG.lua** - Complete setup with all options (~450 lines)
- **examples/debugger-config.lua** - Debugger-specific example

### External Resources

- [Swift.org](https://swift.org) - Official Swift documentation
- [sourcekit-lsp](https://github.com/apple/sourcekit-lsp) - LSP implementation
- [SwiftLint](https://github.com/realm/SwiftLint) - Linter documentation
- [swift-format](https://github.com/apple/swift-format) - Formatter documentation

### Community

- Report bugs: [GitHub Issues](https://github.com/devswiftzone/swift.nvim/issues)
- Feature requests: [GitHub Discussions](https://github.com/devswiftzone/swift.nvim/discussions)

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Credits

Built with ❤️ for the Swift and Neovim communities.

Special thanks to:
- The Swift team for sourcekit-lsp and swift-format
- The Neovim team for an amazing editor
- All contributors and users

---

**swift.nvim** - Swift development in Neovim without compromises.

*Last updated: 2025*
