# Changelog

All notable changes to this project are documented in this file.

## [1.0.1] — 2026-09-28

### Marketplace and open-source distribution preparation
- Replaced embedded Blizzard script sources with a compact derived Warcraft API symbol profile for the extension's bundled IntelliSense data.
- Added ignore rules so local `common.j`, `Blizzard.j`, and `common.ai` files are not committed to the public source repository.
- Added a resource note describing the derived profile and the excluded Blizzard source files.

## [1.0.0] — 2026-09-28

### First distributable release
- Packaged the current JASS/vJASS editor and Warcraft III map workflow for installation on other Visual Studio 2022/2026 computers.
- Fixed parser compatibility with legacy map scripts using `.01`/`0.` real literals, JassHelper-generated `this` locals, multiline strings, and embedded BOM characters.
- Updated semantic type checks to accept legacy map scripts that use `null` as a string/integer sentinel.
- Built as a Release VSIX; the release package is unsigned and distributed for direct sideload installation.

### Known scope
- Warcraft III map support extracts and saves JASS/WTS working copies; structured editing of `.w3i`, `.w3u`, and other binary map formats is not included.
- Map output is Save As and should be checked in Warcraft III World Editor/game before replacing any production map.
- JASS diagnostics are conservative and may not model every compiler or JassHelper-specific rule.

## [Unreleased] — Phase 4 Warcraft III map integration

### Added
- Added **Tools → Open Warcraft III Map Script...** for `.w3x` and `.w3m`
  maps. It reads `war3map.j` and optional `war3map.wts` from the MPQ archive
  into one working folder and opens both in the editor.
- Added a stable per-map working copy under `%LOCALAPPDATA%\JassPlus\MapWorkspaces`.
  Reopening a map keeps the working copy, rather than overwriting edits.
- Added **Tools → Save JASS Working Copy to Map As...**. It rebuilds a separate
  map file, carries forward other MPQ entries, restores the original script
  encoding where identified, then reopens the generated map and verifies its
  `war3map.j` bytes before committing the output file.
- When JassHelper is configured, saving a map runs JassHelper first and
  packages its compiled output. A failed compile prevents the map from being
  written. Without a configured JassHelper path, the working script is packed
  as-is.
- Before saving, checks JASS string-literal references of the form
  `"TRIGSTR_###"` against WTS `STRING ###` entries. Missing IDs and duplicate
  WTS definitions stop packaging and report the affected IDs.
- Preserved the 512-byte `HM3W` wrapper; stale `(attributes)` data and
  invalidated `(signature)` data are omitted from rebuilt maps.
- Preserved the source script encodings independently for JASS and WTS where
  they can be identified. A map without `war3map.wts` gets an empty working
  copy; the output only gains a WTS archive entry if content is added.
- Added MPQ support through War3Net.IO.Mpq 1.0.1, whose `netstandard2.0`
  asset can run in the current `net472` VSIX process.

### Scope
- Saving is intentionally Save As; the opened source map is never overwritten.
  Structured `.w3i`/`.w3u` editing is not yet implemented. Protected maps and
  archives with unsupported encryption may not be rebuildable. Repacked output
  still needs user validation against legacy encodings and the target
  Warcraft III game version.
- The MPQ dependency is an older compatible API line; upgrading it requires
  moving archive operations out of the Visual Studio `net472` process or
  selecting another compatible library.

## [Unreleased] — Phase 3 refactoring foundation

### Added
- Added a language-level rename engine that uses bound symbol references,
  validates JASS identifiers, refuses same-scope collisions and refuses
  edits that would bind an existing reference to another declaration.
- Added an AST-based quick-fix engine for adding a missing `endfunction`.
- Added an AST-based missing-local action for unresolved assignment targets
  when the assigned expression has a safe, known type.
- Added a conservative Extract Function engine for selecting contiguous plain
  function calls and bare-variable assignments. Local variables and parameters
  used by the selection become parameters; a single modified value used later
  is returned to the original function.
- Added **Tools → Rename JASS Symbol...** and **Tools → Add missing
  endfunction** commands. The rename edits are grouped into one Visual Studio
  undo operation.
- Placed the Rename and Add missing `endfunction` commands in the JASS code
  editor's right-click context menu as direct-access fallbacks.
- Added editor light-bulb actions for Rename, Add missing `endfunction`,
  Create missing local declaration, and Extract selected calls to function.

### Scope
- Refactorings remain same-file and are limited to symbols the current
  semantic model can bind.
- Missing-local inference only offers fixes for bare assignment targets with
  a known primitive or declared function return type.
- Extract Function currently accepts only contiguous `call Function(...)` and
  `set name = ...` statements inside a plain function. It declines arrays,
  control flow, member assignments, unresolved values, and selections that
  modify more than one local/parameter later used by the original function.
- F5 interaction has not yet been checked for the light-bulb actions.

## [Unreleased] — Error List diagnostics

### Added
- The diagnostics tagger now publishes errors, warnings, and informational
  diagnostics for open JASS documents to Visual Studio's Error List, including
  file path, line, column, and JASS diagnostic code in the description.
- Editing a file replaces only that document's JASS diagnostics; clearing the
  issues or closing the document removes its rows without clearing other
  providers' entries.
- The package loads for both solution and no-solution contexts so the Error
  List provider is initialized when a JASS document is edited.

### Notes
- The Error List integration is build-verified; its navigation and live update
  behavior still need confirmation in the Experimental Instance with F5.
- JassHelper build output continues to use its dedicated Output pane.

## [Unreleased] — Warcraft API profiles

### Added
- Added isolated, named `WarcraftApiProfile` instances with stable profile
  IDs, version labels, source attribution, parser diagnostics, and separate
  optional AI API data.
- Added profile metadata to the Warcraft API JSON cache while retaining
  support for older flat `WarcraftApi.json` files.
- The shared IntelliSense database can register/switch profiles. When
  configured `common.j` and `Blizzard.j` paths are present, package startup
  loads them as the active profile; bundled API remains the fallback.
- Added API profile name/ID/version and optional `common.ai` fields to the
  JASS Options page.

### Notes
- The version is a user-supplied label. The extension does not infer the
  Warcraft III patch from source contents or claim bundled data belongs to a
  particular patch.
- Profile management UI and persistence of multiple selectable profiles are
  still future work; the service API already supports registering and
  selecting profiles programmatically.

## [Unreleased] — bundled Warcraft API sources

### Changed
- Moved the supplied `common.j` and `Blizzard.j` into `resources/` and
  embedded both files in the VSIX assembly.
