# Quick Start Guide

Get started with swift.nvim in under 5 minutes.

## For LazyVim Users

### Step 1: Create the plugin file

Create `~/.config/nvim/lua/plugins/swift.lua`:

```lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    opts = {},
  },
}
```

### Step 2: Restart Neovim

Restart Neovim or run:
```vim
:Lazy sync
```

### Step 3: Open a Swift project

```bash
cd your-swift-project
nvim main.swift
```

That's it! The plugin will automatically detect your project.

## For Local Development

If you're developing the plugin locally:

```lua
-- ~/.config/nvim/lua/plugins/swift.lua
return {
  {
    dir = "~/projects/nvim/swift.nvim",
    ft = "swift",
    config = function()
      require("swift").setup()
    end,
  },
}
```

## Verify Installation

Run these commands:

```vim
:checkhealth swift
:SwiftProjectInfo
```

## Common Use Cases

### Load on Swift files only (recommended)
```lua
{ "devswiftzone/swift.nvim", ft = "swift", opts = {} }
```

### Load when opening any directory
```lua
{ "devswiftzone/swift.nvim", event = "VeryLazy", opts = {} }
```

### Disable notifications
```lua
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
}
```

### Add keybindings
```lua
{
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = {},
  keys = {
    { "<leader>si", "<cmd>SwiftProjectInfo<cr>", desc = "Swift project info" },
    { "<leader>sd", "<cmd>SwiftDetectProject<cr>", desc = "Detect project" },
  },
}
```

## Troubleshooting

### Plugin not loading?
1. Check `:Lazy` to see if the plugin is installed
2. Try `:Lazy reload swift.nvim`
3. Check `:checkhealth swift`

### Project not detected?
1. Run `:SwiftDetectProject` manually
2. Check if you have `Package.swift`, `*.xcodeproj`, or `*.xcworkspace` in your project
3. Try opening a `.swift` file directly

### Need help?
- Check the full [README.md](./README.md)
- See [examples/](./examples/) for configuration examples
- Run `:help swift.nvim` (coming soon)

## Next Steps

- See [README.md](./README.md) for complete documentation
- Check [examples/lazyvim-config.lua](./examples/lazyvim-config.lua) for full LazyVim integration
- Explore [examples/advanced-config.lua](./examples/advanced-config.lua) for advanced usage
