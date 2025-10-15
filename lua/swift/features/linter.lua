local M = {}

local config = {}

function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    enabled = true,
    swiftlint_path = nil, -- Auto-detect
    lint_on_save = true,
    config_file = nil, -- Auto-detect .swiftlint.yml
    auto_fix = false, -- Auto-fix on save
  }, opts or {})

  if config.lint_on_save then
    M.setup_lint_on_save()
  end

  M.setup_commands()
end

-- Find swiftlint executable
function M.find_swiftlint()
  if config.swiftlint_path then
    return config.swiftlint_path
  end

  local possible_paths = {
    vim.fn.exepath("swiftlint"),
    "/usr/local/bin/swiftlint",
    "/opt/homebrew/bin/swiftlint",
  }

  for _, path in ipairs(possible_paths) do
    if path ~= "" and vim.fn.executable(path) == 1 then
      return path
    end
  end

  return nil
end

-- Find swiftlint config file
function M.find_config_file()
  if config.config_file then
    return config.config_file
  end

  local utils = require("swift.utils")

  -- Look for .swiftlint.yml or .swiftlint.yaml
  local yml = utils.find_file_upwards(".swiftlint.yml")
  if yml then
    return yml
  end

  local yaml = utils.find_file_upwards(".swiftlint.yaml")
  if yaml then
    return yaml
  end

  return nil
end

-- Check if swiftlint is available
function M.is_available()
  return M.find_swiftlint() ~= nil
end

-- Parse swiftlint output
function M.parse_swiftlint_output(output)
  local diagnostics = {}

  for line in output:gmatch("[^\r\n]+") do
    -- Format: file:line:column: severity: message (rule_id)
    local file, lnum, col, severity, message = line:match("([^:]+):(%d+):(%d+):%s*(%w+):%s*(.+)")

    if file and lnum and col and severity and message then
      local diag_severity = vim.diagnostic.severity.INFO

      if severity:lower() == "error" then
        diag_severity = vim.diagnostic.severity.ERROR
      elseif severity:lower() == "warning" then
        diag_severity = vim.diagnostic.severity.WARN
      end

      table.insert(diagnostics, {
        filename = file,
        lnum = tonumber(lnum) - 1, -- 0-indexed
        col = tonumber(col) - 1, -- 0-indexed
        severity = diag_severity,
        message = message,
        source = "swiftlint",
      })
    end
  end

  return diagnostics
end

-- Lint file
function M.lint_file(filename)
  local swiftlint = M.find_swiftlint()
  if not swiftlint then
    vim.notify("swiftlint not found", vim.log.levels.WARN, { title = "swift.nvim" })
    return {}
  end

  filename = filename or vim.api.nvim_buf_get_name(0)

  local cmd = { swiftlint, "lint", filename }

  -- Add config file if found
  local config_file = M.find_config_file()
  if config_file then
    table.insert(cmd, "--config")
    table.insert(cmd, config_file)
  end

  local result = vim.fn.system(cmd)
  return M.parse_swiftlint_output(result)
end

-- Lint current buffer
function M.lint()
  local filename = vim.api.nvim_buf_get_name(0)

  if filename == "" then
    vim.notify("Buffer has no filename", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  -- Save buffer first
  vim.cmd("silent! write")

  local diagnostics = M.lint_file(filename)

  -- Set diagnostics for current buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local namespace = vim.api.nvim_create_namespace("swiftlint")

  -- Filter diagnostics for current file
  local buf_diagnostics = {}
  for _, diag in ipairs(diagnostics) do
    if diag.filename == filename then
      table.insert(buf_diagnostics, {
        lnum = diag.lnum,
        col = diag.col,
        severity = diag.severity,
        message = diag.message,
        source = diag.source,
      })
    end
  end

  vim.diagnostic.set(namespace, bufnr, buf_diagnostics, {})

  if #buf_diagnostics == 0 then
    vim.notify("No SwiftLint issues found", vim.log.levels.INFO, { title = "swift.nvim" })
  else
    local errors = 0
    local warnings = 0
    for _, diag in ipairs(buf_diagnostics) do
      if diag.severity == vim.diagnostic.severity.ERROR then
        errors = errors + 1
      elseif diag.severity == vim.diagnostic.severity.WARN then
        warnings = warnings + 1
      end
    end
    vim.notify(
      string.format("SwiftLint: %d error(s), %d warning(s)", errors, warnings),
      vim.log.levels.INFO,
      { title = "swift.nvim" }
    )
  end
end

-- Auto-fix lint issues
function M.fix(filename)
  local swiftlint = M.find_swiftlint()
  if not swiftlint then
    vim.notify("swiftlint not found", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  filename = filename or vim.api.nvim_buf_get_name(0)

  if filename == "" then
    vim.notify("Buffer has no filename", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  -- Save buffer first
  vim.cmd("silent! write")

  local cmd = { swiftlint, "lint", "--fix", filename }

  -- Add config file if found
  local config_file = M.find_config_file()
  if config_file then
    table.insert(cmd, "--config")
    table.insert(cmd, config_file)
  end

  local result = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  -- Reload buffer to see changes
  vim.cmd("silent! edit!")

  if exit_code == 0 then
    vim.notify("SwiftLint auto-fix completed", vim.log.levels.INFO, { title = "swift.nvim" })
  else
    vim.notify("SwiftLint auto-fix failed: " .. result, vim.log.levels.ERROR, { title = "swift.nvim" })
  end

  -- Re-lint to show remaining issues
  M.lint()
end

-- Setup lint on save
function M.setup_lint_on_save()
  local augroup = vim.api.nvim_create_augroup("SwiftLint", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = "*.swift",
    callback = function()
      if config.auto_fix then
        M.fix()
      else
        M.lint()
      end
    end,
    desc = "Lint Swift file on save",
  })
end

-- Setup commands
function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftLint", function()
    M.lint()
  end, { desc = "Lint Swift file with SwiftLint" })

  vim.api.nvim_create_user_command("SwiftLintFix", function()
    M.fix()
  end, { desc = "Auto-fix SwiftLint issues" })
end

-- Get linter info
function M.get_info()
  return {
    available = M.is_available(),
    swiftlint_path = M.find_swiftlint(),
    config_file = M.find_config_file(),
    lint_on_save = config.lint_on_save,
    auto_fix = config.auto_fix,
  }
end

return M
