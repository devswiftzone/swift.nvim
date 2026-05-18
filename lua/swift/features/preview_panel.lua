local M = {}

local config = require("swift.core.config")
local parser = require("swift.features.preview_parser")
local runner = require("swift.features.htmlkit_runner")

local panel_bufnr = nil
local panel_winid = nil
local current_previews = {}
local selected_preview_idx = 1
local active_mode = "static" -- "static" | "interactive"

local ns_id = vim.api.nvim_create_namespace("swift_preview_panel")

local function is_panel_open()
  return panel_winid and vim.api.nvim_win_is_valid(panel_winid)
end

local function draw_panel()
  if not is_panel_open() or not panel_bufnr then
    return
  end

  -- Setup content
  local lines = {
    " Swift Live Preview",
    " ==================",
    "",
  }

  -- Render Buttons
  local interactive_btn = " [ ▶ Interactivo ] "
  local static_btn = " [ ⏸ Estático ] "

  if active_mode == "interactive" then
    interactive_btn = "*[ ▶ Interactivo ]*"
  else
    static_btn = "*[ ⏸ Estático ]*"
  end

  table.insert(lines, " " .. interactive_btn .. "  " .. static_btn)
  table.insert(lines, "")
  table.insert(lines, " Previews Detectados:")
  table.insert(lines, " --------------------")

  if #current_previews == 0 then
    table.insert(lines, "  (No se detectaron macros #Preview)")
  else
    for i, p in ipairs(current_previews) do
      local prefix = (i == selected_preview_idx) and "  ➜ " or "    "
      table.insert(lines, prefix .. p.name .. " (Línea " .. p.line .. ")")
    end
  end

  -- Set lines
  vim.api.nvim_buf_set_option(panel_bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(panel_bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(panel_bufnr, "modifiable", false)

  -- Apply highlights
  vim.api.nvim_buf_clear_namespace(panel_bufnr, ns_id, 0, -1)

  -- Highlight title
  vim.api.nvim_buf_add_highlight(panel_bufnr, ns_id, "Title", 0, 1, 19)

  -- Highlight buttons based on state
  local btn_line = 3
  if active_mode == "interactive" then
    vim.api.nvim_buf_add_highlight(panel_bufnr, ns_id, "String", btn_line, 1, 20)
    vim.api.nvim_buf_add_highlight(panel_bufnr, ns_id, "Comment", btn_line, 22, 40)
  else
    vim.api.nvim_buf_add_highlight(panel_bufnr, ns_id, "Comment", btn_line, 1, 20)
    vim.api.nvim_buf_add_highlight(panel_bufnr, ns_id, "String", btn_line, 22, 40)
  end

  -- Highlight selected preview
  if #current_previews > 0 then
    local start_idx = 7
    vim.api.nvim_buf_add_highlight(panel_bufnr, ns_id, "Type", start_idx + selected_preview_idx - 1, 0, -1)
  end
end

local function handle_click()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2]

  -- Button row is 4 (1-indexed)
  if row == 4 then
    if col < 21 then
      active_mode = "interactive"
      draw_panel()

      -- Launch interactive
      if #current_previews > 0 then
        local p = current_previews[selected_preview_idx]
        runner.run_interactive(p.name)
      end
    else
      active_mode = "static"
      draw_panel()
      runner.stop_interactive()

      -- Launch static
      if #current_previews > 0 then
        local p = current_previews[selected_preview_idx]
        runner.run_static(p.name)
      end
    end
    return
  end

  -- Preview selection (row 8 onwards)
  local preview_start_row = 8
  if row >= preview_start_row and row < preview_start_row + #current_previews then
    selected_preview_idx = row - preview_start_row + 1
    draw_panel()

    -- Auto-trigger based on active mode
    local p = current_previews[selected_preview_idx]
    if active_mode == "interactive" then
      runner.run_interactive(p.name)
    else
      runner.run_static(p.name)
    end
  end
end

function M.open_panel()
  if is_panel_open() then
    return
  end

  local opts = config.get_feature("preview_panel")

  -- Create buffer
  panel_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(panel_bufnr, "SwiftPreviewPanel")
  vim.api.nvim_buf_set_option(panel_bufnr, "filetype", "swift_preview")
  vim.api.nvim_buf_set_option(panel_bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(panel_bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(panel_bufnr, "bufhidden", "wipe")

  -- Set keymaps
  vim.keymap.set("n", "<CR>", handle_click, { buffer = panel_bufnr, silent = true, noremap = true })
  vim.keymap.set("n", "q", M.close_panel, { buffer = panel_bufnr, silent = true, noremap = true })

  -- Open window
  local split_cmd = opts.position == "left" and "topleft vsplit" or "botright vsplit"
  if opts.position == "bottom" then
    split_cmd = "botright split"
  end

  vim.cmd(split_cmd)
  panel_winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(panel_winid, panel_bufnr)

  -- Set width/height
  if opts.position == "bottom" then
    vim.api.nvim_win_set_height(panel_winid, opts.width)
  else
    vim.api.nvim_win_set_width(panel_winid, opts.width)
  end

  -- Set window options
  vim.api.nvim_win_set_option(panel_winid, "number", false)
  vim.api.nvim_win_set_option(panel_winid, "relativenumber", false)
  vim.api.nvim_win_set_option(panel_winid, "wrap", false)
  vim.api.nvim_win_set_option(panel_winid, "winfixwidth", true)

  -- Go back to original window
  vim.cmd("wincmd p")

  draw_panel()
end

function M.close_panel()
  if is_panel_open() then
    vim.api.nvim_win_close(panel_winid, true)
    panel_winid = nil
    panel_bufnr = nil
  end
  runner.stop_interactive()
end

function M.toggle_panel()
  if is_panel_open() then
    M.close_panel()
  else
    M.open_panel()
    M.refresh(vim.api.nvim_get_current_buf())
  end
end

function M.refresh(bufnr)
  if not is_panel_open() then
    return
  end

  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if filetype ~= "swift" then
    return
  end

  current_previews = parser.detect_previews(bufnr)

  if selected_preview_idx > #current_previews then
    selected_preview_idx = math.max(1, #current_previews)
  end

  draw_panel()
end

function M.setup(opts)
  -- Auto-command to refresh on save
  local group = vim.api.nvim_create_augroup("SwiftPreviewPanel", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    group = group,
    pattern = "*.swift",
    callback = function(args)
      M.refresh(args.buf)
    end,
  })

  -- Create user command
  vim.api.nvim_create_user_command("SwiftPreviewPanel", function()
    M.toggle_panel()
  end, { desc = "Toggle Swift Preview Panel" })
end

return M
