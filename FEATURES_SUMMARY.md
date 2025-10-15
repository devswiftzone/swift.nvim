# swift.nvim - Features Summary & Roadmap

## ✅ Features Implementadas

### 1. Project Detector ✓
**Estado:** Completamente implementado
**Descripción:** Detecta automáticamente proyectos Swift (SPM, Xcode Projects, Workspaces)
**Commit:** Initial commit

### 2. Build Runner ✓
**Estado:** Completamente implementado
**Descripción:** Build, run y test de paquetes Swift Package Manager
**Comandos:** `:SwiftBuild`, `:SwiftRun`, `:SwiftTest`, `:SwiftClean`
**Commit:** 4e1bfe5

### 3. LSP Integration ✓
**Estado:** Completamente implementado
**Descripción:** Configuración automática de sourcekit-lsp con soporte completo
**Características:**
- Auto-detección de sourcekit-lsp
- Setup automático con nvim-lspconfig
- Completion, diagnostics, hover, go-to-definition
- Code actions, refactoring, rename
- Inlay hints y semantic tokens
- Integración con nvim-cmp
**Commit:** 4098bd0

## 🎯 Features de Alta Prioridad (Siguiente)

### 4. Code Formatting
**Prioridad:** ALTA
**Esfuerzo:** Medio (2-3 horas)
**Descripción:** Integración con swift-format y swiftformat

**Funcionalidades:**
- Auto-detección de swift-format/swiftformat
- Format on save configurable
- Format visual selection
- Integración con conform.nvim
- Soporte para archivos de configuración

**API propuesta:**
```lua
features = {
  formatter = {
    enabled = true,
    tool = nil,  -- Auto-detect: "swift-format" | "swiftformat"
    format_on_save = false,
    config_file = nil,  -- Auto-detect
  },
}
```

**Comandos:**
- `:SwiftFormat` - Formatear archivo
- `:SwiftFormatSelection` - Formatear selección

### 5. Linting Integration
**Prioridad:** ALTA
**Esfuerzo:** Medio (2-3 horas)
**Descripción:** Integración con SwiftLint

**Funcionalidades:**
- Auto-detección de SwiftLint
- Lint on save configurable
- Integración con nvim-lint
- Quick fixes para issues comunes

**API propuesta:**
```lua
features = {
  linter = {
    enabled = true,
    lint_on_save = true,
    config_file = nil,  -- Auto-detect .swiftlint.yml
  },
}
```

**Comandos:**
- `:SwiftLint` - Ejecutar linter
- `:SwiftLintFix` - Auto-fix

### 6. Xcode Integration
**Prioridad:** ALTA
**Esfuerzo:** Alto (4-5 horas)
**Descripción:** Soporte completo para proyectos Xcode

**Funcionalidades:**
- Build con xcodebuild
- Selector de schemes (con Telescope/fzf)
- Selector de simuladores
- Run en simulador
- Abrir en Xcode.app
- Ver/limpiar DerivedData

**API propuesta:**
```lua
features = {
  xcode = {
    enabled = true,
    default_scheme = nil,  -- Auto-detect
    default_simulator = nil,  -- Auto-detect or prompt
    show_output = true,
  },
}
```

**Comandos:**
- `:SwiftXcodeBuild` - Build
- `:SwiftXcodeRun` - Run en simulador
- `:SwiftXcodeSchemes` - Selector de schemes
- `:SwiftXcodeSimulators` - Selector de simuladores
- `:SwiftXcodeOpen` - Abrir en Xcode

## 🚀 Features de Prioridad Media

### 7. Testing Integration (Enhanced)
**Prioridad:** MEDIA
**Esfuerzo:** Alto (4-6 horas)
**Descripción:** Mejora de la integración con tests

**Funcionalidades:**
- Run test bajo cursor
- Run tests en archivo/clase
- Test explorer tree
- Inline test results
- Coverage visualization
- Integración con neotest

**Comandos:**
- `:SwiftTestNearest` - Test bajo cursor
- `:SwiftTestFile` - Tests del archivo
- `:SwiftTestClass` - Tests de la clase
- `:SwiftTestLast` - Re-run último test

### 8. Dependencies Manager
**Prioridad:** MEDIA
**Esfuerzo:** Medio-Alto (3-4 horas)
**Descripción:** Gestión de dependencias SPM

**Funcionalidades:**
- Listar dependencias
- Actualizar dependencias
- Agregar dependencias con UI
- Ver versiones disponibles
- Reset cache

**Comandos:**
- `:SwiftDependenciesList`
- `:SwiftDependenciesUpdate`
- `:SwiftDependenciesAdd`

### 9. Symbol Navigator
**Prioridad:** MEDIA
**Esfuerzo:** Medio (2-3 horas)
**Descripción:** Navegación mejorada de símbolos

**Funcionalidades:**
- Lista de símbolos del archivo
- Búsqueda de símbolos en proyecto
- Outline view con Telescope
- Jump to symbol

**Comandos:**
- `:SwiftSymbols` - Símbolos del archivo
- `:SwiftSymbolsProject` - Buscar en proyecto

### 10. Documentation Generator
**Prioridad:** MEDIA
**Esfuerzo:** Medio (3-4 horas)
**Descripción:** Generación de documentación

