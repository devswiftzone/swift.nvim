local root = vim.fn.fnamemodify("./.tests", ":p")

-- set stdpaths to use .tests
for _, name in ipairs({ "config", "data", "state", "cache" }) do
  vim.env[string.format("XDG_%s_HOME", name:upper())] = root .. "/" .. name
end

local function load_plugin(plugin_repo)
  local name = plugin_repo:match(".*/(.*)%.git") or plugin_repo:match(".*/(.*)")
  local plugin_path = root .. "/plugins/" .. name
  if vim.fn.isdirectory(plugin_path) == 0 then
    vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/" .. plugin_repo, plugin_path })
  end
  vim.opt.runtimepath:prepend(plugin_path)
end

load_plugin("nvim-lua/plenary.nvim")

vim.opt.runtimepath:prepend(".")