- `SharedApiDatabaseService` now parses the bundled files once when the MEF
  service is created. Completion, Quick Info, signature help, and diagnostics
  therefore share the loaded Warcraft API database instead of starting empty.
- Fixed parameter parsing when an official API declaration uses a reserved
  vJASS word as its parameter name (the upstream `common.j` uses `override`).
  This had stopped 416 later native declarations from entering the database.
- Configured API source paths and version-specific profiles are still not
  connected; this change uses the bundled source pair for the F5 test.
- The separate `common.ai` API declarations are not bundled yet; this only
  affects Warcraft AI `.ai` scripts, not regular map `.j` sources.

## [Unreleased] — API global-variable diagnostics

### Changed
- The Warcraft API index now includes non-constant globals from `common.j`
  and `Blizzard.j` as well as constants. The resolver, completion, Quick Info,
  and type inference can recognize those shared globals (including `bj_*`)
  instead of reporting them as undefined in every map script.
- API JSON caches now serialize global variables; older caches continue to
  load constants as global symbols for compatibility.

## [Unreleased] — semantic type compatibility

### Changed
- Type compatibility now follows local struct/type inheritance and Warcraft
  handle inheritance, avoiding false warnings when a derived value is used
  where its base type is expected.
- Added known-type checks for boolean conditions/logical operands and integer
  array indexes (JASS0006–JASS0007).

## [Unreleased] — shared semantic snapshots

### Changed
- Added a per-source-version `SemanticSnapshot` containing parse errors, AST,
  symbol scopes, compatibility symbols, and name occurrences.
- VSIX completion, Quick Info, signature help, navigation, reference
  highlighting, and diagnostics now share one lazily built snapshot per exact
  Visual Studio text snapshot. New edits naturally receive a new cache entry.

## [Unreleased] — same-file vJASS library dependencies

### Changed
- Library scopes retain their `requires` and optional dependency names.
- Within one file, required libraries now contribute public symbols to
  completion, Quick Info, F12 binding, same-file references, unresolved-name
  checks, and call-arity checks. Private members remain limited to their
  declaring library.
- Cross-file dependency resolution and project-wide references remain future
  work because the project symbol index is not yet wired into editor services.

## [Unreleased] — same-file vJASS module implementation

### Changed
- Struct scopes now record their `implement ModuleName` declarations and
  expose implemented module fields, methods, and constants to local semantic
  resolution and completion. Members declared directly on a struct take
  precedence over module members with the same name.
- Cross-file module lookup and full static-versus-instance validation remain
  future work.

## [Unreleased] — static and instance member completion

### Changed
- Dot-triggered completion now filters struct members based on the receiver:
  struct names and `thistype` show static members; `this`, local/parameter
  variables, `super`, and implicit `.member` show instance members.
- Semantic member lookup remains unfiltered when no receiver mode is known,
  preserving type inference while expression-level access validation is
  still pending.

## [Unreleased] — responsive editor analysis

### Changed
- JASS diagnostics now wait briefly after the last edit, then analyze on a
  worker thread; results for outdated snapshots are discarded.
- Same-file reference highlighting now debounces caret movement and resolves
  references in the background, ignoring stale results.
- Async completion now builds the semantic snapshot and candidates off the UI
  thread, and honors cancellation when Visual Studio requests a newer list.

## [Unreleased] — static and instance access diagnostics

### Changed
- Added JASS0008 warnings for explicit member accesses that use a known
  static member through an instance receiver or an instance member through a
  struct-type receiver. Unknown receivers and unknown members are left alone
  to avoid speculative reports.

## [Unreleased] — type reference navigation

### Changed
- The parser now preserves source spans for declared type positions,
  parameter/local/field/global types, callable return types, and struct base
  types. The reference collector records these as type-name usages, enabling
  same-file F12 and Find References for user-defined types.
- Unknown type annotations and inheritance types now report a focused JASS0009
  warning; built-in and bundled Warcraft API types are accepted.
- Member usages now retain their inferable receiver type, so same-file F12
  and Find References can bind `object.field` and `object.method()` to members
  of the receiver's struct, including inherited and implemented members.
- Quick Info now uses the same receiver-aware member binding for contextual
  field/method signatures, and computes the semantic result asynchronously
  with cancellation support.
- Member completion now gets the receiver type from the parsed member-access
  expression, supporting chains such as `hero.GetInventory().` and empty dot
  triggers without guessing from the final identifier alone.

## [Unreleased] — duplicate declaration diagnostics

### Changed
- Added JASS0010 warnings for repeated names in one lexical scope, grouped
  by callable, value, type, library, and scope namespaces. Same spellings in
  separate function/struct/library scopes do not count as duplicates.

## [Unreleased] — Phase 2-5 through 2-8 semantic completion

### Changed
- Signature Help now binds explicit struct method calls from the receiver's
  inferred type, including inherited/module methods, then falls back to local
  callable and Warcraft API signatures. Whitespace between a callee and `(`
  no longer prevents the call from being recognized.
- Find Definition and Find References now resolve same-file library
  `requires`/`optional` names and scope/library initializer function names,
  in addition to symbol/type/member references already supported.
- Unresolved symbols are differentiated by category: unresolved functions
  (JASS0013), values (JASS0014), modules (JASS0015), libraries (JASS0016),
  and scopes (JASS0017). Receiver-dependent member names are validated only
  when their receiver can be resolved, avoiding guesses for dynamic handles.

## [Unreleased] — unresolved struct members

### Changed
- Added JASS0011 warnings for missing fields or methods on a receiver whose
  type is a known local struct. The check includes inherited and implemented
  members and skips handle/API types whose member model is incomplete.

## [Unreleased] — operator type diagnostics

### Changed
- Added JASS0012 checks for known incompatible arithmetic, remainder,
  string-concatenation, relational, and equality operands, plus non-numeric
  unary minus. Unknown operand types remain skipped.
- JASS `+` accepts either two numeric operands or two strings; string
  concatenation now infers as `string`, avoiding false warnings in common
  Warcraft UI text expressions such as `"Level is " + I2S(value)`.
- Known struct method calls now receive the same JASS0002 argument-count
  validation as global/native calls, resolved from the call receiver type.

## [Unreleased] — Warcraft III map text files

### Added
- `.wts` files now use a dedicated `warcraft3-wts` content type, separate
  from the JASS language service. The editor highlights `STRING` entry
  markers, numeric IDs, braces, and trigger-string bodies without applying
  JASS diagnostics, completion, or formatting to the text.
- Binary map files such as `.w3i` remain outside the JASS text editor until
  a format-aware reader/viewer is implemented.

## [Unreleased] - Phase 3: syntax highlighting (closed out)