**Funcionalidades:**
- Generar doc comments (///)
- Templates para funciones/clases
- Integración con DocC
- Build y preview de docs

**Comandos:**
- `:SwiftDocGenerate` - Generar doc comment
- `:SwiftDocBuild` - Build DocC docs
- `:SwiftDocPreview` - Preview docs

## 📦 Features de Prioridad Baja

### 11. REPL Integration
**Prioridad:** BAJA
**Esfuerzo:** Medio (2-3 horas)
**Descripción:** Swift REPL interactivo en Neovim

### 12. Refactoring Tools
**Prioridad:** BAJA (LSP ya provee mucho)
**Esfuerzo:** Alto (4-6 horas)
**Descripción:** Herramientas adicionales de refactoring

### 13. Snippet Generator
**Prioridad:** BAJA
**Esfuerzo:** Medio (2-3 horas)
**Descripción:** Snippets Swift para LuaSnip/nvim-cmp

### 14. Import Organizer
**Prioridad:** BAJA
**Esfuerzo:** Bajo-Medio (2-3 horas)
**Descripción:** Organizar y limpiar imports

### 15. Package Templates
**Prioridad:** BAJA
**Esfuerzo:** Bajo (1-2 horas)
**Descripción:** Templates para nuevos paquetes

### 16. SwiftUI Live Preview (Experimental)
**Prioridad:** MUY BAJA (muy complejo)
**Esfuerzo:** Muy Alto (10+ horas)
**Descripción:** Preview de SwiftUI en Neovim

## 🎯 Roadmap Recomendado

### Fase 1: Fundamentos (Completado ✓)
- [x] Project Detector
- [x] Build Runner
- [x] LSP Integration

### Fase 2: Code Quality (Próximo)
1. **Code Formatting** (2-3 horas)
2. **Linting Integration** (2-3 horas)
3. **Xcode Integration** (4-5 horas)

**Tiempo estimado:** 8-11 horas total

### Fase 3: Productividad
4. **Testing Integration Enhanced** (4-6 horas)
5. **Dependencies Manager** (3-4 horas)
6. **Symbol Navigator** (2-3 horas)

**Tiempo estimado:** 9-13 horas total

### Fase 4: Extras (Opcional)
7. Resto de features según necesidad y feedback de usuarios

## 💡 Notas de Implementación

### Para cada feature nueva:

1. **Estructura del archivo:**
   - Crear `lua/swift/features/nombre_feature.lua`
   - Seguir patrón: `M.setup(opts)` para inicialización
   - Exponer API pública consistente

2. **Configuración:**
   - Agregar defaults en `lua/swift/config.lua`
   - Permitir habilitar/deshabilitar feature
   - Opciones documentadas en README

3. **Health Check:**
   - Agregar verificaciones en `lua/swift/health.lua`
   - Verificar dependencias externas
   - Mostrar status de la feature

4. **Documentación:**
   - Actualizar README.md con la feature
   - Agregar ejemplos de uso
   - Documentar comandos y keybindings

5. **Comandos:**
   - Usar convención `:Swift<Feature><Action>`
   - Ejemplo: `:SwiftFormat`, `:SwiftLint`

6. **Integración:**
   - Cargar en `lua/swift/features/init.lua`
   - Respetar enabled/disabled
   - Manejo de errores con pcall

### Priorización basada en:
- **Impacto en workflow:** Features que mejoran productividad diaria
- **Complejidad:** Empezar con features de ROI alto
- **Dependencias:** Features que otras features necesitan
- **Feedback de usuarios:** Escuchar qué necesitan realmente

## 📊 Métricas de Progreso

**Features Implementadas:** 3/20 (15%)
**Features Alta Prioridad:** 3/6 (50%)
**Tiempo invertido:** ~6-8 horas
**Tiempo estimado próxima fase:** 8-11 horas

## 🔗 Referencias Útiles

- [sourcekit-lsp Documentation](https://github.com/apple/sourcekit-lsp/tree/main/Documentation)
- [swift-format](https://github.com/apple/swift-format)
- [SwiftLint](https://github.com/realm/SwiftLint)
- [swiftformat](https://github.com/nicklockwood/SwiftFormat)
- [xcodebuild](https://developer.apple.com/library/archive/technotes/tn2339/)
- [DocC](https://www.swift.org/documentation/docc/)
- [neotest](https://github.com/nvim-neotest/neotest)
- [conform.nvim](https://github.com/stevearc/conform.nvim)
- [nvim-lint](https://github.com/mfussenegger/nvim-lint)

## 📝 Notas Finales

Este plugin ya tiene una base sólida con las 3 features esenciales:
1. **Project Detection** - Fundamental para todo lo demás
2. **Build/Run/Test** - Workflow básico de desarrollo
3. **LSP Integration** - Code intelligence completa

Las próximas features recomendadas (Formatting, Linting, Xcode) completarían el ecosistema básico de desarrollo Swift en Neovim. El resto son extras que añaden conveniencia pero no son críticas.

La arquitectura modular permite que cada feature sea opcional y no afecte a las demás. Esto es ideal para que los usuarios personalicen su experiencia según sus necesidades.
