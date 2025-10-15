local M = {}

local health = vim.health or require("health")

function M.check()
  health.start("swift.nvim")

  -- Check if plugin is loaded
  local ok, swift = pcall(require, "swift")
  if ok then
    health.ok("Plugin loaded successfully")
  else
    health.error("Failed to load plugin")
    return
  end

  -- Check configuration
  local config = require("swift.config")
  if config.get() then
    health.ok("Configuration loaded")
  else
    health.error("Configuration not found")
  end

  -- Check features
  health.start("Features")
  local features = config.get().features
  for name, feature_config in pairs(features) do
    if feature_config.enabled then
      health.ok(string.format("Feature '%s' is enabled", name))
    else
      health.info(string.format("Feature '%s' is disabled", name))
    end
  end

  -- Check Swift compiler
  if vim.fn.executable("swift") == 1 then
    health.ok("Swift compiler found")
    local version = vim.fn.system("swift --version 2>&1 | head -n 1")
    health.info("Version: " .. vim.trim(version))
  else
    health.warn("Swift compiler not found in PATH")
  end

  -- Check Xcode (macOS only)
  if vim.fn.has("mac") == 1 then
    if vim.fn.executable("xcodebuild") == 1 then
      health.ok("Xcode command line tools found")
    else
      health.info("Xcode command line tools not found (optional)")
    end
  end

  -- Check for project detection
  health.start("Project Detection")
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if detector_ok and config.is_feature_enabled("project_detector") then
    local project_info = detector.get_project_info()
    if project_info.type ~= "none" then
      health.ok(string.format("Detected %s project", project_info.type))
      health.info("Root: " .. (project_info.root or "N/A"))
    else
      health.info("No Swift project detected in current directory")
    end
  end

  -- Check LSP
  health.start("LSP (sourcekit-lsp)")
  if config.is_feature_enabled("lsp") then
    local lsp_ok, lsp = pcall(require, "swift.features.lsp")
    if lsp_ok then
      if lsp.is_available() then
        health.ok("sourcekit-lsp found")
        health.info("Path: " .. lsp.find_sourcekit_lsp())

        -- Check if LSP client is active
        local status = lsp.status()
        if status.active then
          health.ok("LSP client is active")
        else
          health.info("LSP client not active (will start when opening Swift files)")
        end
      else
        health.warn("sourcekit-lsp not found in PATH")
        health.info("Install Swift toolchain or Xcode Command Line Tools")
      end

      -- Check nvim-lspconfig
      local lspconfig_ok = pcall(require, "lspconfig")
      if lspconfig_ok then
        health.ok("nvim-lspconfig found")
      else
        health.warn("nvim-lspconfig not found (recommended)")
        health.info("Install: https://github.com/neovim/nvim-lspconfig")
      end

      -- Check nvim-cmp (optional)
      local cmp_ok = pcall(require, "cmp_nvim_lsp")
      if cmp_ok then
        health.ok("nvim-cmp integration available")
      else
        health.info("nvim-cmp not found (optional for completions)")
      end
    end
  else
    health.info("LSP feature is disabled")
  end

  -- Check Formatter
  health.start("Code Formatting")
  if config.is_feature_enabled("formatter") then
    local formatter_ok, formatter = pcall(require, "swift.features.formatter")
    if formatter_ok then
      local info = formatter.get_info()

      if info.swift_format_path then
        health.ok("swift-format found")
        health.info("Path: " .. info.swift_format_path)
      end

      if info.swiftformat_path then
        health.ok("swiftformat found")
        health.info("Path: " .. info.swiftformat_path)
      end

      if not info.swift_format_path and not info.swiftformat_path then
        health.warn("No Swift formatter found")
        health.info("Install swift-format: https://github.com/apple/swift-format")
        health.info("Or swiftformat: https://github.com/nicklockwood/SwiftFormat")
      end

      if info.config_file then
        health.info("Config file: " .. info.config_file)
      end
    end
  else
    health.info("Formatter feature is disabled")
  end

  -- Check Linter
  health.start("Linting (SwiftLint)")
  if config.is_feature_enabled("linter") then
    local linter_ok, linter = pcall(require, "swift.features.linter")
    if linter_ok then
      if linter.is_available() then
        health.ok("SwiftLint found")
        health.info("Path: " .. linter.find_swiftlint())

        local config_file = linter.find_config_file()
        if config_file then
          health.info("Config file: " .. config_file)
        else
          health.info("No .swiftlint.yml found (using defaults)")
        end
      else
        health.warn("SwiftLint not found")
        health.info("Install: https://github.com/realm/SwiftLint")
      end
    end
  else
    health.info("Linter feature is disabled")
  end

  -- Check Xcode
  health.start("Xcode Integration")
  if config.is_feature_enabled("xcode") then
    if vim.fn.has("mac") == 1 then
      if vim.fn.executable("xcodebuild") == 1 then
        health.ok("xcodebuild found")

        local xcode_ok, xcode = pcall(require, "swift.features.xcode")
        if xcode_ok and xcode.is_xcode_project() then
          health.ok("Xcode project detected")
          local schemes = xcode.list_schemes()
          if #schemes > 0 then
            health.info("Schemes: " .. table.concat(schemes, ", "))
          end
        else
          health.info("Not in an Xcode project")
        end
      else
        health.warn("xcodebuild not found")
        health.info("Install Xcode Command Line Tools")
      end
    else
      health.info("Xcode integration only available on macOS")
    end
  else
    health.info("Xcode feature is disabled")
  end
end

return M
