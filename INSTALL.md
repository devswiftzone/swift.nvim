# Installation Guide

## Prerequisites

Before installing swift.nvim, ensure you have the Swift toolchain installed.

**Quick setup:**
```bash
# 1. Install swiftly (Swift version manager)
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash

# 2. Install Swift toolchain
swiftly install latest

# 3. Verify installation
swift --version
sourcekit-lsp --version
```

**For detailed installation instructions**, see [DEPENDENCIES.md](./DEPENDENCIES.md)

## For LazyVim Users (Simplest Method)

### Step 1: Create plugin configuration

Create the file `~/.config/nvim/lua/plugins/swift.lua`:

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

```bash
# Close and reopen Neovim, or run:
:Lazy sync
```

### Step 3: Test it

```bash
cd your-swift-project
nvim main.swift
```

You should see a notification: "Swift Package detected: /path/to/project"

---

## For Local Development

If you're developing the plugin locally:

### Step 1: Clone or create the plugin

```bash
mkdir -p ~/projects/nvim
cd ~/projects/nvim
# Your plugin is already at: ~/projects/nvim/swift.nvim
```

### Step 2: Configure LazyVim

Create `~/.config/nvim/lua/plugins/swift-dev.lua`:

```lua
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

### Step 3: Reload

```vim
:Lazy reload swift.nvim
```

---

## Verification

After installation, verify everything works:

```vim
:checkhealth swift
```

You should see:
- ✓ Plugin loaded successfully
- ✓ Configuration loaded
- ✓ Feature 'project_detector' is enabled

---

## Troubleshooting

### Plugin not loading?

1. Check if installed:
   ```vim
   :Lazy
   ```
   Look for "swift.nvim" in the list

2. Check for errors:
   ```vim
   :messages
   ```

3. Try manual reload:
   ```vim
   :Lazy reload swift.nvim
   ```

### Project not detected?

1. Make sure you have one of these files in your project:
   - `Package.swift`
   - `*.xcodeproj`
   - `*.xcworkspace`

2. Try manual detection:
   ```vim
   :SwiftDetectProject
   ```

3. Check if you're in a Swift file:
   ```vim
   :set filetype?
   ```
   Should show: `filetype=swift`

### Still having issues?

1. Enable debug logging:
   ```lua
   require("swift").setup({
     log_level = "debug",
   })
   ```

2. Check health:
   ```vim
   :checkhealth swift
   ```

3. Check messages:
   ```vim
   :messages
   ```

---

## Next Steps

- See [QUICKSTART.md](./QUICKSTART.md) for usage examples
- See [README.md](./README.md) for full documentation
- See [examples/](./examples/) for configuration examples
- See [.github/CONFIGURATION_TEMPLATE.md](./.github/CONFIGURATION_TEMPLATE.md) for copy-paste templates

## Uninstallation

To remove the plugin:

1. Delete the plugin file:
   ```bash
   rm ~/.config/nvim/lua/plugins/swift.lua
   ```

2. Clean up:
   ```vim
   :Lazy clean
   ```

3. Restart Neovim