Phase 3 in the original plan ("Syntax Highlighting") is satisfied by what
Phase 1 already built: `JassClassifier` colors every lexical category the
brief's §七 lists that can be determined from tokens alone — keywords,
vJASS keywords, built-in types, strings, numbers, FourCC literals,
comments, operators, and preprocessor directives.

The remaining categories in §七 (Native Function vs. user Function,
Variable vs. Constant, Local vs. Global, distinguishing a `Handle Type`
instance from a `BJ Function`, etc.) require knowing what an identifier
*means*, not just what it looks like — that needs the Native API database
(Phase 5) and/or the parser + symbol table (Phase 4/6). Coloring those
now, from lexical guesswork, would just be wrong some of the time. They're
deferred on purpose rather than skipped.

## [Unreleased] - Phase 2: lexer edge-case hardening

### Added
- `Token.IsWellFormed` flag: `false` for strings/FourCC literals that never
  found a closing delimiter before end-of-line, and block comments that
  never found `*/` before end-of-file. The lexer still recovers gracefully
  (no exceptions, no runaway loops) — this flag just gives the future
  Diagnostics phase (Phase 8) a ready-made signal without re-scanning.
- `$`-prefixed hex integer literals (`$1A2B`), in addition to `0x`/`0X`.
- Octal integer literals (leading zero + octal digits, e.g. `0755`), with
  correct fallback to decimal/real parsing when a `.`, `8`, or `9` shows up
  where an octal digit was expected (`089` stays decimal, `07.5` still
  parses as one real number).
- 25 new unit tests covering: unterminated strings/comments/FourCC and
  their recovery on the next line, CRLF vs LF line counting, tabs as
  whitespace, `\0` and lone `$` not hanging the lexer, non-nesting block
  comments, case-sensitive keyword matching, `endif2` not being
  misidentified as the `endif` keyword, chained comparison operators
  (`<=`, `>=`, `!=`), and unary minus staying a separate token from the
  number that follows it.

### Fixed
- Unterminated string literals on a line ending in `\r\n` no longer pull
  the `\r` into the string's text before stopping.

### Fixed (post-review, round 2 — VSIX)
- `BuildCommand.cs` failed to build: `MenuCommandService` (the base class
  of `OleMenuCommandService`) lives in `System.Design.dll`, which SDK-style
  net472 projects don't implicitly reference — same pattern as the
  `System.ComponentModel.Composition` and `EnvDTE` references added
  earlier. Added `<Reference Include="System.Design" />`.
- Also cleared two analyzer warnings while fixing the above: null-checked
  the `SVsOutputWindow`/pane results (VSSDK006) and added
  `ThreadHelper.ThrowIfNotOnUIThread()` to the output-pane write helper
  (VSTHRD010) — not required for the build to succeed, but both are
  genuine correctness hardening in the same spirit as the Phase 6
  signature-help command handler's threading fix.

### Fixed (post-review, round 1 — JassPlus.Language, netstandard2.0)
  netstandard2.0 (it's .NET 5+ only) — replaced with the standard
  netstandard2.0-compatible equivalent: a `TaskCompletionSource`
  completed by the `Process.Exited` event (subscribed before `Start()`
  to avoid a race where the process exits before anything is listening).
- `JassHelperInvocation.cs`: `string.Contains(char)` doesn't exist on
  netstandard2.0 either (only `Contains(string)` does, until netstandard2.1)
  — `value.Contains(' ')` became `value.Contains(" ")`.
- Both caught by `dotnet build` on the real project (this sandbox's
  netstandard2.0 verification setup didn't happen to exercise
  `JassHelperRunner`'s process-launch path against a target framework
  where these gaps would show — the scratch harness used net8.0, which
  has both APIs, masking the netstandard2.0-specific gaps entirely).

## [Unreleased] - Phase 10: JassHelper Integration

### Added
- `JassPlus.Language.Build` (VS-agnostic, fully unit-tested):
  - `JassHelperInvocation`: builds the JassHelper.exe command line from
    configured paths (common.j, blizzard.j, JassHelper.exe itself) plus
    the script being built. The positional-argument convention (common.j,
    blizzard.j, input script, output path) matches the classic JassHelper
    CLI most community tooling targets, but JassHelper has no single
    canonical CLI contract across its various forks — this is a
    best-effort default, not a verified spec. `JassHelperSettings.ExtraArguments`
    is an escape hatch for adapting to a specific JassHelper build without
    a code change.
  - `JassHelperOutputParser`: parses JassHelper's console output into
    `JassHelperDiagnostic`s. Primarily targets the classic
    `file.j(line) : Error : message` (MSVC-style) format, with a looser
    fallback for lines that mention "error"/"warning" without matching
    that exact shape. Same "best-effort, not verified-exact-grammar"
    caveat as the invocation builder — there's no real JassHelper binary
    available to test against in this environment (or this sandbox).
  - `JassHelperRunner`: runs the process and captures stdout/stderr/exit
    code. Generic — has no JassHelper-specific logic itself, which is
    exactly what let it be tested against a real process (`dotnet
    --version`, standing in for jasshelper.exe) rather than only against
    synthetic output.
- 25 new tests across `JassHelperInvocationTests`, `JassHelperOutputParserTests`,
  and `JassHelperRunnerTests` — the latter includes two tests that launch
  an actual external process (not a mock), genuinely exercising the
  process-launch/stdout-capture/exit-code plumbing.
- **First VS Package in this project** (`JassPlusPackage`) — everything
  through Phase 9 worked via MEF components alone; a Tools > Options page
  and a menu command both require a Package. Kept deliberately minimal:
  it does exactly two things (hosts the Options page, initializes the
  Build command) and nothing else.
- `JassOptionsPage`: Tools > Options > Warcraft III > JASS, exposing the
  four paths the project brief's §十八 asks for (Warcraft III install,
  JassHelper.exe, common.j, blizzard.j) plus an extra-arguments field.
- `BuildCommand`: "Build JASS Script" menu command (under Tools, via a
  new `BuildCommand.vsct` command table — the first .vsct in this
  project). Saves the active document if dirty, builds the JassHelper
  invocation from the configured settings, runs it, and writes the
  result to a dedicated "JASS Build" Output window pane. Explicitly does
  **not** integrate with the Error List — same scope decision as Phase
  8's diagnostics (squiggles only, no Error List rows), for the same
  reason: that integration is a separably-sized piece of work.
- If JassHelper isn't configured, the extension continues to work for
  editing/IntelliSense/diagnostics/formatting as before — per the project
  brief's §十七, JassHelper is optional, not a hard dependency.

