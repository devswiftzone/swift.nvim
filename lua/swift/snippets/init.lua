-- Swift Snippets Collection
-- These snippets are compatible with LuaSnip
local M = {}

-- Snippet format:
-- {
--   trigger = "...",      -- What you type to trigger
--   name = "...",         -- Display name
--   dscr = "...",         -- Description
--   body = {...}          -- Lines of code (can use placeholders like $1, $2, etc.)
-- }

M.snippets = {
  -- Basic structures
  {
    trigger = "struct",
    name = "Struct",
    dscr = "Create a struct",
    body = {
      "struct ${1:Name} {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "class",
    name = "Class",
    dscr = "Create a class",
    body = {
      "class ${1:Name} {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "enum",
    name = "Enum",
    dscr = "Create an enum",
    body = {
      "enum ${1:Name} {",
      "\tcase ${2:case1}",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "protocol",
    name = "Protocol",
    dscr = "Create a protocol",
    body = {
      "protocol ${1:Name} {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "extension",
    name = "Extension",
    dscr = "Create an extension",
    body = {
      "extension ${1:Type} {",
      "\t$0",
      "}",
    },
  },

  -- Functions
  {
    trigger = "func",
    name = "Function",
    dscr = "Create a function",
    body = {
      "func ${1:name}(${2:params}) ${3:-> ${4:ReturnType} }{",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "init",
    name = "Initializer",
    dscr = "Create an initializer",
    body = {
      "init(${1:params}) {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "deinit",
    name = "Deinitializer",
    dscr = "Create a deinitializer",
    body = {
      "deinit {",
      "\t$0",
      "}",
    },
  },

  -- Properties
  {
    trigger = "let",
    name = "Let constant",
    dscr = "Create a constant",
    body = "let ${1:name}: ${2:Type} = ${3:value}",
  },
  {
    trigger = "var",
    name = "Var variable",
    dscr = "Create a variable",
    body = "var ${1:name}: ${2:Type} = ${3:value}",
  },
  {
    trigger = "lazy",
    name = "Lazy variable",
    dscr = "Create a lazy variable",
    body = "lazy var ${1:name}: ${2:Type} = ${3:value}",
  },
  {
    trigger = "computed",
    name = "Computed property",
    dscr = "Create a computed property",
    body = {
      "var ${1:name}: ${2:Type} {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "didset",
    name = "Property with didSet",
    dscr = "Create a property with didSet observer",
    body = {
      "var ${1:name}: ${2:Type} = ${3:value} {",
      "\tdidSet {",
      "\t\t$0",
      "\t}",
      "}",
    },
  },
  {
    trigger = "willset",
    name = "Property with willSet",
    dscr = "Create a property with willSet observer",
    body = {
      "var ${1:name}: ${2:Type} = ${3:value} {",
      "\twillSet {",
      "\t\t$0",
      "\t}",
      "}",
    },
  },

  -- Control Flow
  {
    trigger = "if",
    name = "If statement",
    dscr = "Create an if statement",
    body = {
      "if ${1:condition} {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "iflet",
    name = "If let",
    dscr = "Optional binding with if let",
    body = {
      "if let ${1:value} = ${2:optional} {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "guard",
    name = "Guard",
    dscr = "Guard statement",
    body = {
      "guard ${1:condition} else {",
      "\t${2:return}",
      "}",
      "$0",
    },
  },
  {
    trigger = "guardlet",
    name = "Guard let",
    dscr = "Optional binding with guard let",
    body = {
      "guard let ${1:value} = ${2:optional} else {",
      "\t${3:return}",
      "}",
      "$0",
    },
  },
  {
    trigger = "switch",
    name = "Switch",
    dscr = "Switch statement",
    body = {
      "switch ${1:value} {",
      "case ${2:pattern}:",
      "\t$0",
      "default:",
      "\tbreak",
      "}",
    },
  },
  {
    trigger = "for",
    name = "For loop",
    dscr = "For-in loop",
    body = {
      "for ${1:item} in ${2:collection} {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "while",
    name = "While loop",
    dscr = "While loop",
    body = {
      "while ${1:condition} {",
      "\t$0",
      "}",
    },
  },

  -- Error Handling
  {
    trigger = "try",
    name = "Try",
    dscr = "Try expression",
    body = "try ${1:expression}",
  },
  {
    trigger = "try?",
    name = "Try optional",
    dscr = "Optional try",
    body = "try? ${1:expression}",
  },
  {
    trigger = "try!",
    name = "Force try",
    dscr = "Force try",
    body = "try! ${1:expression}",
  },
  {
    trigger = "dotry",
    name = "Do-try-catch",
    dscr = "Do-try-catch block",
    body = {
      "do {",
      "\ttry ${1:expression}",
      "} catch ${2:pattern} {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "throw",
    name = "Throw",
    dscr = "Throw an error",
    body = "throw ${1:error}",
  },

  -- Async/Await
  {
    trigger = "async",
    name = "Async function",
    dscr = "Create an async function",
    body = {
      "func ${1:name}(${2:params}) async ${3:-> ${4:ReturnType} }{",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "await",
    name = "Await",
    dscr = "Await expression",
    body = "await ${1:expression}",
  },
  {
    trigger = "task",
    name = "Task",
    dscr = "Create a Task",
    body = {
      "Task {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "actor",
    name = "Actor",
    dscr = "Create an actor",
    body = {
      "actor ${1:Name} {",
      "\t$0",
      "}",
    },
  },

  -- Property Wrappers (SwiftUI)
  {
    trigger = "@State",
    name = "@State",
    dscr = "SwiftUI State property wrapper",
    body = "@State private var ${1:name}: ${2:Type} = ${3:value}",
  },
  {
    trigger = "@Binding",
    name = "@Binding",
    dscr = "SwiftUI Binding property wrapper",
    body = "@Binding var ${1:name}: ${2:Type}",
  },
  {
    trigger = "@ObservedObject",
    name = "@ObservedObject",
    dscr = "SwiftUI ObservedObject property wrapper",
    body = "@ObservedObject var ${1:name}: ${2:Type}",
  },
  {
    trigger = "@StateObject",
    name = "@StateObject",
    dscr = "SwiftUI StateObject property wrapper",
    body = "@StateObject private var ${1:name} = ${2:Type}()",
  },
  {
    trigger = "@EnvironmentObject",
    name = "@EnvironmentObject",
    dscr = "SwiftUI EnvironmentObject property wrapper",
    body = "@EnvironmentObject var ${1:name}: ${2:Type}",
  },
  {
    trigger = "@Environment",
    name = "@Environment",
    dscr = "SwiftUI Environment property wrapper",
    body = "@Environment(\\.${1:keyPath}) var ${2:name}",
  },
  {
    trigger = "@Published",
    name = "@Published",
    dscr = "Combine Published property wrapper",
    body = "@Published var ${1:name}: ${2:Type} = ${3:value}",
  },

  -- SwiftUI Views
  {
    trigger = "view",
    name = "SwiftUI View",
    dscr = "Create a SwiftUI View",
    body = {
      "struct ${1:ViewName}: View {",
      "\tvar body: some View {",
      '\t\t${2:Text("Hello, World!")}',
      "\t}",
      "}",
    },
  },
  {
    trigger = "preview",
    name = "SwiftUI Preview",
    dscr = "Create a SwiftUI Preview",
    body = {
      "#Preview {",
      "\t${1:ViewName}()",
      "}",
    },
  },

  -- Common Patterns
  {
    trigger = "singleton",
    name = "Singleton",
    dscr = "Singleton pattern",
    body = {
      "class ${1:Name} {",
      "\tstatic let shared = ${1:Name}()",
      "\t",
      "\tprivate init() {",
      "\t\t$0",
      "\t}",
      "}",
    },
  },
  {
    trigger = "codable",
    name = "Codable struct",
    dscr = "Create a Codable struct",
    body = {
      "struct ${1:Name}: Codable {",
      "\t${2:let id: String}",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "equatable",
    name = "Equatable",
    dscr = "Equatable conformance",
    body = {
      "extension ${1:Type}: Equatable {",
      "\tstatic func == (lhs: ${1:Type}, rhs: ${1:Type}) -> Bool {",
      "\t\t$0",
      "\t}",
      "}",
    },
  },
  {
    trigger = "hashable",
    name = "Hashable",
    dscr = "Hashable conformance",
    body = {
      "extension ${1:Type}: Hashable {",
      "\tfunc hash(into hasher: inout Hasher) {",
      "\t\t$0",
      "\t}",
      "}",
    },
  },

  -- Testing
  {
    trigger = "test",
    name = "Test function",
    dscr = "Create a test function",
    body = {
      "func test${1:Name}() throws {",
      "\t$0",
      "}",
    },
  },
  {
    trigger = "testcase",
    name = "XCTestCase",
    dscr = "Create a test case class",
    body = {
      "import XCTest",
      "@testable import ${1:ModuleName}",
      "",
      "final class ${2:TestName}: XCTestCase {",
      "\t$0",
      "}",
    },
  },

  -- Print/Debug
  {
    trigger = "print",
    name = "Print",
    dscr = "Print statement",
    body = "print(${1:value})",
  },
  {
    trigger = "dump",
    name = "Dump",
    dscr = "Dump statement for debugging",
    body = "dump(${1:value})",
  },
  {
    trigger = "mark",
    name = "MARK",
    dscr = "MARK comment",
    body = "// MARK: - ${1:Section}",
  },
  {
    trigger = "todo",
    name = "TODO",
    dscr = "TODO comment",
    body = "// TODO: ${1:Task}",
  },
  {
    trigger = "fixme",
    name = "FIXME",
    dscr = "FIXME comment",
    body = "// FIXME: ${1:Issue}",
  },
}

return M
