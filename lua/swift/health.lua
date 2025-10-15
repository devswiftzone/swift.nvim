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

  -- Check Swift compiler and version
  local validator_ok, validator = pcall(require, "swift.version_validator")

  if vim.fn.executable("swift") == 1 then
    health.ok("Swift compiler found")

    if validator_ok then
      local installed = validator.get_installed_swift_version()
      if installed then
        health.info("Version: " .. installed.string)

        -- Check for .swift-version file
        local required = validator.get_required_swift_version()
        if required then
          health.info(".swift-version file: " .. required.file)
          health.info("Required version: " .. required.string)

          -- Check if versions match
          local matches, info = validator.is_required_version_installed()
          if matches then
            health.ok("Installed version matches requirement")
          else
            health.error("Version mismatch!")
            health.info("Install required version with: swiftly install " .. required.string)
          end
        end

        -- Check swiftly
        if vim.fn.executable("swiftly") == 1 then
          health.ok("swiftly found (Swift version manager)")
          local versions = validator.list_swiftly_versions()
          if versions and #versions > 0 then
            local current = nil
            for _, v in ipairs(versions) do
              if v.current then
                current = v.version
                break
              end
            end
            if current then
              health.info("Current swiftly version: " .. current)
            end
          end
        else
          health.info("swiftly not found (optional, but recommended)")
          health.info("Install: curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash")
        end
      end
    else
      local version = vim.fn.system("swift --version 2>&1 | head -n 1")
      health.info("Version: " .. vim.trim(version))
    end
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

        -- Check formatter compatibility with Swift version
        if validator_ok then
          local compat, compat_info = validator.is_formatter_compatible()
          if compat then
            health.ok("swift-format version is compatible with Swift")
          elseif compat_info then
            health.warn("swift-format version may not match Swift version")
            health.info("Swift: " .. compat_info.swift.string)
            health.info("swift-format: " .. compat_info.formatter.string)
            health.info("Consider updating swift-format to match Swift version")
          end
        end
      end

      if info.swiftformat_path then
        health.ok("swiftformat found")
        health.info("Path: " .. info.swiftformat_path)
      end

      if not info.swift_format_path and not info.swiftformat_path then
        health.warn("No Swift formatter found")
        health.info("Install swift-format: brew install swift-format")
        health.info("Or swiftformat: brew install swiftformat")
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

  -- Check Target Manager
  health.start("Target Manager")
  if config.is_feature_enabled("target_manager") then
    local tm_ok, target_manager = pcall(require, "swift.features.target_manager")
    if tm_ok then
      health.ok("Target manager available")

      -- Check if we can detect targets
      local targets = target_manager.get_targets()
      if #targets > 0 then
        health.ok(string.format("Found %d target(s)", #targets))

        local current = target_manager.get_current_target()
        if current then
          health.info("Current target: " .. current)
        end

        -- Show target types
        local type_counts = {}
        for _, target in ipairs(targets) do
          type_counts[target.type] = (type_counts[target.type] or 0) + 1
        end

        for target_type, count in pairs(type_counts) do
          health.info(string.format("  %s: %d", target_type, count))
        end
      else
        health.info("No targets found (open a Swift project to see targets)")
      end
    end
  else
    health.info("Target manager feature is disabled")
  end
end

return M
