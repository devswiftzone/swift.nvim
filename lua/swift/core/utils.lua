local M = {}

-- Find file in parent directories
function M.find_file_upwards(filename, start_path)
  start_path = start_path or vim.fn.getcwd()
  local path = start_path

  while path ~= "/" do
    local file_path = path .. "/" .. filename
    if vim.fn.filereadable(file_path) == 1 or vim.fn.isdirectory(file_path) == 1 then
      return file_path
    end
    path = vim.fn.fnamemodify(path, ":h")
  end

  return nil
end

-- Find files matching a suffix pattern in parent directories
-- Uses vim.uv.fs_scandir instead of vim.fn.glob to avoid blocking on large dirs
function M.find_pattern_upwards(pattern, start_path)
  start_path = start_path or vim.fn.getcwd()
  local path = start_path

  -- Convert glob pattern like "*.xcworkspace" to a suffix match
  local suffix = pattern:match("^%*(.+)$")

  -- Limit traversal depth to avoid scanning all the way to /
  local max_depth = 10
  local depth = 0

  while path ~= "/" and depth < max_depth do
    depth = depth + 1
    local matches = {}

    if suffix then
      -- Fast suffix scan using libuv (non-blocking within coroutine, instant in practice)
      local handle = vim.uv.fs_scandir(path)
      if handle then
        while true do
          local name, ftype = vim.uv.fs_scandir_next(handle)
          if not name then
            break
          end
          if (ftype == "directory" or ftype == "link") and name:sub(-#suffix) == suffix then
            table.insert(matches, path .. "/" .. name)
          end
        end
      end
    else
      -- Fallback to glob for complex patterns
      matches = vim.fn.glob(path .. "/" .. pattern, false, true)
    end

    if #matches > 0 then
      return matches
    end
    path = vim.fn.fnamemodify(path, ":h")
  end

  return {}
end

-- Check if a file exists
function M.file_exists(path)
  return vim.fn.filereadable(path) == 1
end

-- Check if a directory exists
function M.dir_exists(path)
  return vim.fn.isdirectory(path) == 1
end

-- Get the root directory of current buffer
function M.get_buffer_dir()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" then
    return vim.fn.getcwd()
  end
  return vim.fn.fnamemodify(filepath, ":p:h")
end

-- Logging utility
function M.log(message, level)
  level = level or "info"
  local levels = {
    info = vim.log.levels.INFO,
    warn = vim.log.levels.WARN,
    error = vim.log.levels.ERROR,
    debug = vim.log.levels.DEBUG,
  }

  local log_level = levels[level] or vim.log.levels.INFO
  vim.notify(message, log_level, { title = "swift.nvim" })
end

return M
