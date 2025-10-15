local M = {}

local utils = require("swift.utils")

-- Parse version string to table {major, minor, patch}
function M.parse_version(version_string)
  if not version_string then
    return nil
  end

  local major, minor, patch = version_string:match("(%d+)%.(%d+)%.?(%d*)")
  if not major then
    major, minor = version_string:match("(%d+)%.(%d+)")
  end

  if not major then
    return nil
  end

  return {
    major = tonumber(major),
    minor = tonumber(minor) or 0,
    patch = tonumber(patch) or 0,
    string = string.format("%d.%d.%d", tonumber(major), tonumber(minor) or 0, tonumber(patch) or 0),
  }
end

-- Compare two version tables
-- Returns: -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2
function M.compare_versions(v1, v2)
  if not v1 or not v2 then
    return nil
  end

  if v1.major ~= v2.major then
    return v1.major < v2.major and -1 or 1
  end

  if v1.minor ~= v2.minor then
    return v1.minor < v2.minor and -1 or 1
  end

  if v1.patch ~= v2.patch then
    return v1.patch < v2.patch and -1 or 1
  end

  return 0
end

-- Find .swift-version file in project
function M.find_swift_version_file()
  return utils.find_file_upwards(".swift-version")
end

-- Read .swift-version file
function M.read_swift_version_file(file_path)
  file_path = file_path or M.find_swift_version_file()

  if not file_path then
    return nil
  end

  local file = io.open(file_path, "r")
  if not file then
    return nil
  end

  local content = file:read("*l")
  file:close()

  if not content then
    return nil
  end

  -- Trim whitespace
  content = content:gsub("^%s*(.-)%s*$", "%1")

  return content
end

-- Get required Swift version from project
function M.get_required_swift_version()
  local version_string = M.read_swift_version_file()
  if not version_string then
    return nil
  end

  return {
    string = version_string,
    parsed = M.parse_version(version_string),
    file = M.find_swift_version_file(),
  }
end

-- Get installed Swift version
function M.get_installed_swift_version()
  local output = vim.fn.system("swift --version 2>&1")

  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Parse: "Swift version 6.2 (swiftlang-6.2.0.19.9 clang-1700.3.19.1)"
  local version = output:match("Swift version ([%d%.]+)")

  if not version then
    return nil
  end

  return {
    string = version,
    parsed = M.parse_version(version),
    full_output = output,
  }
end

-- Check if required Swift version is installed
function M.is_required_version_installed()
  local required = M.get_required_swift_version()
  local installed = M.get_installed_swift_version()

  if not required or not installed then
    return true, nil -- No requirement or can't check, assume OK
  end

  if not required.parsed or not installed.parsed then
    return true, nil
  end

  -- Check if major.minor matches (patch can differ)
  local matches = required.parsed.major == installed.parsed.major
    and required.parsed.minor == installed.parsed.minor

  return matches, {
    required = required,
    installed = installed,
  }
end

-- List installed Swift versions with swiftly
function M.list_swiftly_versions()
  if vim.fn.executable("swiftly") ~= 1 then
    return nil
  end

  local output = vim.fn.system("swiftly list 2>/dev/null")

  if vim.v.shell_error ~= 0 then
    return nil
  end

  local versions = {}
  for line in output:gmatch("[^\r\n]+") do
    -- Parse: "* 6.2.0" or "  6.1.0"
    local is_current = line:match("^%*")
    local version = line:match("([%d%.]+)")

    if version then
      table.insert(versions, {
        version = version,
        parsed = M.parse_version(version),
        current = is_current ~= nil,
        line = line,
      })
    end
  end

  return versions
end

-- Check if swiftly has the required version
function M.swiftly_has_version(version_string)
  local versions = M.list_swiftly_versions()

  if not versions then
    return false
  end

  local required = M.parse_version(version_string)
  if not required then
    return false
  end

  for _, v in ipairs(versions) do
    if v.parsed and v.parsed.major == required.major and v.parsed.minor == required.minor then
      return true, v
    end
  end

  return false
end

-- Get swift-format version
function M.get_swift_format_version()
  local formatter = require("swift.features.formatter")
  local swift_format = formatter.find_swift_format()

  if not swift_format then
    return nil
  end

  local output = vim.fn.system(swift_format .. " --version 2>&1")

  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Parse version from output
  local version = output:match("([%d%.]+)")

  return {
    string = version,
    parsed = version and M.parse_version(version) or nil,
    path = swift_format,
    output = output,
  }
end

