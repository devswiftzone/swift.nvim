local M = {}

-- Query to find #Preview macros in Swift code
local preview_query_str = [[
  (macro_expansion
    macro_name: (identifier) @macro_name
    (#eq? @macro_name "Preview")
  ) @preview
]]

-- Fallback regex for when treesitter is not available
local function detect_previews_regex(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local previews = {}

  for i, line in ipairs(lines) do
    -- Match #Preview or #Preview("Name")
    local match = string.match(line, "^%s*#Preview")
    if match then
      -- Try to extract name if present
      local name = string.match(line, '#Preview%s*%(%s*"([^"]+)"') or ("Preview " .. (#previews + 1))
      table.insert(previews, {
        name = name,
        line = i,
      })
    end
  end

  return previews
end

-- Detect previews using tree-sitter
local function detect_previews_ts(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "swift")
  if not ok or not parser then
    return detect_previews_regex(bufnr)
  end

  local tree = parser:parse()[1]
  local root = tree:root()

  local ok_query, query = pcall(vim.treesitter.query.parse, "swift", preview_query_str)
  if not ok_query then
    return detect_previews_regex(bufnr)
  end

  local previews = {}
  for id, node, metadata in query:iter_captures(root, bufnr, 0, -1) do
    local name = query.captures[id]
    if name == "preview" then
      local start_row, start_col, end_row, end_col = node:range()

      -- Default name
      local preview_name = "Preview " .. (#previews + 1)

      -- Try to extract name from tuple argument if it exists
      -- e.g., #Preview("My View")
      for child in node:iter_children() do
        if child:type() == "tuple_expression" then
          -- Get text of tuple
          local tuple_text = vim.treesitter.get_node_text(child, bufnr)
          local extracted_name = string.match(tuple_text, '"([^"]+)"')
          if extracted_name then
            preview_name = extracted_name
          end
          break
        end
      end

      table.insert(previews, {
        name = preview_name,
        line = start_row + 1,
        node = node,
      })
    end
  end

  return previews
end

function M.detect_previews(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if treesitter is available
  local has_ts = pcall(require, "nvim-treesitter")

  if has_ts then
    return detect_previews_ts(bufnr)
  else
    return detect_previews_regex(bufnr)
  end
end

return M
