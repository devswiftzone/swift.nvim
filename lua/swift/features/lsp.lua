local M = {}

local config = {}
local lsp_setup_done = false

function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    auto_setup = true, -- Automatically setup LSP
    sourcekit_path = nil, -- Auto-detect if nil
    inlay_hints = true, -- Enable inlay hints
    semantic_tokens = true, -- Enable semantic tokens
    on_attach = nil, -- Custom on_attach function
    capabilities = nil, -- Custom capabilities
    cmd = nil, -- Custom command (auto-detected if nil)
    root_dir = nil, -- Custom root_dir function
    filetypes = { "swift" },
    settings = {},
  }, opts or {})

  if config.auto_setup then
    M.setup_lsp()
  end
end

-- Find sourcekit-lsp executable
function M.find_sourcekit_lsp()
  if config.sourcekit_path then
    return config.sourcekit_path
  end

  -- Try common locations
  local possible_paths = {
    vim.fn.exepath("sourcekit-lsp"),
    "/usr/bin/sourcekit-lsp",
    "/usr/local/bin/sourcekit-lsp",
    "/opt/homebrew/bin/sourcekit-lsp",
  }

  -- Try Xcode toolchain
  if vim.fn.has("mac") == 1 then
    local xcrun_path = vim.fn.system("xcrun --find sourcekit-lsp 2>/dev/null"):gsub("\n", "")
    if xcrun_path ~= "" and vim.fn.executable(xcrun_path) == 1 then
      table.insert(possible_paths, 1, xcrun_path)
    end
  end

  for _, path in ipairs(possible_paths) do
    if path ~= "" and vim.fn.executable(path) == 1 then
      return path
    end
  end

  return nil
end

-- Check if sourcekit-lsp is available
function M.is_available()
  return M.find_sourcekit_lsp() ~= nil
end

-- Get root directory for Swift project
function M.get_root_dir()
  if config.root_dir then
    return config.root_dir
  end

  -- Try to use project_detector
  local detector_ok, detector = pcall(require, "swift.features.project_detector")
  if detector_ok then
    return function(fname)
      local root = detector.get_project_root()
      if root then
        return root
      end

      -- Fallback to manual detection
      return vim.fs.dirname(vim.fs.find({ "Package.swift", ".git" }, { upward = true, path = fname })[1])
    end
  end

  -- Fallback root_dir function
  return function(fname)
    return vim.fs.dirname(vim.fs.find({ "Package.swift", ".git" }, { upward = true, path = fname })[1])
  end
end

-- Default on_attach function
function M.default_on_attach(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Go to definition/declaration
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

  -- Hover documentation
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

  -- Implementation/references
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

  -- Signature help
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

  -- Code actions
  vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

  -- Rename
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

  -- Format
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)

  -- Diagnostics
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

  -- Inlay hints
  if config.inlay_hints and client.server_capabilities.inlayHintProvider then
    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end

  -- Semantic tokens
  if config.semantic_tokens and client.server_capabilities.semanticTokensProvider then
    -- Semantic tokens are enabled by default in Neovim 0.9+
  end

  -- Call user's on_attach if provided
  if config.on_attach then
    config.on_attach(client, bufnr)
  end
end

-- Get capabilities
function M.get_capabilities()
  if config.capabilities then
    return config.capabilities
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Add completion capabilities if nvim-cmp is available
  local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if cmp_ok then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

-- Setup LSP with lspconfig
function M.setup_lsp()
  if lsp_setup_done then
    return
  end

  local sourcekit_path = M.find_sourcekit_lsp()
  if not sourcekit_path then
    vim.notify(
      "sourcekit-lsp not found. Please install Swift toolchain.",
      vim.log.levels.WARN,
      { title = "swift.nvim" }
    )
    return
  end

  -- Try to use nvim-lspconfig
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if not lspconfig_ok then
    vim.notify(
      "nvim-lspconfig not found. Please install it for LSP support.",
      vim.log.levels.WARN,
      { title = "swift.nvim" }
    )
    return
  end

  local cmd = config.cmd or { sourcekit_path }

  lspconfig.sourcekit.setup({
    cmd = cmd,
    filetypes = config.filetypes,
    root_dir = M.get_root_dir(),
    on_attach = M.default_on_attach,
    capabilities = M.get_capabilities(),
    settings = config.settings,
  })

  lsp_setup_done = true

  vim.notify("sourcekit-lsp configured successfully", vim.log.levels.INFO, { title = "swift.nvim" })
end

-- Manual LSP setup (if auto_setup is disabled)
function M.get_lsp_config()
  return {
    cmd = config.cmd or { M.find_sourcekit_lsp() },
    filetypes = config.filetypes,
    root_dir = M.get_root_dir(),
    on_attach = M.default_on_attach,
    capabilities = M.get_capabilities(),
    settings = config.settings,
  }
end

-- Restart LSP server
function M.restart()
  vim.cmd("LspRestart sourcekit")
end

-- Get LSP client info
function M.get_client()
  local clients = vim.lsp.get_active_clients({ name = "sourcekit" })
  return clients[1]
end

-- Check LSP status
function M.status()
  local client = M.get_client()
  if client then
    return {
      active = true,
      name = client.name,
      cmd = client.config.cmd,
      root_dir = client.config.root_dir,
      capabilities = client.server_capabilities,
    }
  else
    return {
      active = false,
      sourcekit_available = M.is_available(),
      sourcekit_path = M.find_sourcekit_lsp(),
    }
  end
end

return M