### Scope notes (by design)
- **Unverified CLI contract.** Both the argument-building convention and
  the output-parsing patterns are informed best-effort guesses, not
  confirmed against a real JassHelper.exe (none was available to test
  against). Expect to need adjustment once tried against a real install;
  `JassHelperSettings.ExtraArguments` and the parser's generic fallback
  pattern are both there specifically to make that adjustment easy
  without needing a rebuild.
- **No Error List integration**, same reasoning as Phase 8.
- **Doesn't (yet) feed the configured common.j/blizzard.j paths into
  the Phase 5 `NativeApiDatabase`.** The Options page collects those
  paths, which is the natural unlock for "stop returning empty from
  `SharedApiDatabaseService.Database`" — but wiring that up is its own
  piece of work (load-on-settings-change, caching to `WarcraftApi.json`
  per Phase 5, etc.) kept out of this phase's scope.
- No incremental/background build — `BuildCommand` builds the single
  active file synchronously-from-the-user's-perspective (async under the
  hood, but there's no "build on save" or project-wide build yet; that's
  Phase 11 territory once there's a project system to define what
  "the project" even means).

### Verification caveat
- `JassHelperInvocation`, `JassHelperOutputParser`, and `JassHelperRunner`
  are fully covered by the 25 new tests, verified the same way as every
  prior phase — plus, uniquely for this phase, two of those tests launch
  a real external process rather than only testing against synthetic
  input. `JassPlusPackage.cs`, `JassOptionsPage.cs`, `BuildCommand.cs`,
  and `BuildCommand.vsct` are **not verified** — same sandbox limitation
  as every other VSIX adapter file, but with more moving parts than
  prior phases (first Package, first Options page, first .vsct), so
  expect more back-and-forth fixing build errors than usual.

## [Unreleased] - Phase 11: JASS Project System

### Added
- `JassPlus.Language.ProjectSystem` (VS-agnostic, fully unit-tested):
  - `JassProjectFile`: load/save the `.jassproj` XML format from the
    project brief's §十四 (`<Name>`, `<Files><File Include="..."/></Files>`,
    `<Libraries><Library Include="..."/></Libraries>`) — the exact
    structure the brief specifies, verified with its own example as a
    test case.
  - `ProjectSymbolIndex`: runs Phase 6's `FileSymbolCollector` over every
    file in a project and tags each result with its source file — the
    building block a future cross-file Go To Definition/Find References/
    Completion would consume. A file with parse errors still contributes
    whatever symbols it could (same "recover, don't fail" stance as
    everywhere else in this project); errors are tracked per-file
    separately rather than aborting the whole index.
  - `DependencyGraphBuilder`: builds the library dependency graph the
    brief's §十五 describes (e.g. Main → Hero → TimerUtils/Table) from
    every `library`'s `requires`/`uses`/`needs` clause across a project's
    files, with a topological sort (for e.g. feeding files to JassHelper
    in valid dependency order) and cycle detection (returns null rather
    than silently picking an arbitrary order). Also flags requires that
    point at a library name not found anywhere in the project — a likely
    missing-file-in-.jassproj or typo signal for a future diagnostic.
- 14 new tests across `JassProjectFileTests`, `ProjectSymbolIndexTests`,
  `DependencyGraphBuilderTests`.
- VSIX: `.jassproj` files get XML syntax highlighting for free, mapped to
  VS's own built-in `xml` content type rather than a custom one.
- `resources/sample.jassproj`: a worked example matching the brief's own
  sample structure.

### Scope notes (by design — the big one this phase)
- **No VS custom project type.** A real `IVsHierarchy`-based project
  system (Solution Explorer integration, project-level build, `.jassproj`
  as an actual "Open Project" target) is one of the largest, most
  involved categories of work in the whole VS SDK — commonly hundreds of
  files even in minimal official samples. The project brief explicitly
  licenses skipping this for v1: "不要求第一版就完成完整 MSBuild 整合,但架構
  必須保留未來擴充空間" (v1 doesn't need full MSBuild integration, but the
  architecture must leave room to extend later). This phase is exactly
  that: the data layer (file format, multi-file symbol index, dependency
  graph) that a real project system would sit on top of, without
  attempting the VS integration itself.
- **Not wired into the existing single-file engines.** `CompletionEngine`,
  `QuickInfoEngine`, `SignatureHelpEngine`, `GoToDefinitionEngine`,
  `FindReferencesEngine`, and `DiagnosticsEngine` (Phases 6-8) all still
  only see one file at a time — every one of their CHANGELOG entries
  already flagged this as a known gap. `ProjectSymbolIndex` makes
  multi-file data available for the first time, but retrofitting six
  existing engines to consume it (and deciding what "in scope" even means
  across file boundaries) is a distinct, separately-sized piece of work.
- **`//! import` isn't in the dependency graph.** Only vJASS
  `library ... requires` is modeled. `//! import` directives are lexed
  (Phase 1/2) but not currently carried into the AST as declarations (see
  `docs/jass-language.md`'s known-gaps note) — adding that is prerequisite
  work, not part of this phase.

### Verification caveat
- `JassProjectFile`, `ProjectSymbolIndex`, and `DependencyGraphBuilder`
  are fully covered by the 14 new tests, verified the same way as every
  prior phase. The lone VSIX change (the `.jassproj` → `xml` content type
  mapping) is a one-line, low-risk addition reusing an already-proven
  pattern from Phase 1 — still technically unverified here, but far lower
  risk than this phase's Language-side work.

## [Unreleased] - Build fix: extension never deployed to Experimental Instance

### Fixed
- `JassPlus.VSIX.csproj` had `<DeployExtension>false</DeployExtension>`
  since the original Phase 1 scaffold — this explicitly tells the build
  *not* to deploy the extension into the Experimental Instance's hive on
  F5, which is why "Warcraft III JASS Tools" never appeared in Extensions
  > Manage Extensions no matter how many times F5 was run, across every
  phase up to and including Phase 9. Every prior phase's `dotnet build`
  success was real (the code compiled correctly), but none of it could
  ever have been observed running in the editor because of this one
  setting. Changed to `true`. Caught only now because this is the first
  phase where an actual F5 + manual verification pass was done.

## [Unreleased] - Phase 9: Formatter

### Added
- `JassPlus.Language.Formatting.Formatter`: **token-line based**, not an
  AST pretty-printer — a deliberate choice. The parser discards comments
  as trivia (see `Parser.Parse`), so reformatting by pretty-printing the
  AST back to text would silently delete every comment in the file.
  Instead the formatter walks the full token stream (comments included)
  and only touches the *whitespace between and around* tokens — never the
  text inside a token (comments, string contents, identifiers, literals
  are all preserved byte-for-byte).
  - Re-indents every line by nesting depth, tracking
    function/if/loop/struct/method/scope/library/interface/module/globals
    open/close keyword pairs (`else`/`elseif` dedent-then-reindent, since
    their own line sits at the parent level but their body is indented
    again). A self-contained one-liner (opener and its matching closer on
    the same physical line, e.g. `if a then call X() endif`) is detected
    and doesn't creep the indentation of what follows.
  - Normalizes inter-token spacing: tight around `,`/`)`/`]`/`.` per
    context (member-access `.` is tight, e.g. `obj.field`, but the
    vJASS implicit-`this` shorthand's *leading* `.` keeps its space, e.g.
    `return .value` not `return.value` — these needed different rules,
    found via a failing test), no space before a call's own `(` (`Foo(`)
    while a keyword-preceded grouping paren keeps its space (`return (`),
    and a context-sensitive unary-vs-binary `-` (`-1` stays tight, `a - b`
    gets spaces both sides).
  - Collapses runs of 2+ blank lines to exactly 1; trims leading and
    trailing blank lines. Does **not** fabricate new blank lines that
    weren't there (a narrower, safer scope than the project brief's
    illustrative before/after example, which shows a blank line inserted
    between a local declaration and a following `if` — see Scope notes).
  - `FormatOptions { IndentSize = 4, UseSpaces = true }` — configurable,
    per the project brief's §十三.
  - `Formatter.FormatDocument` and `Formatter.FormatRange` (the latter for
    Format Selection: expands the requested character range outward to
    whole lines, then returns the span to replace and its replacement
    text — kept 1:1-with-original-line-index internally specifically so
    slicing a range still works correctly even though blank-line
    collapsing changes the total output line count for the *whole*
    document).
