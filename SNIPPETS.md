# Swift Snippets

swift.nvim includes 50+ built-in Swift snippets for common patterns and boilerplate code.

## Requirements

- **[LuaSnip](https://github.com/L3MON4D3/LuaSnip)** - Snippet engine (required)
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)** - Completion plugin (optional but recommended)
- **[cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)** - nvim-cmp source for LuaSnip (optional)

## Installation

### With lazy.nvim

```lua
return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    dependencies = {
      "L3MON4D3/LuaSnip",           -- Required for snippets
      "hrsh7th/nvim-cmp",            -- Optional: for completion
      "saadparwaiz1/cmp_luasnip",   -- Optional: nvim-cmp source
    },
    opts = {
      features = {
        snippets = {
          enabled = true,
        },
      },
    },
  },
}
```

### Configure nvim-cmp

If you're using nvim-cmp, make sure to include LuaSnip as a source:

```lua
require("cmp").setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },  -- Add this line
    { name = "buffer" },
    { name = "path" },
  },
})
```

## Usage

Type the trigger word and press `<Tab>` (or your configured completion key) to expand the snippet.

### Example

```swift
// Type: struct<Tab>
struct MyStruct {
    // cursor here
}

// Type: func<Tab>
func myFunction(params) -> ReturnType {
    // cursor here
}
```

## Commands

- `:SwiftSnippets` - List all available snippets by category
- `:SwiftSnippetsInfo` - Show snippets info (total count, LuaSnip status)

## Available Snippets

### Structures

| Trigger | Description |
|---------|-------------|
| `struct` | Create a struct |
| `class` | Create a class |
| `enum` | Create an enum |
| `protocol` | Create a protocol |
| `extension` | Create an extension |
| `actor` | Create an actor |

### Functions

| Trigger | Description |
|---------|-------------|
| `func` | Create a function |
| `init` | Create an initializer |
| `deinit` | Create a deinitializer |
| `async` | Create an async function |

### Properties

| Trigger | Description |
|---------|-------------|
| `let` | Create a constant |
| `var` | Create a variable |
| `lazy` | Create a lazy variable |
| `computed` | Create a computed property |
| `didset` | Property with didSet observer |
| `willset` | Property with willSet observer |

### Control Flow

| Trigger | Description |
|---------|-------------|
| `if` | If statement |
| `iflet` | Optional binding with if let |
| `guard` | Guard statement |
| `guardlet` | Optional binding with guard let |
| `switch` | Switch statement |
| `for` | For-in loop |
| `while` | While loop |

### Error Handling

| Trigger | Description |
|---------|-------------|
| `try` | Try expression |
| `try?` | Optional try |
| `try!` | Force try |
| `dotry` | Do-try-catch block |
| `throw` | Throw an error |

### Async/Await

| Trigger | Description |
|---------|-------------|
| `async` | Async function |
| `await` | Await expression |
| `task` | Create a Task |
| `actor` | Create an actor |

### SwiftUI Property Wrappers

| Trigger | Description |
|---------|-------------|
| `@State` | @State property wrapper |
| `@Binding` | @Binding property wrapper |
| `@ObservedObject` | @ObservedObject property wrapper |
| `@StateObject` | @StateObject property wrapper |
| `@EnvironmentObject` | @EnvironmentObject property wrapper |
| `@Environment` | @Environment property wrapper |
| `@Published` | @Published property wrapper |

### SwiftUI Views

| Trigger | Description |
|---------|-------------|
| `view` | Create a SwiftUI View |
| `preview` | Create a SwiftUI Preview |

### Common Patterns

| Trigger | Description |
|---------|-------------|
| `singleton` | Singleton pattern |
| `codable` | Codable struct |
| `equatable` | Equatable conformance |
| `hashable` | Hashable conformance |

### Testing

| Trigger | Description |
|---------|-------------|
| `test` | Test function |
| `testcase` | XCTestCase class |

### Utilities

| Trigger | Description |
|---------|-------------|
| `print` | Print statement |
| `dump` | Dump statement for debugging |
| `mark` | MARK comment |
| `todo` | TODO comment |
| `fixme` | FIXME comment |

## Examples

### Create a struct

```swift
// Type: struct<Tab>
struct User {
    // cursor here
}
```

### Optional binding

```swift
// Type: iflet<Tab>
if let user = optionalUser {
    // cursor here
}

// Type: guardlet<Tab>
guard let user = optionalUser else {
    return
}
// cursor here
```

### SwiftUI View

```swift
// Type: view<Tab>
struct MyView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

### Async function

```swift
// Type: async<Tab>
func fetchData() async -> Data {
    // cursor here
}
```

### Error handling

```swift
// Type: dotry<Tab>
do {
    try somethingThatThrows()
} catch {
    // cursor here
}
```

## Configuration

### Enable/Disable Snippets

```lua
require("swift").setup({
  features = {
    snippets = {
      enabled = true,              -- Enable/disable snippets
      notify_on_load = false,      -- Show notification when loaded
      warn_if_missing = false,     -- Warn if LuaSnip not found
    },
  },
})
```

### Custom Keybindings for LuaSnip

```lua
-- Example: Use Tab and Shift-Tab to navigate snippets
local luasnip = require("luasnip")

vim.keymap.set({"i", "s"}, "<Tab>", function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  else
    return "<Tab>"
  end
end, { expr = true })

vim.keymap.set({"i", "s"}, "<S-Tab>", function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end)
```

## Adding Custom Snippets

You can add your own snippets by extending the snippets collection:

```lua
-- In your config
local swift_snippets = require("swift.snippets")

-- Add custom snippets
table.insert(swift_snippets.snippets, {
  trigger = "custom",
  name = "My Custom Snippet",
  dscr = "Description of my snippet",
  body = {
    "// Custom code here",
    "$0",
  },
})
```

Or create a separate snippet file and load it with LuaSnip:

```lua
-- ~/.config/nvim/lua/snippets/swift.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("swift", {
  s("mycustom", {
    t("// My custom snippet"),
    t({"", ""}),
    i(1),
  }),
})
```

## Troubleshooting

### Snippets not working

1. **Check if LuaSnip is installed:**
   ```vim
   :lua print(vim.inspect(require("luasnip")))
   ```

2. **Run health check:**
   ```vim
   :checkhealth swift
   ```

3. **List available snippets:**
   ```vim
   :SwiftSnippets
   ```

### Snippets not appearing in completion

1. **Make sure cmp_luasnip is installed**
2. **Check nvim-cmp configuration** includes `luasnip` source
3. **Verify LuaSnip is configured as snippet engine:**
   ```lua
   cmp.setup({
     snippet = {
       expand = function(args)
         require("luasnip").lsp_expand(args.body)
       end,
     },
   })
   ```

### Can't navigate between placeholders

Configure keybindings for LuaSnip navigation (see Configuration section above).

## Resources

- [LuaSnip Documentation](https://github.com/L3MON4D3/LuaSnip)
- [nvim-cmp Documentation](https://github.com/hrsh7th/nvim-cmp)
- [Swift Language Guide](https://docs.swift.org/swift-book/)
