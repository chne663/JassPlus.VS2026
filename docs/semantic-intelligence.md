# JASS Semantic Intelligence

This document tracks the semantic-analysis work that follows the original
lexer/parser milestones. The goal is for editor features to consume one
resolved model of the current program, rather than independently guessing
what each identifier means.

## Current increment

- `SemanticModelBuilder` builds a scope tree from the parsed AST: file,
  library, scope, struct, interface, module, and function scopes.
- Symbols retain their declaration span, kind, type/signature, visibility,
  array/static/constant flags, source-order visibility point, and containing
  scope. Parameter and local declarations are children of their function
  scope; struct members are children of their struct scope.
- `SymbolBinder` resolves from the narrowest containing range outward and
  prefers a visible local/parameter over an enclosing field or global.
- Completion, Quick Info, signature help, F12, Find References, and existing
  name/call-arity diagnostics now obtain symbols from this model. Member
  completion resolves a simple receiver's declared struct type and follows
  declared struct inheritance.
- A conservative type-analysis pass now infers literal, variable, function,
  native, member, and basic operator expression types. Diagnostics report
  known mismatches in initializers, assignments, return values, and arguments
  to known functions/methods (JASS0003–JASS0005). Integer-to-real widening and
  `null` to handle-like values are accepted; unknown expression types are
  skipped to avoid speculative warnings.
- Assignability follows local struct/type inheritance and Warcraft handle
  inheritance. Known non-boolean conditions/logical operands and non-integer
  array indexes are reported as JASS0006/JASS0007.
- The bundled API model includes non-constant globals from `common.j` and
  `Blizzard.j` as well as constants, preventing shared names such as `bj_*`
  from being diagnosed as unresolved.
- Same-file `library requires` and `optional` dependencies now expose their
  public symbols to completion and semantic binding; private dependency
  members are hidden. Cross-file dependencies still need the project index.
- Same-file `struct ... implement ModuleName` declarations now contribute
  module fields, methods, and constants to struct-scope resolution and
  completion. Struct-owned members take precedence on name collisions.
- Dot-triggered member completion distinguishes type receivers from object
  receivers: `thistype`/a struct name offers static members, while `this`,
  locals, parameters, and implicit `.member` offer instance members.
- Diagnostics debounce edits and analyze in the background; same-file
  reference highlighting debounces caret changes and resolves off the UI
  thread. Async completion also builds its semantic snapshot and candidates
  on a worker thread. Work for superseded editor snapshots is discarded.
- Type analysis reports JASS0008 when an explicit member access is known to
  use an instance member via a struct type or a static member via an object.
  Unresolved member names and receiver types remain unreported by this rule.
- Source spans for type annotations and inheritance names are collected as
  semantic references, so same-file type usages can bind to declarations for
  F12 and Find References.
- Member occurrences retain an inferable receiver type; same-file F12 and
  Find References can bind field and method accesses to the matching struct
  member, including inherited or implemented members.
- Quick Info uses receiver-aware binding for those member occurrences and
  performs snapshot analysis asynchronously so hovering an unparsed file
  does not synchronously parse the full source on the editor thread.
- Member completion derives receiver type from the parsed access expression,
  including chained calls and the immediate empty `object.` dot trigger.
- Unknown type annotations and base types receive the focused JASS0009
  diagnostic; built-in and bundled Warcraft API types are recognized.
- Repeated declarations within the same lexical scope receive JASS0010;
  shadowing in a nested or separate scope is allowed.
- Missing fields/methods on a known local struct receive JASS0011, including
  inherited and module-implemented members. Unknown handle/API member models
  are skipped.
- Known invalid arithmetic/comparison operands and unary minus are reported
  as JASS0012; rules skip expressions with unknown operand types.
- JASS `+` allows numeric addition and string concatenation, with string
  concatenations inferred as `string`.
- Known struct method calls use their receiver-resolved signature for both
  argument count (JASS0002) and argument type (JASS0005) checks.
- Signature Help also resolves an explicit method receiver to the same
  receiver-aware signature; library dependency and scope/library initializer
  names participate in same-file definition/reference binding.
- Unresolved functions/values/modules/libraries/scopes have focused
  diagnostics JASS0013–JASS0017. Receiver-dependent members are left to
  member analysis when the receiver type is known, and skipped otherwise.
- `FileSymbolCollector` remains as a compatibility projection for existing
  consumers; `SemanticModel` and `JassSymbol` are the source of declaration
  and scope data.
- `SemanticSnapshot` now packages parse errors, AST, semantic model, symbol
  projection, and name occurrences for one source version. The VSIX caches it
  by `ITextSnapshot`, and completion, Quick Info, signature help, navigation,
  reference highlighting, and diagnostics all consume that same snapshot.
- `WarcraftApiProfile` now gives each API set a stable id, display name,
  declared game-version label, source list, parse diagnostics, and isolated
  JASS API database. Optional `common.ai` declarations are indexed separately
  so AI-only entries cannot leak into regular JASS resolution.
- API JSON caches preserve profile metadata and can be read as legacy flat
  caches or as named profiles. The configured `common.j`/`Blizzard.j` paths
  load a profile when the VS package initializes; the shared MEF service
  exposes registration and selection for multiple profiles.

## Remaining work

- Phase 3 now exposes Rename and parser-backed code fixes in the editor
  light-bulb menu, as well as the existing Tools menu commands. Rename follows
  bound same-file references and refuses obvious collisions/capture.
- The missing-local fix is intentionally narrow: it handles a bare unresolved
  assignment target when the right-hand side has a known primitive or declared
  function return type.
- Extract Function currently handles contiguous `call Function(...)` and
  `set name = ...` statements in a plain function. Bound locals/parameters
  become parameters; one modified local/parameter used later is returned.
  Control flow, arrays, member writes, unresolved values, and multiple later-
  used outputs are declined rather than rewritten speculatively.
- The light-bulb actions and extraction output need F5 interaction testing.
- Expand rename/reference operations across project files once the project
  index is available.

- Build a project/file index so `requires`, `//! import`, navigation,
  references, completion, and diagnostics can resolve declarations across
  files. Current dependency and member expansion is same-file only.
- Complete vJASS checks for implicit/unqualified static versus instance
  access, interfaces, and remaining language-specific conversions/operators.
- Add a user-facing selector for multiple saved API profiles, profile
  persistence/management, and reliable game-version detection. The current
  package loads one configured installation profile at initialization; the
  bundled pair remains the fallback and is labeled `unspecified`.
- Expand runtime/semantic regression coverage for cross-file binding,
  shadowing, library visibility, and member access. The user has confirmed
  recent F5 runs succeed, but automated semantic regression tests have not
  been added or run.

## Scope note

JASS's variable model is primarily file/global scope plus function scope;
parameters and locals belong inside the function scope rather than requiring
a separate nested local scope. vJASS introduces additional named containers
and visibility rules, which are modeled separately above.
