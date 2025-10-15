# swift.nvim - Complete Configuration Guide

Comprehensive guide for configuring swift.nvim with all features.

## Table of Contents

- [Quick Start](#quick-start)
- [Basic Configuration](#basic-configuration)
- [Feature-by-Feature Configuration](#feature-by-feature-configuration)
- [Complete LazyVim Setup](#complete-lazyvim-setup)
- [Integration with Other Plugins](#integration-with-other-plugins)
- [Keybinding Examples](#keybinding-examples)
- [Troubleshooting](#troubleshooting)

## Quick Start

### Minimal Setup (Recommended for Beginners)

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {},  -- Uses all defaults
  },
}
```

This will enable all features with sensible defaults.

## Basic Configuration

### Configuration Structure

```lua
{
  enabled = true,
  features = {
    project_detector = { ... },
    build_runner = { ... },
    lsp = { ... },
    formatter = { ... },
    linter = { ... },
    xcode = { ... },
  },
  log_level = "info",
}
```

## Feature-by-Feature Configuration

### 1. Project Detector

Automatically detects Swift Package Manager, Xcode Projects, and Xcode Workspaces.

**Default Configuration:**
```lua
features = {
  project_detector = {
    enabled = true,
    auto_detect = true,          -- Detect on buffer enter
    show_notification = true,    -- Show notification when detected
    cache_results = true,        -- Cache for performance
  },
}
```

**Usage:**
```vim
:SwiftProjectInfo      " Show detected project info
:SwiftDetectProject    " Manually trigger detection
```

**API:**
```lua
local detector = require("swift.features.project_detector")

if detector.is_swift_project() then
  local root = detector.get_project_root()
  local type = detector.get_project_type()  -- "spm", "xcode_project", "xcode_workspace"
end
```

### 2. Build Runner

Build, run, and test Swift Package Manager projects.

**Default Configuration:**
```lua
features = {
  build_runner = {
    enabled = true,
    auto_save = true,              -- Save files before building
    show_output = true,            -- Show output window
    output_position = "botright",  -- Window position
    output_height = 15,            -- Output window height
    close_on_success = false,      -- Auto-close on success
    focus_on_open = false,         -- Focus output when opened
  },
}
```

**Commands:**
```vim
:SwiftBuild              " Build in debug mode
:SwiftBuild release      " Build in release mode
:SwiftRun                " Run the executable
:SwiftRun arg1 arg2      " Run with arguments
:SwiftTest               " Run all tests
:SwiftTest MyTestCase    " Run specific test
:SwiftClean              " Clean build artifacts
:SwiftBuildClose         " Close output window
```

**Example Keybindings:**
```lua
keys = {
  { "<leader>sb", "<cmd>SwiftBuild<cr>", desc = "Swift build" },
  { "<leader>sr", "<cmd>SwiftRun<cr>", desc = "Swift run" },
  { "<leader>st", "<cmd>SwiftTest<cr>", desc = "Swift test" },
  { "<leader>sc", "<cmd>SwiftClean<cr>", desc = "Swift clean" },
}
```

### 3. LSP Integration

Automatic sourcekit-lsp configuration with full language server support.

**Default Configuration:**
```lua
features = {
  lsp = {
    enabled = true,
    auto_setup = true,             -- Auto-configure LSP
    sourcekit_path = nil,          -- Auto-detect
    inlay_hints = true,            -- Show inlay hints
    semantic_tokens = true,        -- Semantic highlighting
    on_attach = nil,               -- Custom on_attach function
    capabilities = nil,            -- Custom capabilities
    cmd = nil,                     -- Custom command
    root_dir = nil,                -- Custom root_dir function
    filetypes = { "swift" },
    settings = {},
  },
}
```

**Built-in Keybindings:**
- `gd` - Go to definition
- `gD` - Go to declaration
- `K` - Hover documentation
- `gi` - Go to implementation
- `gr` - Find references
- `<C-k>` - Signature help
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>f` - Format document
- `[d` / `]d` - Navigate diagnostics
- `<leader>e` - Show diagnostic float
- `<leader>q` - Diagnostics quickfix

**Custom on_attach:**
```lua
features = {
  lsp = {
    enabled = true,
    on_attach = function(client, bufnr)
      -- Your custom logic
      print("Swift LSP attached!")

      -- Custom keybindings
      vim.keymap.set("n", "<leader>K", vim.lsp.buf.hover, { buffer = bufnr })
    end,
  },
}
```

**Disable auto-setup (manual configuration):**
```lua
features = {
  lsp = {
    enabled = true,
    auto_setup = false,  -- Don't auto-configure
  },
}

-- Then configure manually in your LSP setup
require("lspconfig").sourcekit.setup(
  require("swift.features.lsp").get_lsp_config()
)
```

### 4. Code Formatting

Integration with swift-format and swiftformat.

**Default Configuration:**
```lua
features = {
  formatter = {
    enabled = true,
    tool = nil,                    -- Auto-detect: "swift-format" | "swiftformat"
    format_on_save = false,        -- Don't format on save by default
    config_file = nil,             -- Auto-detect config file
  },
}
```

**Commands:**
```vim
:SwiftFormat              " Format current file
:SwiftFormatSelection     " Format selection (formats whole buffer for now)
```

**Format on Save:**
```lua
features = {
  formatter = {
    enabled = true,
    format_on_save = true,  -- Enable format on save
  },
}
```

**Force Specific Tool:**
```lua
features = {
  formatter = {
    enabled = true,
    tool = "swift-format",  -- or "swiftformat"
  },
}
```

**Integration with conform.nvim:**
```lua
-- If you use conform.nvim, you can disable swift.nvim formatter
features = {
  formatter = {
    enabled = false,
  },
}

-- And configure conform.nvim instead
require("conform").setup({
  formatters_by_ft = {
    swift = { "swift_format" },  -- or { "swiftformat" }
  },
})
```

### 5. Linting Integration

SwiftLint integration with diagnostics.

**Default Configuration:**
```lua
features = {
  linter = {
    enabled = true,
    lint_on_save = true,           -- Lint after save
    auto_fix = false,              -- Don't auto-fix by default
    config_file = nil,             -- Auto-detect .swiftlint.yml
  },
}
```

**Commands:**
```vim
:SwiftLint        " Lint current file
:SwiftLintFix     " Auto-fix issues
```

**Auto-fix on Save:**
```lua
features = {
  linter = {
    enabled = true,
    lint_on_save = true,
    auto_fix = true,  -- Enable auto-fix on save
  },
}
```

**Disable Lint on Save:**
```lua
features = {
  linter = {
    enabled = true,
    lint_on_save = false,  -- Lint manually only
  },
}
```

**Integration with nvim-lint:**
```lua
-- If you use nvim-lint, you can disable swift.nvim linter
features = {
  linter = {
    enabled = false,
  },
}

-- And configure nvim-lint instead
require("lint").linters_by_ft = {
  swift = { "swiftlint" },
}
```

### 6. Xcode Integration

Build and manage Xcode projects.

**Default Configuration:**
```lua
features = {
  xcode = {
    enabled = true,
    default_scheme = nil,          -- Auto-detect or prompt
    default_simulator = nil,       -- Auto-detect or prompt
    show_output = true,
    output_position = "botright",
    output_height = 15,
  },
}
```

**Commands:**
```vim
:SwiftXcodeBuild           " Build (prompts for scheme if multiple)
:SwiftXcodeBuild MyScheme  " Build specific scheme
:SwiftXcodeSchemes         " List available schemes
:SwiftXcodeOpen            " Open in Xcode.app
```

**Set Default Scheme:**
```lua
features = {
  xcode = {
    enabled = true,
    default_scheme = "MyApp",  -- Use this scheme by default
  },
}
```

## Complete LazyVim Setup

### All Features Enabled (Recommended)

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",  -- Optional, for better completions
    },
    opts = {
      features = {
        -- Project detection
        project_detector = {
          enabled = true,
          show_notification = true,
        },

        -- Build and run
        build_runner = {
          enabled = true,
          auto_save = true,
        },

        -- LSP
        lsp = {
          enabled = true,
          inlay_hints = true,
        },

        -- Formatting
        formatter = {
          enabled = true,
          format_on_save = false,  -- Enable if you want auto-format
        },

        -- Linting
        linter = {
          enabled = true,
          lint_on_save = true,
        },

        -- Xcode
        xcode = {
          enabled = true,
        },
      },
    },

    -- Keybindings
    keys = {
      -- Project
      { "<leader>si", "<cmd>SwiftProjectInfo<cr>", desc = "Swift project info" },

      -- Build/Run/Test
      { "<leader>sb", "<cmd>SwiftBuild<cr>", desc = "Swift build" },
      { "<leader>sr", "<cmd>SwiftRun<cr>", desc = "Swift run" },
      { "<leader>st", "<cmd>SwiftTest<cr>", desc = "Swift test" },
      { "<leader>sc", "<cmd>SwiftClean<cr>", desc = "Swift clean" },

      -- Format/Lint
      { "<leader>sf", "<cmd>SwiftFormat<cr>", desc = "Swift format" },
      { "<leader>sl", "<cmd>SwiftLint<cr>", desc = "Swift lint" },
      { "<leader>sF", "<cmd>SwiftLintFix<cr>", desc = "Swift lint fix" },

      -- Xcode
      { "<leader>sxb", "<cmd>SwiftXcodeBuild<cr>", desc = "Xcode build" },
      { "<leader>sxs", "<cmd>SwiftXcodeSchemes<cr>", desc = "Xcode schemes" },
      { "<leader>sxo", "<cmd>SwiftXcodeOpen<cr>", desc = "Open in Xcode" },
    },
  },

  -- Optional: which-key integration
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>s", group = "swift" },
        { "<leader>sx", group = "xcode" },
      },
    },
  },

  -- Optional: Configure Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { "swift" })
    end,
  },
}
```

### SPM Projects Only (No Xcode)

```lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      features = {
        project_detector = { enabled = true },
        build_runner = { enabled = true },
        lsp = { enabled = true },
        formatter = { enabled = true, format_on_save = true },
        linter = { enabled = true },
        xcode = { enabled = false },  -- Disable Xcode
      },
    },
  },
}
```

### Xcode Projects Only (No SPM Build)

```lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      features = {
        project_detector = { enabled = true },
        build_runner = { enabled = false },  -- Disable SPM builds
        lsp = { enabled = true },
        formatter = { enabled = true },
        linter = { enabled = true },
        xcode = { enabled = true },
      },
    },
  },
}
```

### Minimal LSP Only

```lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      features = {
        project_detector = { enabled = true },
        lsp = { enabled = true },
        -- Disable everything else
        build_runner = { enabled = false },
        formatter = { enabled = false },
        linter = { enabled = false },
        xcode = { enabled = false },
      },
    },
  },
}
```

## Integration with Other Plugins

### With nvim-cmp (Completion)

```lua
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  opts = function(_, opts)
    -- swift.nvim automatically integrates with nvim-cmp
    -- No additional configuration needed!
  end,
}
```

### With conform.nvim (Formatting)

```lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      swift = { "swift_format" },  -- or { "swiftformat" }
    },
  },
}

