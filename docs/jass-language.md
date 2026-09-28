# JASS / vJASS Language Notes

This document tracks what the lexer/parser currently understand and what's
still open, so contributors don't have to reverse-engineer coverage from the
source.

## JASS keywords (implemented in the Phase 1 lexer)

```
globals endglobals constant native type extends
function endfunction takes returns return nothing
local set call
if then elseif else endif
loop endloop exitwhen
array
and or not
true false null
debug
```

Primitive/handle type names (`integer`, `real`, `boolean`, `string`,
`handle`, `unit`, `player`, ...) are **not** lexer keywords — in real JASS
they're ordinary identifiers that happen to name built-in types. The
classifier currently highlights them as types via a hardcoded lookup table
(`WellKnownTypes` in `JassClassifier.cs`); Phase 5 will replace that table
with real data loaded from `WarcraftApi.json` / parsed `common.j`.

## vJASS / JassHelper keywords (implemented in the Phase 1 lexer)

```
library endlibrary library_once requires uses needs initializer
scope endscope
struct endstruct
method endmethod
interface endinterface
module endmodule implement
private public static stub override operator
delegate thistype this super
optional defaults onDestroy
keyword hook
```

## Literals

- Strings: `"..."` with `\"` escape handling. An unterminated string (no
  closing `"` before end-of-line) is still tokenized — up to end-of-line —
  with `Token.IsWellFormed == false`, so the lexer never runs off into the
  rest of the file.
- FourCC / rawcode: `'Hfoo'`. Same unterminated-recovery behavior as
  strings. The lexer does not currently enforce the 4-character length —
  that's left to a future diagnostics pass.
- Integers: decimal, `0x...`/`0X...` hex, `$...` hex (JASS-specific
  alternative hex prefix), and octal (a leading `0` followed by octal
  digits, e.g. `0755`). A leading zero followed by `8`, `9`, or a decimal
  point falls back to decimal/real parsing (`089` → decimal `089`; `07.5`
  → real `07.5`) rather than splitting awkwardly at the octal boundary.
- Reals: `123.456` (a digit is required on both sides of the dot).

## Comments and directives

- Line comment: `// ...`
- Block comment: `/* ... */` — this is a **JassHelper extension**, not
  present in vanilla JASS; kept because vJASS code in the wild uses it.
  Does **not** nest (matches C/JassHelper behavior): the first `*/` closes
  the comment. An unterminated block comment (no `*/` before end-of-file)
  is tokenized as one comment token with `IsWellFormed == false`.
- `//! import "File.j"` — recognized as a distinct preprocessor-import
  token so a future dependency graph pass (Phase 15) can find includes
  without a full parse.
- Other `//!` lines (e.g. `//! textmacro`, `//! runtextmacro`) are lexed as
  a generic preprocessor-directive token for now; dedicated handling is
  future work if/when Zinc-style textmacros are prioritized.

## Known gaps (tracked, not yet done)

- ~~No parser/AST yet~~ — superseded; the parser/AST landed in Phase 4,
  the native API database in Phase 5, IntelliSense in Phase 6, and Go To
  Definition/Find All References (single-file) in Phase 7.
- No cross-file scoping/symbol resolution — everything above works from
  one parsed file at a time. Depends on the project system (Phase 11)
  knowing what other files exist in the first place.
- `hook` and `keyword` are lexed but have no semantic handling yet.
- Encoding detection (Big5 / ANSI / UTF-8 / UTF-8 BOM, see project brief
  §19) is not implemented in Phase 1; the lexer currently assumes the text
  buffer VS hands it is already decoded correctly by the editor's own
  encoding detection.
- vJASS's implicit-`this` shorthand (`.field` for `this.field`) is
  supported as of Phase 7, in any expression position — not just as a
  `set` target, which is all Phase 4 originally handled (a real bug,
  caught while building Phase 7's tests against a struct method that used
  the shorthand in a `return`).
