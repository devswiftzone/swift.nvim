# Features Roadmap

Lista de features recomendadas para swift.nvim

## ✅ Implementadas

### 1. Project Detector
Detección automática de proyectos Swift (SPM, Xcode Projects, Xcode Workspaces)

### 2. Build Runner
Build, run, y test de paquetes Swift Package Manager

## 🚀 Features Propuestas

### 3. LSP Integration (Alta Prioridad)
**Descripción:** Configuración automática y simplificada de sourcekit-lsp

**Funcionalidades:**
- Auto-configuración de sourcekit-lsp para LSP
- Integración con nvim-lspconfig
- Detección automática de sourcekit-lsp en el sistema
- Configuración de completion, diagnostics, hover, go-to-definition
- Soporte para inlay hints
- Code actions específicas de Swift
- Semantic tokens para mejor highlighting

**API:**
```lua
features = {
  lsp = {
    enabled = true,
    auto_setup = true,            -- Setup LSP automáticamente
    sourcekit_path = nil,         -- Auto-detect si es nil
    inlay_hints = true,           -- Mostrar inlay hints
    semantic_tokens = true,       -- Semantic highlighting
    on_attach = function(client, bufnr) end,  -- Custom on_attach
  },
}
```

### 4. Code Formatting
**Descripción:** Integración con swift-format y swiftformat

**Funcionalidades:**
- Auto-detección de swift-format/swiftformat
- Format on save (configurable)
- Format visual selection
- Integración con conform.nvim si está disponible
- Soporte para archivos de configuración (.swift-format, .swiftformat)

**Comandos:**
- `:SwiftFormat` - Formatear archivo actual
- `:SwiftFormatSelection` - Formatear selección visual

### 5. Linting Integration
**Descripción:** Integración con SwiftLint

**Funcionalidades:**
- Auto-detección de SwiftLint
- Lint on save (configurable)
- Integración con nvim-lint si está disponible
- Mostrar warnings e errors en signcolumn
- Quick fixes para issues comunes

**Comandos:**
- `:SwiftLint` - Ejecutar SwiftLint
- `:SwiftLintFix` - Auto-fix issues

### 6. Xcode Integration
**Descripción:** Soporte para proyectos Xcode

**Funcionalidades:**
- Build Xcode projects con xcodebuild
- Selector de schemes
- Selector de simuladores
- Run en simulador
- Abrir proyecto en Xcode
- Ver y limpiar DerivedData

**Comandos:**
- `:SwiftXcodeBuild` - Build con xcodebuild
- `:SwiftXcodeRun` - Run en simulador
- `:SwiftXcodeSchemes` - Listar/seleccionar schemes
- `:SwiftXcodeSimulators` - Listar/seleccionar simuladores
- `:SwiftXcodeOpen` - Abrir en Xcode.app

### 7. Dependencies Manager
**Descripción:** Gestión de dependencias SPM

**Funcionalidades:**
- Listar dependencias del Package.swift
- Actualizar dependencias (swift package update)
- Resolver dependencias (swift package resolve)
- Ver versiones disponibles
- Agregar dependencias (con UI picker)
- Reset package cache

**Comandos:**
- `:SwiftDependenciesList` - Listar dependencias
- `:SwiftDependenciesUpdate` - Actualizar todas
- `:SwiftDependenciesResolve` - Resolver
- `:SwiftDependenciesAdd` - Agregar nueva

### 8. Snippet Generator
**Descripción:** Generador de code snippets Swift

**Funcionalidades:**
- Snippets para estructuras comunes (struct, class, enum, protocol)
- Snippets para SwiftUI views
- Snippets para testing (XCTest)
- Snippets para property wrappers
- Integración con LuaSnip/nvim-cmp
- Snippets customizables por proyecto

### 9. Documentation Generator
**Descripción:** Generación de documentación

