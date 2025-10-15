# Dependencies Installation Guide

Complete guide for installing all dependencies needed for swift.nvim.

## Table of Contents

- [Required Dependencies](#required-dependencies)
- [Swift Toolchain](#swift-toolchain)
- [Code Formatting](#code-formatting)
- [Linting](#linting)
- [macOS/Xcode](#macosxcode)
- [Troubleshooting](#troubleshooting)

## Required Dependencies

### Neovim

**Minimum version:** 0.8.0 (0.9.0+ recommended)

**Installation:**
```bash
# macOS (Homebrew)
brew install neovim

# macOS (MacPorts)
sudo port install neovim

# Linux (apt)
sudo apt install neovim

# Linux (snap)
sudo snap install nvim --classic

# From source
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=Release
sudo make install
```

**Verify:**
```bash
nvim --version
# Should show v0.8.0 or higher
```

### nvim-lspconfig

Required for LSP support.

**Installation (with lazy.nvim):**
```lua
{
  "neovim/nvim-lspconfig",
  dependencies = {
    "devswiftzone/swift.nvim",
  },
}
```

**Installation (with packer.nvim):**
```lua
use 'neovim/nvim-lspconfig'
```

## Swift Toolchain

The Swift toolchain provides the compiler, LSP server (sourcekit-lsp), and other development tools.

### Option 1: Using swiftly (Recommended)

**swiftly** is the official Swift version manager from Apple. It makes managing multiple Swift versions easy.

#### Install swiftly

```bash
# macOS/Linux
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash
```

Or download from: https://github.com/swiftlang/swiftly

#### Install Swift with swiftly

```bash
# Install latest stable Swift
swiftly install latest

# Install specific version
swiftly install 6.2

# List available versions
swiftly list-available

# List installed versions
swiftly list

# Switch between versions
swiftly use 6.2
```

#### Configure project-specific Swift version

Create a `.swift-version` file in your project root:

```bash
# In your project directory
echo "6.2" > .swift-version
```

swiftly will automatically use this version when you're in that directory.

#### Verify Installation

```bash
# Check Swift version
swift --version
# Should show: Swift version 6.2 (or your installed version)

# Check sourcekit-lsp
which sourcekit-lsp
# Should show: ~/.local/share/swiftly/toolchains/6.2.0/usr/bin/sourcekit-lsp
```

### Option 2: Using Xcode (macOS only)

If you're on macOS and doing iOS/macOS development, Xcode includes the Swift toolchain.

```bash
# Install Xcode from App Store
# Then install Command Line Tools:
xcode-select --install

# Verify
swift --version
which sourcekit-lsp
```

**Note:** Xcode's Swift version may be different from swiftly's. Choose one approach:
- Use swiftly for Swift Package Manager projects
- Use Xcode for iOS/macOS projects

### Option 3: Download Swift Directly

Download from https://swift.org/download/

```bash
# Download and extract
# Add to PATH in your shell config:
export PATH="/path/to/swift/usr/bin:$PATH"
```

## Code Formatting

### swift-format (Official - Recommended)

Apple's official Swift formatter.

#### Installation

**With swiftly (Recommended):**
```bash
# swift-format comes with the Swift toolchain when using swiftly
swiftly install latest

# Verify
which swift-format
swift-format --version
```

**With Homebrew:**
```bash
brew install swift-format
```

**From source:**
```bash
git clone https://github.com/apple/swift-format.git
cd swift-format
swift build -c release
# Copy to PATH
cp .build/release/swift-format /usr/local/bin/
```

#### Configuration

Create `.swift-format` in your project root:

```json
{
  "version": 1,
  "lineLength": 100,
  "indentation": {
    "spaces": 2
  },
  "respectsExistingLineBreaks": true,
  "lineBreakBeforeControlFlowKeywords": false,
  "lineBreakBeforeEachArgument": true
}
```

**Generate default config:**
```bash
swift-format --configuration > .swift-format
```

### swiftformat (Alternative)

Community-maintained Swift formatter with more options.

#### Installation

```bash
# Homebrew
brew install swiftformat

# Mint
mint install nicklockwood/SwiftFormat

# From source
git clone https://github.com/nicklockwood/SwiftFormat
cd SwiftFormat
swift build -c release
cp .build/release/swiftformat /usr/local/bin/
```

#### Configuration

Create `.swiftformat` in your project root:

```
--indent 2
--maxwidth 100
--wraparguments before-first
--wrapcollections before-first
```

**Generate default config:**
```bash
swiftformat --inferoptions . --output .swiftformat
```

## Linting

### SwiftLint

Code linter for Swift.

#### Installation

```bash
# Homebrew (Recommended)
brew install swiftlint

# Mint
mint install realm/SwiftLint

# CocoaPods
pod 'SwiftLint'

# From source
git clone https://github.com/realm/SwiftLint.git
cd SwiftLint
swift build -c release
cp .build/release/swiftlint /usr/local/bin/
```

#### Configuration

Create `.swiftlint.yml` in your project root:

```yaml
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - missing_docs

included:
  - Sources
  - Tests

excluded:
  - .build
  - .swiftpm
  - Packages

line_length:
  warning: 120
  error: 200

identifier_name:
  min_length:
    warning: 2
  max_length:
    warning: 40
    error: 50
```

**Generate default config:**
```bash
swiftlint generate-config > .swiftlint.yml
```

#### Verify Installation

```bash
swiftlint version
swiftlint rules
```

## macOS/Xcode

### Xcode Command Line Tools

Required for Xcode project integration and some Swift features on macOS.

```bash
# Install
xcode-select --install

# Verify
xcodebuild -version
xcode-select -p
```

### Full Xcode (Optional)

Only needed if you're developing iOS/macOS apps.

1. Download from Mac App Store
2. Open Xcode once to complete setup
3. Accept license: `sudo xcodebuild -license accept`

## Optional: nvim-cmp

For better code completions.

```lua
-- lazy.nvim
{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
}
```

## Recommended Setup

### For Swift Package Manager Projects

```bash
# 1. Install swiftly
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash

# 2. Install Swift
swiftly install latest

# 3. Install formatters (choose one or both)
brew install swift-format
brew install swiftformat

# 4. Install linter
brew install swiftlint

# 5. Verify everything
swift --version
sourcekit-lsp --version
swift-format --version
swiftformat --version
swiftlint version
```

### For iOS/macOS Development

```bash
# 1. Install Xcode from App Store

# 2. Install Command Line Tools
xcode-select --install

# 3. Install formatters
brew install swift-format
brew install swiftformat

# 4. Install linter
brew install swiftlint

# 5. Optional: Install swiftly for SPM projects
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash
swiftly install latest

# 6. Verify
swift --version
xcodebuild -version
sourcekit-lsp --version
swift-format --version
swiftlint version
```

## Troubleshooting

### Swift version mismatch with .swift-version file

**Error:**
```
The swift version file .swift-version uses toolchain version 6.2,
but it doesn't match any of the installed toolchains.
```

**Solution:**
```bash
# Install the required version with swiftly
swiftly install 6.2

# Or remove .swift-version if not needed
rm .swift-version

# Or update .swift-version to match installed version
swiftly list  # See installed versions
echo "6.2" > .swift-version
```

### sourcekit-lsp not found

**Solution:**
```bash
# If using swiftly
swiftly install latest

# If using Xcode
xcode-select --install

# Check which sourcekit-lsp is being used
which sourcekit-lsp

# If multiple versions exist, ensure the right one is in PATH
export PATH="$HOME/.local/share/swiftly/toolchains/latest/usr/bin:$PATH"
```

### swift-format not found

**Solution:**
```bash
# Install with Homebrew
brew install swift-format

# Or use the one from Swift toolchain
ls ~/.local/share/swiftly/toolchains/*/usr/bin/swift-format

# Add to PATH
export PATH="$HOME/.local/share/swiftly/toolchains/latest/usr/bin:$PATH"
```

### SwiftLint not working

**Solution:**
```bash
# Reinstall
brew reinstall swiftlint

# Check if .swiftlint.yml is valid
swiftlint lint --config .swiftlint.yml

# Try without config
swiftlint lint
```

### Xcode Command Line Tools not found

**Solution:**
```bash
# Remove old installation
sudo rm -rf /Library/Developer/CommandLineTools

# Reinstall
xcode-select --install

# Reset path
sudo xcode-select --reset
```

### Multiple Swift versions conflicting

**Solution:**
```bash
# See which Swift is being used
which swift
swift --version

# If using swiftly, switch versions
swiftly use 6.2

# If using Xcode, switch toolchain
sudo xcode-select --switch /Applications/Xcode.app

# For SPM projects, use .swift-version file
echo "6.2" > .swift-version
```

## Checking Your Setup

Run these commands to verify your setup:

```bash
# Neovim
nvim --version | head -1

# Swift
swift --version

# LSP
sourcekit-lsp --version 2>&1 | head -1

# Formatters
swift-format --version 2>&1 | head -1
swiftformat --version

# Linter
swiftlint version

# Xcode (macOS)
xcodebuild -version | head -1

# swiftly
swiftly --version
```

Or use swift.nvim's health check:
```vim
:checkhealth swift
```

## Quick Reference

| Tool | Purpose | Install Command | Config File |
|------|---------|----------------|-------------|
| swiftly | Swift version manager | `curl -L https://swift-server.github.io/swiftly/swiftly-install.sh \| bash` | `.swift-version` |
| swift | Compiler & dev tools | `swiftly install latest` | - |
| sourcekit-lsp | LSP server | Included with Swift | - |
| swift-format | Official formatter | `brew install swift-format` | `.swift-format` |
| swiftformat | Alternative formatter | `brew install swiftformat` | `.swiftformat` |
| swiftlint | Linter | `brew install swiftlint` | `.swiftlint.yml` |
| xcodebuild | Xcode build tool | `xcode-select --install` | - |

## Additional Resources

- **swiftly**: https://github.com/swiftlang/swiftly
- **Swift.org**: https://swift.org/download/
- **sourcekit-lsp**: https://github.com/apple/sourcekit-lsp
- **swift-format**: https://github.com/apple/swift-format
- **swiftformat**: https://github.com/nicklockwood/SwiftFormat
- **SwiftLint**: https://github.com/realm/SwiftLint
- **Xcode**: https://developer.apple.com/xcode/

## Support

If you're still having issues:
1. Run `:checkhealth swift` in Neovim
2. Check `:messages` for errors
3. Open an issue: https://github.com/devswiftzone/swift.nvim/issues