- 24 new tests in `FormatterTests.cs`, including the project brief's own
  §十三 before/after example (verbatim) as a test case, an idempotency
  check (formatting already-formatted output changes nothing), and a
  `FormatRange` test confirming untouched regions stay untouched.
- VSIX adapter: `JassFormatCommandHandler`/`Provider` — intercepts
  `VSStd2KCmdID.FORMATDOCUMENT`/`FORMATSELECTION` (Format Document /
  Format Selection) and applies the result via a text edit.

### Fixed (found via tests before shipping)
- No space was being removed before `[` (`arr [5]` instead of `arr[5]`).
- The blanket "no space before `.`" rule broke the implicit-`this`
  shorthand: `return .value` was rendering as `return.value`. Fixed by
  making `.` spacing context-sensitive — tight only when it continues an
  existing expression (after an identifier, `)`, `]`, `this`, `thistype`,
  or `super`); a *leading* `.` (after a keyword like `return`/`set`)
  keeps its space.

### Scope notes (by design)
- No blank-line fabrication (see above) — only normalizes what's already
  there. Deciding *where* a formatter should insert new blank lines is
  genuinely opinionated (unlike re-indenting or spacing, which have one
  clearly-correct answer here), and getting it wrong actively damages
  code the formatter touches. Preserving-and-collapsing existing blank
  lines is the safe subset of that behavior.
- No general statement-splitting: a line containing multiple statements
  (`if x then call A() call B() endif` all on one physical line) is
  reformatted in place, not split onto separate lines — that would need
  AST-driven reconstruction, which reintroduces the comment-loss problem
  this design specifically avoids.
- No user-configurable settings UI yet — `FormatOptions` exists and is
  fully wired through, but the VSIX adapter always uses
  `FormatOptions.Default` since there's no Tools > Options page (Phase
  17/18) to read a user's preferred indent size/tabs-vs-spaces from.

### Verification caveat
- `Formatter` is fully covered by the 24 new tests, verified the same way
  as every prior phase. `JassFormatCommandHandler.cs` is **not verified**
  — same sandbox limitation as every other VSIX adapter file.

## [Unreleased] - Phase 8: Diagnostics

