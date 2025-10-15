local M = {}

local config = {}

M.FormatterType = {
  SWIFT_FORMAT = "swift-format",
  SWIFTFORMAT = "swiftformat",
}

function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    enabled = true,
    tool = nil, -- Auto-detect: "swift-format" | "swiftformat" | nil
    format_on_save = false,
    config_file = nil, -- Auto-detect
    swift_format_path = nil,
    swiftformat_path = nil,
  }, opts or {})

  if config.format_on_save then
    M.setup_format_on_save()
  end

  M.setup_commands()
end

-- Find swift-format executable
function M.find_swift_format()
  if config.swift_format_path then
    return config.swift_format_path
  end

  local possible_paths = {
    vim.fn.exepath("swift-format"),
    "/usr/local/bin/swift-format",
    "/opt/homebrew/bin/swift-format",
  }

  for _, path in ipairs(possible_paths) do
    if path ~= "" and vim.fn.executable(path) == 1 then
      return path
    end
  end

  return nil
end

-- Find swiftformat executable
function M.find_swiftformat()
  if config.swiftformat_path then
    return config.swiftformat_path
  end

  local possible_paths = {
    vim.fn.exepath("swiftformat"),
    "/usr/local/bin/swiftformat",
    "/opt/homebrew/bin/swiftformat",
  }

  for _, path in ipairs(possible_paths) do
    if path ~= "" and vim.fn.executable(path) == 1 then
      return path
    end
  end

  return nil
end

-- Detect which formatter is available
function M.detect_formatter()
  if config.tool then
    return config.tool
  end

  -- Try swift-format first (official Apple tool)
  if M.find_swift_format() then
    return M.FormatterType.SWIFT_FORMAT
  end

  -- Try swiftformat
  if M.find_swiftformat() then
    return M.FormatterType.SWIFTFORMAT
  end

  return nil
end

-- Find config file for formatter
function M.find_config_file(formatter_type)
  if config.config_file then
    return config.config_file
  end

  local utils = require("swift.utils")

  if formatter_type == M.FormatterType.SWIFT_FORMAT then
    -- Look for .swift-format
    return utils.find_file_upwards(".swift-format")
  elseif formatter_type == M.FormatterType.SWIFTFORMAT then
    -- Look for .swiftformat
    return utils.find_file_upwards(".swiftformat")
  end

  return nil
end

-- Check if formatter is available
function M.is_available()
  return M.detect_formatter() ~= nil
end

-- Format buffer with swift-format
function M.format_with_swift_format(bufnr)
  local swift_format = M.find_swift_format()
  if not swift_format then
    vim.notify("swift-format not found", vim.log.levels.ERROR, { title = "swift.nvim" })
    return false
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")

  local cmd = { swift_format }

  -- Add config file if found
  local config_file = M.find_config_file(M.FormatterType.SWIFT_FORMAT)
  if config_file then
    table.insert(cmd, "--configuration")
    table.insert(cmd, config_file)
  end

  local result = vim.fn.system(cmd, content)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    vim.notify("swift-format failed: " .. result, vim.log.levels.ERROR, { title = "swift.nvim" })
    return false
  end

  local new_lines = vim.split(result, "\n")

  -- Remove empty last line if exists
  if new_lines[#new_lines] == "" then
    table.remove(new_lines)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
  return true
end

-- Format buffer with swiftformat
function M.format_with_swiftformat(bufnr)
  local swiftformat = M.find_swiftformat()
  if not swiftformat then
    vim.notify("swiftformat not found", vim.log.levels.ERROR, { title = "swift.nvim" })
    return false
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if filename == "" then
    vim.notify("Buffer has no filename", vim.log.levels.WARN, { title = "swift.nvim" })
    return false
  end

  -- Save buffer first
  vim.cmd("silent! write")

  local cmd = { swiftformat, filename }

  -- Add config file if found
  local config_file = M.find_config_file(M.FormatterType.SWIFTFORMAT)
  if config_file then
    table.insert(cmd, "--config")
    table.insert(cmd, config_file)
  end

  local result = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    vim.notify("swiftformat failed: " .. result, vim.log.levels.ERROR, { title = "swift.nvim" })
    return false
  end

  -- Reload buffer
  vim.cmd("silent! edit!")
  return true
end

-- Format current buffer
function M.format(bufnr, formatter_type)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  formatter_type = formatter_type or M.detect_formatter()

  if not formatter_type then
    vim.notify(
      "No Swift formatter found. Install swift-format or swiftformat.",
      vim.log.levels.WARN,
      { title = "swift.nvim" }
    )
    return false
  end

  if formatter_type == M.FormatterType.SWIFT_FORMAT then
    return M.format_with_swift_format(bufnr)
  elseif formatter_type == M.FormatterType.SWIFTFORMAT then
    return M.format_with_swiftformat(bufnr)
  end

  return false
end

-- Format visual selection
function M.format_selection()
  local formatter = M.detect_formatter()

  if not formatter then
    vim.notify(
      "No Swift formatter found",
      vim.log.levels.WARN,
      { title = "swift.nvim" }
    )
    return
  end

  -- For now, format the whole buffer
  -- TODO: Implement proper range formatting
  vim.notify(
    "Formatting whole buffer (range formatting not yet implemented)",
    vim.log.levels.INFO,
    { title = "swift.nvim" }
  )
  M.format()
end

-- Setup format on save
function M.setup_format_on_save()
  local augroup = vim.api.nvim_create_augroup("SwiftFormat", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*.swift",
    callback = function(args)
      M.format(args.buf)
    end,
    desc = "Format Swift file on save",
  })
end

-- Setup commands
function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftFormat", function()
    M.format()
  end, { desc = "Format Swift file" })

  vim.api.nvim_create_user_command("SwiftFormatSelection", function()
    M.format_selection()
  end, { desc = "Format Swift selection" })
end

-- Get formatter info
function M.get_info()
  local formatter = M.detect_formatter()

  return {
    available = formatter ~= nil,
    formatter = formatter,
    config_file = formatter and M.find_config_file(formatter) or nil,
    swift_format_path = M.find_swift_format(),
    swiftformat_path = M.find_swiftformat(),
  }
end

return M
