# Support

Thank you for using swift.nvim! This document provides guidance on how to get help and support.

## 📚 Documentation

Before asking for help, please check our comprehensive documentation:

- **[Getting Started Guide](GETTING_STARTED.md)** - Quick 3-step setup guide
- **[Complete Documentation](DOCUMENTATION.md)** - Everything in one place
- **[README](README.md)** - Features overview and configuration
- **[Examples](examples/)** - Complete configuration examples
- **[Troubleshooting](README.md#-troubleshooting)** - Common issues and solutions

## 🏥 Health Check

Run `:checkhealth swift` in Neovim to diagnose common issues automatically. This will check:

- Plugin installation
- Swift toolchain
- LSP configuration
- Dependencies (swift-format, swiftlint, etc.)
- Project detection

## 💬 Getting Help

### Questions

If you have a question about how to use swift.nvim:

1. **Check the documentation** - Most questions are answered in the guides above
2. **Search existing issues** - Someone might have asked the same question
3. **Open a new question** - [Ask a question](https://github.com/devswiftzone/swift.nvim/issues/new?template=question.md)

### Bug Reports

If you've found a bug:

1. **Run `:checkhealth swift`** to gather diagnostic information
2. **Search existing issues** to avoid duplicates
3. **Open a bug report** - [Report a bug](https://github.com/devswiftzone/swift.nvim/issues/new?template=bug_report.md)

Include:
- Neovim version (`:version`)
- swift.nvim commit/version
- Operating system
- Swift toolchain version
- Minimal reproducible configuration
- Steps to reproduce
- Expected vs actual behavior

### Feature Requests

Have an idea for a new feature?

1. **Check existing issues** to see if it's already been requested
2. **Open a feature request** - [Request a feature](https://github.com/devswiftzone/swift.nvim/issues/new?template=feature_request.md)

Describe:
- What problem does it solve?
- What's your proposed solution?
- Are there alternatives you've considered?

### Security Issues

Found a security vulnerability? **DO NOT** open a public issue.

Instead:
- Use GitHub's [private security advisory](https://github.com/devswiftzone/swift.nvim/security/advisories/new)
- Or email us at: info@swiftzone.dev

See [SECURITY.md](SECURITY.md) for details.

## 🤝 Community Guidelines

When seeking support:

- Be respectful and courteous
- Provide as much context as possible
- Follow up if you find a solution (help others!)
- Read our [Code of Conduct](CODE_OF_CONDUCT.md)

## ⚡ Quick Debugging Tips

### Plugin not loading?
```vim
:Lazy
:messages
:Lazy reload swift.nvim
```

### LSP not working?
```vim
:LspInfo
:checkhealth swift
```

### Project not detected?
```vim
:SwiftDetectProject
:SwiftProjectInfo
```

### Enable debug logging
```lua
require("swift").setup({
  log_level = "debug",
})
```

Then check:
```vim
:messages
```

## 📬 Contact

- **GitHub Issues**: https://github.com/devswiftzone/swift.nvim/issues
- **Email**: info@swiftzone.dev (for private inquiries)
- **Repository**: https://github.com/devswiftzone/swift.nvim

## ⏱️ Response Times

We're a community-driven project. While we strive to respond quickly:

- **Questions**: 1-3 business days
- **Bug reports**: 1-5 business days
- **Feature requests**: Variable (depends on complexity and maintainer availability)
- **Security issues**: Within 3 business days (initial acknowledgment)

## 🎯 What's NOT Supported Here

For issues with:
- **Swift language itself** → [Swift Forums](https://forums.swift.org)
- **Neovim** → [Neovim Discussions](https://github.com/neovim/neovim/discussions)
- **LSP (sourcekit-lsp)** → [Swift Server](https://github.com/apple/sourcekit-lsp)
- **swift-format** → [swift-format repo](https://github.com/apple/swift-format)
- **SwiftLint** → [SwiftLint repo](https://github.com/realm/SwiftLint)

We appreciate your patience and understanding!
