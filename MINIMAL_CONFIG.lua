-- ═══════════════════════════════════════════════════════════════════════════════
--  CONFIGURACIÓN MINIMALISTA DE SWIFT.NVIM
--  Todo activado con defaults, keybindings esenciales
-- ═══════════════════════════════════════════════════════════════════════════════

return {
  "devswiftzone/swift.nvim",
  ft = "swift",
  opts = {
    -- Todo activado con configuración por defecto
    -- Solo personaliza lo que quieras cambiar
  },
  config = function(_, opts)
    require("swift").setup(opts)

    -- Debugger (Teclas F estándar)
    local debugger = require("swift.features.debugger")
    vim.keymap.set("n", "<F5>", debugger.continue, { desc = "Debug: Continue" })
    vim.keymap.set("n", "<F9>", debugger.toggle_breakpoint, { desc = "Debug: Breakpoint" })
    vim.keymap.set("n", "<F10>", debugger.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<F11>", debugger.step_into, { desc = "Debug: Step Into" })

    -- Build (solo lo esencial)
    vim.keymap.set("n", "<leader>bb", ":SwiftBuild<CR>", { desc = "Build" })
    vim.keymap.set("n", "<leader>br", ":SwiftRun<CR>", { desc = "Run" })
    vim.keymap.set("n", "<leader>bt", ":SwiftTest<CR>", { desc = "Test" })

    -- Format & Lint
    vim.keymap.set("n", "<leader>sf", ":SwiftFormat<CR>", { desc = "Format" })
    vim.keymap.set("n", "<leader>sl", ":SwiftLint<CR>", { desc = "Lint" })
  end,
}