-- Disable swift.nvim formatter to avoid conflicts
return {
  "devswiftzone/swift.nvim",
  opts = {
    features = {
      formatter = { enabled = false },
    },
  },
}
```

### With nvim-lint (Linting)

```lua
return {
  "mfussenegger/nvim-lint",
  opts = function(_, opts)
    opts.linters_by_ft = opts.linters_by_ft or {}
    opts.linters_by_ft.swift = { "swiftlint" }
  end,
}

-- Disable swift.nvim linter to avoid conflicts
return {
  "devswiftzone/swift.nvim",
  opts = {
    features = {
      linter = { enabled = false },
    },
  },
}
```

### With Telescope (Pickers)

```lua
-- Use Telescope for scheme selection
vim.keymap.set("n", "<leader>sxs", function()
  local xcode = require("swift.features.xcode")
  local schemes = xcode.list_schemes()

  require("telescope.pickers").new({}, {
    prompt_title = "Xcode Schemes",
    finder = require("telescope.finders").new_table({
      results = schemes,
    }),
    sorter = require("telescope.config").values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      actions.select_default:replace(function()
        local selection = require("telescope.actions.state").get_selected_entry()
        actions.close(prompt_bufnr)
        xcode.build(selection[1])
      end)
      return true
    end,
  }):find()
end, { desc = "Select Xcode scheme" })
```

## Keybinding Examples

### Recommended Keybinding Scheme

```lua
keys = {
  -- Info/Detection
  { "<leader>si", "<cmd>SwiftProjectInfo<cr>", desc = "Project info" },
  { "<leader>sd", "<cmd>SwiftDetectProject<cr>", desc = "Detect project" },
  { "<leader>sI", "<cmd>SwiftInfo<cr>", desc = "Plugin info" },

  -- Build/Run/Test (SPM)
  { "<leader>sb", "<cmd>SwiftBuild<cr>", desc = "Build" },
  { "<leader>sB", "<cmd>SwiftBuild release<cr>", desc = "Build release" },
  { "<leader>sr", "<cmd>SwiftRun<cr>", desc = "Run" },
  { "<leader>st", "<cmd>SwiftTest<cr>", desc = "Test" },
  { "<leader>sc", "<cmd>SwiftClean<cr>", desc = "Clean" },

  -- Format/Lint
  { "<leader>sf", "<cmd>SwiftFormat<cr>", desc = "Format" },
  { "<leader>sl", "<cmd>SwiftLint<cr>", desc = "Lint" },
  { "<leader>sF", "<cmd>SwiftLintFix<cr>", desc = "Lint fix" },

  -- Xcode
  { "<leader>xb", "<cmd>SwiftXcodeBuild<cr>", desc = "Xcode build" },
  { "<leader>xs", "<cmd>SwiftXcodeSchemes<cr>", desc = "Xcode schemes" },
  { "<leader>xo", "<cmd>SwiftXcodeOpen<cr>", desc = "Open in Xcode" },
}
```

### Alternative: Using Function Keys

```lua
keys = {
  { "<F5>", "<cmd>SwiftBuild<cr>", desc = "Swift build" },
  { "<F6>", "<cmd>SwiftRun<cr>", desc = "Swift run" },
  { "<F7>", "<cmd>SwiftTest<cr>", desc = "Swift test" },
  { "<F8>", "<cmd>SwiftFormat<cr>", desc = "Swift format" },
}
```

## Troubleshooting

### Check Health

Always start with health check:
```vim
:checkhealth swift
```

This will show:
- ✓ What's working
- ⚠ What needs attention
- ✗ What's broken

### Common Issues

#### LSP Not Working

**Check:**
1. Is sourcekit-lsp installed? `which sourcekit-lsp`
2. Is nvim-lspconfig installed?
3. Run `:LspInfo` in a Swift file

**Fix:**
```bash
# macOS with Xcode
xcode-select --install

