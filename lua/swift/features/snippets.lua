local M = {}

local config = require("swift.config")

-- Check if LuaSnip is available
function M.is_luasnip_available()
  local ok, _ = pcall(require, "luasnip")
  return ok
end

-- Check if nvim-cmp is available
function M.is_cmp_available()
  local ok, _ = pcall(require, "cmp")
  return ok
end

-- Load Swift snippets into LuaSnip
function M.load_snippets()
  if not M.is_luasnip_available() then
    vim.notify("LuaSnip not found. Snippets will not be available.", vim.log.levels.WARN, { title = "swift.nvim" })
    return false
  end

  local luasnip = require("luasnip")
  local snippet_collection = require("swift.snippets")

  -- Convert our snippet format to LuaSnip format
  local snippets = {}

  for _, snip in ipairs(snippet_collection.snippets) do
    -- Handle multi-line bodies
    local body_text
    if type(snip.body) == "table" then
      body_text = table.concat(snip.body, "\n")
    else
      body_text = snip.body
    end

    table.insert(snippets, {
      trigger = snip.trigger,
      name = snip.name,
      dscr = snip.dscr,
      body = body_text,
    })
  end

  -- Add snippets to LuaSnip using the snippet collection
  local ls = require("luasnip")
  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node
  local parse = ls.parser.parse_snippet

  local luasnip_snippets = {}

  for _, snip in ipairs(snippets) do
    -- Parse the body to convert $1, $2 placeholders to LuaSnip format
    local parsed_snip = parse(snip.trigger, snip.body)
    parsed_snip.name = snip.name
    parsed_snip.dscr = snip.dscr

    table.insert(luasnip_snippets, parsed_snip)
  end

  -- Add snippets to LuaSnip for Swift filetype
  luasnip.add_snippets("swift", luasnip_snippets)

  return true
end

-- Get snippet info for display
function M.get_snippet_info()
  local snippet_collection = require("swift.snippets")

  return {
    total_snippets = #snippet_collection.snippets,
    luasnip_available = M.is_luasnip_available(),
    cmp_available = M.is_cmp_available(),
  }
end

-- List all available snippets
function M.list_snippets()
  local snippet_collection = require("swift.snippets")

  print("Swift Snippets:")
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

  -- Group by category
  local categories = {
    ["Structures"] = {},
    ["Functions"] = {},
    ["Properties"] = {},
    ["Control Flow"] = {},
    ["Error Handling"] = {},
    ["Async/Await"] = {},
    ["SwiftUI"] = {},
    ["Testing"] = {},
    ["Other"] = {},
  }

  for _, snip in ipairs(snippet_collection.snippets) do
    local trigger = snip.trigger
    local name = snip.name

    -- Categorize
    if trigger:match("^struct") or trigger:match("^class") or trigger:match("^enum") or trigger:match("^protocol") or trigger:match("^extension") or trigger:match("^actor") then
      table.insert(categories["Structures"], snip)
    elseif trigger:match("^func") or trigger:match("^init") or trigger:match("^deinit") then
      table.insert(categories["Functions"], snip)
    elseif trigger:match("^let") or trigger:match("^var") or trigger:match("^lazy") or trigger:match("^computed") or trigger:match("set$") or trigger:match("^@") then
      table.insert(categories["Properties"], snip)
    elseif trigger:match("^if") or trigger:match("^guard") or trigger:match("^switch") or trigger:match("^for") or trigger:match("^while") then
      table.insert(categories["Control Flow"], snip)
    elseif trigger:match("^try") or trigger:match("^dotry") or trigger:match("^throw") then
      table.insert(categories["Error Handling"], snip)
    elseif trigger:match("^async") or trigger:match("^await") or trigger:match("^task") then
      table.insert(categories["Async/Await"], snip)
    elseif trigger:match("^view") or trigger:match("^preview") or name:match("SwiftUI") then
      table.insert(categories["SwiftUI"], snip)
    elseif trigger:match("^test") then
      table.insert(categories["Testing"], snip)
    else
      table.insert(categories["Other"], snip)
    end
  end

  -- Print categorized
  for category, snips in pairs(categories) do
    if #snips > 0 then
      print(string.format("\n%s:", category))
      for _, snip in ipairs(snips) do
        print(string.format("  %-20s - %s", snip.trigger, snip.dscr))
      end
    end
  end

  print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  print(string.format("Total: %d snippets", #snippet_collection.snippets))

  if not M.is_luasnip_available() then
    print("\n⚠ LuaSnip is not installed. Install it to use snippets.")
    print("  Add to your config: 'L3MON4D3/LuaSnip'")
  end

  if not M.is_cmp_available() then
    print("\n⚠ nvim-cmp is not installed. Install it for better completion.")
    print("  Add to your config: 'hrsh7th/nvim-cmp' and 'saadparwaiz1/cmp_luasnip'")
  end
end

-- Setup commands
function M.setup_commands()
  vim.api.nvim_create_user_command("SwiftSnippets", function()
    M.list_snippets()
  end, { desc = "List Swift snippets" })

  vim.api.nvim_create_user_command("SwiftSnippetsInfo", function()
    local info = M.get_snippet_info()
    print("Swift Snippets Information:")
    print(string.format("  Total snippets: %d", info.total_snippets))
    print(string.format("  LuaSnip: %s", info.luasnip_available and "✓ Available" or "✗ Not found"))
    print(string.format("  nvim-cmp: %s", info.cmp_available and "✓ Available" or "✗ Not found"))
  end, { desc = "Show Swift snippets info" })
end

-- Setup
function M.setup(opts)
  opts = opts or {}

  if opts.enabled == false then
    return
  end

  -- Setup commands
  M.setup_commands()

  -- Load snippets if LuaSnip is available
  if M.is_luasnip_available() then
    local success = M.load_snippets()
    if success and opts.notify_on_load then
      vim.notify(
        string.format("Loaded %d Swift snippets", #require("swift.snippets").snippets),
        vim.log.levels.INFO,
        { title = "swift.nvim" }
      )
    end
  else
    if opts.warn_if_missing then
      vim.notify(
        "LuaSnip not found. Snippets feature disabled.\nInstall: 'L3MON4D3/LuaSnip'",
        vim.log.levels.WARN,
        { title = "swift.nvim" }
      )
    end
  end
end

return M
