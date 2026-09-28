# JassPlus.VS2026 — Warcraft III JASS Tools

A from-scratch, Visual Studio 2026–native extension for editing Warcraft III
**JASS** and **vJASS** map scripts. Built on the official VS SDK (MEF editor
extensibility), not a port of any existing VS Code extension.

> **Status: Phases 1–11 complete** (the full roadmap from the original
> project brief). Every phase's core logic lives in `JassPlus.Language`
> and is fully unit-tested (220 tests as of Phase 11 — see
> [Roadmap](#roadmap) for the phase-by-phase breakdown). The VSIX layer
> that wires that logic into Visual Studio is build-verified for Phases
> 1–10; several individual adapter files remain unverified at runtime —
> each phase's CHANGELOG entry says exactly which parts and why. Several
> pieces are explicitly scoped down from what a "complete" version would
> eventually include (no VS custom project type, no cross-file IntelliSense) — see each phase's "Scope notes" in
> [CHANGELOG.md](CHANGELOG.md) for what's deliberately deferred and why,
> rather than treating any gap as an oversight.

## Features

- `.j` / `.ai` / `.dz` file association with a dedicated `jass` content
  type; `.jassproj` (Phase 11's project file format) gets XML highlighting.
- `.wts` TriggerStrings files have their own content type and highlighting
  for `STRING` IDs, braces, and string bodies. Binary map formats such as
  `.w3i` are intentionally not sent through the JASS text editor; structured
  map-info viewing/editing is a follow-up feature.
- Initial Warcraft III map workflow: **Tools → Open Warcraft III Map
  Script...** extracts paired `war3map.j` and `war3map.wts` files from `.w3x` /
  `.w3m` into a per-map working copy and opens both in the editor. **Tools →
  Save JASS Working Copy to Map As...** writes both into a separate map file
  while retaining other MPQ entries; it checks `TRIGSTR_###` references
  against WTS entries, and runs JassHelper first when configured. The opened
  source map is not overwritten.
- Syntax highlighting for:
  - JASS keywords (`function`, `local`, `set`, `call`, `if`/`then`/`endif`,
    `loop`/`endloop`, `globals`/`endglobals`, ...)
  - vJASS / JassHelper keywords (`library`, `scope`, `struct`, `method`,
    `interface`, `module`, `private`/`public`/`static`, `delegate`,
    `thistype`, ...)
  - Built-in types (`integer`, `real`, `unit`, `player`, `trigger`, ...)
  - Strings, numbers, FourCC rawcode literals (`'Hfoo'`)
  - Line comments (`//`), block comments (`/* */`), and `//! import "..."`
    directives
- Full JASS/vJASS parser producing an AST, with error recovery (never
  throws on malformed input)
- Shared per-buffer-version semantic snapshots used by completion, Quick Info,
  signature help, navigation, references, and diagnostics
- IntelliSense: completion, QuickInfo (hover), and signature help, driven by
  in-file symbols plus the bundled `common.j` / `Blizzard.j` API database
- Go To Definition (F12) and same-file reference highlighting
- Diagnostics: syntax errors, unresolved names, call arity, and conservative
  type mismatch checks for initializers, assignments, return values, and call
  arguments when the relevant types are known, plus boolean condition and
  integer array-index checks
- Format Document / Format Selection, preserving comments and string
  contents exactly
- JassHelper build integration: `Tools → Options → Warcraft III → JASS`
  for paths, **Build JASS Script** command, output to a dedicated pane
- `.jassproj` project file format, with multi-file symbol collection and
  a library dependency graph (`requires`/`uses`) as a data layer for
  future cross-file features

Ongoing semantic-analysis work and its known boundaries are tracked in
[docs/semantic-intelligence.md](docs/semantic-intelligence.md); the Phase 6–8
feature engines now consume the symbol/scope model, with type analysis being
expanded incrementally.

## Requirements

- Visual Studio 2026 (any edition), or Visual Studio 2022 17.8+ — the
  extension targets VS SDK API version 17.x, and Visual Studio 2026 loads
  API-17.x extensions unmodified, so the same VSIX installs on either
  (see [Microsoft's extension compatibility notes](https://learn.microsoft.com/en-us/visualstudio/extensibility/migration/extension-compatibility))
- Windows 10/11

## Installation

## Release 1.0.1

A distributable Release VSIX is provided under `releases/1.0.1/`. It installs
on Visual Studio 2022 (17.x) and Visual Studio 2026 on 64-bit Windows. The
VSIX is unsigned, so Visual Studio may show its normal publisher trust prompt.

To install, close Visual Studio, double-click
`JassPlus.VS2026-1.0.1.vsix`, follow the VSIX Installer prompts, then reopen
Visual Studio. The installer requires .NET Framework 4.7.2 or later and the
Visual Studio core editor component. See the release folder's README for the
checksum and full installation notes.

To build a development version from source:

1. Build the solution (see [docs/development.md](docs/development.md)).
2. Double-click the generated `JassPlus.VSIX.vsix` in
   `src/JassPlus.VSIX/bin/<Debug|Release>/net472/`.
3. Restart Visual Studio.

### Phase 1 verification checklist

After installing (or after `F5`-launching the Experimental Instance):

- [ ] Create/open a `.j` file — Visual Studio recognizes it (check the
      status bar / editor doesn't fall back to plain text).
- [ ] Paste in:
  ```jass
  function Test takes nothing returns nothing
      local integer i = 0
      set i = i + 1
      call BJDebugMsg("Hello Warcraft III")
      return
  endfunction
  ```
  and confirm `function`, `local`, `set`, `call`, `return`, `endfunction`
  are colored as keywords, `integer` as a type, and the string literal is
  colored distinctly.
- [ ] Paste in a vJASS snippet (`library` / `struct` / `method` / `scope`)
      and confirm those keywords get the distinct vJASS keyword color.
- [ ] Confirm `//` and `/* */` comments and `//! import "X.j"` are colored
      as comments/directives, not as code.

See [docs/development.md](docs/development.md) for the full build/debug
workflow, including how to use the Experimental Instance and how to reset
it if it gets into a bad state.

## Development

```powershell
git clone <repo-url>
cd JassPlus.VS2026
dotnet restore
dotnet build JassPlus.VS2026.sln -c Debug
dotnet test tests/JassPlus.Language.Tests/JassPlus.Language.Tests.csproj
```

Full details, including Experimental Instance debugging: see
[docs/development.md](docs/development.md).

## Configuration

`Tools → Options → Warcraft III → JASS` (added in Phase 10): Warcraft III
install path, JassHelper.exe path, `common.j`/`blizzard.j` paths, and extra
JassHelper command-line arguments. The API database currently loads the
bundled `resources/common.j` and `resources/Blizzard.j` files; the configured
paths do not yet replace those bundled profiles. There's no formatting-options UI yet (`FormatOptions` exists and works
if you build against it directly; Format Document/Selection currently
always use its defaults).

## JASS support

See [docs/jass-language.md](docs/jass-language.md) for the exact keyword
list the lexer currently recognizes and known gaps.

## vJASS support

Also covered in [docs/jass-language.md](docs/jass-language.md) — `library`,
`scope`, `struct`, `interface`, `module`, and related JassHelper syntax are
lexed and highlighted; same-file `library requires` visibility is now
understood by semantic features. Cross-file `requires`/`uses` resolution is
still future work.

## JassHelper integration

`Tools → Options → Warcraft III → JASS` lets you set the JassHelper.exe,
common.j, blizzard.j, and Warcraft III install paths. **Build JASS Script**
(under the Tools menu) runs JassHelper against the active `.j` file and
writes the result to a "JASS Build" Output window pane — not the Error
List; see the Phase 10 CHANGELOG entry for why that's deliberately
scoped out for now. The argument/output format JassHelper is invoked with
is a best-effort default (JassHelper's CLI varies across forks) —
`Tools → Options` has an extra-arguments field if your JassHelper build
needs different flags. JassHelper is optional: without it configured,
editing/IntelliSense/diagnostics/formatting all still work.

## Architecture

See [docs/architecture.md](docs/architecture.md) for why the language core
(`JassPlus.Language`) is kept separate from the Visual Studio integration
(`JassPlus.VSIX`), and how a syntax-highlighting request flows through the
system today.

## Known issues

- Semantic analysis is currently file-local. It handles symbol scopes and
  selected type mismatches, but project-wide binding through `requires` /
  `//! import` and complete vJASS type checking are still in progress.
- Only `.j` is exercised in testing so far; `.ai` / `.dz` association is
  wired up but untested against real files.
- File encoding is assumed to be whatever Visual Studio's own encoding
  detection decides; explicit Big5/ANSI handling (project requirement §19)
  is not yet implemented.
- Configured `common.j` / `blizzard.j` paths do not yet replace the bundled
  files, and API profile selection by Warcraft III version is not implemented.
- `common.ai` is a separate API profile and is not bundled yet; AI-specific
  declarations may still show as unresolved inside `.ai` scripts.

## Roadmap

| Phase | Scope |
|---|---|
| 1 ✅ | VSIX foundation, content type, lexer, syntax highlighting |
| 2 ✅ | Lexer hardening / edge cases |
| 3 ✅ | Syntax highlighting (closed out as part of Phase 1 — see CHANGELOG for scope) |
| 4 ✅ | Parser / AST |
| 5 ✅ | Warcraft III native API database (`WarcraftApi.json`, `common.j`/`blizzard.j` parsing) |
| 6 ✅ | IntelliSense (completion, signature help, QuickInfo) — engines tested, VSIX adapters build-verified; runtime UX not yet checked with F5 |
| 7 ✅ | Go To Definition / Find All References — engines tested, VSIX adapters build-verified; same-file only, see CHANGELOG |
| 8 ✅⚠️ | Diagnostics — parser/semantic checks, editor squiggles and Error List rows; VSIX runtime behavior needs F5 verification, see CHANGELOG |
| 9 ✅⚠️ | Formatter — engine tested (incl. the spec's own worked example), command handler unverified; no blank-line fabrication or statement-splitting, see CHANGELOG |
| 10 ✅⚠️ | JassHelper build integration — core engine tested (incl. real process execution), Package/Options page/menu command unverified; build output remains in its Output pane, see CHANGELOG |
| 11 ✅⚠️ | JASS project system — data layer tested (file format, multi-file symbol index, dependency graph), no VS custom project type (see CHANGELOG for why that's explicitly licensed to skip in v1) |

## License

[MIT](LICENSE). This is an independent reimplementation; see the note at
the bottom of the LICENSE file regarding the original VS Code "Jass+"
extension.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
