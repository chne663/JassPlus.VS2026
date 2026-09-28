# Architecture

## Why a separate `JassPlus.Language` project

Visual Studio's editor extensibility APIs (`IClassifier`, `ICompletionSource`,
`IAsyncQuickInfoSource`, tagger interfaces, etc.) are a *presentation* layer.
Underneath them, `JassPlus.Language` provides an IDE-agnostic core:

- `Lexing` — `Lexer`, `Token`, `TokenType`. Pure string in, token list out.
  No dependency on `Microsoft.VisualStudio.*`, so it can run outside a VS
  process (unit tests, a future LSP server, CLI tools, etc.).
- `Parsing` — `Parser` (hand-written recursive descent) plus the AST node
  types (`Expressions.cs`, `Statements.cs`, `Declarations.cs`). Same
  no-VS-dependency rule applies. Never throws on malformed input — see
  the error-recovery note in `Parser.cs` and the CHANGELOG's Phase 4 entry.
- `Warcraft` — `NativeApiDatabase`, built by feeding `common.j`/`blizzard.j`
  source text through the same `Parser` (no separate API-file parser), plus
  `WarcraftApiJsonSerializer` for the `WarcraftApi.json` cache format. Not
  yet wired into the live VS extension — see the Phase 5 CHANGELOG entry.
- `IntelliSense` — `FileSymbolCollector`, `CompletionEngine`,
  `QuickInfoEngine`, `SignatureHelpEngine`. Pure VS-agnostic logic; the
  VSIX adapters in `src/JassPlus.VSIX/IntelliSense/` just translate their
  output into VS's Async Completion / Async QuickInfo / classic
  ISignatureHelpSource APIs. See the Phase 6 CHANGELOG entry for what's
  verified vs. not.
- `Navigation` — `ReferenceCollector`, `SymbolBinder`,
  `GoToDefinitionEngine`, `FindReferencesEngine`. Same-file-only (no
  project system yet); see the Phase 7 CHANGELOG entry for the scope
  notes on what "Find All References" means today vs. the eventual
  multi-file tool window.
- `Diagnostics` — `DiagnosticsEngine`, combining parser recovery, unresolved
  names, and call-arity checks with the conservative `Semantics.TypeAnalysis`
  pass for known initializer, assignment, return, and call-argument types.
  Cross-file requires/uses validation and full vJASS type checking remain
  follow-up work. See `docs/semantic-intelligence.md` for current boundaries.
- `Formatting` — `Formatter`, `FormatOptions`. Token-line based, not an
  AST pretty-printer, specifically so comments (which the parser treats
  as trivia) survive formatting. See the Phase 9 CHANGELOG entry for the
  scope notes (no blank-line fabrication, no statement-splitting).
- `Build` — `JassHelperInvocation`, `JassHelperOutputParser`,
  `JassHelperRunner`. VS-agnostic; the CLI argument/output-format
  conventions are a best-effort default (JassHelper has no single
  canonical CLI across its forks) — see the Phase 10 CHANGELOG entry.
- `ProjectSystem` — `JassProjectFile` (the `.jassproj` format),
  `ProjectSymbolIndex` (multi-file symbol collection), `DependencyGraphBuilder`
  (library requires graph + topological sort). Data layer only — no VS
  custom project type (`IVsHierarchy` etc.); see the Phase 11 CHANGELOG
  entry for why that's explicitly out of scope for v1.
- (Phase 6+) `Semantics` — symbol/scope model and conservative expression
  type analysis, shared by the VS-agnostic language features. A
  `SemanticSnapshot` bundles the AST, parse errors, model, symbol projection,
  and references; the VSIX weakly caches it by exact `ITextSnapshot` so all
  editor services reuse the same analysis for an unchanged buffer version.

`JassPlus.VSIX` is intentionally thin: it adapts `JassPlus.Language` output
to VS concepts (`ClassificationSpan`, `CompletionItem`, `IPeekableItem`,
`ErrorListProvider` entries, etc.). This mirrors the plan in the project
brief — if Rider or VS Code support is ever added, only a new thin adapter
project is needed, not a rewrite of the lexer/parser.

## Target frameworks

- `JassPlus.Language`: `netstandard2.0` — usable from both the `net472`
  VSIX host process and any future `net8.0` LSP server or CLI.
- `JassPlus.VSIX`: `net472` — Visual Studio's `devenv.exe` process is still
  .NET Framework in both VS2022 and VS2026, so in-process MEF components
  target `net472`. VS2026 loads API-17.x extensions (what this project
  targets) unmodified, so the same build works on VS2022 and VS2026.
- `JassPlus.Language.Tests`: `net8.0` — modern, fast test host; testing the
  netstandard2.0 library from net8.0 works without any extra shims.

## Phase 1 component map

```
JassPlus.VSIX
├── ContentType/JassContentTypeDefinition.cs   → registers "jass" content type,
│                                                 maps .j / .ai / .dz to it
├── Classification/JassClassificationTypes.cs  → classification type + default colors
└── Classification/JassClassifier.cs           → IClassifier + IClassifierProvider,
                                                   tokenizes via JassPlus.Language.Lexing.Lexer
```

Through Phase 9, no `AsyncPackage`/`Package` class was needed — pure MEF
component export via `[Export]`/`[ContentType]`/`[Name]` attributes was
sufficient for content type registration, classification, IntelliSense,
navigation, diagnostics, and formatting. Phase 10 introduced the first
Package (`JassPlusPackage`), needed for the Tools > Options page and the
Build menu command — see `src/JassPlus.VSIX/JassPlusPackage.cs`,
`Options/JassOptionsPage.cs`, `Build/BuildCommand.cs`, and
`BuildCommand.vsct`.

## Data flow for syntax highlighting (Phase 1)

```
ITextBuffer edit
      │
      ▼
JassClassifierProvider.GetClassifier(buffer)
      │  (cached per-buffer via buffer.Properties)
      ▼
JassClassifier.GetClassificationSpans(span)
      │  (re-lexes only when the snapshot changed)
      ▼
JassPlus.Language.Lexing.Lexer.Tokenize()
      │
      ▼
Token[] → mapped to IClassificationType → ClassificationSpan[]
```