### Added
- `JassPlus.Language.Diagnostics.DiagnosticsEngine.Analyze(source, apiDatabase?)`,
  producing:
  - **Syntax errors for free**: every `ParseError` the Phase 4 parser
    already produces during error recovery — unbalanced
    function/if/loop/library/scope/struct/method/interface/module blocks,
    missing `takes`/`returns`/`=`/etc. — surfaces directly as `Error`-
    severity diagnostics. No new detection logic needed; this was already
    sitting in the parser's error-recovery design from Phase 4.
  - **Unresolved-name check** (`JASS0001`): every usage from Phase 7's
    `ReferenceCollector` that doesn't resolve via `SymbolBinder`, isn't a
    built-in type, and isn't in the (optional) native API database is
    flagged `'{name}' could not be resolved.`. Severity is **Warning**,
    not Error — without a configured Warcraft III install (Phase 17/18,
    not built yet) most native/BJ names are legitimately unresolved from a
    single file, and marking those build-breaking would be wrong.
  - **Call-arity check** (`JASS0002`): every call/method-call site whose
    resolved function/native/method has a known parameter count gets its
    argument count checked; a mismatch is flagged
    `'{name}' expects {N} argument(s) but got {M}.`.
  - `this`/`super`/`thistype` are explicitly excluded from the unresolved-
    name check — they're pseudo-identifiers the parser accepts as
    expressions (see Phase 7's `ParsePrimary` fix) that will never be a
    declared symbol.
- 13 new tests in `DiagnosticsEngineTests.cs`.
- VSIX adapter: `JassErrorTagger`/`Provider` — squiggly underlines in the
  editor (`IErrorTag`), red for errors, the standard warning squiggle for
  warnings, re-analyzing on every buffer edit.

### Original scope note (superseded by the Unreleased Error List entry above)
- **At Phase 8 delivery, there was no Error List window integration.** `JassErrorTagger` gave squiggles
  in the editor, which is the most visible half of "diagnostics" and is
  self-contained MEF with no VS Package needed. Populating the actual
  Error List tool window with rows needs either the classic
  `Microsoft.VisualStudio.Shell.ErrorListProvider` (which needs a
  Package/`IServiceProvider` to reach `SVsErrorList`) or the modern
  `ITableDataSource`/`ITableManager` API, plus tracking every open
  document's lifecycle to add/remove its rows. That's a materially bigger
  integration than a tagger, so it's deferred as a named follow-up rather
  than rushed in half-working.
- **No full type checking.** The project brief's §十二 also asks for type
  checks; doing this properly needs expression type inference across the
  whole type system (including vJASS struct types), which is
  substantially more work than the two checks implemented here. Attempting
  a partial version risked false positives on real code, so it's left out
  entirely rather than shipped half-right.
- **No cross-file requires/uses validation.** Checking that a library's
  `requires`/`uses` targets actually exist would need the project system
  (Phase 11) — real vJASS code almost always splits libraries across
  files, so a single-file check here would just be constantly, incorrectly
  flagging valid code.
- Unoptimized: diagnostics re-run synchronously on every keystroke, no
  debounce, no background thread. Fine at the file sizes tested; worth
  revisiting if real map scripts (which can be large) feel laggy.

### Verification caveat
- `DiagnosticsEngine` is fully covered by the 13 new tests, verified the
  same way as every prior phase. `JassErrorTagger.cs` is **not verified**
  — same sandbox limitation as every other VSIX adapter file.

## [Unreleased] - Phase 7: Go To Definition / Find All References

### Added
- AST now tracks precise name spans, not just whole-declaration spans:
  added `SourceSpan` and a `NameSpan` property on every declaration type
  that has a name (function/native/method/type/struct/interface/module/
  scope/library/parameter/variable), plus on the usage-side expressions
  (`CallExpression`, `MethodCallExpression`, `MemberAccessExpression`) so
  a reference can be highlighted precisely — just "Foo", not "Foo(a, b)".
  `SymbolInfo` (Phase 6) grew a matching `NameSpan`.
- `JassPlus.Language.Navigation`:
  - `ReferenceCollector`: walks the whole file (declarations *and* every
    statement/expression body) into a flat list of `NameOccurrence`
    (declaration or usage, each with its exact span).
  - `SymbolBinder`: resolves "name N used at position P" to the
    declaration it actually refers to — a local/parameter/field in scope
    at P wins over a same-named file-wide declaration (shadowing). This
    is what keeps two different functions' same-named locals from being
    treated as one symbol.
  - `GoToDefinitionEngine.GetDefinition(source, offset)`: token under the
    caret → resolved declaration's exact `NameSpan`.
  - `FindReferencesEngine.FindReferences(source, offset)`: every
    occurrence (declaration + usages) of the resolved symbol, correctly
    scoped (see `SymbolBinder`).
  - `Lexing.TokenLookup.FindTokenAt`: the token-under-caret lookup used by
    QuickInfo (Phase 6) and now Go To Definition/Find References was
    duplicated between call sites; factored out to one shared helper.
- 26 new tests: `GoToDefinitionEngineTests`, `FindReferencesEngineTests`.
- VSIX adapters: `JassGoToDefinitionCommandHandler` (intercepts F12 /
  `VSStd97CmdID.GotoDefn`, moves the caret to the resolved definition) and
  `JassReferenceHighlightTagger` (highlights every occurrence of the
  symbol under the caret in the current file — see the scope note below).

### Fixed
- Two real parser bugs, both caught by building this phase's tests against
  realistic vJASS (a struct method using `.field` shorthand in a `return`,
  not just as a `set` target):
  - `ParsePrimary` had no case for a leading `.` at all — vJASS's
    implicit-`this` shorthand (`.value` for `this.value`) only worked as a
    `set` statement's target, not in general expression position (e.g.
    `return .value`, or as a call argument). Fixed by treating a leading
    `.` as an implicit `this` and letting the existing postfix `.member`
    handling pick it up from there — the same mechanism the `set`-target
    case already used.
  - `StartsExpression` (used by `return` to decide "is there a value here
    or is this a bare return?") didn't include `Dot`, so even after the
    fix above, `return .value` still parsed as a bare `return` with the
    `.value` tokens left dangling as syntax errors.

### Scope notes (by design)
- **Same file only.** Both engines work from a single parsed file; there's
  no cross-file symbol resolution because there's no project system yet
  to know what other files exist (that's Phase 11). Go To Definition on a
  native/BJ function not declared in the current file correctly returns
  "not found" rather than guessing.
- **"Find All References" is single-file reference highlighting, not the
  multi-file Find Symbol Results tool window.** A real Find Symbol Results
  window (`IVsFindSymbol` or the newer `IFindAllReferencesService`) is a
  materially bigger VS integration and, like Go To Definition, would need
  the project system to know what to search across files. Highlighting
  every in-file occurrence when the caret is on a symbol is genuinely
  useful on its own (it's exactly what VS's built-in C#/C++ "Highlight
  References" does) and is what's implemented now; the tool-window version
  is tracked for when Phase 11 makes it possible to do properly.
- Scoping is function/method/struct-granularity (inherited from
  `FileSymbolCollector`, Phase 6) — not declaration-order-aware. In the
  one realistic case that matters (two different functions each
  declaring a local with the same name), this correctly keeps them
  separate; see `DistinguishesSameNamedLocalsInDifferentFunctions` and
  `DoesNotLeakReferencesAcrossDifferentFunctionsWithSameLocalName`.

### Build status: verified
- `dotnet build` on the full solution succeeds cleanly, first try —
  `JassGoToDefinitionCommandHandler.cs` and `JassReferenceHighlightTagger.cs`
  both compiled with no fixes needed (unlike Phase 6's adapters, which
  needed two rounds of fixes). **Not yet confirmed**: actual runtime
  behavior — F12 landing in the right place, references highlighting as
  the caret moves — inside a running Experimental Instance.

### Verification caveat (engines)
- `ReferenceCollector`/`SymbolBinder`/`GoToDefinitionEngine`/
  `FindReferencesEngine` are fully covered by the 26 new tests, verified
  the same way as every prior phase.

## [Unreleased] - Phase 6: IntelliSense

### Added
- `JassPlus.Language.IntelliSense` (VS-agnostic, fully unit-tested):
  - `FileSymbolCollector`: flattens a parsed file's declarations
    (functions, natives, types, globals, struct fields/methods,
    library/scope/struct/interface/module names) plus locals/parameters
    into `SymbolInfo` records, with locals/parameters/fields scoped to
    their enclosing function/method/struct's source range. Explicitly not
    a real symbol table — no declaration-order scoping, no cross-file
    resolution, no type checking. See its doc comment for what that means
    completion can and can't do yet.
  - `CompletionEngine.GetCompletions(source, caretOffset, apiDatabase?)`:
    merges in-scope locals/parameters, file-wide declarations, the Phase 5
    native API database, built-in types, and keywords, filtered by the
    identifier prefix at the caret (case-sensitive, matching JASS).
    Dot-triggered (`obj.`) completion falls back to every Method/Field the
    file declares across all structs — there's no type inference yet to
    narrow it to `obj`'s actual struct type, so this is a known
    approximation, not a bug.
  - `QuickInfoEngine.GetQuickInfo(source, offset, apiDatabase?)`: resolves
    the token under the caret to a description — keyword meaning, native/
    function signature (with source file), type's base type, or a
    variable's declared type.
  - `SignatureHelpEngine.GetSignatureHelp(source, caretOffset, apiDatabase?)`:
    finds the enclosing call by walking the token stream backward with
    paren-depth tracking (correctly resolves the *innermost* call for
    nested calls like `Outer(Inner(1, `), and reports which parameter
    slot the caret is on by counting top-level commas (correctly ignoring
    commas nested inside further parens/brackets, e.g. array indexing
    arguments).
  - `JassKeywords`: hand-maintained keyword → description table (JASS and
    vJASS) for keyword completion items and QuickInfo text.
  - `BuiltinTypes` moved here from the VSIX classifier (was duplicated —
    now a single shared list both the classifier and IntelliSense use).
- 49 new tests across `FileSymbolCollectorTests`, `CompletionEngineTests`,
  `QuickInfoEngineTests`, `SignatureHelpEngineTests`.
- VSIX MEF adapters translating the engines above into VS's IntelliSense
  APIs: `JassCompletionSource`/`Provider` (Async Completion API),
  `JassQuickInfoSource`/`Provider` (Async QuickInfo API), and
  `JassSignatureHelpSource`/`Provider` plus a command-filter
  (`JassSignatureHelpCommandHandler`) that triggers a signature-help
  session on `(`/`,` and dismisses it on `)` — VS has no automatic trigger
  for signature help the way it does for completion/QuickInfo, so this
  glue is required. `SharedApiDatabaseService` is a MEF-singleton empty
  `NativeApiDatabase` all three sources import; it stays empty until
  Phase 17/18 adds a way to point at a real Warcraft III install.

### Build status: verified
- After the two rounds of fixes above, `dotnet build` on the full solution
  (including `JassPlus.VSIX`) succeeds cleanly. All three VSIX adapter
  files now compile. **Not yet confirmed**: actually using completion/
  QuickInfo/signature-help inside a running Experimental Instance — compiling
  and behaving correctly at runtime are different bars, and the signature-help
  command-filter piece in particular (`JassSignatureHelpCommandHandler`)
  is worth an explicit F5 check when convenient, since it's the one part
  of this phase with no automated test coverage possible (it's pure VS
  command-routing glue).

### Verification caveat
- The language-core engines above are fully covered by the 49 new tests
  and verified the same way as every prior phase (real test files
  compiled and executed via the xUnit-shim technique — see prior phase
  entries). **The three VSIX adapter files are not verified** — this
  sandbox cannot restore `Microsoft.VisualStudio.SDK` (no network access
  to nuget.org), so they're written to the documented Async Completion /
  Async QuickInfo / classic ISignatureHelpSource patterns but unconfirmed
  against a real compile. `JassSignatureHelpSource.cs` (the command-filter
  glue) is the highest-risk file in this phase — please report build
  errors from it first.

### Known gaps (by design, tracked for later phases)
- No type inference: dot-completion and hover on a struct instance's
  members can't narrow to *that* struct's actual members — see the
  `CompletionEngine` note above. A real symbol table with type tracking is
  larger, separate work.
- Signature help doesn't attempt overload resolution (JASS/vJASS doesn't
  really have overloading, so this is low-priority, but worth naming).
- The native API database is still not wired to a real common.j/
  blizzard.j — `SharedApiDatabaseService.Database` starts empty. Phase
  17/18's settings page is what will populate it.

### Fixed (post-review, round 2)
- `JassCompletionSource.cs`: `ImageMoniker.ToImageId()` isn't available in
  this SDK version (extension method availability has moved around across
  package versions). Replaced with constructing `ImageId` directly from
  the moniker's own `Guid`/`Id` fields — works regardless of which package
  version supplies (or doesn't supply) that extension method.
- `JassSignatureHelpSource.cs`: added `ThreadHelper.ThrowIfNotOnUIThread()`
  to `QueryStatus`/`Exec`, per the VSTHRD010 analyzer warning — an
  `IOleCommandTarget` implementation should assert main-thread affinity,
  not just conventionally run on it.

### Fixed (post-review, round 1)
- `JassCompletionSource.cs` failed to build: `ImageElement` is declared in
  `Microsoft.VisualStudio.Text.Adornments`, not `Microsoft.VisualStudio.Imaging`
  (that namespace only has `KnownMonikers`). Added the missing `using`.
  This was the only build error across all three VSIX adapter files —
  better than expected given they were written without being able to
  compile them here.

## [Unreleased] - Phase 5: Warcraft III Native API Database

### Added
- `JassPlus.Language.Warcraft`: `NativeApiDatabase`, holding `Functions`
  (natives *and* plain `function`s — see below), `Types`, and `Constants`,
  all keyed by name.
- Deliberately **no separate API-file parser**: `common.j`/`blizzard.j`
  are just JASS, so `NativeApiDatabase.AddFromSource`/`BuildFromSource`
  reuse the Phase 4 `Parser` directly and walk the resulting
  `CompilationUnit` for `NativeDeclaration`, `FunctionDeclaration`,
  `TypeDeclaration`, and `constant` `VarDeclaration`s (both inside
  `globals` blocks and as bare top-level `FieldDeclaration`s).
- `ApiFunction.Kind` distinguishes `Native` (from `native` declarations,
  i.e. common.j) from `Function` (plain `function ... endfunction`, i.e.
  blizzard.j's "BJ" helper wrappers like `GetTriggerUnit`,
  `CreateUnitAtLoc`) — both live in the same `Functions` dictionary since
  callers (future IntelliSense) want to complete against both.
- `WarcraftApiJsonSerializer`: reads/writes the `WarcraftApi.json` cache
  format from the project brief (§九) — sorted-by-name arrays (stable to
  diff), so the extension can skip re-parsing common.j/blizzard.j on every
  startup once Phase 17/18 adds the settings page that points at a real
  Warcraft III install. The cache is purely derived data; the source of
  truth is always the parsed `.j` files.
- First external package dependency in this project:
  `System.Text.Json` (netstandard2.0-compatible, first-party, used only
  for the JSON cache — no impact on the dependency-free Lexer/Parser).
- 12 new tests in `NativeApiDatabaseTests.cs`: native vs. plain-function
  classification, `constant native` flagging, type extraction, constant
  extraction (and correctly *not* picking up non-constant globals),
  later-source-wins merge semantics, readable `Signature` rendering, and
  a full JSON round-trip including sort-stability.

### Fixed
- `type handle extends nothing` — real common.j's very first line — failed
  to parse. `nothing` is a keyword token (`KwNothing`), not an
  `Identifier`, so base-type parsing needed the same special-case handling
  return-type parsing already had. Caught immediately by testing against
  a common.j-shaped fixture; see `ParsesTypeExtendsNothing` in
  `ParserTests.cs`.

### Known gaps (by design, tracked for later phases)
- The database is not yet wired into the live VS extension — no Tools →
  Options path to point at a real Warcraft III install exists yet
  (Phase 17/18), and the classifier doesn't yet color Native/Function
  differently even though it could look the name up now. Wiring this in
  belongs with Phase 6 (IntelliSense), where completion/QuickInfo will be
  the first real consumer.
- `ApiConstant.ValueText` only captures literal initializers
  (`LiteralExpression`) — a constant initialized to an expression (rare in
  practice for common.j/blizzard.j, but not impossible) is stored with a
  null `ValueText`.

## [Unreleased] - Build fix: JassPlus.VSIX missing framework references

`dotnet build` on the full solution (as opposed to `dotnet test`, which
only touches `JassPlus.Language`/`JassPlus.Language.Tests`) surfaced that
`JassPlus.VSIX.csproj` never actually compiled before — Phase 1 through 4
were only ever verified via `dotnet test`, which doesn't build it.

### Fixed
- SDK-style projects (`Microsoft.NET.Sdk`) targeting `net472` do **not**
  implicitly reference the full .NET Framework the way old-style
  `.csproj` did. Two things `JassClassifier.cs`/`JassClassificationTypes.cs`
  need were missing:
  - `System.ComponentModel.Composition` (MEF — `[Export]`/`[Import]`).
    Added as an explicit `<Reference>`.
  - WPF (`System.Windows.Media.Color`, used by
    `ClassificationFormatDefinition.ForegroundColor`). Added via
    `<UseWPF>true</UseWPF>`, which is supported for `net47x` targets as
    well as `net5.0-windows`+.
- **Not yet verified end-to-end**: this environment can't restore
  `Microsoft.VisualStudio.SDK` (no network access to nuget.org), so this
  fix is based on the known SDK-style/net472 reference gap, not a
  confirmed clean `dotnet build`. Please rebuild and report back if
  anything else is missing.

## [Unreleased] - Phase 4: Parser / AST

### Added
- Full AST node set under `JassPlus.Language.Parsing`: `Expressions.cs`,
  `Statements.cs`, `Declarations.cs`, plus `AstNode`/`CompilationUnit`/`ParseError`.
- Hand-written recursive-descent `Parser` covering:
  - Top level: `globals`/`endglobals`, `type X extends Y`, `native`
    (including `constant native`), `function`/`endfunction` (including
    `private`/`public` visibility for vJASS-scoped functions), and a bare
    top-level `constant <var>` outside a `globals` block.
  - Statements: `local`, `set` (including vJASS's implicit-`this`
    `.member` shorthand), `call` (including `debug call`/`debug set`),
    `if`/`elseif`/`else`/`endif`, `loop`/`exitwhen`/`endloop`, `return`.
  - Expressions with correct precedence (`or` → `and` → `==`/`!=` →
    `<`/`<=`/`>`/`>=` → `+`/`-`/`&` → `*`/`/`/`%` → unary `-`/`not` →
    postfix `.member`, `.method(...)`, `array[index]`, `Function(...)`),
    literals, parentheses, and `this`/`super`/`thistype`.
  - vJASS containers: `library`/`library_once` (with `initializer`,
    `requires`/`uses`/`needs`, and per-item `optional`), `scope` (with
    `initializer`), `struct` (with `extends`, fields, methods), `interface`
    (including bodyless `stub` methods), `module`, `implement`.
- Error recovery: the parser never throws on malformed input. Every
  problem becomes a `ParseError` (message + source span) and parsing
  continues, so editor features keep working around a typo mid-edit.
  Every loop that consumes tokens has an explicit "no progress → force
  advance" guard, so a single unrecognized token can never hang the parser.
- `ParserTests.cs`: one test class per §23-required category (Function,
  Native, Global, Local, If, Loop, Struct, Method, Library, Scope,
  Requires) plus a full-file integration test and a `[Theory]` covering
  six kinds of malformed input to confirm the parser recovers instead of
  throwing.
- Lexer: added `LBracket`/`RBracket` tokens for `arr[index]` syntax, which
  the Phase 1/2 lexer had no token for at all — a real gap the parser work
  surfaced immediately.

### Fixed
- `thistype` as a return type / parameter type (e.g. `returns thistype`)
  now parses correctly. It's a distinct keyword token (`KwThisType`), not
  an `Identifier`, so type-name parsing needed to explicitly accept it —
  found via the full-sample integration test.

### Known gaps (by design, tracked for later phases)
- No symbol table / name resolution yet — `IdentifierExpression`,
  `CallExpression`, etc. hold names as strings; nothing here knows what
  they refer to. That's Phase 6/7 work.
- Operator-overload methods (`method operator [] takes ... returns ...`)
  are parsed leniently — the operator symbol(s) land in `Name` verbatim
  rather than being modeled as a distinct construct.
- `keyword`, `hook`, and `//! textmacro`/`//! runtextmacro` preprocessor
  constructs are not parsed into the AST (the lexer still tokenizes `//!`
  lines, but the parser currently treats them as trivia, same as
  comments). Revisit if/when Zinc-style textmacros are prioritized.
- No parsing of `//! import` into the AST yet — needed for the dependency
  graph work in a later phase (§15 in the project brief); currently
  filtered out as trivia along with other `//!` directives.

## [0.1.0] - Phase 1: VSIX foundation + language service skeleton

### Added
- Solution/project layout separating the IDE-agnostic language core
  (`JassPlus.Language`) from the Visual Studio integration (`JassPlus.VSIX`).
- `.j` / `.ai` / `.dz` content type registration.
- Hand-written JASS/vJASS lexer (`Lexer`, `Token`, `TokenType`) covering
  JASS keywords, vJASS/JassHelper keywords, string/number/FourCC literals,
  line and block comments, and `//!` preprocessor directives.
- MEF-based `IClassifier` implementation that drives syntax highlighting
  from the lexer's token stream, with classification formats for keywords,
  vJASS keywords, types, strings, numbers, comments, operators, and
  preprocessor directives.
- Unit test project (`JassPlus.Language.Tests`) with lexer coverage.

### Not yet implemented (tracked for later phases)
- Parser / AST, symbol table, type system (Phase 4).
- Warcraft III native API database (Phase 5).
- Completion, QuickInfo, Go To Definition, Find All References (Phases 6–7).
- Diagnostics / Error List integration (Phase 8).
- Formatter (Phase 9).
- JassHelper build integration (Phase 10).
- JASS project system (Phase 11).
