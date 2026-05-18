local parser = require("swift.features.preview_parser")

describe("Preview Parser", function()
  it("should extract previews correctly using fallback regex", function()
    -- Create a temporary buffer
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "import SwiftUI",
      "",
      "struct ContentView: View {",
      "    var body: some View {",
      '        Text("Hello, world!")',
      "    }",
      "}",
      "",
      "#Preview {",
      "    ContentView()",
      "}",
      "",
      '#Preview("Second Preview") {',
      "    ContentView()",
      "}",
    })

    -- Force treesitter to fail or mock it if needed, but the regex works on text
    -- For testing regex directly, we can just let it run if TS is not installed
    local previews = parser.detect_previews(bufnr)

    -- Assertions
    assert.are.same(2, #previews)
    assert.are.same("Preview 1", previews[1].name)
    assert.are.same(9, previews[1].line)

    assert.are.same("Second Preview", previews[2].name)
    assert.are.same(13, previews[2].line)

    -- Cleanup
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)
