local M = {}

-- Show a Telescope picker for Xcode schemes
function M.xcode_schemes()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("Telescope is not installed", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local xcode = require("swift.features.xcode")
  local schemes = xcode.list_schemes()

  if #schemes == 0 then
    vim.notify("No schemes found", vim.log.levels.INFO, { title = "swift.nvim" })
    return
  end

  pickers
    .new({}, {
      prompt_title = "Xcode Schemes",
      finder = finders.new_table({
        results = schemes,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            xcode.build(selection[1])
          end
        end)
        return true
      end,
    })
    :find()
end

-- Show a Telescope picker for Swift targets (SPM)
function M.swift_targets()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("Telescope is not installed", vim.log.levels.WARN, { title = "swift.nvim" })
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local target_manager = require("swift.features.target_manager")
  local targets = target_manager.get_targets()

  if #targets == 0 then
    vim.notify("No targets found", vim.log.levels.INFO, { title = "swift.nvim" })
    return
  end

  local display_items = {}
  for _, target in ipairs(targets) do
    local icon = target.type == "executable" and "󰘧 " or "󰴋 "
    table.insert(display_items, {
      value = target,
      display = icon .. target.name,
      ordinal = target.name,
    })
  end

  pickers
    .new({}, {
      prompt_title = "Swift Targets",
      finder = finders.new_table({
        results = display_items,
        entry_maker = function(entry)
          return {
            value = entry.value,
            display = entry.display,
            ordinal = entry.ordinal,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            target_manager.set_current_target(selection.value.name)
          end
        end)
        return true
      end,
    })
    :find()
end

return M