# Or install Swift toolchain
# Download from https://swift.org/download/
```

#### Formatter Not Working

**Check:**
1. Is swift-format or swiftformat installed?
2. Run `:SwiftFormat` and check error message

**Fix:**
```bash
# Install swift-format
brew install swift-format

# Or swiftformat
brew install swiftformat
```

#### Linter Not Working

**Check:**
1. Is SwiftLint installed?
2. Do you have a .swiftlint.yml file?

**Fix:**
```bash
# Install SwiftLint
brew install swiftlint

# Create config (optional)
swiftlint generate-config > .swiftlint.yml
```

#### Build/Run Not Working

**Check:**
1. Are you in a Swift Package Manager project?
2. Does `swift build` work in terminal?
3. Is Package.swift valid?

**Fix:**
```bash
# Verify package
swift package describe

# Clean and rebuild
swift package clean
swift build
```

#### Xcode Integration Not Working

**Check:**
1. Are you on macOS?
2. Is xcodebuild installed?
3. Are you in an Xcode project?

**Fix:**
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify xcodebuild
xcodebuild -version
```

### Debug Mode

Enable verbose logging:
```lua
opts = {
  log_level = "debug",
}
```

### Getting Help

1. Check `:checkhealth swift`
2. Check `:messages` for errors
3. Open an issue: https://github.com/devswiftzone/swift.nvim/issues

