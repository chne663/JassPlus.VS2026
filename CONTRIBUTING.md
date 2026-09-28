# Contributing

Thanks for considering a contribution to JassPlus.VS2026.

## Before you start

- Check the [Roadmap in README.md](README.md#roadmap) and
  [CHANGELOG.md](CHANGELOG.md) to see what phase the project is in — PRs
  that jump far ahead of the current phase (e.g. a formatter before the
  parser exists) are harder to review and merge.
- Open an issue first for anything non-trivial so design direction can be
  agreed before you invest time.

## Development setup

See [docs/development.md](docs/development.md).

## Code organization

- `src/JassPlus.Language` — IDE-agnostic lexer/parser/symbol table. No
  `Microsoft.VisualStudio.*` references allowed here, ever. This is what
  keeps a future LSP server or VS Code port possible without a rewrite.
- `src/JassPlus.VSIX` — Visual Studio integration (MEF components,
  classification, completion, etc.). Keep VS-specific glue here; if logic
  can be tested without a running VS instance, it probably belongs in
  `JassPlus.Language` instead.
- `tests/` — mirrors `src/`. New lexer/parser features should come with
  tests in `JassPlus.Language.Tests`.

## Pull request checklist

- [ ] `dotnet build JassPlus.VS2026.sln` succeeds.
- [ ] `dotnet test tests/JassPlus.Language.Tests/JassPlus.Language.Tests.csproj` passes.
- [ ] New keywords/syntax additions are reflected in
      [docs/jass-language.md](docs/jass-language.md).
- [ ] No code copied from the original VS Code "Jass+" extension or other
      un-licensed sources — see the note in [LICENSE](LICENSE).

## Reporting bugs

Please include: the `.j`/vJASS snippet that triggers the issue, what you
expected, what actually happened, and your Visual Studio version.
