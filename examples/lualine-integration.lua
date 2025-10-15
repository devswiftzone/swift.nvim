-- LuaLine Integration Examples for swift.nvim
--
-- This file contains examples of how to integrate Swift target information
-- into your LuaLine statusline.

-- ============================================================================
-- Example 1: Simple Target Display
-- ============================================================================
-- Shows only the current target name with an icon

local function swift_target_simple()
  local ok, target_manager = pcall(require, "swift.features.target_manager")
  if not ok then
    return ""
  end

  return target_manager.statusline_simple()
end

-- Add to your LuaLine config:
-- require("lualine").setup({
--   sections = {
--     lualine_x = { swift_target_simple, "encoding", "fileformat", "filetype" },
--   },
-- })

-- ============================================================================
-- Example 2: Detailed Target Display
-- ============================================================================
-- Shows target name and total number of targets

local function swift_target_detailed()
  local ok, target_manager = pcall(require, "swift.features.target_manager")
  if not ok then
    return ""
  end

  return target_manager.statusline_detailed()
end

-- Add to your LuaLine config:
-- require("lualine").setup({
--   sections = {
--     lualine_x = { swift_target_detailed, "encoding", "fileformat", "filetype" },
--   },
-- })

-- ============================================================================
-- Example 3: Custom Formatted Target
-- ============================================================================
-- Full control over formatting

local function swift_target_custom()
  local ok, target_manager = pcall(require, "swift.features.target_manager")
  if not ok then
    return ""
  end

  -- Only show in Swift files
  if vim.bo.filetype ~= "swift" then
    return ""
  end

  local info = target_manager.get_statusline_info()
  if not info then
    return ""
  end

  if not info.current_target then
    return ""
  end

  -- Custom icons based on project type
  local icons = {
    spm = "󰛥",
    xcode_project = "",
    xcode_workspace = "",
  }

  local icon = icons[info.project_type] or "󰛥"

  return string.format("%s %s", icon, info.current_target)
end

-- ============================================================================
-- Example 4: Clickable Target Selector
-- ============================================================================
-- Click to select a different target (requires Neovim 0.8+)

local function swift_target_clickable()
  local ok, target_manager = pcall(require, "swift.features.target_manager")
  if not ok then
    return ""
  end

  if vim.bo.filetype ~= "swift" then
    return ""
  end

  local info = target_manager.get_statusline_info()
  if not info or not info.current_target then
    return ""
  end

  -- Add click handler
  return string.format("%%{v:lua.require'swift.features.target_manager'.select_target()}󰛥 %s%%X", info.current_target)
end

-- ============================================================================
-- Example 5: Complete LuaLine Setup with Swift Integration
-- ============================================================================

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_, opts)
    -- Swift target component
    local swift_target = {
      function()
        local ok, target_manager = pcall(require, "swift.features.target_manager")
        if not ok then
          return ""
        end

        if vim.bo.filetype ~= "swift" then
          return ""
        end

        return target_manager.statusline_detailed()
      end,
      icon = "󰛥",
      color = { fg = "#ff6b00" }, -- Swift orange
      on_click = function()
        require("swift.features.target_manager").select_target()
      end,
    }

    -- Add to sections
    table.insert(opts.sections.lualine_x, 1, swift_target)

    return opts
  end,
}

-- ============================================================================
-- Example 6: LazyVim Compatible Setup
-- ============================================================================
-- For LazyVim users, create this in: ~/.config/nvim/lua/plugins/lualine.lua

--[[
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local swift_component = {
      function()
        local ok, tm = pcall(require, "swift.features.target_manager")
        if not ok or vim.bo.filetype ~= "swift" then
          return ""
        end
        return tm.statusline_simple()
      end,
      color = { fg = "#ff6b00" },
    }

    table.insert(opts.sections.lualine_x, 1, swift_component)
  end,
}
]]

-- ============================================================================
-- Example 7: With Project Type Indicator
-- ============================================================================

local function swift_with_project_type()
  local ok, target_manager = pcall(require, "swift.features.target_manager")
  if not ok or vim.bo.filetype ~= "swift" then
    return ""
  end

  local info = target_manager.get_statusline_info()
  if not info then
    return ""
  end

  local type_labels = {
    spm = "SPM",
    xcode_project = "Xcode",
    xcode_workspace = "Workspace",
  }

  local type_label = type_labels[info.project_type] or "Swift"
  local target_text = info.current_target or "No target"

  return string.format("%s • %s", type_label, target_text)
end

-- ============================================================================
-- Example 8: Minimal Setup (Just the Target Name)
-- ============================================================================

--[[
-- In your init.lua or LuaLine config:

require("lualine").setup({
  sections = {
    lualine_c = {
      "filename",
      {
        function()
          if vim.bo.filetype ~= "swift" then
            return ""
          end
          local ok, tm = pcall(require, "swift.features.target_manager")
          if ok then
            return tm.get_current_target() or ""
          end
          return ""
        end,
      },
    },
  },
})
]]

-- ============================================================================
-- Example 9: Advanced - With Build Status Integration
-- ============================================================================

local function swift_target_with_status()
  local ok, target_manager = pcall(require, "swift.features.target_manager")
  if not ok or vim.bo.filetype ~= "swift" then
    return ""
  end

  local info = target_manager.get_statusline_info()
  if not info or not info.current_target then
    return ""
  end

  -- Check if build is running (if you have build_runner integration)
  local build_ok, build_runner = pcall(require, "swift.features.build_runner")
  local status_icon = ""

  if build_ok and build_runner._job then
    status_icon = " 󰦖" -- Building indicator
  end

  return string.format("󰛥 %s%s", info.current_target, status_icon)
end

-- ============================================================================
-- Example 10: Color-Coded by Target Type
-- ============================================================================

local function swift_target_colored()
  local ok, target_manager = pcall(require, "swift.features.target_manager")
  if not ok or vim.bo.filetype ~= "swift" then
    return ""
  end

  local targets = target_manager.get_targets()
  local current = target_manager.get_current_target()

  if not current then
    return ""
  end

  -- Find current target info
  local target_info = nil
  for _, t in ipairs(targets) do
    if t.name == current then
      target_info = t
      break
    end
  end

  if not target_info then
    return current
  end

  -- Different icons/colors per type
  local type_config = {
    executable = { icon = "󰘧", color = "#00ff00" },
    test = { icon = "󰙨", color = "#ffaa00" },
    library = { icon = "󰴋", color = "#0099ff" },
    xcode_scheme = { icon = "", color = "#ff6b00" },
    xcode_target = { icon = "", color = "#ff6b00" },
  }

  local config = type_config[target_info.type] or { icon = "󰛥", color = "#ffffff" }

  return string.format("%s %s", config.icon, current)
end

-- Usage in LuaLine with highlight:
--[[
require("lualine").setup({
  sections = {
    lualine_x = {
      {
        swift_target_colored,
        color = function()
          local ok, tm = pcall(require, "swift.features.target_manager")
          if not ok then return nil end

          local targets = tm.get_targets()
          local current = tm.get_current_target()

          for _, t in ipairs(targets) do
            if t.name == current then
              local colors = {
                executable = { fg = "#00ff00" },
                test = { fg = "#ffaa00" },
                library = { fg = "#0099ff" },
              }
              return colors[t.type] or { fg = "#ff6b00" }
            end
          end
        end,
      },
    },
  },
})
]]
