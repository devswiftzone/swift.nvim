# 🚀 Getting Started with swift.nvim

## Quick Links

- **📘 [Complete Documentation](DOCUMENTATION.md)** - Everything you need to know
- **⚡ [Minimal Config](MINIMAL_CONFIG.lua)** - Copy & paste to get started (30 lines)
- **🔧 [Full Config](FULL_CONFIG.lua)** - All options documented (450 lines)

---

## Installation (3 Steps)

### Step 1: Copy Configuration

Choose one:

```bash
# Option A: Minimal (recommended for beginners)
cp MINIMAL_CONFIG.lua ~/.config/nvim/lua/plugins/swift.lua

# Option B: Full (recommended for advanced users)
cp FULL_CONFIG.lua ~/.config/nvim/lua/plugins/swift.lua
```

### Step 2: Restart Neovim

```bash
nvim  # Plugin installs automatically
```

### Step 3: Verify

```vim
:checkhealth swift
```

You should see:
- ✓ LLDB found
- ✓ Swift debugging is configured
- ✓ Plugin loaded successfully

---

## Try the Debugger (30 seconds)

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
```

---

## Key Features

✅ **Direct LLDB Integration** - No nvim-dap required
✅ **Visual Debugging** - Breakpoints (●) and current line (➤)
✅ **Test Support** - Debug .xctest bundles
✅ **All-in-One** - LSP, formatter, linter, build system, and debugger
✅ **Zero Dependencies** - Just Swift toolchain + Neovim

---

## Essential Keybindings

```
F5   → Continue/Run
F9   → Toggle Breakpoint
F10  → Step Over
F11  → Step Into

<leader>bb → Build
<leader>br → Run
<leader>bt → Test
<leader>sf → Format
<leader>sl → Lint
```

---

## Need Help?

- **📘 Full Documentation**: [DOCUMENTATION.md](DOCUMENTATION.md)
- **❓ Troubleshooting**: See [Troubleshooting section](DOCUMENTATION.md#-troubleshooting)
- **💡 Examples**: See [Workflows section](DOCUMENTATION.md#-workflows)
- **🐛 Issues**: [GitHub Issues](https://github.com/devswiftzone/swift.nvim/issues)

---

## What's Different from Other Solutions?

| Feature | swift.nvim | Others |
|---------|------------|--------|
| Debug Dependencies | ✅ None (direct LLDB) | ❌ Requires nvim-dap |
| Visual Indicators | ✅ Built-in (● ➤) | ⚠️ Requires DAP UI |
| Test Debugging | ✅ .xctest support | ⚠️ Limited |
| Setup Complexity | ✅ Minimal | ❌ Complex |
| Working Directory | ✅ Correct (project root) | ⚠️ Often wrong |

---

## Next Steps

1. ✅ **Install** - Copy config and restart Neovim
2. ✅ **Verify** - Run `:checkhealth swift`
3. ✅ **Try it** - Set breakpoint (F9) and debug
4. 📖 **Learn** - Read [DOCUMENTATION.md](DOCUMENTATION.md)
5. 🎨 **Customize** - Modify keybindings as needed

---

**swift.nvim** - Swift development in Neovim without compromises.