**Funcionalidades:**
- Generar doc comments (///)
- Template para funciones/clases
- Integración con DocC
- Preview de documentación
- Exportar documentación

**Comandos:**
- `:SwiftDocGenerate` - Generar doc comment para símbolo
- `:SwiftDocBuild` - Build DocC documentation
- `:SwiftDocPreview` - Preview documentation

### 10. REPL Integration
**Descripción:** Swift REPL interactivo

**Funcionalidades:**
- Terminal con swift REPL
- Enviar línea/selección a REPL
- Importar módulos del proyecto actual
- Historial de comandos
- Toggle REPL window

**Comandos:**
- `:SwiftREPL` - Abrir REPL
- `:SwiftREPLSend` - Enviar código a REPL

### 11. Symbol Navigator
**Descripción:** Navegación de símbolos Swift

**Funcionalidades:**
- Lista de clases/structs/enums en archivo
- Lista de métodos/propiedades
- Jump to symbol
- Outline view con Telescope/fzf
- Búsqueda de símbolos en proyecto

**Comandos:**
- `:SwiftSymbols` - Listar símbolos del archivo
- `:SwiftSymbolsProject` - Buscar símbolos en proyecto

### 12. Refactoring Tools
**Descripción:** Herramientas de refactoring

**Funcionalidades:**
- Rename symbol (con LSP)
- Extract function/variable
- Convert to computed property
- Add/remove property wrapper
- Convert entre if/guard/switch

**Comandos:**
- `:SwiftExtractFunction` - Extraer función
- `:SwiftExtractVariable` - Extraer variable

### 13. Testing Integration
**Descripción:** Mejor integración con XCTest

**Funcionalidades:**
- Run test bajo cursor
- Run tests en archivo
- Run all tests
- Test explorer/tree
- Ver resultados inline
- Jump to failing test
- Test coverage
- Integración con neotest

**Comandos:**
- `:SwiftTestNearest` - Run test bajo cursor
- `:SwiftTestFile` - Run tests en archivo
- `:SwiftTestAll` - Run all tests
- `:SwiftTestLast` - Re-run último test

### 14. SwiftUI Live Preview (Experimental)
**Descripción:** Preview de SwiftUI en Neovim

**Funcionalidades:**
- Preview de SwiftUI views
- Hot reload
- Multi-device preview
- Preview en simulador externo

**Nota:** Esta feature es experimental y compleja

### 15. Package Templates
**Descripción:** Templates para crear nuevos paquetes

**Funcionalidades:**
- Crear nuevo SPM package desde template
- Templates: library, executable, plugin
- Templates customizables
- Estructura de carpetas automática

**Comandos:**
- `:SwiftPackageNew` - Crear nuevo package
- `:SwiftPackageInit` - Inicializar en directorio actual

### 16. Import Organizer
**Descripción:** Organizar y limpiar imports

**Funcionalidades:**
- Sort imports alfabéticamente
- Remover imports no usados
- Agregar imports faltantes
- Formato consistente
- Auto-fix on save

**Comandos:**
- `:SwiftImportOrganize` - Organizar imports
- `:SwiftImportClean` - Remover unused imports

### 17. Code Actions UI
**Descripción:** UI mejorada para code actions

**Funcionalidades:**
- Preview de code actions
- Quick fixes con UI
- Bulk actions
- Custom actions para Swift

### 18. Project Diagnostics
**Descripción:** Vista general de diagnostics del proyecto

**Funcionalidades:**
- Lista de todos los warnings/errors
- Filter por severidad
- Jump to issue
- Fix all (para fixeables)
- Integration con Trouble.nvim

**Comandos:**
- `:SwiftDiagnostics` - Ver todos los diagnostics
- `:SwiftDiagnosticsProject` - Diagnostics de todo el proyecto

### 19. Async/Await Helpers
**Descripción:** Herramientas para código asíncrono

**Funcionalidades:**
- Convert callbacks to async/await
- Highlight de async boundaries
- Actor isolation warnings
- Task visualization

### 20. Performance Profiler Integration
**Descripción:** Integración con Instruments

**Funcionalidades:**
- Launch Instruments
- Profile builds
- Memory leaks detection
- Performance hints

## 🎯 Prioridades Recomendadas

### Fase 1 (Esenciales)
1. **LSP Integration** - Fundamental para desarrollo
2. **Code Formatting** - Importante para calidad de código
3. **Linting Integration** - Complementa LSP

### Fase 2 (Productividad)
4. **Xcode Integration** - Para proyectos iOS/macOS
5. **Testing Integration** - Mejorar workflow de testing
6. **Dependencies Manager** - Gestión de paquetes

### Fase 3 (Avanzadas)
7. **Symbol Navigator** - Navegación mejorada
8. **Refactoring Tools** - Productividad avanzada
9. **REPL Integration** - Experimentación rápida
10. **Documentation Generator** - Documentación mejor

### Fase 4 (Extras)
11. Resto de features según necesidad

## 💡 Notas de Implementación

### LSP Integration
- Debe ser fácil de usar out-of-the-box
- Auto-detección de sourcekit-lsp
- Fallback a configuración manual si es necesario
- Integración con nvim-lspconfig existente sin conflictos

### Code Formatting
- Soporte para ambos: swift-format y swiftformat
- Auto-detección de cual está instalado
- Respetar archivos de configuración del proyecto

### Linting
- No interferir con LSP diagnostics
- Mostrar en lugares apropiados
- Quick fixes integrados

### Xcode Integration
- Solo habilitar cuando hay proyectos Xcode
- UI para selección de schemes/simuladores
- Cacheo de información para performance

## 🔧 Arquitectura Sugerida

Cada feature debe:
1. Ser opcional (habilitada/deshabilitada en config)
2. Tener su propio módulo en `lua/swift/features/`
3. Exponer API pública consistente
4. Tener health checks apropiados
5. Documentación completa en README
6. Ejemplos de configuración

## 📚 Referencias

- [sourcekit-lsp](https://github.com/apple/sourcekit-lsp)
- [swift-format](https://github.com/apple/swift-format)
- [SwiftLint](https://github.com/realm/SwiftLint)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [conform.nvim](https://github.com/stevearc/conform.nvim)
- [nvim-lint](https://github.com/mfussenegger/nvim-lint)