## Best Practices

1. **Start Simple**: Use default configuration first, then customize
2. **Use Health Check**: Run `:checkhealth swift` regularly
3. **Enable Format on Save**: For consistent code style
4. **Use Linting**: Catch issues early with SwiftLint
5. **Keybindings**: Choose keybindings that fit your workflow
6. **Project-Specific**: Use .swiftlint.yml and .swift-format for project consistency

## Example Workflows

### SPM Development Workflow

1. Open project: `nvim Package.swift`
2. Plugin detects SPM project automatically
3. Edit Swift files with LSP support
4. Build: `<leader>sb` or `:SwiftBuild`
5. Run: `<leader>sr` or `:SwiftRun`
6. Test: `<leader>st` or `:SwiftTest`
7. Format: `<leader>sf` or `:SwiftFormat`
8. Lint: Auto-lints on save

### Xcode Development Workflow

1. Open project: `cd MyApp.xcodeproj/.. && nvim`
2. Plugin detects Xcode project
3. Edit Swift files with LSP support
4. Build in Xcode: `<leader>xb` or `:SwiftXcodeBuild`
5. Select scheme if prompted
6. Format and lint as you work
7. Open in Xcode for UI work: `<leader>xo`

## Next Steps

- Read [README.md](./README.md) for feature details
- Check [FEATURES_ROADMAP.md](./FEATURES_ROADMAP.md) for upcoming features
- See [examples/](./examples/) for more configuration examples
- Run `:checkhealth swift` to verify setup

## Contributing

Found a bug or have a feature request?
Open an issue: https://github.com/devswiftzone/swift.nvim/issues
