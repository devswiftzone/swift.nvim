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

-- Find files matching pattern in parent directories
function M.find_pattern_upwards(pattern, start_path)
  start_path = start_path or vim.fn.getcwd()
  local path = start_path

  while path ~= "/" do
    local matches = vim.fn.glob(path .. "/" .. pattern, false, true)
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

return M
