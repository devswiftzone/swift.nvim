-- Test script: validate all shell calls in health.lua are fast
-- Run with: nvim --headless -u tests/minimal_init.lua -l tests/test_health_speed.lua

local function time_call(label, fn)
  local start = vim.loop.hrtime()
  local ok, result = pcall(fn)
  local elapsed_ms = (vim.loop.hrtime() - start) / 1e6
  local status = ok and "OK" or "ERROR"
  print(string.format("[%s] %-50s %.0fms", status, label, elapsed_ms))
  if not ok then
    print("   Error: " .. tostring(result))
  end
  return result
end

print("=== swift.nvim checkhealth speed test ===")
print("")

-- Bootstrap plugin
local plugin_ok = pcall(require, "swift")
if not plugin_ok then
  -- minimal setup without lspconfig
  vim.opt.runtimepath:prepend(".")
  plugin_ok = pcall(require, "swift")
end

-- 1. swift --version
time_call("swift --version (via version_validator)", function()
  local v = require("swift.version_validator")
  return v.get_installed_swift_version()
end)

-- 2. xcrun --find sourcekit-lsp
time_call("xcrun --find sourcekit-lsp (via lsp.find_sourcekit_lsp)", function()
  local lsp = require("swift.features.lsp")
  return lsp.find_sourcekit_lsp()
end)

-- 3. swift-format --version
time_call("swift-format --version (via validator.is_formatter_compatible)", function()
  local v = require("swift.version_validator")
  return v.is_formatter_compatible()
end)

-- 4a. Project detection — xcworkspace scan (was the culprit)
time_call("detect_xcode_workspace (find_pattern_upwards *.xcworkspace)", function()
  local d = require("swift.features.project_detector")
  return d.detect_xcode_workspace(vim.fn.getcwd())
end)

-- 4b. Project detection — xcodeproj scan
time_call("detect_xcode_project  (find_pattern_upwards *.xcodeproj)", function()
  local d = require("swift.features.project_detector")
  return d.detect_xcode_project(vim.fn.getcwd())
end)

-- 4c. Project detection — SPM (io.open Package.swift, fast)
time_call("detect_spm            (find_file_upwards Package.swift)", function()
  local d = require("swift.features.project_detector")
  return d.detect_spm(vim.fn.getcwd())
end)

-- 5. lsp.status() — should be instant (just checks active clients)
time_call("lsp.status() — check active clients", function()
  local lsp = require("swift.features.lsp")
  return lsp.status()
end)

-- 6. debugger.find_lldb() — just exepath, instant
time_call("debugger.find_lldb() — exepath/executable", function()
  local d = require("swift.features.debugger")
  return d.find_lldb()
end)

print("")
print("=== Done. All calls above 1000ms are potential hangs. ===")
vim.cmd("quit")