-- Check if swift-format is compatible with Swift version
function M.is_formatter_compatible()
  local swift_version = M.get_installed_swift_version()
  local format_version = M.get_swift_format_version()

  if not swift_version or not format_version then
    return true, nil -- Can't check, assume OK
  end

  if not swift_version.parsed or not format_version.parsed then
    return true, nil
  end

  -- swift-format should match Swift major.minor version
  local compatible = swift_version.parsed.major == format_version.parsed.major
    and swift_version.parsed.minor == format_version.parsed.minor

  return compatible, {
    swift = swift_version,
    formatter = format_version,
  }
end

-- Validate entire environment
function M.validate_environment()
  local results = {
    swift_version_file = nil,
    required_version = nil,
    installed_version = nil,
    version_matches = true,
    version_info = nil,
    swiftly_available = vim.fn.executable("swiftly") == 1,
    swiftly_versions = nil,
    formatter_compatible = true,
    formatter_info = nil,
    errors = {},
    warnings = {},
  }

  -- Check .swift-version file
  results.swift_version_file = M.find_swift_version_file()
  if results.swift_version_file then
    results.required_version = M.get_required_swift_version()
  end

  -- Check installed Swift
  results.installed_version = M.get_installed_swift_version()
  if not results.installed_version then
    table.insert(results.errors, "Swift is not installed or not in PATH")
  end

  -- Check version match
  if results.required_version and results.installed_version then
    local matches, info = M.is_required_version_installed()
    results.version_matches = matches
    results.version_info = info

    if not matches then
      local msg = string.format(
        "Swift version mismatch: required %s, installed %s",
        results.required_version.string,
        results.installed_version.string
      )
      table.insert(results.errors, msg)

      -- Check if swiftly has the version
      if results.swiftly_available then
        local has_version = M.swiftly_has_version(results.required_version.string)
        if has_version then
          table.insert(results.warnings, "Version is installed via swiftly, run: swiftly use " .. results.required_version.string)
        else
          table.insert(results.warnings, "Install with: swiftly install " .. results.required_version.string)
        end
      end
    end
  end

  -- Check swiftly versions
  if results.swiftly_available then
    results.swiftly_versions = M.list_swiftly_versions()
  end

  -- Check formatter compatibility
  local compat, compat_info = M.is_formatter_compatible()
  results.formatter_compatible = compat
  results.formatter_info = compat_info

  if not compat and compat_info then
    local msg = string.format(
      "swift-format version mismatch: Swift %s, swift-format %s",
      compat_info.swift.string,
      compat_info.formatter.string
    )
    table.insert(results.warnings, msg)
  end

  return results
end

-- Show validation results
function M.show_validation_results(results)
  results = results or M.validate_environment()

  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  print("Swift Environment Validation")
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

  -- Swift version file
  if results.swift_version_file then
    print("✓ .swift-version file: " .. results.swift_version_file)
    if results.required_version then
      print("  Required version: " .. results.required_version.string)
    end
  else
    print("○ No .swift-version file found")
  end

  print("")

  -- Installed Swift
  if results.installed_version then
    print("✓ Installed Swift: " .. results.installed_version.string)
  else
    print("✗ Swift not found")
  end

  print("")

  -- Version match
  if results.required_version and results.installed_version then
    if results.version_matches then
      print("✓ Version matches requirement")
    else
      print("✗ Version mismatch!")
    end
  end

  print("")

  -- swiftly
  if results.swiftly_available then
    print("✓ swiftly is available")
    if results.swiftly_versions and #results.swiftly_versions > 0 then
      print("  Installed versions:")
      for _, v in ipairs(results.swiftly_versions) do
        local marker = v.current and "→" or " "
        print(string.format("  %s %s", marker, v.version))
      end
    end
  else
    print("○ swiftly not installed")
  end

  print("")

  -- Formatter
  if results.formatter_info then
    if results.formatter_compatible then
      print("✓ swift-format is compatible")
    else
      print("⚠ swift-format version mismatch")
    end
    print("  Swift: " .. results.formatter_info.swift.string)
    print("  swift-format: " .. results.formatter_info.formatter.string)
  end

  -- Errors
  if #results.errors > 0 then
    print("")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("Errors:")
    for _, err in ipairs(results.errors) do
      print("✗ " .. err)
    end
  end

  -- Warnings
  if #results.warnings > 0 then
    print("")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("Warnings/Suggestions:")
    for _, warn in ipairs(results.warnings) do
      print("⚠ " .. warn)
    end
  end

  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

  return results
end

return M
